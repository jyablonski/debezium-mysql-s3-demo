.PHONY: docker-run
docker-run:
	@docker-compose up -d

.PHONY: docker-down
docker-down:
	@docker-compose down

.PHONY: ksql
ksql:
	@docker exec -it ksqldb ksql http://ksqldb:8088

.PHONY: follow-logs
follow-logs:
	@docker-compose logs -f kafka-connect