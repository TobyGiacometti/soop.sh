# shellcheck shell=sh

# test.sh
# https://github.com/TobyGiacometti/test.sh
# Copyright (c) 2022 Toby Giacometti and contributors
# Apache License 2.0

#---
# Run all tests in the current test file.
#
# Any test file function whose name starts with `test` represents a single test.
# Each test function runs in a separate subshell and any return code other than
# 0 is interpreted as a test failure.
#
# Other special functions can be defined in test files to execute actions during
# testing:
#
# - `setup_test_file()`: Invoked before tests in a test file run. Any return code
#   other than 0 skips all tests in the test file.
# - `teardown_test_file()`: Invoked before a test file exits.
# - `setup_test()`: Invoked before each test runs. Any return code other than 0
#   skips the test and marks it as failed.
# - `teardown_test()`: Invoked before a test subshell exits. Any return code other
#   than 0 marks the test as failed.
#
# A typical test file looks as follows:
#
# ```sh
# #!/bin/sh
#
# . /path/to/test.sh
#
# setup_test_file() { # optional
# 	# test file setup code
# }
#
# teardown_test_file() { # optional
# 	# test file teardown code
# }
#
# setup_test() { # optional
# 	# test setup code
# }
#
# teardown_test() { # optional
# 	# test teardown code
# }
#
# test_feature_one() {
# 	# test code
# }
#
# test_feature_two() {
# 	# test code
# }
#
# run_tests "$0"
# ```
#
# @param $1 Path to the test file this function is called from. This parameter
#           is required since test.sh can't use `$0` internally (value of `$0`
#           in sourced scripts is unspecified in the POSIX standard).
# @stdout [TAP](https://testanything.org/tap-specification.html)
# @exit
run_tests() {
	if [ -z "$1" ]; then
		printf "%s\n" "Path to the test file is required." >&2
		exit 1
	fi

	_testsh_test_funcs=$(
		sed -n \
			's/^[[:space:]]*\(test[A-Za-z0-9_][A-Za-z0-9_]*\)[[:space:]]*().*/\1/p' \
			-- "$1"
	) || exit

	# First create the private directory in case the public directory is stored
	# within. As a result, the operation is more secure since we don't have to
	# use the `-p` option.
	mkdir -m 700 -- "$_testsh_data_dir" "$test_data_dir" || exit

	_testsh_register_exit_handler _testsh_handle_file_exit

	# Since we don't need valid TAP output during a trace, output recording is
	# not enabled if the xtrace option is set. As a result, infinite loops are
	# prevented in some circumstances in which the output buffer file is being
	# used as STDIN.
	case $- in
		*x*)
			exec 3>&1
			: >"$_testsh_data_dir/output" || exit
			;;
		*)
			exec 3>&1 >>"$_testsh_data_dir/output" 2>&1 || exit
			;;
	esac

	_testsh_scope=setup_file setup_test_file || exit

	set 0
	if [ -n "$_testsh_test_funcs" ]; then
		_testsh_printf "# %s\n" <"$_testsh_data_dir/output" >&3
		: >"$_testsh_data_dir/output"

		while IFS= read -r test_func; do
			# STDIN is connected to /dev/null so that the test function does not
			# receive the test function name when reading STDIN.
			_testsh_run_test "$test_func" </dev/null || set 1
			[ -e "$_testsh_data_dir/bail" ] && exit 1
		done <<-EOF
			$_testsh_test_funcs
		EOF
	fi

	exit "$1"
}

#---
# Mark the current test as todo.
#
# Check the [TAP specification](https://testanything.org/tap-specification.html#todo-tests)
# for more details.
#
# @param $1 Reason why the current test is marked as todo (optional).
mark_test_todo() {
	case $_testsh_scope in
		setup_test | test | teardown_test)
			printf "%s" "$1" >"$_testsh_data_dir/$_testsh_test_num.todo"
			;;
		*)
			printf "%s\n" "No test is currently running." >&2
			exit 1
			;;
	esac
}

#---
# Skip the current test or all tests in the current test file.
#
# Call this function inside `setup_test_file()` to skip all tests in the current
# test file.
#
# Note: This function calls `exit`. If called inside a subshell, the `exit` call
# needs to be propagated.
#
# @param $1 Reason why the current test or all tests in the current test file are
#           being skipped (optional).
# @exit
skip_test() {
	case $_testsh_scope in
		setup_file)
			printf "%s" "$1" >"$_testsh_data_dir/skip"
			exit
			;;
		setup_test | test)
			printf "%s" "$1" >"$_testsh_data_dir/$_testsh_test_num.skip"
			exit
			;;
		*)
			printf "%s\n" "Test(s) cannot be skipped anymore." >&2
			exit 1
			;;
	esac
}

