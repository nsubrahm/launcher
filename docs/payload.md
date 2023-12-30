## Overview

This application exposes a `/data` end-point to which machine data is published as a JSON payload with a `POST` request. If the payload is valid, then a `202` status message is returned. This indicates that the message is valid and has been published to Kafka for downstream consumption. Else, a `400` message is published to indicate the payload is invalid.

> This application limits upto `3600` requests in a time window of `1 hour` at one go.

- [Overview](#overview)
- [Rate limiting](#rate-limiting)
- [Build and deploy](#build-and-deploy)
- [Configuration](#configuration)
  - [Application](#application)
  - [Licensing](#licensing)
- [Raw data](#raw-data)

## Rate limiting

This application implements rate-limiting such that, a maximum of `3600` requests can be sent in a time window of `1 hour` - whichever is earlier. For example, if a machine publishes data every second, then the machine can keep publishing continuously upto a maximum of `3600` requests (`1*3600=3600`) for upto `1 hour`. The rate limit is applied even if the number of requests exceed `3600` _within_ the time window of `1 hour`.

When the rate limit is reached, a response with HTTP status code `429` will be sent with the following payload and additional headers. See following sections for additional headers.

```json
{
  "statusCode": 429,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded, retry in 1 minute"
}
```

## Build and deploy

The GitHub Actions configured in [`publish.yaml`](.github/workflows/publish.yaml) will build the container image using distroless base image and deploy to GHCR when a push is done to the appropriate branch.

## Configuration

The configuration properties are provided via two files - `payload.env` and `license.env` - for configuring this application and licensing respectively.

### Application

```bash
# Must change
MACHINE_DATA_TOPIC=m001_data
# May change
GRACE_TIME=10000
# Do not change
KAFKA_BROKER=broker:9092
APP_ID=M001_PAYLOAD
HOST=0.0.0.0
PORT=8081
HEALTHCHECK_HOST=localhost
HEALTHCHECK_PORT=9000
FREQUENCY=5000
INITIAL_DELAY=3000
```

| Variable name        | Description                                                                                              | Example                                |
| -------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| `MACHINE_DATA_TOPIC` | A Kafka topic to which validated messages will be published to.                                          | `m001_data`                            |
| `GRACE_TIME`         | Accept payloads with a timestamp that is in the range of current timestamp ± `GRACE_TIME` milli-seconds. | `10000` (default) for 10 seconds, etc. |

The following variables should not be changed.

| Variable name      | Description                                               | Example        |
| ------------------ | --------------------------------------------------------- | -------------- |
| `KAFKA_BROKER`     | URL of Kafka broker                                       | `broker:9092`  |
| `APP_ID`           | Application ID for the Kafka publisher                    | `M001_DATA`         |
| `HOST`             | Interfaces where the application listens at               | `0.0.0.0`      |
| `PORT`             | Endpoint port number                                      | `8081`         |
| `HEALTHCHECK_HOST` | Interfaces where the health check application listens at  | `localhost`    |
| `HEALTHCHECK_PORT` | Port number where the health check application listens at | `9000`         |
| `FREQUENCY`        | Frequency (ms) to poll for health                         | `5000`         |
| `INITIAL_DELAY`    | Initial (ms) delay before polling for health              | `10000`        |
| `TZ`               | Time zone for time calculations                           | `Asia/Kolkata` |

### Licensing

> Contact us to purchase license for longer duration.

Licensing is maintained in `license.env` file as described below.

```bash
LICENSE_KEY=long hexa decimal string
```

| Variable name | Description                           | Example                   |
| ------------- | ------------------------------------- | ------------------------- |
| `LICENSE_KEY` | License string to use the application | A long hexadecimal string |

## Raw data

The following JSON payload is an example of valid payload expected at the `/data` endpoint.

```json
{
  "meta": {
    "id": "8c3aacea-7bf5-4f91-a767-7ad1083a5958",
    "ts": "2022-10-01T21:00:00.400",
    "type" : "data"
  },
  "data": [
    {
      "key": "rpm",
      "value": 1000
    },
    {
      "key": "temperature",
      "value": 1000
    }
  ],
  "alarms": [
    {
      "key": "OIL_LEVEL",
      "value": "FULL"
    },
    {
      "key": "COOLANT_TEMP",
      "value": "HIGH"
    }
  ]
}
```

1. Each message will have three keys - `meta`, `data` and `alarms` where, `meta` and `data` are mandatory and `alarms` is optional.
2. The Kafka message will have UUID as the key and will be same as `meta.id`.
3. The `meta` object _must_ have the keys `ts`, `id`  and `type` for timestamp, message ID and `data` respectively. This message ID _must_ be a UUID. The timestamp _must_ be in the `YYYY-MM-DDTHH:mm:ss.SSS` and should be within a window of `GRACE_TIME` milliseconds.
4. The `data` object is an array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to numeric (real number) values.
5. The `alarms` object is an optional array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to alphanumeric values.
