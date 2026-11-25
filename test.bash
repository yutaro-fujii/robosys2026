#!/bin/bash
# SPDX-FileCopyrightText: 2026 Yutaro Fujii
# SPDX-License-Identifier: BSD-3-Clause

ng () {
    echo "${1}行目のテスト失敗"
    res=1
}

res=0

### plus: NORMAL INPUT ###
out=$(seq 5 | ./plus)
[ "$?" = 0 ] || ng "$LINENO"
[ "${out}" = 15 ] || ng "$LINENO"

### plus: STRANGE INPUT ###
out=$(echo あ | ./plus)
[ "$?" = 1 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

out=$(echo | ./plus)
[ "$?" = 1 ] || ng "$LINENO"
[ "${out}" = "" ] || ng "$LINENO"

### gradecheck: NORMAL INPUT ###

check_ok () {
    local out
    out=$(printf '%s\n' "$1" | ./gradecheck)
    [ "$?" = 0 ] || ng "$3"
    [ "$out" = "$2" ] || ng "$3"
}

check_ok "センサ工学,60,中間,51,35,演習,100,30" "センサ工学,35" "$LINENO"

check_ok "科目A,60,中間,50,20,出席,100,10,課題,80,20,小テスト,70,10" "科目A,43" "$LINENO"

check_ok "科目B,60" "科目B,60" "$LINENO"

check_ok "科目C,60,中間,80,80" "科目C,PASS" "$LINENO"

check_ok "科目D,60,中間,20,80" "科目D,IMPOSSIBLE" "$LINENO"

check_ok "科目E,60,試験,60,100" "科目E,PASS" "$LINENO"

check_ok "科目F,60,試験,59,100" "科目F,IMPOSSIBLE" "$LINENO"

check_ok "科目G,60,中間,50.5,50" "科目G,70" "$LINENO"

check_ok "科目H,60,中間,20,50" "科目H,100" "$LINENO"

check_ok $'科目A,60\n科目B,70' $'科目A,60\n科目B,70' "$LINENO"

### gradecheck: STRANGE INPUT ###

err=$(mktemp) || exit 1
trap 'rm -f "$err"' EXIT

check_bad () {
    local out
    out=$(printf '%s' "$1" | ./gradecheck 2>"$err")
    [ "$?" = 1 ] || ng "$2"
    [ "$out" = "" ] || ng "$2"
    grep -q "Error:" "$err" || ng "$2"
}

check_bad "科目A,60,中間,-10,50" "$LINENO"
check_bad "科目A,60,中間,101,50" "$LINENO"
check_bad "科目A,60,中間,abc,50" "$LINENO"
check_bad "科目A,60,中間,NaN,50" "$LINENO"
check_bad "科目A,60,中間,80,60,課題,80,50" "$LINENO"
check_bad "科目A,60,中間,50" "$LINENO"
check_bad "科目A,101" "$LINENO"
check_bad ",60" "$LINENO"
check_bad "科目A,60,,50,30" "$LINENO"
check_bad "" "$LINENO"

### gradecheck: MIXED INPUT ###

out=$(printf '科目A,60\n不正入力\n科目B,70\n' | ./gradecheck 2>"$err")
[ "$?" = 1 ] || ng "$LINENO"
[ "$out" = $'科目A,60\n科目B,70' ] || ng "$LINENO"
grep -q "Error: 2行目:" "$err" || ng "$LINENO"

### RESULT ###
[ "${res}" = 0 ] && echo OK
exit $res