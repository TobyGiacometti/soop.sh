# test.sh

A Unix shell library that turns shell scripts into test runners.

## Table of Contents

- [Why?](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Creating Tests](#creating-tests)
    - [Setup and Teardown](#setup-and-teardown)
    - [Skipping Tests](#skipping-tests)
    - [Failing Tests](#failing-tests)
    - [Todo Tests](#todo-tests)
    - [Abort](#abort)
    - [Test Data Storage](#test-data-storage)
    - [Diagnostic Output](#diagnostic-output)
    - [Running Tests](#running-tests)
    - [Example](#example)

## Why?

While many testing frameworks for the Unix shell are available, most of them share two traits: They are not portable and introduce new syntax. test.sh adopts a more universal approach by offering a wide range of useful testing features while supporting any POSIX-compatible shell and standard shell syntax.

## Features

- Simple architecture: Create an empty shell script, source test.sh and define tests (shell functions). Once done, simply execute the script to start testing.
- Various hooks for different stages of the testing process are available.
- Temporary directories for test data storage are automatically created/removed.
- Tests can be skipped or aborted easily.
- [TAP output][1] with helpful diagnostic information is produced.

## Requirements

test.sh should work in any POSIX-compatible shell (tested with posh, dash, ksh93 and bash).

## Installation

Installing test.sh is as simple as storing the file [test.sh][2] in a location of choice.

## Usage

### Creating Tests

Any test file function whose name starts with `test` represents a single test. Each test function runs in a separate subshell and any return code other than 0 is interpreted as a test failure:

```sh
#!/bin/sh

. /path/to/test.sh

test_feature_one() {
	return 0 # Pass
}

test_feature_two() {
	return 1 # Fail
}

run_tests "$0"
```

> **Note:** Test functions must be defined using POSIX-compliant syntax. Any test function that is defined with the syntax `function fname compound-command` won't be detected.

### Setup and Teardown

Special functions can be defined in test files to execute actions during testing:

- `setup_test_file()`: Invoked before tests in a test file run. Any return code other than 0 skips all tests in the test file.
- `teardown_test_file()`: Invoked before a test file exits.
- `setup_test()`: Invoked before each test runs. Any return code other than 0 skips the test and marks it as failed.
- `teardown_test()`: Invoked before a test subshell exits. Any return code other than 0 marks the test as failed.

You can use the variable `$test_func` inside `setup_test()` and `teardown_test()` if you need to know which test function is currently active.

### Skipping Tests

`skip_test` can be called inside `setup_test()` or a test function to skip the current test. If called inside `setup_test_file()`, all tests in the current test file are skipped. If desired, you can provide a reason as the first argument.

> **Note:** `skip_test` calls `exit`. If called inside a subshell, the `exit` call needs to be propagated.

### Failing Tests

In addition to calling `return` or `exit` with a non-zero status code, you can also call `fail_test` to fail tests:

```sh
#!/bin/sh

. /path/to/test.sh

test_feature_one() {
	# A code that helps to identify what caused the fail must be provided as
	# the first argument. Additional information can be provided after the 
	# code (optional).
	printf "%s\n" "An error occurred" >&2
	fail_test 1 "Additional information" "Some more information"
}

run_tests "$0"
```

`fail_test` automatically generates well formatted diagnostic output:

```
not ok 1 test_feature_one
# FAIL 1
# ---
# An error occurred
# Additional information
# Some more information
1..1
```

`fail_test` can also be called inside `setup_test()` or `teardown_test()`.

> **Note:** `fail_test` calls `exit`. If called inside a subshell, the `exit` call needs to be propagated.

### Todo Tests

`mark_test_todo` can be called inside `setup_test()`, `teardown_test()` or a test function if code under test is not yet complete (failures occur) but the test should pass regardless. More information can be found in the [TAP specification][3]. If desired, you can provide a reason as the first argument.

### Abort

`abort_testing` can be called at any time to abort the testing process. Once called, the current test (if one is running) is aborted and any remaining tests in the current test file are not invoked. If a [TAP harness][4] is being used to invoke tests, any remaining test files are not processed. If desired, you can provide a reason as the first argument.

> **Note:** `abort_testing` calls `exit`. If called inside a subshell, the `exit` call needs to be propagated.

### Test Data Storage

Each test file run gets its own temporary directory for test data storage. The path to the directory is stored in the variable `$test_data_dir`. The directory is automatically created and removed.

Whenever possible, test data should be scoped to test functions to isolate tests from each other. This can be achieved by naming test data files/directories using the current test function name. For this purpose, the variable `$test_func` can be used inside `setup_test()`, `teardown_test()` and test functions.

### Diagnostic Output

Any output that is sent to STDOUT or STDERR when inside `setup_test_file()`, `setup_test()`, `teardown_test()`, `teardown_test_file()` or a test function is recorded and automatically printed as [TAP diagnostics][5].

> **Note:** Output that is generated outside of the said functions will not be processed. Depending on the [TAP harness][4], this could lead to an error.

### Running Tests

To run tests, you can simply execute any test file that is powered by test.sh. If one of the tests in the file fails, the file will exit with a non-zero status code:

```
$ t/run.sh
not ok 1 test_missing_path_failure
ok 2 test_call
1..2
$ echo "$?"
1
```

Since [TAP output][1] is produced, test files can be processed by a [TAP harness][4]. The command-line utility [prove][6], which is preinstalled on many Unix operating systems, can be used for this purpose:

```
$ prove t/*.sh
t/abort.sh ..... ok   
t/data_dir.sh .. ok   
t/fail.sh ...... ok   
t/run.sh ....... ok   
t/setup.sh ..... ok   
t/skip.sh ...... ok   
t/teardown.sh .. ok   
t/todo.sh ...... ok   
All tests successful.
Files=8, Tests=34,  1 wallclock secs ( 0.06 usr  0.04 sys +  0.41 cusr  0.17 csys =  0.68 CPU)
Result: PASS
```

> **Note:** Don't forget to call `run_tests "$0"` at the end of a test file.

### Example

Check out the [test suite for toolbelt.sh][7] to see test.sh in action.

[1]: https://testanything.org/tap-specification.html
[2]: test.sh
[3]: https://testanything.org/tap-specification.html#todo-tests
[4]: https://testanything.org/consumers.html
[5]: https://testanything.org/tap-specification.html#diagnostics
[6]: https://perldoc.perl.org/prove.html
[7]: https://github.com/TobyGiacometti/toolbelt.sh/tree/master/t
