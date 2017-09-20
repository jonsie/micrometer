#!/bin/bash
# This script will build the project.

SWITCHES="-s --console=plain"

if [ $CIRCLE_PR_NUMBER ]; then
  echo -e "WARN: Should not be here => Found Pull Request #$CIRCLE_PR_NUMBER => Branch [$CIRCLE_BRANCH]"
  echo -e "Not attempting to publish"
elif [ -z $CIRCLE_TAG ]; then
  echo -e "Publishing Snapshot => Branch ['$CIRCLE_BRANCH']"
  openssl aes-256-cbc -d -in gradle.properties.enc -out gradle.properties -k $KEY
  ./gradlew snapshot $SWITCHES
elif [ $CIRCLE_TAG ]; then
  echo -e "Publishing Release => Branch ['$CIRCLE_BRANCH']  Tag ['$CIRCLE_TAG']"
  openssl aes-256-cbc -d -in gradle.properties.enc -out gradle.properties -k $KEY
  case "$CIRCLE_TAG" in
  *-rc\.*)
    ./gradlew -Prelease.disableGitChecks=true -Prelease.useLastTag=true clean build candidate $SWITCHES
    ;;
  *)
    ./gradlew -Prelease.disableGitChecks=true -Prelease.useLastTag=true clean build final $SWITCHES
    ;;
  esac
else
  echo -e "WARN: Should not be here => Branch ['$CIRCLE_BRANCH']  Tag ['$CIRCLE_TAG']  Pull Request ['$CIRCLE_PR_NUMBER']"
  echo -e "Not attempting to publish"
fi

EXIT=$?

exit $EXIT