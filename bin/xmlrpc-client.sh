#!/bin/bash
# authors
# - jiyin@redhat.com
# - bjoern.riemer@tu-berlin.de

#TEMP=`getopt -o vt:  -n 'example.bash' -- "$@"`
#if [ $? != 0 ] ; then echo "getopt fail, terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
#eval set -- "$TEMP"

Usage() {
    echo "usage: $0 -t <rpcServUrl> <method> [arg1 arg2 ...]"
    exit 1
}
simpleArg() {
    local arg="$1"
    local type=${arg%%:*} val=${arg#*:}
        echo -e "${indent}<param><value><$type>$val</$type></value></param>"
}
structArg() {
    local arg="$1"
        : parse wait complete ...
}

while getopts "t:v" opt ; do
    case "$opt" in
    t) servUrl=$OPTARG;shift 2;;
    v) verbose=--verbose;shift ;;

    \?) echo "Internal error!"; exit 1;;
    esac
done
[ -z "$servUrl" ] && Usage
[ $# -lt 1 ] && Usage

#<method> <arg1> <arg2> ... <argx>
generateRequestXml() {
    method=$1; shift
    echo '<?xml version="1.0"?>'
    echo "<methodCall>"
    echo "    <methodName>$method</methodName>"
    echo "    <params>"

    indent="    "
    for arg; do
        indent="${indent}    "
        case $arg in
        struct:*) structArg "$arg";;
        *) simpleArg "$arg";;
        esac
    done

    echo "    </params>"
    echo "</methodCall>"
}
rpcxml=rpc$$.xml
generateRequestXml "$@" > $rpcxml
[ "$verbose" = "--verbose" ] && cat "$rpcxml"

#curl -kf $verbose --data "@$rpcxml" "$servUrl" 
XMLRES=$(curl -kf $verbose --data "@$rpcxml" "$servUrl" 2>/dev/null)
RET=$?
#[ $RET = 0 ] && echo $XMLRES | xmllint --format -
[ $RET = 0 ] && echo $XMLRES 
\rm -f $rpcxml
exit $RET
