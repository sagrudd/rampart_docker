#!/bin/bash

USER_ID=${LOCAL_USER_ID:-9001}
CLIENT_PORT=${CLIENT:-3000}
SERVER_PORT=${SERVER:-3001}

echo "starting with UID : $USER_ID"

echo "creating RAMPART user"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m rampart

echo "raising RAMPART on $CLIENT_PORT $SERVER_PORT"

echo "cd /data && /opt/rampart/rampart.js --verbose --clearAnnotated --protocol /opt/artic-ncov2019/rampart/ --basecalledPath /data/pass --ports $CLIENT_PORT ${SERVER_PORT}"
gosu rampart bash -c "cd /data && if ! [ -d pass ] && [ -d fastq_pass ]; then ln -s fastq_pass pass; fi && /opt/rampart/rampart.js --verbose --clearAnnotated --protocol /opt/artic-ncov2019/rampart/ --basecalledPath /data/pass --ports ${CLIENT_PORT} ${SERVER_PORT}"

