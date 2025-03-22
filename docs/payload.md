## Overview

The payload should be published to the `/data` endpoint as a JSON payload with a `POST` request. If the payload is valid, then a `202` status message is returned. This indicates that the message is valid and has been published to Kafka for downstream consumption. Else, a `400` message is published to indicate the payload is invalid.

- [Overview](#overview)
- [Rate limiting](#rate-limiting)
- [Payload format](#payload-format)

> With the default license, The `/data` endpoint limits upto `3600` requests in a time window of `1 hour` at one go.

- [Overview](#overview)
- [Rate limiting](#rate-limiting)
- [Payload format](#payload-format)

## Rate limiting

This `/data` endpoint implements rate-limiting such that, a maximum of `3600` requests can be sent in a time window of `1 hour` - whichever is earlier. For example, if a machine publishes data every second, then the machine can keep publishing continuously upto a maximum of `3600` requests (`1*3600=3600`) for upto `1 hour`. The rate limit is applied even if the number of requests exceed `3600` _within_ the time window of `1 hour`.

When the rate limit is reached, a response with HTTP status code `429` will be sent with the following payload and additional headers. See following sections for additional headers.

```json
{
  "statusCode": 429,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded, retry in 1 minute"
}
```

## Payload format

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
2. The `meta` object _must_ have the keys `ts`, `id`  and `type` for timestamp, message ID and `data` respectively. This message ID _must_ be a UUID version `4`. The timestamp _must_ be in the `YYYY-MM-DDTHH:mm:ss.SSS` and should be within a window of `GRACE_TIME` milliseconds.
3. The `data` object is an array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to numeric (real number) values.
4. The `alarms` object is an optional array of objects where each object has two keys - `key` and `value`. The `key` is set to parameter name and `value` is set to alphanumeric values.
