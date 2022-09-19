_testsh_fork

. ./test.sh

teardown_test() {
	mark_test_todo
	printf "%s\n" teardown_test
}

test_1() {
	printf "%s\n" test_1
	return 1
}
