#!/bin/sh

. /ensimag-sdtd/data_processing/spark_cluster_setup/start_common.sh

/opt/spark/sbin/start-slave.sh spark://spark-master:7077