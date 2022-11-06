#!/usr/bin/env bash

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-snowflake-sink/config \
    -d '
 {
		"connector.class": "com.snowflake.kafka.connector.SnowflakeSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "snowflake.topic2table.map": "movies:movies,second_movies:second_movies",
        "buffer.count.records":"10000",
        "buffer.flush.time":"60",
        "buffer.size.bytes":"5000000",
        "snowflake.url.name":"yk63760.us-east-2.aws.snowflakecomputing.com:443",
        "snowflake.user.name":"aaa",
        "snowflake.private.key":"zzzz",
        "snowflake.private.key.passphrase":"yyyy",
        "snowflake.database.name":"kafka_db",
        "snowflake.schema.name":"kafka_schema",
        "input.data.format": "AVRO",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset"
	}
'
