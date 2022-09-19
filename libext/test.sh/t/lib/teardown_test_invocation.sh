_testsh_fork

. ./test.sh

teardown_test() {
	printf "%s\n" teardown_test
	exit 1
}

test_1() {
	printf "%s\n" test_1
}
