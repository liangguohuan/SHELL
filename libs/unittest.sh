#!/bin/bash
# Brief: unit test for common functions

source ./common.sh

# ###########################
# String function
# ###########################
assert $(strlen 'abcdef') 6 'strlen'
assert $(substr 'abcdef' 1 2) 'bc' 'substr'
assert $(strcut 'abcdcef' 'c') 'dcef' 'strcut'
assert $(strcut 'abcdcef' 'c' 1) 'ef' 'strcut'
assert $(strrcut 'abcdcef' 'c') 'abcd' 'strrcut'
assert $(strrcut 'abcdcef' 'c' 1) 'ab' 'strrcut'
assert $(strinstr 'abcdef' 'de') 1 'strinstr'
declare -a arr=(1 2 3)
assert "$(implode arr ',')" '1,2,3' 'implode'
assert "$(explode '1,2,3' ',')" '1 2 3' 'explode'


# ######################################################
# Array functions: only support single dimension array
# ######################################################
arr=(2 9 3 4 7 5 6 1 8)
arrsort arr
assert "$(implode arr ',')" '9,8,7,6,5,4,3,2,1' 'arrsort'

arr=(2 9 3 4 7 5 6 1 8)
assert $(inarr arr 3) 2 'inarr'
assert $(inarr arr 10) -1 'inarr'

declare -A arr2
arr2=([a]=1 [b]=2 [c]=3)
assert "$(arrkeys arr2)" '(a b c)' 'arrkeys'

assert "$(arrvalues arr2)" '(1 2 3)' 'arrvalues'

assert "$(count arr)" 9 'count'
assert "$(count arr2)" 3 'count'

arr=(2 9 3 4 7 5 6 1 8)
assert "$(arrslice arr 1 3)" '(9 3 4)' 'arrslice'

declare -a akeys=(1 9 6 8 2 5)
declare -a avals=(a b c d e f)
declare -A arrc=$(arrcombine akeys avals)

declare -a akeycheck=$(arrkeys arrc)
assert "$(implode akeycheck)" '1 2 5 6 8 9' 'arrcombine'
declare -a avalcheck=$(arrvalues arrc)
assert "$(implode avalcheck)" 'a e f c d b' 'arrcombine'

arr=(2 9 3 4 7 5 6 1 8)
arrremove arr 3 6
declare -a arrcheck=$(arrvalues arr)
assert "$(implode arrcheck)" '2 9 4 7 5 1 8' 'arrremove'

arr=(0 1 2)
declare -A arrassoc=([a]=1 [b]=2 [c]=3)
arrpush arr 3 6
assert "$(implode arr)" '0 1 2 3 6' 'arrpush'
arrpush arrassoc f=5 h=7
checkstr=$(printf 'declare -A arrassoc=%s([a]="1" [b]="2" [c]="3" [f]="5" [h]="7" )%s' "'" "'")
assert "$(str arrassoc)" "$checkstr" 'arrpush'

declare -a arrcheck1=(1 2 3 4 5)
declare -A arrcheck2=([a]=1 [b]=2 [c]=3)
assert "$(arrisassoc arrcheck1)" 0 'arrisassoc'
assert "$(arrisassoc arrcheck2)" 1 'arrisassoc'

# ###########################
# System
# ###########################
SITE="http://www.google.com/html/index.html"
declare -A arrurl=$(urlparse $SITE)
assert "${arrurl[basename]}" 'index.html' 'urlparse'
assert "${arrurl[proto]}" 'http://' 'urlparse'
assert "${arrurl[host]}" 'www.google.com' 'urlparse'
assert "${arrurl[path]}" 'html/index.html' 'urlparse'

# vim: fdm=marker ts=4 sw=4 sts=4 expandtab

