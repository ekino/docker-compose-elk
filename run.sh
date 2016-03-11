#!/bin/bash

sudo rm -rf elasticsearch/data/*

pushd logstash/etc
curl -sSL https://raw.githubusercontent.com/frntn/x509-san/master/gencert.sh | CRT_FILENAME='logstash' CRT_CN='ELK Demo' CRT_SAN="DNS:elasticsearch,IP:127.0.0.1" bash
popd

docker-compose kill
docker-compose rm -f

docker-compose up -d

wait=15
echo "Waiting ${wait}s for apps to startup"
sleep $wait

echo "Creating logstash index in elasticsearch"
{
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"title":"logstash-*","timeFieldName":"@timestamp"}' 'http://localhost:5601/elasticsearch/.kibana/index-pattern/logstash-*'
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' 'http://localhost:5601/elasticsearch/.kibana/_refresh'
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"query":{"match_all":{}},"size":10000}' 'http://localhost:5601/elasticsearch/.kibana/index-pattern/_search?fields='
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"docs":[{"_index":".kibana","_type":"index-pattern","_id":"logstash-*"}]}' 'http://localhost:5601/elasticsearch/_mget?timeout=0&ignore_unavailable=true&preference=1457700774788'
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"doc":{"buildNum":9693,"defaultIndex":"logstash-*"}}' 'http://localhost:5601/elasticsearch/.kibana/config/4.4.1/_update'
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"title":"logstash-*","timeFieldName":"@timestamp","fields":"[{\"name\":\"_index\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":false,\"analyzed\":false,\"doc_values\":false},{\"name\":\"host.raw\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"message\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":true,\"doc_values\":false},{\"name\":\"geoip.ip\",\"type\":\"ip\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"path\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":true,\"doc_values\":false},{\"name\":\"@timestamp\",\"type\":\"date\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"geoip.location\",\"type\":\"geo_point\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"@version\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"host\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":true,\"doc_values\":false},{\"name\":\"geoip.latitude\",\"type\":\"number\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"_source\",\"type\":\"_source\",\"count\":0,\"scripted\":false,\"indexed\":false,\"analyzed\":false,\"doc_values\":false},{\"name\":\"geoip.longitude\",\"type\":\"number\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"path.raw\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":true,\"analyzed\":false,\"doc_values\":true},{\"name\":\"_id\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":false,\"analyzed\":false,\"doc_values\":false},{\"name\":\"_type\",\"type\":\"string\",\"count\":0,\"scripted\":false,\"indexed\":false,\"analyzed\":false,\"doc_values\":false},{\"name\":\"_score\",\"type\":\"number\",\"count\":0,\"scripted\":false,\"indexed\":false,\"analyzed\":false,\"doc_values\":false}]"}' 'http://localhost:5601/elasticsearch/.kibana/index-pattern/logstash-*'
curl -sSL -X POST -H 'kbn-version: 4.4.1' -H 'Content-Type: application/json;charset=UTF-8' -d '{"docs":[{"_index":".kibana","_type":"config","_id":"4.4.1"}]}' 'http://localhost:5601/elasticsearch/_mget?timeout=0&ignore_unavailable=true&preference=1457700774788'
} | jq '.' >/dev/null

echo "
Help:
=====

  Dashboards:
  -----------
    Elasticsearch -> http://localhost:9200
    Kibana        -> http://localhost:5601

  Logs:
  -----
    docker-compose logs elasticsearch
    docker-compose logs logstash
    docker-compose logs kibana
"
