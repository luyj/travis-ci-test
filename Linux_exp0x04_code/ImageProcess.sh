#!/bin/bash
function usage
{
        cat << OUTPUT
    usage: $0 [-f filename][-cq percent][-cs percent][-ctj][-tw text][-sr suffixrename][-pr prefixrename][-bp directory][-h]

    optional arguments:
    -f,  --file <filename>               					The filename
    -cq, --compress_q <percent> [newfilename]            	Image compression,quality is interget
    -cs, --compress_s <percent> [newfilename]        		Compresse image resolution,percent is interget
    -ctj, --changetojpg                  					Change image format to jpg(Keep Original Image)
    -tw, --textwatermark <text>          					Add text watermark
    -sr, --suffixname <suffix>   							Add suffixname(jpeg,jpg,png,svg)
    -pr, --prefixname  <prefixname>  						Add prefixname(jpeg,jpg,png,svg)
    -bp, --batchprocessing <directory>   					Batch processing of image
    -h,  --help
OUTPUT

}

function mCat
{
	cat<<OUTPUT
	Command 'convert' not found, but can be installed with:
	sudo apt install imagemagick-6.q16
	sudo apt install graphicsmagick-imagemagick-compat
	sudo apt install imagemagick-6.q16hdri

OUTPUT
}
function dealFileName
{
    fullfile="$1"
    #获取路径
    filepath=$(dirname -- "$fullfile")
    #获取文件名
    filename=$(basename -- "$fullfile")
    #获取文件拓展名
    if [[ "$filename" = *.* ]];
    then
	extension="${filename##*.}"
    else
	extension=''
    fi
    #获取文件名称
    filename="${filename%.*}"
    tmp=("$filepath" "$filename" "$extension")
    echo "${tmp[*]}"

}

function imageCompression
{
    fname="$1"
    fullfile=($(dealFileName "$fname"))
    qual="$2"
    if [[ ! -z "$3" ]];
    then
	tname="$3"
    else
	tname="${fullfile[0]}/cq_${fullfile[1]}.jpg"
    fi
    if hash convert 2>/dev/null;
    then
	convert "$fname" -quality "$qual" "$tname"
	echo "$tname compress finished!"
    else
		mcat
    fi
}

function imageResize
{
    fname="$1"
    precent=$(("$2"))
    fullfile=($(dealFileName "$fname"))
    if [[ ! -z "$3" ]];
    then
	tname="$3"
    else
	tname="${fullfile[0]}/cs_${fullfile[1]}.jpg"
    fi
    width=$(identify -format "%w" "$fname")
    heigth=$(identify -format "%h" "$fname")
    r_width=$(("$width" * "$precent" / 100))
    r_heigth=$(("$heigth" * "$precent" /100))
	if hash convert 2>/dev/null;
	then
    	convert "$fname" -resize "$r_width"x"$r_heigth" "$tname"
    	echo "$tname resize finished!"
	else
		mcat
	fi

}

function imageWatermark
{
    fname="$1"
    watermark="$2"
    fullfile=($(dealFileName "$fname"))
    if [[ ! -z "$3" ]];
    then
	tname="$3"
    else
	tname="${fullfile[0]}/wt_${fullfile[1]}.jpg"
    fi
    fullfile=($(dealFileName "$fname"))
    width=$(identify -format "%w" "$fname")
	if hash convert 2>/dev/null;
	then
		convert "$fname"  -gravity south -size "$width"x30 -background '#0008' -fill white -draw 'text 0,0 '\'"$watermark"\' "$tname"
		echo "$fname add watermark finished"
	else
		mcat
	fi
} 
function addPrefixToName
{
    fname="$1"
    prefix="$2"
    fullfile=($(dealFileName "$fname"))
    tname="$prefix${fullfile[1]}.${fullfile[2]}"
    tpath="${fullfile[0]}/$tname"
    mv "$fname" "$tpath"
    echo "$tpath add prefix finished"

}
function addSuffixToName
{
    fname="$1"
    suffix="$2"
    fullfile=($(dealFileName "$fname"))
    tname="${fullfile[1]}$suffix.${fullfile[2]}"
    tpath="${fullfile[0]}/$tname"
    mv "$fname" "$tpath"
    echo "$tpath add suffix finished"
}

function convertImgJpg
{
    fname="$1"
	if hash convert 2>/dev/null;
	then
    convert "$fname" "${fname%.*}.jpg"
    echo "$fname change to jpg finished"
	else
		mcat
	fi
}

