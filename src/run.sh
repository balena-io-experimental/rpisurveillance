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

log "Start app..."
/app/v4l2rtspserver/v4l2rtspserver -F 30 -W 1280 -H 720 -P 8555 /dev/video0
