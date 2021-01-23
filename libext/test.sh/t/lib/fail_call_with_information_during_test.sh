_testsh_fork

. ./test.sh

test_1() {
	printf "%s\n" test_1
	fail_test 1 error_1 error_2 error_3
}

test_2() {
	printf "%s\n" test_2
}
