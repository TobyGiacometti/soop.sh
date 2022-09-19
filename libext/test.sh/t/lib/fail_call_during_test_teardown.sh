_testsh_fork

. ./test.sh

teardown_test() {
	fail_test 1
	printf "%s\n" teardown_test
}

test_1() {
	printf "%s\n" test_1
}
