# Introduction

This page describes the procedure to purchase license.

## Overview

To use Maintenance Mitra for unlimited duration and invocations, a license is required. Follow the steps below to purchase and use license.

1. Go to [something](https://something.somewhere.com).
2. Provide your e-mail address and click **Next**.
3. You are redirected to payment gateway. Make payment with your desired option.
4. An e-mail will be sent (typically, in 5 mins) with a license key.
5. Open [`license.env`](../launch/conf/license.env) in a text editor.
6. Comment out the existing line with a `#` at the start of the line.
7. Add a new line as shown below.

```bash
LICENSE_KEY=paste license key here
```
