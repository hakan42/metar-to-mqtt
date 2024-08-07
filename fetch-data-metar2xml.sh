#!/bin/sh -x

STATIONS=""

HERE=$(dirname $(realpath $0))

. ${HERE}/stations.sh

TARGET=${HERE}/target/metar2xml

rm -rf ${TARGET}
mkdir -p ${TARGET}

for s in ${STATIONS}
do
    mkdir -p ${TARGET}/${s}
    RAW=${TARGET}/${s}/${s}-m2x-FULL.xml

    curl \
        --silent \
        --output ${RAW} \
	"https://metaf2xml.sourceforge.io/cgi-bin/metaf.pl?lang=en&format=xml&mode=latest&hours=24&unit_temp=C&type_metaf=icao&msg_metaf="${s}"&type_synop=synop&msg_synop=&type_buoy=buoy&msg_buoy=&type_amdar=amdar&msg_amdar="

    xmllint \
	--xpath '(//info)[1]' ${RAW} \
	> ${TARGET}/${s}/${s}-info.xml

    xmllint --xpath '//info/text()' ${TARGET}/${s}/${s}-info.xml \
	> ${TARGET}/${s}/${s}-name.txt
    
    #
    # Now publish it via MQTT
    #
    # TODO would be nice to a check and publish-if-not-changed
    #
    mosquitto_pub \
     	--retain \
	--topic metarmap/${s}/name \
	--file ${TARGET}/${s}/${s}-name.txt

done
