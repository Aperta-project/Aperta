#!/bin/sh

RAILS_ROOT_DIR=$(cd $(dirname $0)/..; pwd)
RAILS_TEMP_DIR="${RAILS_ROOT_DIR}/tmp"
RAILS_LOG_DIR="${RAILS_ROOT_DIR}/log"

CAS_VERSION="3.5.2.1"
CAS_DIRECTORY="cas-server-${CAS_VERSION}"
CAS_TARBALL_FILENAME="${CAS_DIRECTORY}-release.tar.gz"
CAS_DOWNLOAD_URL="http://downloads.jasig.org/cas/${CAS_TARBALL_FILENAME}"

echo "Installing Maven & Tomcat"
brew install maven
brew install tomcat

TOMCAT_CATALINA_HOME=$(catalina --help | grep CATALINA_HOME | cut -d : -f 2 | tr -d ' ')

echo "Downloading CAS tarball"
curl -o ${RAILS_TEMP_DIR}/${CAS_TARBALL_FILENAME} ${CAS_DOWNLOAD_URL}

echo "Unpacking CAS tarball"
(cd ${RAILS_TEMP_DIR} && tar zxf ${CAS_TARBALL_FILENAME})

echo "Configuring CAS"
(cd ${RAILS_TEMP_DIR}/${CAS_DIRECTORY}/cas-server-webapp/src/main/webapp/WEB-INF/classes/ && \
  cp log4j.xml log4j.xml.orig && \
  sed -e "s,param name=\"File\" value=\"cas.log\",param name=\"File\" value=\"${RAILS_LOG_DIR}/cas/cas.log\"," \
      -e "s,param name=\"File\" value=\"perfStats.log\",param name=\"File\" value=\"${RAILS_LOG_DIR}/cas/perfStats.log\"," \
      -i '' log4j.xml)

echo "Building WAR file"
(cd ${RAILS_TEMP_DIR}/${CAS_DIRECTORY}/cas-server-webapp/ && mvn package install)

echo "Copying CAS WAR file to Tomcat's webapps directory"
(cd ${RAILS_TEMP_DIR}/${CAS_DIRECTORY}/cas-server-webapp/ && cp target/cas.war ${TOMCAT_CATALINA_HOME}/webapps/)

echo "Now execute 'catalina run' to start the Tomcat server"
echo "CAS will be available at http://localhost:8080/cas-server-webapp/login"

