#!/bin/bash
# ###########################
# Bash Shell Function Library
# ###########################
#
# Author: Hanson <liangguohuan@gmail.com>
#
# Copyright © 2015
#
# Released under the curren GPL version.
#
# Description:
#
# This is a shell script library. It contains functions that can be called by
# programs that include (source) this library. 
#
#

# Shell编程返回值得注意事项：
# 获取 return 返回值，只能是返回整数值，而且必须通过 $? 变量间接捕获。
# 所以一般用 echo 直接输出当作返回值比较好，除非是复杂的返回类型
# 
# Example： 
# myfun() {
#  return $(( 5 + 1 )); 
# }
# myfun
# RESULTS=$?
# echo $RESULTS
# 

########################################################################
#=> String function
# Examples: 
# 	str="hello,everybody, let's go to play!"
# 	echo $(strlen "$str")
# 	echo $(substr "$str" -5 2)
# 	echo $(strcut "$str" "o")
# 	echo $(strrcut "$str" "l")
# 	echo $(strinstr "$str" "go")
#
########################################################################

#
# bash generate random character alphanumeric string (upper and lowercase) 
# 
# ARG1 = string length, default:32
#
function randchar {
	[[ -n $1 ]] && WIDTH=$1 || WIDTH=32
    RANDUUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$WIDTH" | head -n 1)
    echo $RANDUUID
}

#
# bash generate random number
# 
# ARG1 = number width, default:1
#
function randdigital {    
    [[ -n $1 ]] && WIDTH=$1 || WIDTH=1
    RANDNUMBER=$(cat /dev/urandom | tr -dc '0-9' | fold -w 256 | head -n 1 | sed -e 's/^0*//' | head --bytes "$WIDTH")
    echo $RANDNUMBER
}

