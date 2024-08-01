#!/bin/sh

STATIONS=""

HERE=$(dirname $(realpath $0))

. ${HERE}/stations.sh

TARGET=${HERE}/target/aviationweather

rm -rf ${TARGET}
mkdir -p ${TARGET}

for s in ${STATIONS}
do
    RAW=${TARGET}/${s}-aw-FULL.xml

    curl \
        --silent \
        --output ${RAW} \
        -H 'accept: */*' \
        "https://aviationweather.gov/api/data/dataserver?requestType=retrieve&dataSource=metars&hoursBeforeNow=1&format=xml&mostRecent=true&stationString="${s} \

    xmllint \
        --xpath '//flight_category/text()' ${RAW} \
        > ${TARGET}/${s}-category

    #
    # Now publish it via MQTT
    #
    mosquitto_pub \
        --retain \
        --topic metarmap/${s}/flight_category \
        --file ${TARGET}/${s}-category

done

ls -l ${TARGET}
