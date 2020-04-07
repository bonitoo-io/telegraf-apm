# telegraf-apm

## java

Start java application with agent tracing:

```bash
export ELASTIC_APM_LOG_LEVEL=trace
mvn spring-boot:run -Dspring-boot.run.agents=elastic-apm-agent-1.14.0.jar
```
