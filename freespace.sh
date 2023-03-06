#! /bin/bash

while getopts "rt:" opt;
do
        case "$opt" in
                r)
                        r=1
                ;;
                t)
                        time=${OPTARG}
                ;;
        esac
done

shift $((OPTIND-1))

if [ -z $time ];
then
        time=48
fi

fr_dir() {
        if [[ $r -eq 1 ]];
        then
                dir_args=$(find $1 -type f)
        else
                dir_args=$(find $1 -maxdepth 1 -type f)
        fi
        frsp $dir_args
}

chk_name() {
        echo "chk_name"
        if [ ${arg:0:3} != "fc-" ];
        then
                echo $arg
                touch $arg
                mv $arg "fc-$arg"
        else
                return 1
        fi
}

chk_time() {
        if [ "$(date -d "$t hour ago")" > "$(date -r $arg)" ];
        then
                rm $arg
        fi
}

chk_file() {

        file=${1##*/}
        dir=${1%/*}
        if [[ "$1" == *'/'* ]] ;
        then
                if [[ "$dir" == *'/'* ]];
                then
                        cd ${dir##*/}
                else
                        cd $dir
                fi
        fi
        zip -m "fc-$file.zip" $file
}

frsp() {
        for arg in "$@";
        do
                ftyp=$(file $arg | awk '{print $2}')
                case $ftyp in
                        "directory")
                                fr_dir $arg
                                ;;
                        "Zip" | "gzip" | "bzip2")
                                if ! chk_name $arg ; then chk_time; fi
                                ;;
                        *)
                                chk_file $arg
                                ;;
                esac
        done
}
frsp $@
