# Debezium
Practice Repo with Debezium which spins up MySQL, Kafka, and a Debezium Client to tap into the Bin Log and perform CDC on all database changes, and writes them to S3 every 60 seconds.

The Example connects to 2 separate Tables, builds 2 separate Kafka Topics, and writes out all changes to 2 separate Kafka S3 Sinks using 1 Source Connector + 1 Sink Connector.  You can adapt this example to include more tables as needed, all while using the same connector.

## Steps
1. Run `docker-compose up`.
2. Run `docker-compose logs -f kafka-connect` to follow logs for debugging purposes as well as to see if Debezium is sending CDC Messages.
3. Run the PUT S3 Sink Connector script in your local terminal.
4. Run the PUT Debezium Connector script in your local terminal.
5. Connect to ksql in another terminal via `docker exec -it ksqldb ksql http://ksqldb:8088`.
   1. Run `show connectors;` and `show topics;` to see if your stuff is running.
6. Login to MySQL Workbench & start screwing around with records in the `movies` table to see if CDC works & stores to S3.

## Articles
[Debugging](https://levelup.gitconnected.com/fixing-debezium-connectors-when-they-break-on-production-49fb52d6ac4e)
[S3 Sink](https://docs.confluent.io/kafka-connectors/s3-sink/current/overview.html)
[Original Debezium Repo](https://github.com/confluentinc/demo-scene/blob/master/livestreams/july-15/data/queries.sql)
[Kafka Sink Repo](https://github.com/confluentinc/demo-scene/blob/master/kafka-to-s3/docker-compose.yml)

## S3 IAM User
Create an IAM User and attach policy that looks like below, then create access/secret credentials and paste into aws_credentials

```
[default]
aws_access_key_id = xxx
aws_secret_access_key = yyy
```

S3 Policy
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::jyablonski-kafka-s3-sink"
            ]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "s3:*Object*",
            "Resource": [
                "arn:aws:s3:::jyablonski-kafka-s3-sink/*"
            ]
        }
    ]
}
```


S3 Sink Connector
```
curl -i -X PUT -H "Accept:application/json" \
    -H  "Content-Type:application/json" http://localhost:8083/connectors/jyablonski-kafka-s3-sink/config \
    -d '
 {
		"connector.class": "io.confluent.connect.s3.S3SinkConnector",
		"key.converter":"org.apache.kafka.connect.storage.StringConverter",
		"tasks.max": "1",
		"topics": "movies",
		"s3.region": "us-east-1",
		"s3.bucket.name": "jyablonski-kafka-s3-sink",
        "rotate.schedule.interval.ms": "60000",
        "timezone": "UTC",
		"flush.size": "65536",
		"storage.class": "io.confluent.connect.s3.storage.S3Storage",
		"format.class": "io.confluent.connect.s3.format.json.JsonFormat",
		"schema.generator.class": "io.confluent.connect.storage.hive.schema.DefaultSchemaGenerator",
		"schema.compatibility": "NONE",
        "partitioner.class": "io.confluent.connect.storage.partitioner.DefaultPartitioner",
        "transforms": "AddMetadata",
        "transforms.AddMetadata.type": "org.apache.kafka.connect.transforms.InsertField$Value",
        "transforms.AddMetadata.offset.field": "_offset",
        "transforms.AddMetadata.partition.field": "_partition"
	}
'
```


ksqldb Source Connector to create dummy data
`confluent-hub install --no-prompt mdrogalis/voluble:0.1.0` add to docker-compose if you want.

```
CREATE SOURCE CONNECTOR s WITH (
  'connector.class' = 'io.mdrogalis.voluble.VolubleSourceConnector',

  'genkp.owners.with' = '#{Internet.uuid}',
  'genv.owners.name.with' = '#{Name.full_name}',
  'genv.owners.creditCardNumber.with' = '#{Finance.credit_card}',

  'genk.cats.name.with' = '#{FunnyName.name}',
  'genv.cats.owner.matching' = 'owners.key',

  'genk.diets.catName.matching' = 'cats.key.name',
  'genv.diets.dish.with' = '#{Food.vegetables}',
  'genv.diets.measurement.with' = '#{Food.measurements}',
  'genv.diets.size.with' = '#{Food.measurement_sizes}',

  'genk.adopters.name.sometimes.with' = '#{Name.full_name}',
  'genk.adopters.name.sometimes.matching' = 'adopters.key.name',
  'genv.adopters.jobTitle.with' = '#{Job.title}',
  'attrk.adopters.name.matching.rate' = '0.05',
  'topic.adopters.tombstone.rate' = '0.10',

  'global.history.records.max' = '100000'
);

