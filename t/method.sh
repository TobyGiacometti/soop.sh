#!/bin/sh

. ./libext/test.sh/test.sh
. ./soop.sh

test_outside_of_object_private_call_failure() {
	new object_1 t/lib/MethodOutsideOfObjectPrivateCallFailure
	output=$($object_1 _method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Private method cannot be accessed outside of object." ] \
		|| fail_test 2 "$output"
}

test_undefined_failure() {
	new object_1 t/lib/MethodUndefinedFailure
	output=$($object_1 method_1 2>&1 || true)
	set "$?"
	[ "$1" -eq 127 ] || fail_test 1 "$1" "$output"
}

test_private_call() {
	new object_1 t/lib/MethodPrivateCall
	$object_1 method_1
	set "$?"
	[ "$pass" -eq 1 ] || fail_test 4
	[ "$1" -eq 15 ] || fail_test 5 "$1"
	output=$($self method_1 2>&1 || true) && fail_test 6
	[ "$output" = '$self cannot be used outside of object.' ] \
		|| fail_test 7 "$output"
}

test_public_call() {
	new object_1 t/lib/MethodPublicCall
	$object_1 method_1 test
	set "$?"
	[ "$pass" -eq 1 ] || fail_test 4
	[ "$1" -eq 15 ] || fail_test 5 "$1"
	output=$($self method_1 2>&1 || true) && fail_test 6
	[ "$output" = '$self cannot be used outside of object.' ] \
		|| fail_test 7 "$output"
}

run_tests "$0"
