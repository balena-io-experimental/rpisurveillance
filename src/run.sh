#!/bin/bash

set -e

V4L2_KMOD="bcm2835-v4l2"

# Configurable parameters
CAMERA_ROTATE=${CAMERA_ROTATE:-0}
RTSP_PORT=${RTSP_PORT:-8555}
FRAMERATE=${FRAMERATE:-30}
V4L2_W=${V4L2_W:-1920}
V4L2_H=${V4L2_H:-1080}

# Get the absolute script location
pushd `dirname $0` > /dev/null 2>&1
SCRIPTPATH=`pwd`
popd > /dev/null 2>&1

. $SCRIPTPATH/helpers.sh

if modprobe -n --first-time $V4L2_KMOD &> /dev/null; then
    log "Load kernel module $V4L2_KMOD..."
    modprobe $V4L2_KMOD
else
    log "Kernel module $V4L2_KMOD already loaded..."
fi

log "Rotate to $CAMERA_ROTATE..."
v4l2-ctl --set-ctrl rotate="$CAMERA_ROTATE"

# Did the last run left hanging sockets?
if [ -z "$TIME_WAIT_INTERVAL" ]; then
    if [ -f "/proc/sys/net/ipv4/tcp_fin_timeout" ]; then
        TIME_WAIT_INTERVAL=$(cat /proc/sys/net/ipv4/tcp_fin_timeout)
    else
        TIME_WAIT_INTERVAL=60
    fi
fi
STARTTIME=$(date +%s)
ENDTIME=$(date +%s)
until [ -z "$(netstat | grep $RTSP_PORT | grep TIME_WAIT)" ]; do
    if [ $(($ENDTIME - $STARTTIME)) -le $TIME_WAIT_INTERVAL ]; then
        log WARN "Socket is in TIME_WAIT... Waiting..."
        sleep 5
        ENDTIME=$(date +%s)
    else
        log ERROR "Socket didn't get out of TIME_WAIT even after $TIME_WAIT_INTERVAL seconds. Bailing out."
        exit 1
    fi
done

log "Start RTSP server..."
/app/v4l2rtspserver/v4l2rtspserver -F $FRAMERATE -W $V4L2_W -H $V4L2_H -P $RTSP_PORT /dev/video0
