# Overview

This page describes the steps to set-up limits for various parameters whose data is published by a machine.

- [Overview](#overview)
  - [Usage](#usage)
    - [Set limits](#set-limits)
    - [Get limits](#get-limits)

## Usage

The limits application can be used to set and get limits of the parameters.

### Set limits

To set limits of parameters, upload a JSON document to the `/limits` endpoint with HTTP `POST` endpoint. The following is an example of JSON document to set limits for `spindleLoad`, `spindleSpeed` and `spindleTemperature`.

```json
[
  {
    "key":"spindleLoad",
    "lo": 10,
    "hi": 100
  },
  {
    "key": "spindleTemperature",
    "lo": 10,
    "hi": 90
  },
  {
    "key": "spindleSpeed",
    "lo": 10,
    "hi": 1000
  }
]
```

> The parameters, that do not have limits set, will not generate limits.

1. The JSON payload is an array of objects, where each object has the keys - `key`, `lo` and `hi`.
2. The `key` is mandatory whereas at least one of `lo` and `hi` should be provided.
3. The `key` is set to string whereas the values of `lo` and `hi` are real values.
4. The values of `lo` and `hi` are set to raise alerts when actual value is lesser than `lo` or higher than `hi`.

### Get limits

To get a list of limits that are set, send a HTTP `GET` command to the `/limits` endpoint.