# Introduction

Maintenance Mitra is an application to display machine parameters, detect alarm conditions and duration in near real-time from one machine to one user at a time. The application is launched as a Docker Compose stack.

![Screen-shot](./png/dashboard.png)

- [Introduction](#introduction)
  - [On-premise installation](#on-premise-installation)
    - [Pre-requisites](#pre-requisites)
    - [Install instructions](#install-instructions)

This repository documents installation of Maintenance Mitra on on-premise.

## On-premise installation

The diagram below shows the topology to install Maintenance Mitra application on the on-premises server.

![on-premise](png/on-premise.png)

### Pre-requisites

The pre-requisites for installation are as follows:

1. A 64-bit Windows or a Linux server with minimum 1 core CPU and 4GB RAM to spare.
2. Docker and Docker Compose are pre-installed.
3. Internet connection should be available for the duration of installation (typically, 15 mins).

### Install instructions

See [here](docs/on-premises.md) for install instructions on on-premise machine.
