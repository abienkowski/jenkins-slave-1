#!/bin/bash
set -e

# if `docker run` first argument start with `-` the user is passing jenkins swarm launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
  # Provide a way to customise this image
  echo
  for f in /docker-entrypoint-init.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *)     echo "$0: ignoring $f" ;;
    esac
    echo
  done

  # jenkins swarm slave
  JAR=`ls -1 /usr/share/jenkins/swarm-client-*.jar | tail -n 1`

  PARAMS=""
  if [ ! -z "$JENKINS_USERNAME" ]; then
    PARAMS="$PARAMS -username $JENKINS_USERNAME"
  fi
  if [ ! -z "$JENKINS_PASSWORD" ]; then
    PARAMS="$PARAMS -passwordEnvVariable JENKINS_PASSWORD"
  else
    PARAMS="$PARAMS -password $(cat ${JENKINS_SECRET_FILE})"
  fi
  if [ ! -z "$SLAVE_EXECUTORS" ]; then
    PARAMS="$PARAMS -executors $SLAVE_EXECUTORS"
  fi
  if [ ! -z "$JENKINS_MASTER" ]; then
    PARAMS="$PARAMS -master $JENKINS_MASTER"
  fi

  echo Running java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
  exec java $JAVA_OPTS -jar $JAR -fsroot $HOME $PARAMS "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for sample a `bash` shell to explore this image
exec "$@"
