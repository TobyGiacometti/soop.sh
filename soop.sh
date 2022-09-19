# shellcheck shell=sh

# soop.sh
# https://github.com/TobyGiacometti/soop.sh
# Copyright (c) 2022 Toby Giacometti and contributors
# Apache License 2.0

#---
# Create a new object.
#
# Following operations occur:
#
# - The class is autoloaded if necessary.
# - The constructor is invoked.
# - An object reference variable is created.
#
# Check `_soopsh_assign_field_value()` and `_soopsh_call()` for details on how
# to define fields/constructors/methods.
#
# @param $1 Name of the object reference variable. The object reference variable
#           can be used to call public object methods:
#
#           ```sh
#           #              Public method  Method arguments
#           $video_backup  run            force
#           ```
#
# @param $2 Path to the class that should be instantiated. Check the documentation
#           of `_soopsh_load_class()` for more details. If a named constructor
#           should be invoked, its name can be appended to the class path with
#           `__` as separator:
#
#           ```sh
#           new video_backup /usr/local/lib/backup/DataBackup__from_working_dir
#           ```
#
# @param... Arguments that should be passed to the constructor.
new() {
	# - `$1`: Object reference variable name
	# - `$2`: Class directory path with trailing slash
	# - `$3`: Class name with named constructor specification
	# - Remaining parameters: Constructor arguments
	_soopsh_1=$1 _soopsh_2=$2
	shift "$(($# >= 1))" && shift "$(($# >= 1))" # No shift if arguments missing.
	case $_soopsh_2 in
		*/*)
			set -- "$_soopsh_1" "${_soopsh_2%/*}/" "${_soopsh_2##*/}" "$@"
			;;
		*)
			set -- "$_soopsh_1" "" "$_soopsh_2" "$@"
			;;
	esac
	unset -v _soopsh_1 _soopsh_2

	if ! _soopsh_is_posix_name "$1"; then
		printf "%s\n" "Variable name is invalid." >&2
		exit 1
	fi

	_soopsh_load_class "$2${3%%__*}"

	eval '_soopsh_object_'"$_soopsh_next_object_id"'_class=$_soopsh_last_loaded_class'
	eval "$1"'="_soopsh_exec_instruction $_soopsh_next_object_id"'

	# Next object ID has to be generated before constructor invocation to ensure
	# that class instantiation inside the constructor uses the correct object ID.
	_soopsh_next_object_id=$((_soopsh_next_object_id + 1))

	# - `$1`: Constructor name
	# - Remaining parameters: Constructor arguments
	_soopsh_3=$3
	shift 3
	case $_soopsh_3 in
		*__*)
			set -- "${_soopsh_3#*__}" "$@"
			;;
		*)
			set "" "$@"
			;;
	esac
	unset -v _soopsh_3

	_soopsh_call "$((_soopsh_next_object_id - 1))" ctor "$@" || exit 1
}

#---
# Check whether a value is an object reference.
#
# @param $1 Value that should be checked.
is_object() {
	case $1 in
		"_soopsh_exec_instruction "[0-9]*)
			_soopsh_is_uint "${1#* }"
			;;
		*)
			return 1
			;;
	esac
}

