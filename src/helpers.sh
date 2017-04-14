#!/bin/sh

log() {
    # Address log levels
    case $1 in
        ERROR)
            loglevel="ERROR"
            shift
            ;;
        WARN)
            loglevel="WARN"
            shift
            ;;
        DEBUG)
            loglevel="DEBUG"
            shift
            ;;
        *)
            loglevel="INFO"
            ;;
    esac
    echo "[$loglevel] $@"
    if [ "$loglevel" == "ERROR" ] || [ "$loglevel" == "FAILED" ]; then
        exit 1
    fi
    if [ "$loglevel" == "PASSED" ]; then
        exit 0
    fi
}
