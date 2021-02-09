#!/bin/sh

hostname=`hostname -f`

interval=15
hour=6

APPLICATION_ROOT=$(cd $(dirname $0) && pwd)
LOG_DIR=${APPLICATION_ROOT}/log
LOG_FILEPATH=${LOG_DIR}/${hostname}_`date "+%Y%m%d_%H%M%S"`.log

mkdir -p ${LOG_DIR}
if [ ! -d ${LOG_DIR} ]; then
  exit 1
fi

touch ${LOG_FILEPATH}
if [ ! -f ${LOG_FILEPATH} ]; then
  exit 1
fi

rm ${LOG_FILEPATH}
if [ -f ${LOG_FILEPATH} ]; then
  exit 1
fi

LOOP_COUNT=$((hour*60*60/interval))
for ((i=0; i<${LOOP_COUNT}; i++)); do 
  date >> ${LOG_FILEPATH}
  free >> ${LOG_FILEPATH}
  w >> ${LOG_FILEPATH}
  echo '- - - - - - - - - - - - - - -' >> ${LOG_FILEPATH}

  sleep ${interval}
done

gzip -9 $LOG_FILEPATH
echo $LOG_FILEPATH
