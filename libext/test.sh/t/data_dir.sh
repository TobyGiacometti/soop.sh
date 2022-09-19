#!/bin/sh

. ./test.sh

test_creation() {
	[ -d "$test_data_dir" ] || fail_test 1 "$test_data_dir"
	output=$(ls -ld -- "$test_data_dir") || fail_test 2
	perms=${output%% *}
	[ "$perms" = drwx------ ] || fail_test 3 "$perms"
}

test_removal() {
	test_file=t/lib/data_dir_removal.sh
	ipc_file=$test_data_dir/removal.ipc
	(. "$test_file" && run_tests "$test_file" >/dev/null) || fail_test 1
	data_dir=$(cat -- "$ipc_file") || fail_test 2
	[ ! -d "$data_dir" ] || fail_test 3 "$data_dir"
}

run_tests "$0"