#---
# Load a class.
#
# In addition to class loading, following operations occur:
#
# - The variable `$_soopsh_last_loaded_class` is updated.
# - The special field `classpath` is automatically defined for the loaded class
#   and contains the absolute class path (without `.sh`).
#
# Keep in mind that the class file is only loaded once.
#
# @param $1 Path to the class that should be loaded. If this function is called
#           inside a class file, the path is relative to the class file. If called
#           outside of a class file, the path is relative to the current working
#           directory. An absolute path can be provided as well. Please note that
#           `.sh` is automatically appended to the path specification.
# @internal
_soopsh_load_class() {
	if ! _soopsh_is_posix_name "${1##*/}"; then
		printf "%s" "Class name is invalid. Only alphanumeric ASCII characters " \
			"and underscores are supported. In addition, the class name must not " \
			"start with a number." >&2
		printf "\n" >&2
		exit 1
	fi

	# Make sure that parameter expansion returns the correct directory path if
	# only a filename was provided.
	[ "${1%/*}" = "$1" ] && set "./$1"

	# - `$OLDPWD`: Absolute class directory path
	# - `$1`: Absolute class path
	case $1 in
		/*)
			set -- "$1" "${1%/*}"
			;;
		*)
			if [ -z "$_soopsh_call_stack" ]; then
				set -- "$1" "$PWD"
			else
				# We are inside a class file.
				eval 'set -- "$1"' \
					'"$_soopsh_object_'"${_soopsh_call_stack##* }"'_class"'
				eval 'set -- "$1" "${'"$2"'__ro__classpath%/*}"'
			fi
			set -- "$1" "$2/${1%/*}"
			;;
	esac
	cd -P -- "$2" >/dev/null 2>&1 || {
		printf "%s\n" "Class could not be found." >&2
		exit 1
	}
	# shellcheck disable=SC2164
	cd -- "$OLDPWD" >/dev/null 2>&1
	set -- "$OLDPWD/${1##*/}"

	# - `$2`: Class name ID
	# - `$3`: `1` if class has been loaded already, `0` otherwise
	eval 'set -- "$1" "$_soopsh_class_'"${1##*/}"'_name_id_map"'
	case $2 in
		*"$1="*)
			# We assign `$1` to a variable because some shells choke on positional
			# parameters inside parameter expansion patterns.
			_soopsh_1=$1
			set -- "$1" "${2#*"$_soopsh_1="}"
			unset -v _soopsh_1
			set -- "$1" "${2%%:*}" 1
			;;
		*)
			set -- "$1" "${2##*=}"
			set -- "$1" "${2%:}"
			set -- "$1" "$(($2 + 1))" 0
			;;
	esac

	_soopsh_last_loaded_class=_soopsh_class_${1##*/}_$2

	if [ "$3" -eq 0 ]; then
		eval '_soopsh_class_'"${1##*/}"'_name_id_map=$_soopsh_class_'"${1##*/}"'_name_id_map$1=$2:'

		if ! [ -r "$1.sh" ]; then
			printf "%s\n" "Class could not be found." >&2
			exit 1
		fi

		eval "$(
			printf "%s" "${_soopsh_last_loaded_class}__ro__classpath='"
			printf "%s" "$1" | sed -e s/\'/\'\\\\\'\'/g || exit
			printf "%s\n" "'"
			printf "%s\n" "${_soopsh_last_loaded_class}__ctor() { :; }"
			sed -e 's/^\(r[ow]__.*\)/'"$_soopsh_last_loaded_class"'__\1/' \
				-e 's/^\(ctor.*\)/'"$_soopsh_last_loaded_class"'__\1/' \
				-e 's/^\(public__.*\)/'"$_soopsh_last_loaded_class"'__\1/' \
				-e 's/^\(private__.*\)/'"$_soopsh_last_loaded_class"'__\1/' \
				-- "$1.sh"
		)" || exit 1
	fi
}

#---
# Execute an object instruction.
#
# Please note that fields and private methods can only be accessed from within
# objects.
#
# @param $1 ID of the object for which the instruction should be executed.
# @param $2 Instruction that should be executed:
#
#           - `field=value` assigns a value to a field. For example: `mode=noop`
#           - `field:` extracts a field value into a variable with the same name
#              as the field. For example: `mode:`
#           - `_method` calls a private method. For example: `_print_destination`
#           - `method` calls a public method. For example: `run`
#
# @param... Arguments that should be passed to the method.
# @internal
_soopsh_exec_instruction() {
	if [ -z "$2" ]; then
		printf "%s\n" "Instruction is required." >&2
		exit 1
	fi

	# - `$1`: Function name
	# - Remaining parameters: Function arguments
	case $2 in
		*=*)
			if [ "${_soopsh_call_stack##* }" != "$1" ]; then
				printf "%s\n" "Field cannot be accessed outside of object." >&2
				exit 1
			fi
			# shellcheck disable=SC2121
			set _soopsh_assign_field_value "$1" "${2%%=*}" "${2#*=}"
			;;
		*:)
			if [ "${_soopsh_call_stack##* }" != "$1" ]; then
				printf "%s\n" "Field cannot be accessed outside of object." >&2
				exit 1
			fi
			# shellcheck disable=SC2121
			set _soopsh_extract_field_value "$1" "${2%:}"
			;;
		_*)
			if [ "${_soopsh_call_stack##* }" != "$1" ]; then
				printf "%s\n" "Private method cannot be accessed outside of object." >&2
				exit 1
			fi
			_soopsh_1=$1 _soopsh_2=$2
			shift 2
			# shellcheck disable=SC2121
			set _soopsh_call "$_soopsh_1" private "${_soopsh_2#_*}" "$@"
			unset -v _soopsh_1 _soopsh_2
			;;
		*)
			_soopsh_1=$1 _soopsh_2=$2
			shift 2
			# shellcheck disable=SC2121
			set _soopsh_call "$_soopsh_1" public "$_soopsh_2" "$@"
			unset -v _soopsh_1 _soopsh_2
			;;
	esac

	"$@"
}

