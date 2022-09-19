_testsh_fork

. ./test.sh

teardown_test_file() {
	abort_testing
	printf "%s\n" teardown_test_file
}
