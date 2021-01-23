_testsh_fork

. ./test.sh

teardown_test() {
	abort_testing
	printf "%s\n" teardown_test
}

test_1() {
	printf "%s\n" test_1
}
