#date=$1
#days=$2
#work_dir=$3

###### STEP 1:SOURCE FILES ######
s_file='./job_run_state.txt'
##### STEP 2: GET INPUT PARAMS ######
if [ ! $1 ];then
	date=`date -d "today -1 day" +%Y%m%d`
else
	date=$1
fi

if [ ! $2 ];then
	days=7
else
	days=$2
fi
last_d=`date -d "-1 day $date" +%Y%m%d`
if [ `cat $s_file | grep -E "job_${last_d} is failed" | wc -l` -gt 0 ];then
    date=$last_d
fi

if [ `cat $s_file | grep -E "job_${date} is running|job_${date} is done" | wc -l` -gt 0 ];then
    echo "job_${date} is running or done" > $s_file
    exit 0
fi

echo "job_${date} is running" > $s_file
src_dir=$(cd $(dirname ${0});pwd)
work_dir=$(dirname ${src_dir})

#####################
# @ run experiment all day.
echo "proc date : ${date}"
sh ./stat.sh $date $days
if [ $? -ne 0 ];then
    echo "job_${date} is failed" > $s_file
    echo "failed in runing stat" >> $s_file
    exit 0
fi
######################
echo "job_${date} is done" > $s_file
