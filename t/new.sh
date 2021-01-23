#!/bin/sh

. ./libext/test.sh/test.sh
. ./soop.sh

test_missing_variable_name_failure() {
	output=$(new 2>&1 || true) && fail_test 1
	[ "$output" = "Variable name is invalid." ] || fail_test 2 "$output"
}

test_invalid_variable_name_failure() {
	output=$(new "object_1; echo evil; " 2>&1 || true) && fail_test 1
	[ "$output" = "Variable name is invalid." ] || fail_test 2 "$output"
}

test_missing_class_name_failure() {
	output=$(new object_1 2>&1 || true) && fail_test 1
	case $output in
		"Class name is invalid."*)
			true
			;;
		*)
			fail_test 2 "$output"
			;;
	esac
}

test_invalid_class_name_failure() {
	output=$(
		new object_1 "t/lib/NewInvalidClassNameFailure; echo evil; " 2>&1 || true
	) && fail_test 1
	case $output in
		"Class name is invalid."*)
			true
			;;
		*)
			fail_test 2 "$output"
			;;
	esac
}

test_invalid_class_dir_path_failure() {
	output=$(new object_1 t/lib/newinvalidclassdirpathfailure/Test 2>&1 || true) \
		&& fail_test 1
	[ "$output" = "Class could not be found." ] || fail_test 2 "$output"
}

test_invalid_class_file_path_failure() {
	output=$(new object_1 t/lib/NewInvalidClassFilePathFailure 2>&1 || true) \
		&& fail_test 1
	[ "$output" = "Class could not be found." ] || fail_test 2 "$output"
}

test_class_eval_failure() {
	output=$(new object_1 t/lib/NewClassEvalFailure 2>&1 || true) \
		&& fail_test 1 || true
}

test__class_name_collision() {
	new object_1 t/lib/new1/NewClassNameCollision
	[ "$pass_1" -eq 1 ] || fail_test 1
	new object_2 t/lib/new2/NewClassNameCollision
	[ "$pass_2" -eq 1 ] || fail_test 2
	new object_3 t/lib/new3/NewClassNameCollision
	[ "$pass_3" -eq 1 ] || fail_test 3
}

test_absolute_class_path_load() {
	new object_1 "$PWD/t/lib/NewAbsoluteClassPathLoad"
	[ "$pass" -eq 1 ] || fail_test 1
}

test_class_name_load() {
	cd t/lib
	new object_1 NewClassNameLoad
	[ "$pass" -eq 1 ] || fail_test 1
}

test_cwd_relative_class_path_load() {
	new object_1 t/lib/NewCwdRelativeClassPathLoad
	[ "$pass" -eq 1 ] || fail_test 1
}

test_class_relative_class_path_load() {
	new object_1 t/lib/new1/NewClassRelativeClassPathLoad
	[ "$pass" -eq 1 ] || fail_test 1
}

test_one_time_class_file_load() {
	mkdir "$test_data_dir/$test_func"
	cp -r t/lib/new1 t/lib/new2 t/lib/new3 "$test_data_dir/$test_func"
	new object_1 "$test_data_dir/$test_func/new1/NewOneTimeClassFileLoad"
	[ "$pass_1" -eq 1 ] || fail_test 1
	new object_2 "$test_data_dir/$test_func/new2/NewOneTimeClassFileLoad"
	[ "$pass_2" -eq 1 ] || fail_test 2
	new object_3 "$test_data_dir/$test_func/new3/NewOneTimeClassFileLoad"
	[ "$pass_3" -eq 1 ] || fail_test 3
	printf "%s\n" 'public__method_1() { :; }' >>"$test_data_dir/$test_func/new2/NewOneTimeClassFileLoad.sh"
	unset pass_2
	new object_4 "$test_data_dir/$test_func/new2/NewOneTimeClassFileLoad"
	[ "$pass_2" -eq 1 ] || fail_test 4
	output=$($object_4 method_1 2>&1 || true)
	status=$?
	[ "$status" -eq 127 ] || fail_test 5 "$status" "$output"
}

test_undefined_constructor_failure() {
	output=$(new object_1 t/lib/NewUndefinedConstructorFailure__ctor_1 2>&1 || true)
	status=$?
	[ "$status" -eq 127 ] || fail_test 1 "$status" "$output"
}

test_default_constructor_invocation() {
	new object_1 t/lib/NewDefaultConstructorInvocation test
	[ "$pass" -eq 1 ] || fail_test 4
	output=$($self method_1 2>&1 || true) && fail_test 5
	[ "$output" = '$self cannot be used outside of object.' ] \
		|| fail_test 6 "$output"
}

test_named_constructor_invocation() {
	new object_1 t/lib/NewNamedConstructorInvocation__ctor_1 test
	[ "$pass" -eq 1 ] || fail_test 4
	output=$($self method_1 2>&1 || true) && fail_test 5
	[ "$output" = '$self cannot be used outside of object.' ] \
		|| fail_test 6 "$output"
}

test_constructor_failure() {
	output=$(new object_1 t/lib/NewConstructorFailure 2>&1 || true) && fail_test 1
	[ "$output" = error ] || fail_test 2 "$output"
}

test_implicit_constructor() {
	new object_1 t/lib/NewImplicitConstructor
	$object_1 method_1
	[ "$pass" -eq 1 ] || fail_test 1
}

test_object_creation() {
	new object_1 t/lib/new1/NewObjectCreation
	[ "$object_1" != "$object_2" ] || fail_test 1
	$object_2 method_1
	[ "$pass_2" -eq 1 ] || fail_test 2
	$object_1 method_1
	[ "$pass_1" -eq 1 ] || fail_test 3
}

run_tests "$0"
