_testsh_fork

. ./test.sh

teardown_test_file() {
	fail_test 1
	printf "%s\n" teardown_test_file
}
