# Overview

This page describes the steps to set-up limits for various parameters whose data is published by a machine.

- [Overview](#overview)
  - [Usage](#usage)
    - [Set limits](#set-limits)
    - [Get limits](#get-limits)

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