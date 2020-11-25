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

FROM gradiant/spark:2.4.4-python
WORKDIR /

# Reset to root to run installation tasks
USER 0

RUN apt-get update

RUN apt install -y tesseract-ocr libtesseract-dev git vim && \
    # We remove ensurepip since it adds no functionality since pip is
    # installed on the image and it just takes up 1.6MB on the image
    pip3 install pytesseract Pillow kafka-python && \
    # You may install with python3 packages by using pip3.6
    # Removed the .cache to save space
    rm -r /root/.cache && rm -rf /var/cache/apt/*

RUN git clone https://amineKammah:95ec4f4005cfccdd0dfa2779a2f9c0861f104d94@github.com/amineKammah/ensimag-sdtd.git /ensimag-sdtd

RUN cd $SPARK_HOME && \
    wget https://repo1.maven.org/maven2/org/apache/spark/spark-streaming-kafka-0-8-assembly_2.11/2.4.4/spark-streaming-kafka-0-8-assembly_2.11-2.4.4.jar && \
    ln -s /usr/bin/python3 /usr/bin/python

RUN chmod +x /ensimag-sdtd/data_processing/spark_cluster_setup/*

WORKDIR /ensimag-sdtd/

RUN pip3 install flask

EXPOSE 5000
# ENTRYPOINT [ "/bin/bash" ]