#---
# Abort the testing process.
#
# Note: This function calls `exit`. If called inside a subshell, the `exit` call
# needs to be propagated.
#
# @param $1 Reason why the testing process is being aborted (optional).
# @exit
abort_testing() {
	printf "%s" "$1" >"$_testsh_data_dir/bail"
	exit 1
}

#---
# Fail the current test.
#
# While `return 1` or `exit 1` also fail a test, calling this function is often
# more convenient because it automatically generates well formatted diagnostic
# output that helps to identify what caused the fail.
#
# Note: This function calls `exit`. If called inside a subshell, the `exit` call
# needs to be propagated.
#
# @param $1 Code that helps to identify what caused the fail.
# @param... Additional information (optional). Each parameter's value is printed
#           on its own line.
# @stdout Diagnostic information
# @exit
fail_test() {
	if [ -z "$1" ]; then
		printf "%s\n" "Code is required." >&2
		exit 1
	elif [ "$_testsh_scope" != setup_test ] \
		&& [ "$_testsh_scope" != test ] \
		&& [ "$_testsh_scope" != teardown_test ]; then
		printf "%s\n" "No test is currently running." >&2
		exit 1
	fi

	cp -- "$_testsh_data_dir/output" "$_testsh_data_dir/output.fail"
	: >"$_testsh_data_dir/output"

	printf "%s\n" "FAIL $1"
	shift 1
	if [ -s "$_testsh_data_dir/output.fail" ] || [ "$#" -gt 0 ]; then
		printf "%s\n" ---
		cat -- "$_testsh_data_dir/output.fail"
		[ "$#" -gt 0 ] && printf "%s\n" "$@"
	fi

	exit 1
}

# There's no way to check whether a function has been defined in shells that use
# an older version of the POSIX standard without the User Portability Utilities
# option. Due to this, we define no-op functions here in case the user does not
# define them.
setup_test_file() { :; }
teardown_test_file() { :; }
setup_test() { :; }
teardown_test() { :; }

#---
# @param $1 Name of the test function that should be invoked.
# @fd 3 [TAP](https://testanything.org/tap-specification.html)
# @internal
_testsh_run_test() {
	if [ -z "$1" ]; then
		printf "%s\n" "Name of the test function is required." >&2
		exit 1
	fi

	_testsh_test_num=$((_testsh_test_num + 1))

	(
		_testsh_fork
		_testsh_register_exit_handler _testsh_handle_test_exit
		_testsh_scope=setup_test setup_test || exit 1
		# shellcheck disable=SC2209
		_testsh_scope=test "$1"
	)
}

#---
# @param $1 Name of the exit handler (function). The exit handler receives `sig`
#           as the first argument if invoked due to a signal or an empty string
#           otherwise. The second parameter contains the status code of the last
#           command that was executed. Please note that `exit` calls inside the
#           exit handler should only be made to override the exit status.
# @internal
_testsh_register_exit_handler() {
	if ! _testsh_is_posix_name "$1"; then
		printf "%s\n" "Name of the exit handler is invalid." >&2
		exit 1
	fi

	_testsh_handle_exit() {
		# Execute the handler only once.
		trap '' INT TERM EXIT
		# Exit status needs to be specified explicitly otherwise the script exits
		# with the status of the command that was executed before the trap.
		"$@" || exit "$?"
		# We need to call exit explicitly on signal otherwise some shells don't
		# exit. In addition, we always want a nonzero exit status on signals.
		[ "$2" != sig ] || exit 1
	}

	trap '_testsh_handle_exit '"$1"' "" "$?"' EXIT
	# Some shells ignore the exit trap on signals.
	trap '_testsh_handle_exit '"$1"' sig "$?"' INT TERM
}

#---
# @param $@ Check the documentation of `_testsh_register_exit_handler()`.
# @fd 3 [TAP](https://testanything.org/tap-specification.html)
# @internal
_testsh_handle_file_exit() {
	# Use a subshell to catch `exit` calls so that we can continue final tasks.
	(_testsh_scope=teardown_file teardown_test_file)
	set "$?"

	if [ -e "$_testsh_data_dir/bail" ]; then
		printf "%s" "Bail out!" >&3
		_testsh_printf " %s" <"$_testsh_data_dir/bail" >&3
		printf "\n" >&3
		set 1
	fi

	printf "%s" "1.." >&3
	if [ -e "$_testsh_data_dir/skip" ]; then
		printf "%s" "0 # SKIP" >&3
		_testsh_printf " %s" <"$_testsh_data_dir/skip" >&3
	elif [ -z "$_testsh_test_funcs" ]; then
		printf "%s" 0 >&3
	else
		printf "%s\n" "$_testsh_test_funcs" | wc -l | tr -d '[:space:]' >&3
	fi
	printf "\n" >&3

	_testsh_printf "# %s\n" <"$_testsh_data_dir/output" >&3

	# Users should be notified if files/directories inside test data directories
	# cannot be removed.
	rm -rf -- "$test_data_dir" "$_testsh_data_dir" 2>&1 | _testsh_printf "# %s\n" >&3

	return "$1"
}

