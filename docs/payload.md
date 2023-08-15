# Introduction

This page describes the steps to publish payload via HTTP for downstream transmission.

- [Introduction](#introduction)
  - [Overview](#overview)
  - [Rate limiting](#rate-limiting)
  - [Sample payload](#sample-payload)

## Overview

A REST client should `POST` a JSON document as payload to `/data` end-point to publish machine data. If the payload is valid, then a `202` status message is returned. This indicates that the message is valid and has been published to Kafka for downstream consumption. Else, a `400` message is published to indicate the payload is invalid.

By default, the API will be accessible at `http://127.0.0.1:8080/data`. The port number can be configured by changing the `PAYLOAD_PORT` and `PORT` in [`launch.env`](../launch/launch.env) and [`payload.env`](../launch/conf/payload.env) respectively to same values.

## Rate limiting

> By default, the `payload` application limits upto `3600` requests in a time window of `1 hour` at one go. For unlimited usage, purchase a license as described [here](./docs/license.md).

This rate-limiting is implemented such that, a maximum of `3600` requests can be sent in a time window of `1 hour` - whichever is earlier. For example, if a machine publishes data every second, then the machine can keep publishing continuously upto a maximum of `3600` requests (`1*3600=3600`) for upto `1 hour`. The rate limit is applied even if the number of requests exceed `3600` _within_ the time window of `1 hour`.

When the rate limit is reached, a response with HTTP status code `429` will be sent with the following payload and additional headers. See following sections for additional headers.

```json
{
  "statusCode": 429,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded, retry in 1 minute"
}
```

## Sample payload

The following JSON payload is an example of valid payload.

```json
{
  "meta": {
    "id": "8c3aacea-7bf5-4f91-a767-7ad1083a5958",
    "ts": "2022-10-01T21:00:00.400"
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
2. The `meta` object _must_ have the keys `ts` and `id` for timestamp and message ID respectively. This message ID _must_ be a UUID. The timestamp _must_ be in the `YYYY-MM-DDTHH:mm:ss.SSS` and should be within a window of `GRACE_TIME` milliseconds. The `GRACE_TIME` configuration parameter is defined in [`payload.env`](../launch/conf/payload.env).
3. The `data` object is an array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to numeric (real number) values.
4. The `alarms` object is an array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to alphanumeric values.
