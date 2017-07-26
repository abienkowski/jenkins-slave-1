FROM java:7-jdk-alpine

MAINTAINER abienkowski-ethoca <adrian.bienkowski@ethoca.com>

ENV JENKINS_SWARM_VERSION 2.2
ENV JENKINS_SWARM_DOWNLOAD_SITE https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client
ENV JENKINS_HOME /home/jenkins
ENV JENKINS_USER jenkins

RUN set -x &&\
    apk add --update --no-cache curl bash openssh git

RUN adduser -D -h "${JENKINS_HOME}" -g "Jenkins User" -s /sbin/nologin "${JENKINS_USER}" \
  && mkdir -p ${JENKINS_HOME}/.m2 ${JENKINS_HOME}/.ssh \
  && chmod 600 ${JENKINS_HOME/.ssh \
  && chown ${JENKINS_USER}: ${JENKINS_HOME}/.m2 ${JENKINS_HOME}/.ssh
RUN curl --create-dirs -sSLo /usr/share/jenkins/swarm-client-${JENKINS_SWARM_VERSION}-jar-with-dependencies.jar \
  ${JENKINS_SWARM_DOWNLOAD_SITE}/${JENKINS_SWARM_VERSION}/swarm-client-${JENKINS_SWARM_VERSION}-jar-with-dependencies.jar \
  && chmod 755 /usr/share/jenkins

COPY jenkins-slave.sh /usr/local/bin/jenkins-slave.sh

RUN mkdir /docker-entrypoint-init.d
ONBUILD ADD ./*.sh /docker-entrypoint-init.d

USER "${JENKINS_USER}"
VOLUME "${JENKINS_HOME}/.m2"
VOLUME "${JENKINS_HOME}/.ssh"

ENTRYPOINT ["/usr/local/bin/jenkins-slave.sh"]
