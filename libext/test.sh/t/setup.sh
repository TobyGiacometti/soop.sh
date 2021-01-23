#!/bin/sh

. ./test.sh

test_file_invocation() {
	test_file=t/lib/setup_file_invocation.sh
	{ expected_output=$(cat); } <<-EOF
		1..1
		# setup_test_file
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

test_test_invocation() {
	test_file=t/lib/setup_test_invocation.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# setup_test
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && fail_test 1
	[ "$output" = "$expected_output" ] || fail_test 2 "$output"
}

run_tests "$0"
