FROM openjdk:11-jre-slim-buster

# Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini /tini
RUN chmod +x /tini

# Debian packages
RUN apt-get update -qy && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
      bzip2 \
      curl \
      git \
      groff-base \
      gawk \
      make \
      openssh-client \
      python3-openssl \
      python3-pip \
      python3-setuptools \
      zip \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install docker client, nerdctl, kubectl and helm
RUN export DEBIAN_FRONTEND=noninteractive && \
    curl -sSL https://get.docker.com/ | sh && \
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm -f get_helm.sh && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 755 kubectl && \
    mv kubectl /usr/local/bin/kubectl && \
#    curl https://github.com/containerd/nerdctl/releases/download/v1.4.0/nerdctl-1.4.0-linux-amd64.tar.gz > nerdctl.tar.gz && \
#    tar zxf nerdctl.tar.gz && \
#    mv nerdctl /usr/local/bin/nerdctl && \
    rm -rf /var/lib/apt/lists/*

# AWS CLI, j2cli, docker-compose
RUN pip3 install awscli && \
    pip3 install j2cli && \
    pip3 install docker-compose~=1.23.2 && \
    pip3 install --upgrade urllib3

# Jenkins
ENV HOME /home/jenkins
RUN groupadd -g 998 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 998 -m jenkins
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar) and tools: j2cli, awscli, docker client, docker-compose, kubectl and helm" Vendor="KoreKontrol" Version="3.27"

ARG VERSION=4.7

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
