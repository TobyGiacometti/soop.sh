_testsh_fork

. ./test.sh

setup_test_file() {
	printf "%s\n" "$test_data_dir" >"$ipc_file"
}
