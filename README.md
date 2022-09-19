# soop.sh

A Unix shell library that enables [SOOP (simple object-oriented programming)][1] in shell scripts.

## Table of Contents

- [Why?](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Defining a Class](#defining-a-class)
    - [Creating Objects](#creating-objects)
    - [Working with Objects](#working-with-objects)
    - [Example](#example)

## Why?

Complex shell scripts can quickly turn into a big ball of mud. With the help of [SOOP][1], a natural structure that is easy to reason about can be introduced into such scripts. As a result, the implementation of features becomes easier and maintenance more pleasant.

## Features

- All functionality required for [SOOP][1] is made available to shell scripts.
- Class files are automatically loaded when referenced.
- Shell builtins are used exclusively and subshells are avoided[^1].

## Requirements

soop.sh should work in any POSIX-compatible shell (tested with posh, dash, ksh93 and bash).

## Installation

Installing soop.sh is as simple as storing the file [soop.sh][2] in a location of choice.

## Usage

> **Note:** The examples below do not scope variables to functions due to strict POSIX compliance. If the `local` or `typeset` builtins are available in your shell, you should definitely use them.

### Defining a Class

```sh
# /usr/local/lib/backup/DataBackup.sh

# Fields and methods of the current object can be accessed as follows inside
# constructors/methods:
#
# - `$self mode=noop` assigns the value `noop` to the `mode` field.
# - `$self mode:` extracts the `mode` field value into the variable `$mode`.
# - `$self _print_destination` calls the private `print_destination` method.
# - `$self run force` calls the public `run` method with the argument `force`.

# Fields are defined by creating variables whose name is prefixed with `ro__`
# for read-only fields and `rw__` for read/write fields.
#
# > **Note:** The special field `classpath` is automatically defined for each
# > class and contains the absolute class path (without `.sh`).
ro__config_dir=.backup # This is a constant.
ro__source= # Once initialized, this field cannot be modified.
rw__mode= # This field can be read and written to at will.
rw__mode=default # Same as above but with default value.

# Default constructors are defined by creating functions with the name `ctor`.
ctor() {
	if [ -z "$1" ]; then
		printf "%s\n" "Backup source is required." >&2
		return 1
	fi

	$self source="$1"
	$self mode="$2"
}

# Named constructors are defined by creating functions whose name is prefixed
# with `ctor__`.
ctor__from_working_dir() {
	$self source="$PWD"
	$self mode="$1"
}

# Public methods are defined by creating functions whose name is prefixed with
# `public__`.
public__run() {
	destination=$($self _print_destination) || return
	$self mode:
	$self source:

	printf "%s\n" "Backing up $source to $destination..."
	if [ "$mode" != noop ] || [ "$1" = force ]; then
		rsync -av -- "$source" "$destination"
	fi
}

# Private methods are defined by creating functions whose name is prefixed with
# `private__`.
private__print_destination() {
	$self source:
	$self config_dir:
	cat -- "$source/$config_dir/destination"
}
```

> **Note:** Functions must be defined using POSIX-compliant syntax. Any function that is defined with the syntax `function fname compound-command` won't be associated with the class.

### Creating Objects

Objects are created with the `new` command:

```sh
#!/bin/sh

. /path/to/soop.sh

#    Object variable  Class path                        Constructor arguments
new  music_backup     /usr/local/lib/backup/DataBackup  ~/music
```

When `new` is called inside a class file, the class path is relative to the class file:

```sh
# /usr/local/lib/backup/DataBackup.sh

ctor() {
	# Loads `/usr/local/lib/backup/GenericData.sh`.
	new music_data GenericData ~/music
}
```

When `new` is called outside of a class file, the class path is relative to the current working directory:

```sh
#!/bin/sh

. /path/to/soop.sh

cd /usr/local/lib

# Loads `/usr/local/lib/backup/DataBackup.sh`.
new music_backup backup/DataBackup ~/music
```

If a named constructor should be invoked, its name can be appended to the class path with `__` as separator:

```sh
#!/bin/sh

. /path/to/soop.sh

cd ~/videos

# Invokes `ctor__from_working_dir` from `/usr/local/lib/backup/DataBackup.sh`.
new video_backup /usr/local/lib/backup/DataBackup__from_working_dir
```

> **Note:** `.sh` is automatically appended to the class path specification.

### Working with Objects

Use the object reference variable to call public object methods:

```sh
#!/bin/sh

. /path/to/soop.sh

cd ~/videos

new music_backup /usr/local/lib/backup/DataBackup ~/music
new video_backup /usr/local/lib/backup/DataBackup__from_working_dir noop

#              Public method  Method arguments
$music_backup  run
$video_backup  run            force
```

Objects can be passed around:

```sh
#!/bin/sh

. /path/to/soop.sh

run_backup() {
	$1 run
}

new music_backup /usr/local/lib/backup/DataBackup ~/music

run_backup "$music_backup"
```

Use the `is_object` command to check whether a value is an object reference:

```sh
#!/bin/sh

. /path/to/soop.sh

new music_backup /usr/local/lib/backup/DataBackup ~/music

is_object "$music_backup"
```

Fields and private methods can only be accessed from within objects:

```sh
#!/bin/sh

. /path/to/soop.sh

new music_backup /usr/local/lib/backup/DataBackup ~/music

$music_backup source: # Fails
$music_backup _print_destination # Fails
```

> **Note:** The object reference variable must be quoted appropriately. Whenever the variable is passed as an argument, it must be wrapped in quotes. If it is used to call public object methods, it must not be quoted.

### Example

Check out [toolbelt.sh][3] to see soop.sh in action.

[^1]: When a class file is loaded by the autoloading mechanism, a subshell is created and `sed` is called. This only happens once per class file.

[1]: https://www.soop.dev
[2]: soop.sh
[3]: https://github.com/TobyGiacometti/toolbelt.sh
