#!/bin/bash

# 抽取年龄
ageOfPlayer=$(awk -F '\t' '{print $6}' worldcupplayerinfo.tsv)

numberOfPlayer=0
ageRange_20=0
ageRange20_30=0
ageRange30_=0
maxAge=0
minAge=300
maxLength=0
minLength=300
i=1
slen=0
for n in ${ageOfPlayer};do
    if [[ $n != "Age" ]];
    then
        numberOfPlayer=$((numberOfPlayer+1))
        name=$(awk -F '\t' 'NR=='$((numberOfPlayer+1))' {print $9}' worldcupplayerinfo.tsv)
        name=${name//[[:space:]]/}
        slen=${#name}
        if [[ $n -lt 20 ]];
        then
            ageRange_20=$((ageRange_20+1))
        fi
        if [[ $n -ge 20 && $n -le 30 ]];
        then
            ageRange20_30=$((ageRange20_30+1))
        fi
        if [[ $n -gt 30 ]];
        then
            ageRange30_=$((ageRange30_+1))
        fi
        if [[ $n -gt $maxAge ]];
        then
            maxAge=$n
        fi
        if [[ $n -lt $minAge ]];
        then
            minAge=$n
        fi
        if [[ $slen -gt $maxLength ]];
        then
            maxLength=$slen
        fi
        if [[ $slen -lt $minLength ]];
        then
            minLength=$slen
        fi
    fi
done



i=1
x1=0
x2=0
y1=0
y2=0
declare -a youngest
declare -a oldest
declare -a namelongest
declare -a nameshortest

for n in ${ageOfPlayer};do
    if [[ $n != "Age" ]];
    then
        name=$(awk -F '\t' 'NR=='$((i+1))' {print $9}' worldcupplayerinfo.tsv)
        t=${name//[[:space:]]/}
        slen=${#t}
        age=$n

        if [[ $slen == $maxLength ]];
        then
            namelongest["$x1"]="$name"
            x1=$((x1+1))
        fi
        if [[ $slen == $minLength ]];
        then
            nameshortest[$x2]="$name"
            x2=$((x2+1))
        fi
        if [[ $age == $maxAge ]];
        then
            oldest[$y1]="$name"
            y1=$((y1+1))
        fi
        if [[ $age == $minAge ]];
        then
            youngest["$y2"]="$name"
            y2=$((y2+1))
        fi
        i=$((i+1))
    fi
done
echo "-------------------------------------------"
echo "年龄在20岁以下的数量:$ageRange_20,百分比:$(echo "scale=2; $ageRange_20*100/$numberOfPlayer" | bc) %"
echo "-------------------------------------------"
echo "年龄在20-30岁的数量:$ageRange20_30,百分比:$(echo "scale=2; $ageRange20_30*100/$numberOfPlayer" | bc) %"
echo "-------------------------------------------"
echo "年龄在20-30岁的数量:$ageRange30_,百分比:$(echo "scale=2; $ageRange30_*100/$numberOfPlayer" | bc) %"
echo "-------------------------------------------"
echo "名字最长的球员是:"
cnt=0
while [ $cnt -lt "$x1" ];do
    echo "${namelongest[${cnt}]}"
    cnt=$((cnt+1))
done
echo "-------------------------------------------"
echo "名字最短的球员是:"
cnt=0
while [ $cnt -lt "$x2" ];do
    echo "${nameshortest[${cnt}]}"
    cnt=$((cnt+1))
done
echo "-------------------------------------------"
echo "年龄最大的球员是:"
cnt=0
while [ $cnt -lt "$y1" ];do
    echo "${oldest[${cnt}]}"
    cnt=$((cnt+1))
done
echo "-------------------------------------------"
echo "年龄最小的球员是"
cnt=0
while [ $cnt -lt "$y2" ];do
    echo "${youngest[${cnt}]}"
    cnt=$((cnt+1))
done

declare -A position
positions=$(awk -F '\t' '{print $5}' worldcupplayerinfo.tsv)

for n in ${positions};do
    if [[ "$n" != "Position" ]];
    then
        if [[ "$n" != "" ]];
        then
            position["$n"]=$((position["$n"]+1))
        fi
    fi
done
echo "-------------------------------------------"
for key in "${!position[@]}";do
    echo "$key: ${position[$key]} 所占比例 $(echo "scale=2; ${position[$key]}*100/$numberOfPlayer" | bc) %"
done
