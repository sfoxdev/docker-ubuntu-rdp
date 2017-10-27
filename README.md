# Ubuntu via RDP or SSH

Ubuntu 16.04 via RDP with pre installed Xfce4, SSH, Google Chrome and VNC-Server.

[![Docker Build Status](https://img.shields.io/docker/build/sfoxdev/ubuntu-rdp.svg?style=flat-square)]()
[![Docker Build Status](https://img.shields.io/docker/automated/sfoxdev/ubuntu-rdp.svg?style=flat-square)]()
[![Docker Build Status](https://img.shields.io/docker/pulls/sfoxdev/ubuntu-rdp.svg?style=flat-square)]()
[![Docker Build Status](https://img.shields.io/docker/stars/sfoxdev/ubuntu-rdp.svg?style=flat-square)]()

## Usage

### Build container
```
docker build -t sfoxdev/ubuntu-rdp .
```

### Run container with default user and password

Username: chrome
Password: chrome

```
docker run -d --privileged -p 3389:3389 -p 5900:5900 -p 2222:22 --name chrome sfoxdev/ubuntu-rdp
```
### Run container with password

```
docker run -d --privileged -e PASSWORD=mypassword -p 3389:3389 -p 5900:5900 -p 2222:22 --name chrome sfoxdev/ubuntu-rdp
```
### Add new users

```
docker exec -it chrome adduser mynewuser
```
