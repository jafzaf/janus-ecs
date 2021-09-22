#!/bin/bash
ACURL=`curl --silent ${ECS_CONTAINER_METADATA_URI_V4}/task`

echo "ACURL: ->${ACURL}<-"

PUBLICIP=`/bin/curl --silent http://checkip.amazonaws.com/`
#PRIVATEIP=`/bin/curl --silent http://169.254.169.254/latest/meta-data/local-ipv4`
PRIVATEIP=`echo $ACURL | jq -r '.Containers[] | .Networks[] | .IPv4Addresses[0]'`
AZONE=`echo $ACURL | jq -r '.AvailabilityZone'`
SERVERNAME=${HOSTNAME}

echo "ZONE: ->${AZONE}<- | PUBLICIP: ->${PUBLICIP}<- | PRIVATEIP: ->${PRIVATEIP}<- | SERVERNAME: ->${SERVERNAME}<-"

echo "curl --silent ${ECS_CONTAINER_METADATA_URI_V4}/task" > /etc/aws.env
echo ${ACURL} >> /etc/aws.env
echo ${AZONE} >> /etc/aws.env
echo ${PRIVATEIP} >> /etc/aws.env
echo ${SERVERNAME} >> /etc/aws.env
echo ${PUBLICIP} >> /etc/aws.env

cd /etc/janus
/bin/sed -e "s/PRIVATEIP/${PRIVATEIP}/g" /etc/janus/janus.plugin.sip.template > /etc/janus/janus.plugin.sip.jcfg
/bin/sed -e "s/PUBLICIP/${PUBLICIP}/g" /etc/janus/janus.template > /tmp/janus.jcfg0
/bin/sed -e "s/LOG_LVL/${LOG_LVL}/g" /tmp/janus.jcfg0 > /tmp/janus.jcfg1
/bin/sed -e "s/API_SECRET/${API_SECRET}/g" /tmp/janus.jcfg1 > /tmp/janus.jcfg2
/bin/sed -e "s/SERVERNAME/${SERVERNAME}/g" /tmp/janus.jcfg2 > /etc/janus/janus.jcfg
rm -fr /tmp/janus.*

exec "$@"
