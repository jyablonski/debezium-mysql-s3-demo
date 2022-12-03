#!/usr/bin/env bash

# ran into issues with quote sql identifiers - apparently you have to uppercase the topic name with a separate connector or some shit?
# oracle database dialect either

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-snowflake-sink6/config \
    -d '
 {
		"connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "poll.interval.ms": 300000,
        "batch.max.rows": 1000,
        "connection.url":"jdbc:snowflake://xxx.us-east-2.aws.snowflakecomputing.com:443/?db=kafka_db&warehouse=test_warehouse&schema=kafka_schema&role=KAFKA_CONNECTOR_ROLE_1",
        "connection.user": "kafka_user",
        "connection.password": "yyy",
        "dialect.name": "OracleDatabaseDialect",
        "auto.create": "true",
        "auto.evolve": "true",
        "delete.enabled": "false",
        "pk.mode": "none",
        "pk.fields": "none",
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