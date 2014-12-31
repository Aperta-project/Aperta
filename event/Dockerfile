FROM     ubuntu:14.04

RUN      sudo apt-get -y update && sudo apt-get install -y golang git

EXPOSE   31337
ENV      GOPATH /root/go
RUN      go get github.com/tahi-project/golang-eventsource
CMD      ["/bin/bash", "-c", "/root/go/bin/golang-eventsource -p=31337 -t=token123"]