#---
# Assign a value to a field.
#
# Fields can be defined as follows inside a class file:
#
# ```sh
# ro__config_dir=.backup # This is a constant.
# ro__source= # Once initialized, this field cannot be modified.
# rw__mode= # This field can be read and written to at will.
# rw__mode=default # Same as above but with default value.
# ```
#
# @param $1 ID of the object whose field should be modified.
# @param $2 Name of the field.
# @param $3 Value that should be assigned.
# @internal
_soopsh_assign_field_value() {
	if ! _soopsh_is_uint "$1"; then
		printf "%s\n" "Object ID is invalid." >&2
		exit 1
	elif eval '[ -z ${_soopsh_object_'"$1"'_class+set} ]'; then
		printf "%s\n" "Object with the specified ID does not exist." >&2
		exit 1
	elif ! _soopsh_is_posix_name "$2"; then
		printf "%s\n" "Field name is invalid." >&2
		exit 1
	fi

	# - `$4`: Name of the variable that is used as read-only field definition.
	# - `$5`: Name of the variable that is used as read/write field definition.
	eval 'set -- "$1" "$2" "$3"' \
		'"${_soopsh_object_'"$1"'_class}__ro__'"$2"'"' \
		'"${_soopsh_object_'"$1"'_class}__rw__'"$2"'"'

	if eval '[ -z ${'"$4"'+set} ]' && eval '[ -z ${'"$5"'+set} ]'; then
		printf "%s\n" "Field with the specified name is not defined." >&2
		exit 1
	elif eval '[ -n "${'"$4"'+set}" ]' && eval '[ -n "${'"$5"'+set}" ]'; then
		printf "%s\n" "Field with the specified name is defined as read-only and read/write." >&2
		exit 1
	elif eval '[ -n "${'"$4"'+set}" ]'; then
		if eval '[ -n "${_soopsh_object_'"$1"'_'"$2"'_value+set}" ]' \
			|| eval '[ -n "$'"$4"'" ]'; then
			printf "%s\n" "Field with the specified name is read-only." >&2
			exit 1
		fi
	fi

	eval '_soopsh_object_'"$1"'_'"$2"'_value=$3'
}

#---
# Extract a field value into a variable.
#
# Check `_soopsh_assign_field_value()` for details on how to define fields.
#
# The variable into which the field value is extracted has the same name as the
# field.
#
# @param $1 ID of the object whose field value should be extracted.
# @param $2 Name of the field.
# @internal
_soopsh_extract_field_value() {
	if ! _soopsh_is_uint "$1"; then
		printf "%s\n" "Object ID is invalid." >&2
		exit 1
	elif eval '[ -z ${_soopsh_object_'"$1"'_class+set} ]'; then
		printf "%s\n" "Object with the specified ID does not exist." >&2
		exit 1
	elif ! _soopsh_is_posix_name "$2"; then
		printf "%s\n" "Field name is invalid." >&2
		exit 1
	fi

	# - `$3`: Name of the variable that is used as read-only field definition.
	# - `$4`: Name of the variable that is used as read/write field definition.
	eval 'set -- "$1" "$2"' \
		'"${_soopsh_object_'"$1"'_class}__ro__'"$2"'"' \
		'"${_soopsh_object_'"$1"'_class}__rw__'"$2"'"'

	if eval '[ -z ${'"$3"'+set} ]' && eval '[ -z ${'"$4"'+set} ]'; then
		printf "%s\n" "Field with the specified name is not defined." >&2
		exit 1
	fi

	if eval '[ -n "${_soopsh_object_'"$1"'_'"$2"'_value+set}" ]'; then
		eval "$2"'=$_soopsh_object_'"$1"'_'"$2"'_value'
	elif eval '[ -n "${'"$3"'+set}" ]'; then
		eval "$2"'=$'"$3"
	else
		eval "$2"'=$'"$4"
	fi
}

