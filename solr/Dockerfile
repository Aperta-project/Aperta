FROM    makuk66/docker-oracle-java7

ENV SOLR_VERSION 4.10.2
ENV SOLR solr-$SOLR_VERSION
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y install lsof curl procps git && \
  mkdir -p /opt && \
  wget -nv --output-document=/opt/$SOLR.tgz http://www.mirrorservice.org/sites/ftp.apache.org/lucene/solr/$SOLR_VERSION/$SOLR.tgz && \
  tar -C /opt --extract --file /opt/$SOLR.tgz && \
  rm /opt/$SOLR.tgz && \
  ln -s /opt/$SOLR /opt/solr

EXPOSE 8983

# need to do this because we can't access ../
RUN      git clone https://github.com/tahi-project/tahi.git /tmp/tahi
RUN      mkdir -p /opt/solr/example/solr/tahi/conf/
RUN      rsync -a /tmp/tahi/solr/conf/ /opt/solr/example/solr/tahi/conf/

CMD ["/bin/bash", "-c", "/opt/solr/bin/solr -f"]
