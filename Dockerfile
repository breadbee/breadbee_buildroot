FROM debian:bullseye
RUN adduser --disabled-password --gecos "" builder
RUN apt-get -qq update && \
	apt-get -qq install build-essential \
			file \
			wget \
			cpio \
			python \
			python3 \
			unzip \
			rsync \
			bc \
			git \
			linux-headers-amd64
USER builder
