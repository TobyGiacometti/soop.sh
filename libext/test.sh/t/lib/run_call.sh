_testsh_fork

. ./test.sh

setup_test_file() {
	printf "%s\n" setup_test_file
}

teardown_test_file() {
	printf "%s\n" teardown_test_file
}

setup_test() {
	printf "%s\n" setup_test
}

teardown_test() {
	printf "%s\n" teardown_test
}

test_1() {
	printf "%s\n" "$test_func"
	exit
}

test_2() {
	printf "%s\n" "$test_func"
	printf "%s\n" error >&2
	return 1
}

test_3() {
	printf "%s\n" "$test_func"
}

test_4() {
	kill "$(exec sh -c 'printf "%s" "$PPID"')"
	printf "%s\n" "$test_func"
}
