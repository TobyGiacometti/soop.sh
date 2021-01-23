rw__field_1=test_1

ctor() {
	new _object_1 NewDefaultConstructorInvocation__ctor_1
	$self field_1:
	[ "$field_1" = test_1 ] || fail_test 2 "$field_1"
	[ "$1" = test ] || fail_test 3 "$1"
	pass=1
}

ctor__ctor_1() {
	$self field_1=test_2
	$self field_1:
	[ "$field_1" = test_2 ] || fail_test 1 "$field_1"
}