#---
# Call a constructor/method.
#
# Constructors/methods can be defined as follows inside a class file:
#
# ```sh
# ctor() { :; } # Default constructor
# ctor__from_working_dir() { :; } # Named constructor
# public__run() { :; } # Public method
# private__print_destination() { :; } # Private method
# ```
#
# @param $1 ID of the object whose constructor/method should be called.
# @param $2 Type of the function that should be called. Can be `ctor`, `private`
#           or `public`.
# @param $3 Name of the constructor/method. An empty string leads to a default
#           constructor call if `$2` is set to `ctor`.
# @param... Arguments that should be passed to the constructor/method.
# @internal
_soopsh_call() {
	if ! _soopsh_is_uint "$1"; then
		printf "%s\n" "Object ID is invalid." >&2
		exit 1
	elif eval '[ -z ${_soopsh_object_'"$1"'_class+set} ]'; then
		printf "%s\n" "Object with the specified ID does not exist." >&2
		exit 1
	elif [ "$2" != ctor ] && [ "$2" != private ] && [ "$2" != public ]; then
		printf "%s\n" "Function type is invalid." >&2
		exit 1
	elif [ "$2" = ctor ] && [ -z ${3+set} ]; then
		printf "%s\n" "Constructor name is required." >&2
		exit 1
	elif [ "$2" != ctor ] && [ -z "$3" ]; then
		printf "%s\n" "Method name is required." >&2
		exit 1
	fi

	_soopsh_call_stack="$_soopsh_call_stack $1"
	self="_soopsh_exec_instruction $1"

	# - `$1`: Constructor/method name
	# - Remaining parameters: Constructor/method arguments
	_soopsh_1=$1 _soopsh_2=$2 _soopsh_3=$3
	shift 3
	if [ "$_soopsh_2" = ctor ] && [ -z "$_soopsh_3" ]; then
		eval 'set -- "${_soopsh_object_'"$_soopsh_1"'_class}__ctor" "$@"'
	elif [ "$_soopsh_2" = ctor ]; then
		eval 'set -- "${_soopsh_object_'"$_soopsh_1"'_class}__ctor__$_soopsh_3" "$@"'
	elif [ "$_soopsh_2" = private ]; then
		eval 'set -- "${_soopsh_object_'"$_soopsh_1"'_class}__private__$_soopsh_3" "$@"'
	elif [ "$_soopsh_2" = public ]; then
		eval 'set -- "${_soopsh_object_'"$_soopsh_1"'_class}__public__$_soopsh_3" "$@"'
	fi
	unset -v _soopsh_1 _soopsh_2 _soopsh_3

	"$@"
	set "$?"

	_soopsh_call_stack=${_soopsh_call_stack% *}
	if [ -z "$_soopsh_call_stack" ]; then
		self="eval printf '%s\n' '\$self cannot be used outside of object.' >&2; exit 1;"
	else
		self="_soopsh_exec_instruction ${_soopsh_call_stack##* }"
	fi

	[ "$1" -eq 127 ] && exit "$1" || return "$1"
}

#---
# Check whether a value is a POSIX name.
#
# <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_235>
#
# @param $1 Value that should be checked.
# @internal
_soopsh_is_posix_name() {
	case $1 in
		"")
			return 1
			;;
		[0-9]*)
			return 1
			;;
		*[!a-zA-Z0-9_]*)
			return 1
			;;
	esac
}

#---
# Check whether a value is an unsigned integer.
#
# @param $1 Value that should be checked.
# @internal
_soopsh_is_uint() {
	case $1 in
		"")
			return 1
			;;
		*[!0-9]*)
			return 1
			;;
	esac
}

#---
# @var Reference to the current object inside constructors/methods. The object
#      reference variable can be used to execute object instructions:
#
#      ```sh
#      #      Instruction          Method arguments
#      $self  mode:
#      $self  run                  force
#      ```
#
#      Check `_soopsh_exec_instruction()` for supported instructions.
#
# shellcheck disable=SC2034
self=
#---
# @var Each time a constructor/method is called, the object's ID is appended to
#      this variable and removed once the call completes. The IDs are separated
#      by a space character.
# @internal
_soopsh_call_stack=
#---
# @internal
_soopsh_next_object_id=1
#---
# @var Internal name of the last loaded class.
# @internal
_soopsh_last_loaded_class=
#---
# @var $_soopsh_class_<class>_name_id_map
#      <class> Name of the class.
#
#      Mapping from class paths to class name IDs.
#
#      The mapping is used to create unique internal class names without the help
#      of external utilities. This is much better for performance since external
#      utilities would have to be called on each class instantiation otherwise.
#
#      The mapping has following format:
#
#      `/path/to/class=class_name_id:/path/to/class=class_name_id:`
#
#      Instead of creating a single mapping variable, multiple variables are
#      created to increase parameter expansion performance.
# @internal
#---
# @var $_soopsh_object_<id>_class
#      <id> Object ID
#      Internal class name of an object.
# @internal
#---
# @var $_soopsh_object_<id>_<field>_value
#      <id> Object ID
#      <field> Field name
#      Value of a field. If not defined, the default value is retrieved.
# @internal
