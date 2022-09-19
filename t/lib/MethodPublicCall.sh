rw__field_1=test_1

ctor__ctor_1() {
	$self field_1=test_2
	$self field_1:
	[ "$field_1" = test_2 ] || fail_test 1 "$field_1"
}

public__method_1() {
	new _object_1 MethodPublicCall__ctor_1
	$self field_1:
	[ "$field_1" = test_1 ] || fail_test 2 "$field_1"
	[ "$1" = test ] || fail_test 3 "$1"
	pass=1
	return 15
}
