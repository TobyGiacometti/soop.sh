# Contribution Guide

First of all, thanks for your interest and for taking the time to contribute! This document shall be your guide throughout the contribution process and will hopefully answer any questions you have.

## Table of Contents

- [Response Times](#response-times)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Contributing Changes](#contributing-changes)
    - [Prerequisites](#prerequisites)
    - [Development Environment](#development-environment)
    - [Conventions](#conventions)
        - [General](#general)
        - [Unix Shell Script](#unix-shell-script)
    - [Testing](#testing)
    - [Pull Request](#pull-request)
- [Code of Conduct](#code-of-conduct)
- [Questions](#questions)

## Response Times

This project has been made available to you without expecting anything in return. As a result, maintenance does not happen on a set schedule. Please keep in mind that the irregular maintenance schedule can lead to significant delays in response times.

## Reporting Bugs

Before reporting a bug, please check if the bug occurs in the latest version. If it does, and if it hasn't already been reported in the [bug tracker][1], feel free to [file a bug report][2].

## Suggesting Enhancements

> **Note:** Simplicity is a core principle of this project. Every enhancement suggestion is carefully evaluated and only accepted if the usefulness of the enhancement greatly outweighs any increase in complexity.

Before suggesting an enhancement, please ensure that the enhancement is not implemented in the latest version. In addition, please ensure that there is no straightforward alternative to achieve the desired outcome. If these conditions are met, and if the enhancement hasn't already been suggested in the [enhancement tracker][3], feel free to [file an enhancement suggestion][4].

## Contributing Changes

### Prerequisites

Before making changes that you plan to contribute, please follow these instructions:

- **Changes related to a [reported bug][1]:** Make sure that the bug has not yet been assigned to anybody (and that nobody has volunteered) and write a comment letting the community know that you have decided to fix the bug.
- **Changes related to an unreported bug:** [File a bug report][2].
- **Changes related to an [already suggested enhancement][3]:** Make sure that the enhancement has not yet been assigned to anybody and write a comment letting the maintainers know that you would like to implement the enhancement. Wait until the enhancement suggestion has been assigned to you.
- **Changes related to a not yet suggested enhancement:** [File an enhancement suggestion][4] and wait until it has been assigned to you.

Following these instructions keeps you (and others) from investing time in changes that would get rejected or are already being worked on.

### Development Environment

This project uses [Vagrant][5] to manage a portable development environment. Simply execute `vagrant up` inside the project's directory to start the setup. Once completed, you can access the development environment with `vagrant ssh`.

### Conventions

#### General

- Code *should* document itself (meaningful naming).
- Code *must* be formatted by executing `vagrant ssh -c /mnt/project/sbin/format` inside the project's directory.

#### Unix Shell Script

- The [general conventions][6] *must* be followed.
- Lines longer than 80 characters *should* be avoided.
- Unless the script is inside the `sbin` or `t` directories, it *must* have following file header:

    ```sh
    # shellcheck shell=sh

    # test.sh
    # https://github.com/TobyGiacometti/test.sh
    # Copyright (c) <year> Toby Giacometti and contributors
    # Apache License 2.0
    ```

    The file header *must* be separated from other elements with an empty line.

- Commands *must* be grouped and ordered as follows and groups *must* be separated from each other with an empty line:
    1. Environment checks (check if OS is supported, etc.)
    2. Shell option setting/unsetting
    3. File sourcing
    4. Public function definitions
    5. Internal function definitions
    6. Trap registrations
    7. Common public variable assignments
    8. Common internal variable assignments
    9. Main logic
- Functions *must* be separated from each other with an empty line.
- Function and variable names *must* use snake case.
- If the script is to be sourced by end users, functions and variables that are not intended for public use *must* be named with the `_testsh_` prefix.
- Names of functions that make modifications *must* read as imperative verb phrases. For example: `print_help`, `fork`.
- Names of functions that don't make modifications *must* read as [predicate phrases][7]. For example: `is_empty`, `exists`.
- Functions *must* be documented using Markdown syntax and following template:

    ```sh
    #---
    # Summary for function (if not obvious or description is provided).
    #
    # Description for function (if extended documentation is needed).
    #
    # @param $@ Description for all parameters (if function takes multiple arguments that are all of the same type).
    # @param $<number> Description for a parameter (if not using a description for all parameters).
    # @param... Description for remaining parameters (if function takes multiple trailing arguments that are all of the same type).
    # @stdin Description for STDIN (if used).
    # @stdout Description for STDOUT (if used).
    # @stderr Description for STDERR (if used for non-error output).
    # @fd <number> Description for a non-standard file descriptor.
    # @status Description for all status codes (if documenting each status code separately is suboptimal).
    # @status <number> Description for a non-standard status code (if not using a description for all status codes).
    # @exit (if function calls `exit` outside of error cases)
    # @internal (if function is not intended for public use)
    func() { :; }
    ```

- If the script is to be sourced by end users, global variables *must* be documented using Markdown syntax and following template:

    ```sh
    #---
    # @var Description for variable (if not obvious).
    # @internal (if variable is not intended for public use)
    var=
    #---
    # @var $var_<placeholder>
    #      <placeholder> Description for placeholder.
    #      Description for dynamically defined variable (if not obvious).
    # @readonly (if variable is read-only)
    # @internal (if variable is not intended for public use)
    ```

### Testing

The tests are stored inside the `t` directory. Simply execute `vagrant ssh -c /mnt/project/sbin/test` inside the project's directory to run the test suite.

### Pull Request

Before creating a pull request, please follow these instructions:

- Recreate the development environment if `sbin/provision` has been modified.
- Ensure that the instructions in the [Prerequisites][8] and [Conventions][9] sections have been followed.
- Lint the codebase by executing `vagrant ssh -c /mnt/project/sbin/lint` inside the project's directory.
- Update the [test suite][10] and exercise the code you have written.
- Update the [README file][11].
- Update the [changelog][12].

After the pull request has been created, confirm that all [status checks][13] are passing. If you believe that a status check failure is a false positive, comment on the pull request and a maintainer will review the failure.

## Code of Conduct

Please note that this project is released with a [contributer code of conduct][14]. By participating in this project you agree to abide by its terms.

## Questions

Still have questions? No problem! Use the [question tracker][15] to [ask a question][16].

[1]: https://github.com/TobyGiacometti/test.sh/issues?q=is%3Aissue+label%3Abug
[2]: https://github.com/TobyGiacometti/test.sh/issues/new?template=bug.md
[3]: https://github.com/TobyGiacometti/test.sh/issues?q=is%3Aissue+label%3Aenhancement
[4]: https://github.com/TobyGiacometti/test.sh/issues/new?template=enhancement.md
[5]: https://www.vagrantup.com
[6]: #general
[7]: https://en.wikipedia.org/wiki/Predicate_(grammar)
[8]: #prerequisites
[9]: #conventions
[10]: #testing
[11]: README.md
[12]: CHANGELOG.md
[13]: https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-status-checks
[14]: CODE_OF_CONDUCT.md
[15]: https://github.com/TobyGiacometti/test.sh/issues?q=is%3Aissue+label%3Aquestion
[16]: https://github.com/TobyGiacometti/test.sh/issues/new?template=question.md
