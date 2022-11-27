#!/usr/bin/env bash

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-snowflake-sink2/config \
    -d '
 {
		"connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "poll.interval.ms": 300000,
        "batch.max.rows": 1000,
        "connection.url":"jdbc:snowflake://xxx",
        "auto.create": "true",
        "auto.evolve": "true",
        "delete.enabled": "true",
        "pk.mode": "record_key",
        "table.name.format": "${topic}",
        "quote.sql.identifiers": "always",
        "insert.mode": "upsert",
        "transforms": "unwrap,AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.unwrap.drop.tombstones": "true",
        "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
        "transforms.unwrap.delete.handling.mode": "rewrite",
        "transforms.AddMetadata.offset.field": "_offset",
        "value.converter": "io.confluent.connect.avro.AvroConverter",
        "value.converter.schema.registry.url": "http://schema-registry:8081",
        "key.converter": "io.confluent.connect.avro.AvroConverter",
        "key.converter.schema.registry.url": "http://schema-registry:8081"
	}
'