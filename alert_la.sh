#!/bin/sh

hostname=`hostname -f`

interval=15
hour=6
# notification address
to=
# from address
from=

APPLICATION_ROOT=$(cd $(dirname $0) && pwd)
MAIL_DIR=${APPLICATION_ROOT}/mail
MAIL_FILEPATH=${MAIL_DIR}/${hostname}.txt

mkdir -p ${MAIL_DIR}
if [ ! -d ${MAIL_DIR} ]; then
  exit 1
fi

touch ${MAIL_FILEPATH}
if [ ! -f ${MAIL_FILEPATH} ]; then
  exit 1
fi

rm ${MAIL_FILEPATH}
if [ -f ${MAIL_FILEPATH} ]; then
  exit 1
fi

COUNT=0

LOOP_COUNT=$((hour*60*60/interval))
for ((i=0; i<${LOOP_COUNT}; i++)); do
  lv=`cat /proc/loadavg |awk {'print $1'}|cut -d "." -f1`
  echo "[$(date "+%Y-%m-%d %H:%M:%S")] (${i}) $(cat /proc/loadavg)"

  if [ ${lv} -ge 4 ]; then
    if [ ${lv} -ge 10 ]; then
      status=alert
    elif [ ${lv} -ge 8 ]; then
      status=notice
    elif [ ${lv} -ge 4 ]; then
      status=info
    fi

    echo "From: ${from}" > $MAIL_FILEPATH
    echo "To: ${to}" >> $MAIL_FILEPATH
    echo "Subject: [${hostname}][${status}] web server load average notification" >> $MAIL_FILEPATH
    echo '' >> $MAIL_FILEPATH
    w >>  $MAIL_FILEPATH
    echo '' >> $MAIL_FILEPATH
    free >>  $MAIL_FILEPATH
    echo '' >> $MAIL_FILEPATH
    ps -elf >>  $MAIL_FILEPATH

    ${APPLICATION_ROOT}/sendjpmail.sh $MAIL_FILEPATH
    COUNT=$((COUNT + 1))

    if [ ${COUNT} -ge 10 ]; then
      exit
    fi
  else
    COUNT=0
  fi
  sleep ${interval}
done
