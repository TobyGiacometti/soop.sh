_testsh_fork

. ./test.sh

test_1() {
	mark_test_todo
	printf "%s\n" test_1
	return 1
}

test_2() {
	printf "%s\n" test_2
}
