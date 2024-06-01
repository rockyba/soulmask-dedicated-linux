#!/bin/bash

die() {
    echo "$0 script failed, hanging forever..."
    while [ 1 ]; do sleep 10;done
    # exit 1
}

id
if [ "$(id -u)" != "1000" ];then
    echo "script must run as steam"
    die
fi

steamcmd=${STEAM_HOME}/steamcmd/steamcmd.sh

ACTUAL_PORT=7777
if [ "${PORT}" != "" ];then
    ACTUAL_PORT=${PORT}
fi
ARGS="${ARGS} Level01_Main -server -SLIENT"

if [ "${SERVER_NAME}" != "" ];then
    ARGS="${ARGS} -SteamServerName=${SERVER_NAME}"
fi
if [ "${PLAYERS}" != "" ];then
    ARGS="${ARGS} -MaxPlayers=${PLAYERS}"
fi
ARGS="${ARGS} -backup=900 -saving=600 -log -UTF8Output"

if [ "${MULTIHOME}" != "" ];then
   ARGS="${ARGS} -MULTIHOME=${MULTIHOME}"
fi
ARGS="${ARGS} -Port=${ACTUAL_PORT} -QueryPort=27015"
ARGS="${ARGS} -online=Steam -forcepassthrough"

if [ "${SERVER_PASSWORD}" != "" ];then
    ARGS="${ARGS} -PSW=${SERVER_PASSWORD}"
fi

SoulmaskServerDir=/app/Soulmask_Dedicated_Server

mkdir -p ${SoulmaskServerDir}
DirPerm=$(stat -c "%u:%g:%a" ${SoulmaskServerDir})
if [ "${DirPerm}" != "1000:1000:755" ];then
    echo "${SoulmaskServerDir} has unexpected permission ${DirPerm} != 1000:1000:755"
    die
fi

set -x
$steamcmd +force_install_dir ${SoulmaskServerDir} +login anonymous +app_update ${APPID} validate +quit || die
set +x

SoulmaskServerExe="${SoulmaskServerDir}/WSServer.sh"

echo "starting server with: ${CMD}"
exec ${SoulmaskServerExe} ${ARGS}
