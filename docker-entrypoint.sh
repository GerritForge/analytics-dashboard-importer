#!/bin/sh

if [ -z "$DASHBOARDS" ];
then
  DASHBOARDS="base"
fi

/wait-for-elasticsearch

for dashboard in ${DASHBOARDS}; do
    echo "* * * Configure dashboard ${dashboard} * * *"

    echo "* * * * Elasticsearch index templates * * * *"
    for file in `ls -v /elasticsearch-config/${dashboard}/*.json`; do
        echo "--> $file";
        index_name=$(basename $file .json)
        curl -X PUT -v -H 'Content-Type: application/json' \
             -d @$file http://elasticsearch:9200/_template/$index_name

        echo "* * * * Creating $index_name index * * * *"
        curl -XPUT "http://elasticsearch:9200/$index_name?pretty" -H 'Content-Type: application/json'

    done;
done;

for dashboard in ${DASHBOARDS}; do
    echo "* * * * Kibana settings * * * *"
    for file in `ls -v /kibana-config/settings/${dashboard}/*.data.json`; do
        echo "--> SETTINGS: $file";
        # Allow this object to be saved and indexed to make sure it gets propagated
        # if another migration reindex is required https://www.elastic.co/guide/en/kibana/current/upgrade-migrations.html
        sleep 1;
        /usr/lib/node_modules/elasticdump/bin/elasticdump \
            --output=http://elasticsearch:9200/.kibana \
            --input=$file \
            --type=data \
            --headers '{"Content-Type": "application/json"}';
    done;

    echo "* * * * Kibana visualizations * * * *"
    for file in `ls -v /kibana-config/dashboards/${dashboard}/*.data.json`; do
        echo "--> VISUALIZATION: $file";
        # Allow this object to be saved and indexed to make sure it gets propagated
        # if another migration reindex is required https://www.elastic.co/guide/en/kibana/current/upgrade-migrations.html
        sleep 1;
        /usr/lib/node_modules/elasticdump/bin/elasticdump \
            --output=http://elasticsearch:9200/.kibana \
            --input=$file \
            --type=data \
            --headers '{"Content-Type": "application/json"}';
    done;
done;