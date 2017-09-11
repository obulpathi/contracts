FROM ubuntu:17.04

MAINTAINER Obul <obulpathi@merkletree.vc>

# force bash always
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install dependencies
RUN apt-get update && apt-get install -y git libssl-dev libffi-dev python3.6 python3.6-dev python3-pip
RUN pip3 install virtualenv

# copy the code
COPY . /code

# create virtual environment
RUN virtualenv --python=/usr/bin/python3.6 --no-site-packages ~/.virtualenvs/viper
RUN source ~/.virtualenvs/viper/bin/activate

# download and install Viper
WORKDIR /code
RUN git clone https://github.com/ethereum/viper.git
WORKDIR /code/viper
RUN python3 setup.py install
