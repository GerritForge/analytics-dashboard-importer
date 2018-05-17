#!/bin/sh
/wait-for-elasticsearch

echo "** Creating Gerrit index"
curl -XPUT "http://elasticsearch:9200/gerrit?pretty" -H 'Content-Type: application/json'

echo "** Importing Kibana setting from: "
for file in `ls -v /*.kibana.data.json`;
    do  echo "--> $file";
        /usr/lib/node_modules/elasticdump/bin/elasticdump \
        --output=http://elasticsearch:9200/.kibana \
        --input=$file \
        --type=data \
        --headers '{"Content-Type": "application/json"}';
done;

echo "** Importing Elasticsearch mapping from: "
for file in `ls -v /*.es.mapping.json`;
    do  echo "--> $file";
        /usr/lib/node_modules/elasticdump/bin/elasticdump \
        --output=http://elasticsearch:9200/gerrit \
        --input=$file \
        --type=mapping \
        --headers '{"Content-Type": "application/json"}';
done;
