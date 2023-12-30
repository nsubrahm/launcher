# Overview

This page describes the steps to set-up limits for various parameters whose data is published by a machine.

- [Overview](#overview)
  - [Configuration](#configuration)
  - [Usage](#usage)
    - [Set limits](#set-limits)
    - [Get limits](#get-limits)

## Configuration

The configuration properties are provided via `limits.env` as described below.

```bash
# Must change
MACHINE_LIMITS_TOPIC=m001_limits
# May change
KAFKA_BROKER=broker:9092
# Do not change
APP_ID=M001_LIMITS
GROUP_ID=M001_LIMITS
HOST=0.0.0.0
PORT=8083
HEALTHCHECK_HOST=localhost
HEALTHCHECK_PORT=9000
FREQUENCY=5000
INITIAL_DELAY=10000
TZ="Asia/Kolkata"
```

| Variable name          | Description                                  | Example       |
| ---------------------- | -------------------------------------------- | ------------- |
| `MACHINE_LIMITS_TOPIC` | A Kafka topic to store limits of parameters. | `m001_limits` |

The following variables should not be changed.

| Variable name      | Description                                               | Example        |
| ------------------ | --------------------------------------------------------- | -------------- |
| `KAFKA_BROKER`     | URL of Kafka broker                                       | `broker:9092`  |
| `APP_ID`           | Application ID for the Kafka publisher                    | `M001_LIMITS`  |
| `GROUP_ID`         | Application ID for the Kafka consumer                     | `M001_LIMITS`  |
| `HOST`             | Interfaces where the application listens at               | `0.0.0.0`      |
| `PORT`             | Endpoint port number                                      | `8081`         |
| `HEALTHCHECK_HOST` | Interfaces where the health check application listens at  | `localhost`    |
| `HEALTHCHECK_PORT` | Port number where the health check application listens at | `9000`         |
| `FREQUENCY`        | Frequency (ms) to poll for health                         | `5000`         |
| `INITIAL_DELAY`    | Initial (ms) delay before polling for health              | `10000`        |
| `TZ`               | Time zone for time calculations                           | `Asia/Kolkata` |

## Usage

The limits application can be used to set and get limits of the parameters.

### Set limits

To set limits - one or many - prepare a CSV file, e.g., `limits.csv` where, each row has three columns as shown below.

| Column # | Column name    | Description                               | Format  |
| -------- | -------------- | ----------------------------------------- | ------- |
| 1        | Parameter name | The parameter whose limits are to be set. | String  |
| 2        | Lower limit    | The safe low limit of the parameter.      | Decimal |
| 3        | Higher limit   | The safe high limit of the parameter.     | Decimal |

Here is an example of the CSV file to be prepared.

```csv
rpm,100,1000
temperature,10,100
vibration,-9.5,9.5
current,10.0,300.0
voltage,5,440
```

Once the CSV file is prepared, upload them to the `/limits` endpoint with HTTP `POST` endpoint.

> The parameters, that do not have limits set, will not generate limits.

### Get limits

To get a list of limits that are set, send a HTTP `GET` command to the `/limits` endpoint.