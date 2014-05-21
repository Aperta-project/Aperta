#!/usr/bin/env ruby

require 'fileutils'

RAILS_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
RAILS_TEMP_DIR = "#{RAILS_ROOT_DIR}/tmp"
CAS_VERSION = "3.5.2.1"
CAS_DIRECTORY = "cas-server-#{CAS_VERSION}"
TOMCAT_CATALINA_HOME = `catalina --help | grep CATALINA_HOME | cut -d : -f 2 | tr -d ' '`.strip


FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/", verbose: true) do
  puts "Building WAR file"
  system 'mvn package -DskipTests'
  puts "Copying CAS WAR fie to Tomcat's webapps directory"
  FileUtils.cp('target/cas.war', "#{TOMCAT_CATALINA_HOME}/webapps/")
end

puts "Now execute 'catalina run' to start the Tomcat server"
puts "CAS will be available at http://localhost:8080/cas/login"
