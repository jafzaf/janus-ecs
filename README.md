# janus-ecs
## Janus ECS image

Janus is an open source, general purpose, WebRTC server designed and developed by Meetecho. This version of the server is tailored for Linux systems, although it can be compiled for, and installed on, MacOS machines as well. Windows is not supported, but if that's a requirement, Janus is known to work in the "Windows Subsystem for Linux" on Windows 10: do NOT trust repos that provide .exe builds of Janus, they are not official and will not be supported.

For some online demos and documentations, make sure you pay the [project website](https://janus.conf.meetecho.com/) a visit!

To discuss Janus with us and other users, there's a Google Group called [meetecho-janus](https://groups.google.com/forum/#!forum/meetecho-janus) that you can use. If you encounter bugs, though, please submit an issue on github instead.

This repository provides the Dockerfile to build a full-featured docker image for the Janus WebRTC Server based on Centos7, it fully configure sofia-sip plugin for use in AWS, all plugins are generated but not enabled. We use sofia 1.12.11, libnice 0.1.18 and libsrtp-2.3.0.

This image is plug and play as far the sip plugin is related. You need to create a task definition, we added a json task example, pick a role and deploy to ECS Fargate. The resulting service or task will be fully provisioned and ready to play janus with the sip plugin, the websocket transport is enable but don't have wss or tls setup, you need to setup a net work load balancer for this, using a target group for ws and forwarding to the target group, using a certificate setup in ACM.

