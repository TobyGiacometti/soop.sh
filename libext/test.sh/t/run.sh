#!/bin/sh

. ./test.sh

exit_status=0

test_num=1
test_name=test_missing_path_failure
if output=$(run_tests 2>&1 || true); then
	printf "%s\n" "not ok $test_num $test_name"
	exit_status=1
elif [ "$output" != "Path to the test file is required." ]; then
	printf "%s\n" "not ok $test_num $test_name"
	_testsh_printf "# %s\n" <<-EOF
		$output
	EOF
	exit_status=1
else
	printf "%s\n" "ok $test_num $test_name"
fi

test_num=2
test_name=test_call
test_file=t/lib/run_call.sh
{ expected_output=$(cat); } <<-EOF
	# setup_test_file
	ok 1 test_1
	# setup_test
	# test_1
	# teardown_test
	not ok 2 test_2
	# setup_test
	# test_2
	# error
	# teardown_test
	ok 3 test_3
	# setup_test
	# test_3
	# teardown_test
	not ok 4 test_4
	# setup_test
	# teardown_test
	1..4
	# teardown_test_file
EOF
if output=$(exec 2>&1 && . "$test_file" && run_tests "$test_file"); then
	printf "%s\n" "not ok $test_num $test_name"
	exit_status=1
elif [ "$output" != "$expected_output" ]; then
	printf "%s\n" "not ok $test_num $test_name"
	_testsh_printf "# %s\n" <<-EOF
		$output
	EOF
	exit_status=1
else
	printf "%s\n" "ok $test_num $test_name"
fi

printf "%s\n" "1..2"

exit "$exit_status"
