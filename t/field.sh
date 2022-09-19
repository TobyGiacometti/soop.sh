#!/bin/sh

. ./libext/test.sh/test.sh
. ./soop.sh

test_outside_of_object_assignment_failure() {
	new object_1 t/lib/FieldOutsideOfObjectAssignmentFailure
	output=$($object_1 field_1=test 2>&1 || true) && fail_test 1
	[ "$output" = "Field cannot be accessed outside of object." ] \
		|| fail_test 2 "$output"
}

test_invalid_name_assignment_failure() {
	new object_1 t/lib/FieldInvalidNameAssignmentFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field name is invalid." ] || fail_test 2 "$output"
}

test_undefined_assignment_failure() {
	new object_1 t/lib/FieldUndefinedAssignmentFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field with the specified name is not defined." ] \
		|| fail_test 2 "$output"
}

test_ambiguous_definition_failure() {
	new object_1 t/lib/FieldAmbiguousDefinitionFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field with the specified name is defined as read-only and read/write." ] \
		|| fail_test 2 "$output"
}

test_ro_assignment_failure() {
	new object_1 t/lib/FieldRoAssignmentFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field with the specified name is read-only." ] \
		|| fail_test 2 "$output"
}

test_constant_assignment_failure() {
	new object_1 t/lib/FieldConstantAssignmentFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field with the specified name is read-only." ] \
		|| fail_test 2 "$output"
}

test_ro_assignment() {
	new object_1 t/lib/FieldRoAssignment
	$object_1 method_1
	[ "$field_1" = test ] || fail_test 1 "$field_1"
}

test_rw_assignment() {
	new object_1 t/lib/FieldRwAssignment
	$object_1 method_1
	[ "$field_1" = test_3 ] || fail_test 1 "$field_1"
}

test_outside_of_object_extraction_failure() {
	new object_1 t/lib/FieldOutsideOfObjectExtractionFailure
	output=$($object_1 field_1: 2>&1 || true) && fail_test 1
	[ "$output" = "Field cannot be accessed outside of object." ] \
		|| fail_test 2 "$output"
}

test_invalid_name_extraction_failure() {
	new object_1 t/lib/FieldInvalidNameExtractionFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field name is invalid." ] || fail_test 2 "$output"
}

test_undefined_extraction_failure() {
	new object_1 t/lib/FieldUndefinedExtractionFailure
	output=$($object_1 method_1 2>&1 || true) && fail_test 1
	[ "$output" = "Field with the specified name is not defined." ] \
		|| fail_test 2 "$output"
}

test_object_value_extraction() {
	new object_1 t/lib/FieldObjectValueExtraction
	$object_1 method_1
	[ "$field_1" = test ] || fail_test 1 "$field_1"
}

test_constant_value_extraction() {
	new object_1 t/lib/FieldConstantValueExtraction
	$object_1 method_1
	[ "$field_1" = test ] || fail_test 1 "$field_1"
}

test_default_value_extraction() {
	new object_1 t/lib/FieldDefaultValueExtraction
	$object_1 method_1
	[ "$field_1" = test ] || fail_test 1 "$field_1"
}

test_class_path_extraction() {
	new object_1 t/lib/FieldClassPathExtraction
	$object_1 method_1
	[ "$classpath" = "$PWD/t/lib/FieldClassPathExtraction" ] || fail_test 1 "$classpath"
}

run_tests "$0"
