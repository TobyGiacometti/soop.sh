#!/bin/sh

. ./libext/test.sh/test.sh
. ./soop.sh

test_null_check() {
	! is_object "" || fail_test 1
}

test_string_check() {
	! is_object test || fail_test 1
}

test_invalid_object_reference_check() {
	! is_object "_soopsh_exec_instruction 1; echo evil; " || fail_test 1
}

test_object_check() {
	new object_1 t/lib/TypeObjectCheck
	is_object "$object_1" || fail_test 1
}

run_tests "$0"
