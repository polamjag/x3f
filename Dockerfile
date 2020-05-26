FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y software-properties-common python-virtualenv python-dev python-pip
RUN apt-get install -y clang build-essential mingw-w64 zlib1g-dev git cmake zip ntp
RUN apt-get install -y flex libelf-dev libc6-dev libc++-dev libc++abi-dev libc6-dev-i386 binutils-dev libdwarf-dev
RUN pip install -U setuptools
RUN pip install virtualenv

COPY . /x3f/
RUN rm -rf /x3f/deps

CMD [ "/bin/bash" ]
