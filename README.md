# Telegraf apm-input plugin demo

This demo demonstrates how to use Elastic APM agents (ruby, java, js..) and send application metrics using telegraf-apm 
plugin into InfluxDB.

### Requirements

* Docker (tested on Mac and Linux)

### Start the demo

The whole demo can be started using  `./run-telegraf-apm-demo.sh` script.

It will start following containers in docker:

- InfluxDB 2.0 - http://localhost:9999 
  - username: my-user
  - password: my-password
- Telegraf with enabled `apm-server` input plugin 
- Rails demo - http://localhost:3000
- Java demo - http://localhost:8080
- PostresDB
- Redis

## Rails APM agent

Demo simple blog application (CRUD) Rails application is located in ./demo-rails-app
It uses Postgres DB and Redis for caching.
 
UI is accessible on http://localhost:3000

#### Manually build and run Rails demo app

```.env
docker -v  build ./demo-rails-app -t demo-rails-app

docker run -d --name=demo-rails-app \
  --network apm_network \
  -p 3000:3000 \
  --env ELASTIC_APM_SERVER_URL=http://telegraf-apm:8200 \
  --env POSTGRES_HOST=postgres-demo \
  --env ELASTIC_APM_TRANSACTION_SAMPLE_RATE=0.1 \
  --env REDIS_HOST=redis-demo \
  demo-rails-app:latest

```
### Notes about performance

By default APM agents sends data from all transactions and spans and generates huge network/cpu/storage utilization.
There are several possibilities how to setup APM agent and Telegraf plugin to reduce overhead.

#### On agent configuration
* ELASTIC_APM_TRANSACTION_SAMPLE_RATE - example 0.1 value means that only 10% transactions will be recorder with spans. 
* disable ELASTIC_APM_CAPTURE_HEADERS, ELASTIC_APM_CAPTURE_ENV, capture_body  
* other tips: https://www.elastic.co/guide/en/apm/agent/ruby/current/tuning-and-overhead.html   

### In telegraf apm-server

* `drop_unsampled_transactions = true` - it is possible to exclude transactions that are not sampled (affected by ELASTIC_APM_TRANSACTION_SAMPLE_RATE ) 

* aggregate transaction/span duration using `aggregators.basicstats`
```
  # Keep the aggregate basicstats of each metric passing through.
  [[aggregators.basicstats]]
    ## The period on which to flush & clear the aggregator.
    period = "10s"

    ## If true, the original metric will be dropped by the
    ## aggregator and will not get sent to the output plugins.
    drop_original = true

    ## Configures which basic stats to push as fields
    stats = ["count","min","max","mean"]
    namepass = ["apm_transaction", "apm_span"]
``` 

* drop not important fields, stacktraces... 
```
  exclude_fields = [
        "exception_stacktrace*", "stacktrace*", "log_stacktrace*",
        "process_*",
        "service_language*",
        "service_runtime*",
        "service_agent_version",
        "service_framework*",
        "service_version",
        "service_agent_ephemeral_id",
        "system_architecture",
        "system_platform",
        "system_container_id",
        "span_count*",
        "context_request*",
        "context_response*",
        "context_destination*",
        "context_db_type",
        "context_db_statement",
        "id", "parent_id", "trace_id",
        "transaction_id",
        "sampled"
        ]
```
* adjust tags,fields mapping: `tag_keys = ["result", "name", "transaction_type", "transaction_name", "type", "span_type", "span_subtype"]`
* completely exclude event type `exclude_events = ["span", "error"]`