```

1. Single message transforms
   1. changes the data as it passes through
   2. you can add additional columns or metadata onto the messages.


Storage Class Formats:
    1. `io.confluent.connect.s3.format.parquet.ParquetFormat`
    2. `io.confluent.connect.s3.format.json.JsonFormat`
    3. `io.confluent.connect.s3.format.avro.AvroFormat`

# Debugging
Make sure aws credentials are in the container
`docker exec kafka-connect cat /root/.aws/credentials`

Follow logs to see if errors are happening and if Debezium CDC messages are getting sent to Kafka.
`docker-compose logs -f kafka-connect`

Show connectors to see if they're running or failing w/ a warning.
`show connectors;`


# Schema Registry
Used to capture schema information from connectors.


# Converters
Avro, Protobuf, and JsonSchemaConverter all exist to convert data from internal data types used in Kafka into data types we can store in remote storage like S3.

Sink Connectors receive schema information in addition to the data for the actual message.  Allows the sink connector to know the strucutre of the data to provide additional capabilities like maintaining a database table structure or creating/updating a search index.

JSON is easiest to debug while getting started (can download to s3 and see it), parquet might be best long term for snowflake + storage?

# Debezium Quirks
[Article](https://groups.google.com/g/debezium/c/wIByhyNN9bQ)
[Debez Article](https://debezium.io/documentation/reference/stable/connectors/mysql.html)

These 2 fkn database properties have nothing to do with the MySQL Database apparently.  They're supposed to have something to do with schema changes + the Kafka Topic. There's also some additional properties, which seems like they're writing stuff as asgard.{table_name} and the transform are to drop that prefix and the asgard.demo.(.*) is to drop the ACTUAL MySQL DB name (demo) as well.

If you have 2+ Debezium Connectors, you *CANNOT* use the same `database.server.id` or `database.server.name` for each table to do CDC on or it'll yell at you and the worker will ,,, die.

```
"database.server.id": "42",
"database.server.name": "asgard",

"include.schema.changes": "true",
"transforms": "unwrap,dropTopicPrefix",
"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
"transforms.dropTopicPrefix.type":"org.apache.kafka.connect.transforms.RegexRouter",
"transforms.dropTopicPrefix.regex":"asgard.demo.(.*)",
"transforms.dropTopicPrefix.replacement":"$1",
```

## Docker Port Stuff
`-p 8080:80`	Maps TCP port 80 in the container to port 8080 on the Docker host.

## Workflow Diagram
Each MySQL/Postgres Database you have would need its own Debezium Connector, but they can all write to the same Kafka Cluster.

![image](https://user-images.githubusercontent.com/16946556/191134280-5db8097f-3130-48d1-a564-096e64748be3.png)

## Git Stuff

### Clone
`git clone --filter=blob:none --sparse  https://github.com/confluentinc/demo-scene`
    - Filter the Repo with nothing but gitignroe and licencse
`git sparse-checkout add livestreams/july-15`
    - Add the subdirectory you want

### Rebasing
`git reset --soft HEAD~3` undos the last 3 local commits you made, but keeps the local code as-is.  Effectively allowing you to do a NEW "squash" commit all in one.

`git checkout development`
`git pull`
    - this is to make sure that branch is fully up to date locally for you.

`git checkout staging`
`git pull`
`git rebase master` - Rebases the CURRENT branch onto master
`git push --force`

`git checkout production`
`git pull`
`git rebase staging`
`git push --force`

### deleting a branch locally + remotely
`git push origin --delete test-branch`

# NEW WORKFLOW
1. git pull development
2. create a new feature branch off of development
3. add commits locally but don't push until youre ready
4. when ready, squash and merge the last x commits with `git reset --soft HEAD~3` (if you made 3 commits)
5. git push
6. go in github and make your pull request
7. merge with rebase & merge
8. when ready, go merge development into staging.
9. merge with rebase & merge.
10. when ready, go merge staging into production.
11. merge with rebase & merge.
12. then locally do git pull on everything.
13. and then do git checkout staging and run `git rebase production` and `git push -f`
14. and then do git checkout development and run `git rebase production` and `git push -f`


## Handling Deletes
Adding the following properties allows you to track deletes - it will add a `__deleted` column to every record which is set to true or false depending on whether the event represents a delete operation or not.

```
"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
"transforms.unwrap.delete.handling.mode": "rewrite",
"drop.tombstones": "false"
```
`drop.tombstones` - keeps records for DELETE operations in the event stream.