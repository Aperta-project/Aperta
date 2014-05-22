#!/usr/bin/env ruby

require 'fileutils'
require 'nokogiri'

RAILS_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
RAILS_TEMP_DIR = "#{RAILS_ROOT_DIR}/tmp"
RAILS_LOG_DIR = "#{RAILS_ROOT_DIR}/log"

CAS_VERSION = "3.5.2.1"
CAS_DIRECTORY = "cas-server-#{CAS_VERSION}"
CAS_TARBALL_FILENAME = "#{CAS_DIRECTORY}-release.tar.gz"
CAS_DOWNLOAD_URL = "http://downloads.jasig.org/cas/#{CAS_TARBALL_FILENAME}"

def brew_install(package)
  system("brew install #{package}") if system("brew info #{package} | grep 'Not installed' > /dev/null")
end

puts "Installing Maven & Tomcat"
brew_install 'maven'
brew_install 'tomcat'

TOMCAT_CATALINA_HOME = `catalina --help | grep CATALINA_HOME | cut -d : -f 2 | tr -d ' '`.strip

puts "Downloading CAS tarball"
system "curl -o #{RAILS_TEMP_DIR}/#{CAS_TARBALL_FILENAME} #{CAS_DOWNLOAD_URL}"

puts "Unpacking CAS tarball"
FileUtils.cd("#{RAILS_TEMP_DIR}", verbose: true) { system "tar zxf #{CAS_TARBALL_FILENAME}" }

puts "Configuring CAS"
FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/src/main/webapp/WEB-INF/classes/", verbose: true) do
  FileUtils.cp('log4j.xml', 'log4j.xml.orig') unless File.exist?('log4j.xml.orig')
  text = File.read('log4j.xml.orig')
    .gsub('param name="File" value="cas.log"', "param name=\"File\" value=\"#{RAILS_LOG_DIR}/cas/cas.log\"")
    .gsub('param name="File" value="perfStats.log"', "param name=\"File\" value=\"#{RAILS_LOG_DIR}/cas/perfStats.log\"")
  File.open('log4j.xml', 'w') { |f| f.write text }
end

FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/", verbose: true) do
  FileUtils.cp('pom.xml', 'pom.xml.orig') unless File.exist?('pom.xml.orig')
  text = File.read('pom.xml.orig')
    .gsub('  </dependencies>', '
    <dependency>
      <groupId>org.jasig.cas</groupId>
      <artifactId>cas-server-support-oauth</artifactId>
      <version>${project.version}</version>
      <scope>runtime</scope>
    </dependency>
  </dependencies>')
  File.open('pom.xml', 'w') { |f| f.write text }
end

FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/src/main/webapp/WEB-INF/", verbose: true) do
  FileUtils.cp('web.xml', 'web.xml.orig') unless File.exist?('web.xml.orig')
  text = File.read('web.xml.orig')
    .gsub('  <session-config>', '  <servlet-mapping>
    <servlet-name>cas</servlet-name>
    <url-pattern>/oauth2.0/*</url-pattern>
  </servlet-mapping>

  <session-config>')
  File.open('web.xml', 'w') { |f| f.write text }
end

FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/src/main/webapp/WEB-INF/", verbose: true) do
  FileUtils.cp('cas-servlet.xml', 'cas-servlet.xml.orig') unless File.exist?('cas-servlet.xml.orig')
  text = File.read('cas-servlet.xml.orig')
    .gsub('</beans>', '
  <bean
    id="oauth20WrapperController"
    class="org.jasig.cas.support.oauth.web.OAuth20WrapperController"
    p:loginUrl="http://localhost:8080/cas/login"
    p:servicesManager-ref="servicesManager"
    p:ticketRegistry-ref="ticketRegistry"
    p:timeout="7200" />
</beans>')
    .gsub('      </props>', '        <prop key="/oauth2.0/*">oauth20WrapperController</prop>
      </props>')
  File.open('cas-servlet.xml', 'w') { |f| f.write text }
end

text = ''
FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/src/main/webapp/WEB-INF/", verbose: true) do
  FileUtils.cp('deployerConfigContext.xml', 'deployerConfigContext.xml.orig') unless File.exist?('deployerConfigContext.xml.orig')
  text = File.read('deployerConfigContext.xml.orig')
  xml = Nokogiri::XML(text)
  list = xml.at_css('bean[id=serviceRegistryDao] list')
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.bean(class: "org.jasig.cas.services.RegisteredServiceImpl") {
      xml.property(name: "id", value: "0")
      xml.property(name: "name", value: "HTTP")
      xml.property(name: "description", value: "oauth wrapper callback url")
      xml.property(name: "serviceId", value: "${server.prefix}/oauth2.0/callbackAuthorize")
    }
  end
  bean = builder.doc.root.to_xml
  list.add_child(bean)
  builder = Nokogiri::XML::Builder.new do |xml|
    xml.bean(class: "org.jasig.cas.services.RegisteredServiceImpl") {
      xml.property(name: "id", value: "1")
      xml.property(name: "name", value: "the_key_for_caswrapper1")
      xml.property(name: "description", value: "the_secret_for_caswrapper1")
      xml.property(name: "serviceId", value: "http://localhost:")
      xml.property(name: "theme", value: "Tahi")
    }
  end
  bean = builder.doc.root.to_xml
  list.add_child(bean)
  File.open('deployerConfigContext.xml', 'w') { |f| f.write xml }
end

FileUtils.cd("#{RAILS_TEMP_DIR}/#{CAS_DIRECTORY}/cas-server-webapp/", verbose: true) do
  puts "Building WAR file"
  system 'mvn package -DskipTests'
  puts "Copying CAS WAR fie to Tomcat's webapps directory"
  FileUtils.cp('target/cas.war', "#{TOMCAT_CATALINA_HOME}/webapps/")
end

puts "Now execute 'catalina run' to start the Tomcat server"
puts "CAS will be available at http://localhost:8080/cas/login"
