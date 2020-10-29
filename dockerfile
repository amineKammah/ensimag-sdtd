#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ARG base_img

FROM $base_img
WORKDIR /

# Reset to root to run installation tasks
USER 0

RUN mkdir ${SPARK_HOME}/python
# TODO: Investigate running both pip and pip3 via virtualenvs
RUN apt-get update && \
#     apt install -y python python-pip && \
    apt install -y python3 python3-pip
RUN mkdir -p /usr/share/man/man1 && apt install -y openjdk-11-jre

RUN apt install -y tesseract-ocr libtesseract-dev git && \
    # We remove ensurepip since it adds no functionality since pip is
    # installed on the image and it just takes up 1.6MB on the image
#     rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install pytesseract Pillow pyspark && \
    # You may install with python3 packages by using pip3.6
    # Removed the .cache to save space
    rm -r /root/.cache && rm -rf /var/cache/apt/*
RUN apt install sudo && sudo ln -s /usr/bin/python3 /usr/local/bin/python

RUN git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git /ensimag-sdtd

COPY python/pyspark ${SPARK_HOME}/python/pyspark
COPY python/lib ${SPARK_HOME}/python/lib

WORKDIR /opt/spark/work-dir
# ENTRYPOINT [ "/bin/bash" ]

# Specify the User that the actual main process will run as
# ARG spark_uid=185
# USER ${spark_uid}