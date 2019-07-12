FROM debian:buster
RUN adduser --disabled-password --gecos "" breadbee
RUN apt-get -qq update
RUN apt-get -qq install build-essential file wget cpio python unzip rsync bc git
USER breadbee
