#!/bin/sh

. ./test.sh

test_call_during_file_setup() {
	test_file=t/lib/todo_call_during_file_setup.sh
	{ expected_output=$(cat); } <<-EOF
		1..0
		# No test is currently running.
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_setup() {
	test_file=t/lib/todo_call_during_test_setup.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1 # TODO
		# setup_test
		# test_1
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_without_reason_during_test() {
	test_file=t/lib/todo_call_without_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1 # TODO
		# test_1
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_with_reason_during_test() {
	test_file=t/lib/todo_call_with_reason_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1 # TODO test
		# test_1
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_test_teardown() {
	test_file=t/lib/todo_call_during_test_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1 # TODO
		# test_1
		# teardown_test
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") || fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_call_during_file_teardown() {
	test_file=t/lib/todo_call_during_file_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		1..0
		# No test is currently running.
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

run_tests "$0"
