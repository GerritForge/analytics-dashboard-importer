#!/bin/sh
/wait-for-elasticsearch

echo "** Creating Gerrit index"
curl -XPUT "http://elasticsearch:9200/gerrit?pretty" -H 'Content-Type: application/json'

echo "** Importing Kibana settings from: "
for file in `ls -v /*.kibana.data.json`;
    do  echo "--> $file";
        /usr/lib/node_modules/elasticdump/bin/elasticdump \
        --output=http://elasticsearch:9200/.kibana \
        --input=$file \
        --type=data \
        --headers '{"Content-Type": "application/json"}';
done;

echo "** Importing Elasticsearch templates from: "
for file in `ls -v /*.es.template.json`;
    do  echo "--> $file";
        curl -X PUT -v -H 'Content-Type: application/json' \
             -d @$file http://elasticsearch:9200/_template/$(basename $file .es.template.json)
done;
