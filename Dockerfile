FROM openjdk:8-jdk
MAINTAINER Marek Obuchowicz <marek@korekontrol.eu>

# Tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini

# Install docker client, kubectl and helm
RUN curl -sSL https://get.docker.com/ | sh && \
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Debian packages
RUN apt-get update -qy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy python-pip groff-base && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# AWS CLI, j2cli
RUN pip install awscli && \
    pip install j2cli

# Jenkins
ENV HOME /home/jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 999 -m jenkins
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar) and tools: j2cli, awscli, docker client, kubectl and helm" Vendor="KoreKontrol" Version="3.27"

ARG VERSION=3.27

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER jenkins
RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

# jnlp slave
COPY jenkins-slave /usr/local/bin/jenkins-slave
ENTRYPOINT ["/tini", "--", "jenkins-slave"]
