# Jenkins JNLP Agent Docker image with docker inside

# Changelog
r10 - JRE 11, Agent 4.7
r9  - [cancelled]
r8  - 


[![Docker Stars](https://img.shields.io/docker/stars/korekontrol/docker-jnlp-slave-docker.svg)](https://hub.docker.com/r/korekontrol/docker-jnlp-slave-docker/)
[![Docker Pulls](https://img.shields.io/docker/pulls/korekontrol/docker-jnlp-slave-docker.svg)](https://hub.docker.com/r/korekontrol/docker-jnlp-slave-docker/)
[![Docker Automated build](https://img.shields.io/docker/automated/korekontrol/docker-jnlp-slave-docker.svg)](https://hub.docker.com/r/korekontrol/docker-jnlp-slave-docker/)

This is an image for [Jenkins](https://jenkins.io) agent (FKA "slave"/"worker") using JNLP to establish connection.
This agent is powered by the [Jenkins Remoting library](https://github.com/jenkinsci/remoting), which version is being taken from the base [Docker Agent](https://github.com/jenkinsci/docker-slave/) image.

It includes addionally to original image tools useful on CI/CD workers:
* `docker` installed locally for docker-inside-docker or docker-outside-docker scenario
* `awscli`
* `docker-compose`
* `j2cli`
* `kubectl`
* `helm`
* `nerdctl`

See [Jenkins Distributed builds](https://wiki.jenkins-ci.org/display/JENKINS/Distributed+builds) for more info.

## Running

To run a Docker container

    docker run korekontrol/jnlp-slave-docker -url http://jenkins-server:port <secret> <agent name>

Optional environment variables:

* `JENKINS_URL`: url for the Jenkins server, can be used as a replacement to `-url` option, or to set alternate jenkins URL
* `JENKINS_TUNNEL`: (`HOST:PORT`) connect to this agent host and port instead of Jenkins server, assuming this one do route TCP traffic to Jenkins master. Useful when when Jenkins runs behind a load balancer, reverse proxy, etc.
* `JENKINS_SECRET`: agent secret, if not set as an argument
* `JENKINS_AGENT_NAME`: agent name, if not set as an argument

## Running docker inside docker
If you want to use Jenkins in a container for building and running docker images, you must run docker inside/outside docker. Two scenarios
are possible - see: https://applatix.com/case-docker-docker-kubernetes-part/
Docker outside docker seems very slow...

## Configuration specifics
### Enabled JNLP protocols

By default, the [JNLP3-connect](https://github.com/jenkinsci/remoting/blob/master/docs/protocols.md#jnlp3-connect) is disabled due to the known stability and scalability issues.
You can enable this protocol on your own risk using the 
`JNLP_PROTOCOL_OPTS=-Dorg.jenkinsci.remoting.engine.JnlpProtocol3.disabled=false` property (the protocol should be enabled on the master side as well).

In Jenkins versions starting from `2.27` there is a [JNLP4-connect](https://github.com/jenkinsci/remoting/blob/master/docs/protocols.md#jnlp4-connect) protocol. 
If you use Jenkins `2.32.x LTS`, it is recommended to enable the protocol on your instance.

### Amazon ECS
Make sure your ECS container agent is [updated](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-agent-update.html) before running. Older versions do not properly handle the entryPoint parameter. See the [entryPoint](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definitions) definition for more information.

## Credits
Created by [Marek Obuchowicz](https://github.com/marek-obuchowicz) from [KoreKontrol - kubernetes consulting](https://www.korekontrol.eu/)

## License
[MIT](LICENSE)
