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
# 统计字符串长度
# 
# ARG1 = string to be count length
#
function strlen {
	STR="$1"
	echo ${#STR}
}

# 截取字符串
#
# ARG1 = string to be substr
# ARG2 = where to be start
# ARG3 = where to be end
# 
function substr {
	STR="$1"
	START="($2)"
	END="$3"
	echo ${STR:$START:$END}
}

# 从左边开始截断字符串
# 
# ARG1 = string to be strcut
# ARG2 = what the ended char is
# ARG3 = whether greedy mode to be handle
# 
function strcut {
	STR="$1"
	CHAR="$2"
	MORE="$3"
	MATCH="${STR:0:1}*$CHAR"
	if [[ $MORE == 1 ]]; then
		echo ${STR##$MATCH}
	else
		echo ${STR#$MATCH}
	fi
}

# 从右边开始截断字符串
#
# ARG1 = string to be strcut
# ARG2 = what the started char is
# ARG3 = whether greedy mode to be handle
# 
function strrcut {
	STR="$1"
	CHAR="$2"
	MORE="$3"
	MATCH="$CHAR*${STR:(-1):1}"
	echo @$MATCH@
	if [[ $MORE == 1 ]]; then
		echo ${STR%%$MATCH}
	else
		echo ${STR%$MATCH}
	fi
}

# 判断字符串是否包含子串
#
# ARG1 = string to be strinstr
# ARG2 = substr to be found
# 
# return = 1 or 0
# 
function strinstr {
	STR="$1"
	SUBSTR="$2"
	[[ "$STR" =~ "$SUBSTR" ]] \
	&& echo 1 \
	|| echo 0
}

#
# 将数组转换为字符串
# ARG1 = array to be handle
# ARG2 = what char to be split, default is space
#
function implode {
	local -n ARR=$1
	declare str=${ARR[@]}
	[[ -n $2 ]] \
		&& declare glue=$2 \
		|| declare glue=" "
	echo ${str// /$glue}
}

#
# 将字符串转换为数组
# 
# ARG1 = string to be handle
# ARG2 = what char to be split, default is space
#
function explode {
	str=$1
	[[ -n $2 ]] \
		&& declare glue=$2 \
		|| declare glue=" "
	str=${str//$glue/ }
	for x in $str   
	do  
	    echo $x
	done  
}

########################################################################
#=> Array functions: only support single dimension array
########################################################################


#
# 冒泡排序，不支持关联数组排序
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
	local -n ARR=$1
	len=${#ARR[@]}
	for (( i = `expr $len-1`; i > 0; i-- )); do
		for (( j = `expr $i-1`; j > -1; j-- )); do
			if [[ ${ARR[i]} > ${ARR[j]} ]]; then
	            temp=${ARR[$i]}
	            ARR[$i]=${ARR[$j]}
	            ARR[$j]=$temp
			fi
		done
	done
}

#
# 查找数组中是否包含指定的元素
# 
# ARG1 = the array to be loop
# ARG2 = the element to be found
# RETURN = -1 or gt -1, return the element index if the element be found
#
# Example:
# 	arr=(1 3 5 7 9)
# 	echo $(inarr arr 3) # 注意数组'x'不要加'$'
function inarr {
	# [[ "${array[@]/$var/}" != "${array[@]}" ]] && echo "in"
	# echo "${array[@]}" | grep -wq "$var" &&  echo "in"
	local -n ARR=$1
    NEDDLE=$2
    i=0
    for ELE in ${ARR[@]}; do
    	if [[ "$ELE" == "$NEDDLE" ]]; then
    		echo $i
    		return
    	fi
    	((i++))
    done
    echo -1
}

#
# 获取关联数组中所有键值
# 
# ARG1 = array to be handle
# 
# Example:
# 	declare -A arr
# 	arr=([index1]=val1 [index2]=val2)
# 	arrkeys arr
# 
function arrkeys {
	local -n ARR=$1
	echo ${!ARR[@]}
}

#
# 获取关联数组中所有值
# 
# ARG1 = array to be handle
# 
# Example:
# 	declare -A arr
# 	arr=([index1]=val1 [index2]=val2)
# 	arrvalues arr
# 
function arrvalues {
	local -n ARR=$1
	echo ${ARR[@]}
}

#
# 统计数组元素总数
# 
# ARG1 = array to be handle
# 
function count {
	local -n ARR=$1
	echo ${#ARR[@]}
}

#
# 数组截取
# 
# ARG1 = array to be handle
# ARG2 = where to be start
# ARG3 = where to be end
# 
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	declare -A temp=$(arrslice arr -2 2)
# 	arrprint temp
#
function arrslice {
	local -n ARR=$1
	declare -i START="($2)"
	declare -i END="$3"
	declare -a temp1=(${!ARR[@]}) # 注意数组下标不支持 ${!ARR[@]:1:2} 这种方式，只有取值才支持
	declare -a temp2=(${ARR[@]})  # 注意这里要做下间接处理,否则索引0,1开始取元素都是一样的，会破坏原来数组截取方式
	declare -a keys=(${temp1[@]:$START:$END})
	declare -a values=(${temp2[@]:$START:$END})
	arrcombine keys values
}

# 
# 创建一个数组，用一个数组的值作为其键名，另一个数组的值作为其值
# 
# ARG1 = array keys
# ARG2 = array values
#
# Example:
# 	declare -a keys=(1 9 6 8 2 5)
# 	declare -a vals=(a b c d e f)
# 	declare -A arr=$(arrcombine keys vals)
# 	arrprint arr
# 	
function arrcombine {
	local -n ARRKEYS=$1
	local -n ARRVALUES=$2
	declare -i i=0
	echo -n "( "
	for ELE in ${ARRKEYS[@]}; do
		echo -n [$ELE]=${ARRVALUES[@]:i:1}
		echo -n " "
		((i++))
	done
	echo -n ")"
}

#
# 删除数组元素
# 
# ARG1 = array to be handle
# ARG1..ARGN element to be removed(show the value), split by space
# 
# Example:
# 	declare -a arr=(a b c d e f)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3 [index4]=val4)
# 	arrremove arr b d
# 	arrremove arrr val2 val3
# 	arrprint arr arrr
# 
# Important: 直接改变数组，不要用 $(arrremove ...) 这种调用方式
#
function arrremove {
	local -n ARR=$1
	local -a ARRKEYS=($(arrkeys $1))
	local -a ARRVALUES=($(arrvalues $1))
	declare -i i=0
	declare -i bprint=1
	for x in ${ARRKEYS[@]}; do
		declare -i ii=0
		for xx in $*; do
			if [[ $ii > 0 ]]; then
				if [[ ${ARRVALUES[@]:i:1} == $xx ]]; then
					unset ARR[$x]
					bprint=0
					break
				fi
			fi
			((ii++))
		done
		bprint=1
		((i++))
	done
}

#
# 数组添加新元素
# 
# ARG1 = array to be handle
# ARG1..ARGN elements to be added, split by space
# 
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	arrpush arr 12 25 67
# 	arrpush arrr index4=val4 index8=val8
# 	arrprint arr arrr
# 	
# Important: 直接改变数组，不要用 $(arrpush ...) 这种调用方式
#
function arrpush {
	local -n ARR=$1
	declare is=$(arrisnormal $1)
	# 用 declare is=$(arrisnormal $1) 会报错: "警告: ARR: circular name reference"
	declare -i i=0
	for x in $*; do
		if [[ $i > 0 ]]; then
			if [[ $is == 1 ]]; then
				[[ $i > 0 ]] && [[ -n $x ]] && ARR=("${ARR[@]}" $x)
			else
				declare ac=${#ARR[@]}
				declare -a temp=($(explode $x "="))
				declare tk=${temp[@]:0:1}
				declare tv=${temp[@]:1:1}
				if [[ -z $tv ]]; then
					tk=`expr $ac + $i - 1`
					tv=$x
				else
					temp=($(explode $x "="))
					tk=${temp[@]:0:1}
					tv=${temp[@]:1:1}
				fi
				ARR[$tk]=$tv
			fi
		fi
		((i++))
	done
}

#
# 判断数组是否关联数组
# 
function arrisnormal {
	local -n ARR=$1
	declare -i i=0
	for x in ${!ARR[@]}; do
		[[ $i != $x ]] && echo -1 && return
		((i++))
	done
	echo 1
}

#
# 打印数组，支持多个数组传入
# 
# Example:
# 	declare -a arr=(1 9 6 8 2 5)
# 	declare -A arrr=([index1]=val1 [index2]=val2 [index3]=val3)
# 	arrprint arrr arr
# 
function arrprint {
	for param in $*; do
		local -n ARR=$param
		declare -a keys=(${!ARR[@]})
		declare -a values=(${ARR[@]})
		declare -i i=0
		echo $param
		echo "("
		for ELE in ${keys[@]}; do
			echo "  [$ELE] => ${values[@]:i:1}"
			((i++))
		done
		echo ")"
	done
}


########################################################################
#=> system
########################################################################


#
# URL解析
# 
# Example:
# 	SITE="http://www.google.com/html/index.html"
# 	declare -A arr=$(urlPaser $SITE)
#	arrprint arr
#	echo ${arr[host]}
function urlPaser {
	declare SITE=$1
	declare ARR_URL=
	# extract the protocol
	proto="$(echo $SITE | grep :// | sed -e's,^\(.*://\).*,\1,g')"
	# remove the protocol
	url="$(echo ${SITE/$proto/})"
	# extract the host
	host="$(echo ${url/$user@/} | cut -d/ -f1)"
	# extract the path (if any)
	path="$(echo $url | grep / | cut -d/ -f2-)"
	basename=$(basename $path)

	ARR_URL='([proto]="'$proto'" [host]="'$host'" [path]="'$path'" [basename]="'$basename'")'
	echo $ARR_URL
}

# Show help messages
# 
# $1 msg
# $2 exitcode
function helpShow {
	declare TEMP=
	[[ -n "$1" ]] && TEMP="$1" || TEMP="$HELP_MESSAGE"
	echo "$TEMP" | sed -e '1{/^$/d}' -e '${/^$/d}'
	[[ -n "$2" ]] && exit $2 || exit 1
}