function batchProcess
{
	dir=$1
	slen=${#dir}
	dic=('jpeg' 'jpg' 'png' 'svg')
	last=$(("$slen"-1))
	if [[ ${dir:last:1} != '/' ]]
	then
		dir="$dir/"
	fi
	for file in "$dir"*
	do
		if [[ -f $file ]];
		then
			format="${file##*.}"
			for form in ${dic[@]}
			do 
				if [[ $form == $format ]];
				then
					if [[ 1 == "$ifcq" ]];
					then
					imageCompression "$fname" "$quality" "$tname"
					fi
					if [[ 1 == "$ifcs" ]];
					then
					imageResize "$fname" "$precent" "$tname"
					fi
					if [[ 1 == "$ifctj" ]];
					then
					convertImgJpg "$fname"
					fi
					if [[ 1 == "$iftw" ]];
					then
					imageWatermark "$fname" "$watermark"
					fi
					if [[ 1 == "$ifpr" ]];
					then
					addPrefixToName "$fname" "$prefix"
					fi
					if [[ 1 == "$ifsr" ]];
					then
					addSuffixToName "$fname" "$suffix"
					fi
					break
				fi
			done
		fi
	done
}	

if [[ "$0" && "$1" == "" ]];
then
	usage
fi
while [ "$1" != "" ];do
    case "$1" in
	-f | --file )
	    shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		fname="$1"
	    else
		echo "Missing parameter [-f,  --file <filename>]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		echo "Excess parameters [-f, --file <filename>]"
		exit
	    fi
	    ;;
	-cq | --compress_q )
	    ifcq=1
	    shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		quality="$1"
	    else
		echo "Missing parameter [-cq,  --compress_q <precent> [newfilename]]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		shift
		tname="$1"
		if [[ "$2" != -* && "$2" != "" ]];
		then
		    echo "Excess parameter [-cq, --compress_q <precent> [newfilename]]"
		    exit
		fi
	    fi
	    ;;
	-cs | --compress_s )
	    ifcs=1
	    shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		precent="$1"
	    else
		echo "Missing parameter [-cs, --compress_s <percent> [newfilename]]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		shift
		tname="$1"
		if [[ "$2" != -* && "$2" != "" ]];
		then
		    echo "Excess parameter [-cs, --compress_s <percent> [newfilename]]"
		    exit
		fi
	    fi
	    ;;
	-ctj | --changetojpg )
	    ifctj=1
	    shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		echo "Excess parameters [-ctj, --changetojpg]"
		exit
	    fi
	    ;;
	-tw | --textwatermark )
	    iftw=1
		shift
		echo "$1"
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		watermark="$1"
	    else
		echo "Missing parameter [-tw, --textwatermark <text>]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		echo "Excess parameters [-tw, --textwatermark <text>]"
		exit
	    fi
	    ;;
	-sr | --suffixname )
	    ifsr=1
		shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		suffix="$1"
	    else
		echo "Missing parameter [-sr, --suffixname <suffix>]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		echo "Excess parameters [-sr, --suffixname <suffix>]"
		exit
	    fi
	    ;;
	-pr | --prefixname )
	    ifpr=1
		shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		prefix="$1"
	    else
		echo "Missing parameter [-pr, --prefixname <prefix>]"
		exit
	    fi
	    if [[ "$2" != -* && "$2" != "" ]];
	    then
		echo "Excess parameter [-pr, --prefixname <prefix>]"
		exit
	    fi
	    ;;
	-bp | --batchprocess )
	    ifbp=1
		shift
	    if [[ "$1" != -* && "$1" != "" ]];
	    then
		dir="$1"
	    else
		echo "Missing parameter [-bp, --batchprocessing <directory>]"
		exit
	    fi
	    if [[ "$2" != *- && "$2" != "" ]];
	    then
		echo "Excess Parameter [-bp, --batchprocessing <directory>]"
		exit
	    fi
	    ;;
	-h | --help )
	    usage
	    exit
	    ;;
	* )
		usage
	    exit 1
    esac
    shift
done

if [[ 1 == "$ifbp" ]];
then
    batchProcess "$dir" 
else
    if [[ 1 == "$ifcq" ]];
    then
	imageCompression "$fname" "$quality" "$tname"
    fi
    if [[ 1 == "$ifcs" ]];
    then
	imageResize "$fname" "$precent" "$tname"
    fi
    if [[ 1 == "$ifctj" ]];
    then
	convertImgJpg "$fname"
    fi
    if [[ 1 == "$iftw" ]];
    then
	imageWatermark "$fname" "$watermark"
    fi
    if [[ 1 == "$ifpr" ]];
    then
	addPrefixToName "$fname" "$prefix"
    fi
    if [[ 1 == "$ifsr" ]];
    then
	addSuffixToName "$fname" "$suffix"
    fi
fi