#
# Get string length
# 
# ARG1 = string to be count length
#
function strlen {
	_STR="$1"
	echo ${#_STR}
}

# Get substr from string
#
# ARG1 = string to be substr
# ARG2 = where to be start
# ARG3 = where to be end
# 
function substr {
	_STR="$1"
	_START="($2)"
	_END="$3"
	echo ${_STR:$_START:$_END}
}

# Cut substr start from left
# 
# ARG1 = string to be strcut
# ARG2 = what the ended char is
# ARG3 = whether greedy mode to be handle
# 
function strcut {
	_STR="$1"
	_CHAR="$2"
	_MORE="$3"
	_MATCH="${_STR:0:1}*$_CHAR"
	if [[ $_MORE == 1 ]]; then
		echo ${_STR##$_MATCH}
	else
		echo ${_STR#$_MATCH}
	fi
}

# Cut substr start from right
#
# ARG1 = string to be strcut
# ARG2 = what the started char is
# ARG3 = whether greedy mode to be handle
# 
function strrcut {
	_STR="$1"
	_CHAR="$2"
	_MORE="$3"
	_MATCH="$_CHAR*${_STR:(-1):1}"
	if [[ $_MORE == 1 ]]; then
		echo ${_STR%%$_MATCH}
	else
		echo ${_STR%$_MATCH}
	fi
}

# Check substr in string
#
# ARG1 = string to be strinstr
# ARG2 = substr to be found
# 
# RETURN = 1 or 0
# 
function strinstr {
	_STR="$1"
	_SUBSTR="$2"
	[[ "$_STR" =~ "$_SUBSTR" ]] \
	&& echo 1 \
	|| echo 0
}

#
# Join array elements with a string 
#
# ARG1 = array to be handle
# ARG2 = what char to be split, default is space
#
# RETURN = string
#
function implode {
	local -n _ARRAY=$1
	local _STR=${_ARRAY[@]}
	[[ -n $2 ]] \
		&& local _GLUE=$2 \
		|| local _GLUE=" "
	echo ${_STR// /$_GLUE}
}

#
# Split a string by string
# 
# ARG1 = string to be handle
# ARG2 = what char to be split, default is space
#
# RETURN = array
#
function explode {
	_STR=$1
	[[ -n $2 ]] \
		&& local _GLUE=$2 \
		|| local _GLUE=" "
	_STR=${_STR//$_GLUE/ }
    echo $_STR
	# for _X in $_STR   
	# do  
		# printf '%s \a' $_X
	# done  
}

########################################################################
#=> Array functions: only support single dimension array
########################################################################


#
# Sort array
# 
# ARG1 = the array to be loop
# 
# Example:
# 	arr1=(2 9 3 4 7 6 1 8)
# 	arr2=(m p k e j g w u i)
# 	arr3=('john' 'hanson' 'peter' 'andy' 'kenter')
# 	arrsort arr1
# 	arrsort arr2
# 	arrsort arr3
# 	arrprint arr1 arr2 arr3
#
function arrsort {
	local -n _ARRAY=$1
	_LEN=${#_ARRAY[@]}
	for (( i = `expr $_LEN-1`; i > 0; i-- )); do
		for (( j = `expr $i-1`; j > -1; j-- )); do
			if [[ ${_ARRAY[i]} > ${_ARRAY[j]} ]]; then
	            _TEMP=${_ARRAY[$i]}
	            _ARRAY[$i]=${_ARRAY[$j]}
	            _ARRAY[$j]=$_TEMP
			fi
		done
	done
}

#
# Check element whether in array
# 
# ARG1 = the array to be loop
# ARG2 = the element to be found
#
# RETURN = -1 or gt -1, return the element index if the element be found
#
# Example:
# 	arr=(1 3 5 7 9)
# 	echo $(inarr arr 3)
#
function inarr {
	# [[ "${array[@]/$var/}" != "${array[@]}" ]] && echo "in"
	# echo "${array[@]}" | grep -wq "$var" &&  echo "in"
	local -n _ARRAY=$1
    NEDDLE=$2
    i=0
    for _ELE in ${_ARRAY[@]}; do
    	if [[ "$_ELE" == "$NEDDLE" ]]; then
    		echo $i
    		return
    	fi
    	((i++))
    done
    echo -1
}

#
# Get all keys from array
# 
# ARG1 = array to be handle
# 
# RETURN = array
#
# Example:
# 	declare -A arr
# 	arr=([index1]=val1 [index2]=val2)
# 	arrkeys arr
# 
function arrkeys {
	local -n _ARRAY=$1
    echo '('${!_ARRAY[@]}')'
}

#
# Get all values from array
# 
# ARG1 = array to be handle
# 
# RETURN = array
#
# Example:
# 	declare -A arr
# 	arr=([index1]=val1 [index2]=val2)
# 	arrvalues arr
# 
function arrvalues {
	local -n _ARRAY=$1
	echo '('${_ARRAY[@]}')'
}

#
# Array count
# 
# ARG1 = array to be handle
# 
# RETURN = number
# 
function count {
	local -n _ARRAY=$1
	echo ${#_ARRAY[@]}
}

#
# Extract a slice of the array
# 
# ARG1 = array to be handle
# ARG2 = offset
# ARG3 = length
# 
# RETURN = array
#
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	declare -A arrtemp=$(arrslice arr -2 2)
# 	arrprint arrtemp
#
function arrslice {
	local -n _ARRAY=$1
	local -i _START="($2)"
	local -i _END="$3"
	local -a _TEMP1=(${!_ARRAY[@]})
	local -a _TEMP2=(${_ARRAY[@]})
	local -a _KEYS=(${_TEMP1[@]:$_START:$_END})
	local -a _VALUES=(${_TEMP2[@]:$_START:$_END})
    [[ $(arrisassoc $1) == 1 ]] \
    && arrcombine _KEYS _VALUES \
    || echo '('${_TEMP2[@]:$_START:$_END}')'
}

# 
# Create a new array from keys and vals
# 
# ARG1 = array keys
# ARG2 = array vals
#
# RETURN = array
#
# Example:
# 	declare -a keys=(1 9 6 8 2 5)
# 	declare -a vals=(a b c d e f)
# 	declare -A arr=$(arrcombine keys vals)
# 	arrprint arr
# 	
function arrcombine {
	local -n _ARRAYKEYS=$1
	local -n _ARRAYVALUES=$2
    local -i _LEN=$(count _ARRAYKEYS)
    ((_LEN--))
	local -i i=0
	echo -n "("
	for _ELE in ${_ARRAYKEYS[@]}; do
		echo -n [$_ELE]=${_ARRAYVALUES[@]:i:1}
        [[ $_LEN != $i ]] && echo -n " "
		((i++))
	done
	echo -n ")"
}

#
# Remove elements from array
# 
# ARG1 = array to be handle
# ARG2..N element to be removed(show the value), split by space
# 
# RETURN = array
#
# Example:
# 	declare -a arr=(a b c d e f)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3 [index4]=val4)
# 	arrremove arr b d
# 	arrremove arrr val2 val3
# 	arrprint arr arrr
#
function arrremove {
	local -n _ARRAY=$1
	local -a _ARRAYKEYS=$(arrkeys $1)
	local -a _ARRAYVALUES=$(arrvalues $1)
	local -i i=0
	local -i _BPRINT=1
	for _X in ${_ARRAYKEYS[@]}; do
		local -i _II=0
		for _XX in $*; do
			if [[ $_II > 0 ]]; then
				if [[ ${_ARRAYVALUES[@]:i:1} == $_XX ]]; then
					unset _ARRAY[$_X]
					_BPRINT=0
					break
				fi
			fi
			((_II++))
		done
		_BPRINT=1
		((i++))
	done
}

#
# Push elements to array
# 
# ARG1 = array to be handle
# ARG2..N elements to be added, split by space
# 
# RETURN = array
#
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	arrpush arr 12 25 67
# 	arrpush arrr index4=val4 index8=val8
# 	arrprint arr arrr
#
function arrpush {
	local -n _ARRAY=$1
	local -i i=0
	for _X in $*; do
		if [[ $i > 0 ]]; then
            if [[ $(arrisassoc $1) == 0 ]]; then
				[[ $i > 0 ]] && [[ -n $_X ]] && _ARRAY=("${_ARRAY[@]}" $_X)
			else
				local _AC=${#_ARRAY[@]}
				local -a _TEMP=($(explode $_X "="))
				local _TK=${_TEMP[@]:0:1}
				local _TV=${_TEMP[@]:1:1}
				if [[ -z $_TV ]]; then
					_TK=`expr $_AC + $i - 1`
					_TV=$_X
				else
					_TEMP=($(explode $_X "="))
					_TK=${_TEMP[@]:0:1}
					_TV=${_TEMP[@]:1:1}
				fi
				_ARRAY[$_TK]=$_TV
			fi
		fi
		((i++))
	done
}

#
# Check whether araay is assoc type
#
# ARG1 = array
#
# RETURN = 1 if array is assoc else 0
# 
function arrisassoc {
    [[ $(declare -p $1 | grep '\-A') ]] && echo 1 || echo 0
}

#
# Print array nicely
#
# ARG1..N
# 
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	arrprint arrr arr
# 
function arrprint {
	for _PARAM in $*; do
		local -n _ARRAY=$_PARAM
		local -a _KEYS=(${!_ARRAY[@]})
		local -a _VALUES=(${_ARRAY[@]})
		local -i i=0
		echo $_PARAM
		echo "("
		for _ELE in ${_KEYS[@]}; do
			echo "  [$_ELE] => ${_VALUES[@]:i:1}"
			((i++))
		done
		echo ")"
	done
}


########################################################################
#=> system
########################################################################


#
# URL Parse
# ARG1 = url
# 
# RETURN = array
#
# Example:
# 	SITE="http://www.google.com/html/index.html"
# 	declare -A arr=$(urlparse $SITE)
#	arrprint arr
#	echo ${arr[host]}
function urlparse {
	local _SITE=$1
	local _ARRAY_URL=
	# extract the protocol
	_PROTO="$(echo $_SITE | grep :// | sed -e's,^\(.*://\).*,\1,g')"
	# remove the protocol
	_URL="$(echo ${_SITE/$_PROTO/})"
	# extract the host
	_HOST="$(echo ${_URL/$user@/} | cut -d/ -f1)"
	# extract the path (if any)
	_PATH="$(echo $_URL | grep / | cut -d/ -f2-)"
	_BASENAME=$(basename $_PATH)

    _ARRAY_URL=$(printf '([proto]="%s" [host]="%s" [path]="%s" [basename]="%s")' "$_PROTO" "$_HOST" "$_PATH" "$_BASENAME")
	echo $_ARRAY_URL
}

function fileparse {
    local _FILENAME=$1
    local _ARRAY_FILE=
    _DIRNAME=$(dirname $_FILENAME)
    _BASENAME=$(basename $_FILENAME)
    _EXT=$(strcut $_BASENAME '.' 1)
    _ARRAY_FILE=$(printf '([dirname]="%s" [basename]="%s" [ext]="%s")' "$_DIRNAME" "$_BASENAME" "$_EXT")
    echo $_ARRAY_FILE
}

# Show help messages
# 
# $1 msg
# $2 exitcode
function helpShow {
	local _TEMP=
	[[ -n "$1" ]] && _TEMP="$1" || _TEMP="$HELP_MESSAGE"
	echo "$_TEMP" | sed -e '1{/^$/d}' -e '${/^$/d}'
	[[ -n "$2" ]] && exit $2 || exit 1
}

# Assert expr
# do noting if pass else exit with exitcode 1
# ARG1 = expr
function assert {
    [[ "$1" == "$2" ]] || ERROR=1
    if [[ "$ERROR" == 1 ]]; then
        echo "$1"
        echo "$2"
        [[ -n "$3" ]] && echo "$3"
        exit 1
    fi
}

#
# All type translate into string
# ARG1..N
#
function str {
    declare -p "$@"
}

