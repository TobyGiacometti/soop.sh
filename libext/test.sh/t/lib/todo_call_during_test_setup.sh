_testsh_fork

. ./test.sh

setup_test() {
	mark_test_todo
	printf "%s\n" setup_test
}

test_1() {
	printf "%s\n" test_1
	return 1
}