#---
# @param $@ Check the documentation of `_testsh_register_exit_handler()`.
# @fd 3 [TAP](https://testanything.org/tap-specification.html)
# @exit
# @internal
_testsh_handle_test_exit() {
	# Use a subshell to catch `exit` calls so that we can continue final tasks.
	(_testsh_scope=teardown_test teardown_test) || set -- "$1" 1

	if [ "$1" != sig ] && [ "$2" -eq 0 ]; then
		printf "%s" ok >&3
	else
		printf "%s" "not ok" >&3
		set -- "$1" 1
	fi
	printf "%s" " $_testsh_test_num $test_func" >&3

	if [ -e "$_testsh_data_dir/$_testsh_test_num.skip" ]; then
		printf "%s" " # SKIP" >&3
		_testsh_printf " %s" <"$_testsh_data_dir/$_testsh_test_num.skip" >&3
	elif [ -e "$_testsh_data_dir/$_testsh_test_num.todo" ]; then
		printf "%s" " # TODO" >&3
		_testsh_printf " %s" <"$_testsh_data_dir/$_testsh_test_num.todo" >&3
		# Tests that fail but are marked as todo should not lead to a nonzero
		# exit status.
		set -- "$1" 0
	fi

	printf "\n" >&3

	_testsh_printf "# %s\n" <"$_testsh_data_dir/output" >&3
	: >"$_testsh_data_dir/output"

	# Since we are inside an exit trap, we exit with an explicit status code so
	# that we can override the exit status for tests that are marked as todo.
	exit "$2"
}

#---
# Write formatted output.
#
# This function is less optimized than external utilities that are specifically
# designed for text processing. However, since we don't usually process a lot of
# text, this function ends up being faster. In addition, it is more convenient
# for our usecase.
#
# @param $1 Format string for `printf`. Applied to each line of text.
# @stdin Text that should be formatted.
# @stdout Formatted text
# @internal
_testsh_printf() {
	if [ -z "$1" ]; then
		printf "%s\n" "Format string is required." >&2
		exit 1
	fi

	# We also process the last line if it does not end with a newline character.
	while IFS= read -r _testsh_line || [ -n "$_testsh_line" ]; do
		# shellcheck disable=SC2059
		printf -- "$1" "$_testsh_line" || exit "$?" # Exit traps need explicit status.
	done

	unset -v _testsh_line
}

#---
# Fork a new process.
#
# Some shells don't fork a new process for subshells even though it is required.
# This function forks a new process in those shells.
#
# @internal
_testsh_fork() {
	# shellcheck disable=SC3045
	[ -z "$KSH_VERSION" ] || ulimit -t unlimited
}

#---
# Check whether a value is a POSIX name.
#
# <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_235>
#
# @param $1 Value that should be checked.
# @internal
_testsh_is_posix_name() {
	case $1 in
		"")
			return 1
			;;
		[0-9]*)
			return 1
			;;
		*[!a-zA-Z0-9_]*)
			return 1
			;;
	esac
}

#---
# @var Path to a directory that can be used to store test data. The directory is
#      created when `run_tests()` is called and removed once testing completes.
#
# shellcheck disable=SC2016
test_data_dir=${TMPDIR:-/tmp}/test$(exec sh -c '[ -n "$PPID" ] && printf "%s" "$PPID" && awk "BEGIN { srand (); print int(rand()*100000) }"')/public || exit
#---
# @var Name of the current test function. Populated shortly before `setup_test()`
#      invocation.
test_func=
#---
# @var Name of the current scope:
#
#      - `file`
#      - `setup_file`
#      - `setup_test` (only inside a test subshell)
#      - `test` (only inside a test subshell)
#      - `teardown_test` (only inside a test subshell)
#      - `teardown_file`
#
# @internal
#
# shellcheck disable=SC2209
_testsh_scope=file
#---
# @var Names of test functions in the current test file. Each name is separated
#      by a newline. This variable is populated after `run_tests()` is called.
# @internal
_testsh_test_funcs=
#---
# @var Number of the current test.
# @internal
_testsh_test_num=0
#---
# @var Path to a directory that can be used internally by test.sh to store test
#      data. The directory is created when `run_tests()` is called and removed
#      once testing completes.
# @internal
_testsh_data_dir=${test_data_dir%/*}
