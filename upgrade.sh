#! /bin/bash

# For test
if [[ -z $BACKEND_VERSION ]]; then
    BACKEND_VERSION="0.15.4"
fi
if [[ -z $AUTO_UPGRADE ]]; then
    AUTO_UPGRADE="yes"
fi

LOCAL=`pwd`
UPDATE_URL=https://raw.githubusercontent.com/smartcatboy/deploy/main/VERSION
VERSION_INFO=`wget -qO - $UPDATE_URL | grep -v ^\# | grep -P "^$BACKEND_VERSION "`
#echo $VERSION_INFO
LATEST_VERSION=`echo $VERSION_INFO | awk '{print $2}'`
#echo $LATEST_VERSION
if [[ -z $LATEST_VERSION ]]; then
    echo "No need to upgrade."
    exit 0
fi
LATEST_ID=`echo $VERSION_INFO | awk '{print $3}'`
if [[ $LATEST_ID == "#" ]]; then
    rm -rf /tmp/compose
    LATEST_ID=`git clone -q https://github.com/smartcatboy/compose.git /tmp/compose && \
    cd /tmp/compose && git checkout -q tags/$LATEST_VERSION && \
    git ls-files -s backend | grep -w backend$ | awk '{print $2}'`
fi
LATEST_ID=${LATEST_ID:0:7}
#echo $LATEST_ID
FORCE=`echo $VERSION_INFO | awk '{print $4}'`
if [[ $FORCE == "N" && $AUTO_UPGRADE != "yes" ]]; then
    echo "No need to upgrade."
    exit 0
fi

cd $LOCAL
LOCAL_ID=`git rev-parse HEAD`
LOCAL_ID=${LOCAL_ID:0:7}
#echo $LOCAL_ID
if [[ -z $LATEST_ID || -z $LOCAL_ID || $LATEST_ID == $LOCAL_ID ]]; then
    echo "No need to upgrade."
    exit 0
fi
echo "Start upgrading from ($LOCAL_ID) to $LATEST_VERSION ($LATEST_ID) ..."
git fetch && git reset --hard $LATEST_ID
if [ $? -eq 0 ]; then
    echo "Upgrade successfully!"
    exit 0
else
    echo "Upgrade failed!"
    exit 1
fi
