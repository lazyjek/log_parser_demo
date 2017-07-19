#!/bin/bash

[[ $# != 2 ]] && echo "input param error" && exit 1;
log_date=$1
count=$2

source ./conf.dat
#获取输入路径函数
function get_path(){
    local log_date_t=$1
    local count=$2
    local path=$3
    datelist=$log_date_t
    iter=1
    while [[ $iter -ne $count ]];do
        date_t=`date -d "-$iter day $log_date_t" +%Y%m%d`
        datelist=${datelist},$date_t
        ((iter++));
    done;
    if [ `${HADOOP_BIN} fs -D hadoop.job.ugi=${HADOOP_USER},${HADOOP_PASSWD} -D mapred.job.queue.name=${HADOOP_QUEUE} -ls "$path/${log_date_t}/$done_file" | wc -l` -lt 2 ];then
        return 1
    fi
    echo "$path/{${datelist}}/part*"
    return 0
}

function update_dict(){
    local ftp_path=$1
    local dt_name=$2
    for back_date in {1..6}
    do
        local date=`date -d "-${back_date} days" +%Y%m%d`
        wget ${ftp_path}.${date} -O $dt_name
        if [ $? -eq 0 ];then
            return 0
        fi
    done
    if [ ! -s $dt_name ];then
        return 1
    fi
}

function parse_example() {
    local log_date=$1
    local count=$2
    local path=$3
    INPUT=`get_path $log_date $count $path`
    if [ $? -ne 0 ];then
        echo "upper log not ready" && exit 1
    fi

    OUTPUT=${example_path}/$log_date
    ${HADOOP_BIN} fs -D hadoop.job.ugi=${HADOOP_USER},${HADOOP_PASSWD} -D mapred.job.queue.name=${HADOOP_QUEUE} -rmr ${OUTPUT}
    ${HADOOP_BIN} streaming \
        -D stream.num.map.output.key.fields=1 \
        -D mapred.map.tasks=500 \
        -D mapred.reduce.tasks=100 \
        -D mapred.text.key.partitioner.options=-k1,1 \
        -D hadoop.job.ugi=${HADOOP_USER},${HADOOP_PASSWD} -D mapred.job.queue.name=${HADOOP_QUEUE} \
        -partitioner org.apache.hadoop.mapred.lib.KeyFieldBasedPartitioner \
        -input ${INPUT} \
        -output ${OUTPUT} \
        -mapper "python27/bin/python ./example.py" \
        -reducer "cat" \
        -file "example.py" \
        -file "dataParser.py" \
        -cacheArchive "${HDFS_PY}#python27" \
        -jobconf mapred.job.name="test" \
        -jobconf stream.memory.limit="8000" \
        -jobconf mapred.job.priority=${JOB_PRIORITY} \
        || return 1
    ${HADOOP_BIN} fs -D hadoop.job.ugi=${HADOOP_USER},${HADOOP_PASSWD} -D mapred.job.queue.name=${HADOOP_QUEUE} -touchz ${OUTPUT}/$donefile || return 1
}

## get alias dict from ftp.
#update_dict ${alias_ftp_path} ${dict_name}
#[[ $? != 0 ]] && echo "$log_date: updating dict error!" && exit 2

# example
parse_test $log_date $count $upper_path
[[ $? != 0 ]] && echo "$log_date: running example failed!" && exit 2
