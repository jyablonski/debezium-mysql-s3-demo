#!/usr/bin/env bash

curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/source-debezium-movies-00/config \
  -d '{
            "connector.class": "io.debezium.connector.mysql.MySqlConnector",
            "database.hostname": "mysql",
            "database.port": "3306",
            "database.user": "debezium",
            "database.password": "dbz",
            "database.server.id": "42",
            "database.server.name": "asgard",
            "table.whitelist": "demo.movies",
            "database.history.kafka.bootstrap.servers": "broker:29092",
            "database.history.kafka.topic": "dbhistory.demo" ,
            "decimal.handling.mode": "double",
            "include.schema.changes": "true",
            "transforms": "unwrap,dropTopicPrefix",
            "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
            "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
            "transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
            "transforms.dropTopicPrefix.replacement":"$1",
            "key.converter": "io.confluent.connect.avro.AvroConverter",
            "key.converter.schema.registry.url": "http://schema-registry:8081",
            "value.converter": "io.confluent.connect.avro.AvroConverter",
            "value.converter.schema.registry.url": "http://schema-registry:8081"
    }'

curl -i -X PUT -H "Content-Type:application/json" \
  http://localhost:8083/connectors/source-debezium-second-movies/config \
  -d '{
            "connector.class": "io.debezium.connector.mysql.MySqlConnector",
            "database.hostname": "mysql",
            "database.port": "3306",
            "database.user": "debezium",
            "database.password": "dbz",
            "database.server.id": "43",
            "database.server.name": "asgard_second_movies",
            "table.whitelist": "demo.second_movies",
            "database.history.kafka.bootstrap.servers": "broker:29092",
            "database.history.kafka.topic": "dbhistory.demo" ,
            "decimal.handling.mode": "double",
            "include.schema.changes": "true",
            "transforms": "unwrap,dropTopicPrefix",
            "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
            "transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
            "transforms.dropTopicPrefix.regex":"asgard_second_movies.demo.(.*)",
            "transforms.dropTopicPrefix.replacement":"$1",
            "key.converter": "io.confluent.connect.avro.AvroConverter",
            "key.converter.schema.registry.url": "http://schema-registry:8081",
            "value.converter": "io.confluent.connect.avro.AvroConverter",
            "value.converter.schema.registry.url": "http://schema-registry:8081"
    }'