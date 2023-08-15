# Introduction

This page describes the configuration of the limits of the parameters that will be published as machine data payload.

## Overview

The limits of parameters can be configured individually using JSON payload or in bulk using a CSV file. In either case, a REST client e.g., `curl` should do a `POST` with appropriate payload.

By default, the API will be accessible at `http://127.0.0.1:9090`. The port number can be configured by changing the `LIMITS_PORT` and `PORT` in [`launch.env`](../launch/launch.env) and [`limits.env`](../launch/conf/limits.env) respectively to same values.

### Individual configuration

To configure limits individually, `POST` JSON payload to `/limits`. The following is an example of limit to be configured.

```json
{
  "meta": {
    "id": "8c3aacea-7bf5-4f91-a767-7ad1083a5958",
    "ts": "2022-10-01T21:00:00.400"
  },
  "data": {
    "key": "rpm",
    "lo": 1200,
    "hi": 2200
  }
}
```

1. The payload will have two mandatory keys - `meta` and `data`.
2. The `meta` object _must_ have the keys `ts` and `id` for timestamp and message ID respectively. This message ID _must_ be a UUID. The timestamp _must_ be in the `YYYY-MM-DDTHH:mm:ss.SSS` and should be within a window of `GRACE_TIME` milliseconds. The `GRACE_TIME` configuration parameter is defined in [`payload.env`](../launch/conf/payload.env).
3. The `data` object will have three keys - `key`, `lo` and `hi` where, `key` is the name of the parameter whose limits are to be configured. The `lo` and `hi` values are the limits beyond which alert condition arises.
4. It is **important** to keep the value of `key` **exactly** the same as used when publishing raw data.

### Bulk configuration

To configure limits in bulk, `POST` JSON payload to `/bulk`.

1. Create a CSV file named as `limits.csv` with limits as shown below. These limits are defined for parameters published by REST simulator.

```csv
meta.id=8c3aacea-7bf5-4f91-a767-7ad1083a5958,meta.ts=2023-08-15T00:00:00.000,data.key=rpm,data.lo=1000,data.hi=10000
meta.id=1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed,meta.ts=2023-08-15T00:00:00.000,data.key=temperature,data.lo=20,data.hi=60
meta.id=74058447-87a1-4a17-8023-54ad56067ac1,meta.ts=2023-08-15T00:00:00.000,data.key=current,data.lo=100,data.hi=1000
meta.id=74058447-87a1-4a17-8023-54ad56067ac1,meta.ts=2023-08-15T00:00:00.000,data.key=vibration,data.lo=-10,data.hi=10
meta.id=74058447-87a1-4a17-8023-54ad56067ac1,meta.ts=2023-08-15T00:00:00.000,data.key=voltage,data.lo=100,data.hi=1000
```

- Each row in the CSV file has five key-value pairs separated by commas where, the key-value pair is separated by **equals** symbol.
- All of key-value pairs are required.
- `meta.id` _must_ be UUID.
- `meta.ts` _must_ be a timestamp in the `YYYY-MM-DDTHH:mm:ss.SSS` format.
- `data.key` is the name of the parameter to be configured.
- `data.lo` is the lower limit of the parameter to be configured.
- `data.hi` is the upper limit of the parameter to be configured.
- It is **important** to keep the value of `key` **exactly** the same as used when publishing raw data.

2. Run the following command to configure limits in bulk.

```bash
curl -X POST http://127.0.0.1:9090/bulk -H "Content-Type: text/plain" --data-file "@limits.csv"
```
