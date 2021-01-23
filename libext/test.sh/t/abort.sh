#!/bin/sh

. ./test.sh

test_call_during_file_setup() {
	test_file=t/lib/abort_call_during_file_setup.sh
	{ expected_output=$(cat); } <<-EOF
		Bail out!
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_setup() {
	test_file=t/lib/abort_call_during_test_setup.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		Bail out!
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_without_reason_during_test() {
	test_file=t/lib/abort_call_without_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		Bail out!
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_with_reason_during_test() {
	test_file=t/lib/abort_call_with_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		Bail out! test
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_teardown() {
	test_file=t/lib/abort_call_during_test_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# test_1
		Bail out!
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_file_teardown() {
	test_file=t/lib/abort_call_during_file_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		Bail out!
		1..0
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

run_tests "$0"
