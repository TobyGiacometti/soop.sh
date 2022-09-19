#!/bin/sh

. ./test.sh

test_missing_code_failure() {
	output=$(fail_test 2>&1 || true) && return 1
	[ "$output" = "Code is required." ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_during_file_setup() {
	test_file=t/lib/fail_call_during_file_setup.sh
	{ expected_output=$(cat); } <<-EOF
		1..0
		# No test is currently running.
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_during_test_setup() {
	test_file=t/lib/fail_call_during_test_setup.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# FAIL 1
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_without_information_during_test() {
	test_file=t/lib/fail_call_without_information_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# FAIL 1
		# ---
		# test_1
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_with_information_during_test() {
	test_file=t/lib/fail_call_with_information_during_test.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# FAIL 1
		# ---
		# test_1
		# error_1
		# error_2
		# error_3
		ok 2 test_2
		# test_2
		1..2
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_during_test_teardown() {
	test_file=t/lib/fail_call_during_test_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		not ok 1 test_1
		# FAIL 1
		# ---
		# test_1
		1..1
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

test_call_during_file_teardown() {
	test_file=t/lib/fail_call_during_file_teardown.sh
	{ expected_output=$(cat); } <<-EOF
		1..0
		# No test is currently running.
	EOF
	output=$(. "$test_file" && run_tests "$test_file") && return 1
	[ "$output" = "$expected_output" ] || {
		printf "%s\n" "$output"
		return 1
	}
}

run_tests "$0"
