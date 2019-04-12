#!/bin/bash
function usage
{
    cat<<OUTPUT
    usage $0: WebProcessing.sh [-sh][-si][-sc][-u][-uh][-fs][-h]
    optional arguments:
    -sh             统计访问来源主机TOP 100和分别对应出现的总次数
    -si             统计访问来源主机TOP 100 IP和分别对应出现的总次数
    -sc             统计不同响应状态码的出现次数和对应百分比
    -u              统计最频繁被访问的URL TOP 100
    -uh <url>       给定URL输出TOP 100访问来源主机
    -fs             分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
    -h,  --help"
OUTPUT
}
function sourceHost
{
    # sed -e '1d'删除web_log.tsv第一行
    # 记录第一列host每个种类出现的个数
    # 将记录的数组排序，打印前100行
    (sed -e '1d' web_log.tsv|awk -F '\t' '{a[$1]++} END {for(i in a) {print i,a[i]}}'|sort -nr -k2|head -n 100)
}

function sourceIp
{
    (sed -e '1d' web_log.tsv|awk -F '\t' '{if($1~/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$/) print $1}'|awk '{a[$1]++} END {for(i in a){print i,a[i]}}'|sort -nr -k2|head -n 100)
}

function usualUrl
{
    (sed -e '1d' web_log.tsv|awk -F '\t' '{a[$6]++} END {for(i in a) {printf("%d 数量为：%d\n",i,a[i])}}' |sort -nr -k2|head -n 100)
}

function statusCode
{
    (sed -e '1d' web_log.tsv|awk -F '\t' '{a[$6]++;c++} END {for(i in a) {printf("%d 数量为：%-10d 所占比例为：%.5f%\n",i,a[i],a[i]*100/c)}}')
}

function urlHost
{
    (sed -e '1d' web_log.tsv|awk -F '\t' '{if($5=="'$1'") a[$1]++} END {for(i in a){print i,a[i]}}'|sort -nr -k2|head -n 100)
}

function 4xxURL
{
    a=$(sed -e '1d' 'web_log.tsv'|awk -F '\t' '{if($6~/^4+/) a[$6]++} END {for(i in a) print i}')
    for i in $a
    do
        (sed -e '1d' web_log.tsv|awk -F '\t' '{if($6~/^'$i'/) a[$6][$5]++} END {for(i in a){for(j in a[i]){print i,j,a[i][j]}}}'|sort -nr -k3|head -n 10)
    done
}

if [[ "$0" && "$1" == "" ]];
then
	usage
fi
while [ "$1" != "" ];do
    case "$1" in
    -sh )
        ifsh=1
        ;;
    -si )
        ifsi=1
        ;;
    -u )
        ifu=1
        ;;
    -sc )
        ifsc=1
        ;;
    -uh )
        ifuh=1
        shift
        if [[ "$1" != -* && "$1" ]]
        then 
            url="$1"
        else
            echo "Missing parameter [-uh <url>]"
            exit
        fi
        ;;
    -fs )
        iffs=1
        ;;
    h | --help )
        usage
        exit;;
    * )
        usage
        exit 1
    esac
    shift
done
if [[ $ifsh ]];
then
    sourceHost
fi
if [[ $ifsi ]];
then
    sourceIp
fi
if [[ $ifsc ]];
then
    statusCode
fi

if [[ $ifu ]];
then
    usualUrl
fi

if [[ $ifuh ]];
then
    if [[ $url != "" ]];
    then
        urlHost $url
    fi
fi

if [[ $iffs ]];
then
    4xxURL
fi 

