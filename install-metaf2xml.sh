#!/bin/sh -x

HERE=$(pwd -P)

TARGET=${HERE}/target

rm -rf ${TARGET}

git -c http.sslVerify=false clone https://git.code.sf.net/p/metaf2xml/code ${TARGET}/metaf2xml-code
cd ${TARGET}/metaf2xml-code
git checkout r2.8
git checkout unstable
METAF2XML=${HERE}/metaf2xml ./install.pl all

cd METAF2XML=${HERE}/metaf2xml
./metaf.pl --help     2> ${TARGET}/metaf.help
./metaf2xml.pl --help 2> ${TARGET}/metaf2xml.help
