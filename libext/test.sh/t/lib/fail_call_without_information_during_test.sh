_testsh_fork

. ./test.sh

test_1() {
	printf "%s\n" test_1
	fail_test 1
}

test_2() {
	printf "%s\n" test_2
}
