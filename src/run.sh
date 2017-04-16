#!/bin/bash

set -e

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

. $SCRIPTPATH/helpers.sh

log "Load kernel module..."
modprobe bcm2835-v4l2

if [ -n "$CAMERA_ROTATE" ]; then
    log "Rotate to $CAMERA_ROTATE..."
    v4l2-ctl --set-ctrl rotate="$CAMERA_ROTATE"
fi

# Did the last run left hanging sockets?
if [ -f "/proc/sys/net/ipv4/tcp_fin_timeout" ]; then
    TIME_WAIT_INTERVAL=$(cat /proc/sys/net/ipv4/tcp_fin_timeout)
else
    TIME_WAIT_INTERVAL=60
fi
STARTTIME=$(date +%s)
ENDTIME=$(date +%s)
until [ -z "$(netstat | grep 8555 | grep TIME_WAIT)" ]; do
    if [ $(($ENDTIME - $STARTTIME)) -le $TIME_WAIT_INTERVAL ]; then
        log WARN "Socket is in TIME_WAIT... Waiting..."
        sleep 5
        ENDTIME=$(date +%s)
    else
        log ERROR "Socket didn't get out of TIME_WAIT even after $TIME_WAIT_INTERVAL seconds. Bailing out."
        exit 1
    fi
done

log "Start app..."
/app/v4l2rtspserver/v4l2rtspserver -F 30 -W 1920 -H 1080 -P 8555 /dev/video0
