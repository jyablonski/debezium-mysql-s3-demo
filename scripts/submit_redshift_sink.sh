#!/usr/bin/env bash

curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-redshift-sink-postgres/config \
    -d '
 {
        "confluent.topic.bootstrap.servers": "localhost:9092",
		"connector.class": "io.confluent.connect.aws.redshift.RedshiftSinkConnector",
		"tasks.max": "1",
		"topics": "second_movies,movies",
        "aws.redshift.domain": "bigcluster",
        "aws.redshift.port": "5439",
        "aws.redshift.database": "dev",
        "aws.redshift.user": "jacob",
        "aws.redshift.password": "zzzz",
        "auto.create": "true",
        "auto.evolve": "true",
        "pk.mode": "record_key",
        "delete.enabled": "true",
        "table.name.format": "dbz.${topic}"
	}
'