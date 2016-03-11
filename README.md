# ekino/elk

All-in-one ELK stack build docker-compose from official elasticsearch/logstash/kibana images

## What's inside

* Elasticsearch: from official image, port 9200 published, bind mounted volume on the host
* Logstash: from official image, port 5000 published (for lumberjack input)
* Kibana: from official image, port 5601 published

## Usage

```bash
git clone https://github.com/ekino/docker-compose-elk.git
cd docker-compose-elk
./run.sh
```

It will :
1. Remove all elasticsearch data (previous runs)
2. Generate new certificate/key bundle (for lumberjack input => logstash-forwarder expected to send the log lines)
3. Kill and Remove previous containers(compose kill, compose rm)
4. Start new containers (compose up)
5. Wait 15s for applications to start
6. Create logstash index in elasticsearch (otherwise you'll have to wait the first log line for it to be created)
7. Echo kibana dashboard url

