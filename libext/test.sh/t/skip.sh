#!/bin/sh

. ./test.sh

test_call_without_reason_during_file_setup() {
	test_file=t/lib/skip_call_without_reason_during_file_setup.sh
	{ expected_output=$(cat); } <<-EOF
		1..0 # SKIP
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_with_reason_during_file_setup() {
	test_file=t/lib/skip_call_with_reason_during_file_setup.sh
	{ expected_output=$(cat); } <<-EOF
		1..0 # SKIP test
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_setup() {
	test_file=t/lib/skip_call_during_test_setup.sh
	{ expected_output=$(cat); } <<-EOF
		ok 1 test_1 # SKIP
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_without_reason_during_test() {
	test_file=t/lib/skip_call_without_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		ok 1 test_1 # SKIP
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_with_reason_during_test() {
	test_file=t/lib/skip_call_with_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		ok 1 test_1 # SKIP test
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_teardown() {
	test_file=t/lib/skip_call_during_test_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# test_1
		# Test(s) cannot be skipped anymore.
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_file_teardown() {
	test_file=t/lib/skip_call_during_file_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		1..0
		# Test(s) cannot be skipped anymore.
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

run_tests "$0"
