#!/bin/bash
#
# Upload this script as a ONE file and select the file as a context "init"
# script in a template. This script requires the following template context
# variables:
#
# CONTEXT_REPO_URL - git clone url for a repo containing context scripts
#
# The following variables are optional but may require tweaking (especially
# CONTEXT_REPO_RUN_FILE depending on the repo layout):
#
# CONTEXT_REPO_RUN_FILE - path to run script relative to repo (DEFAULT: runcontext.sh)
# CONTEXT_REPO_RUN_LOG - path to log file for run (DEFAULT: /root/context-repo-run.log)
# CONTEXT_REPO_DEST_DIR - destination path for repo clone (DEFAULT: /root/context-repo)
#
set -a

source /mnt/context.sh

CONTEXT_REPO_DEST_DIR=${CONTEXT_REPO_DEST_DIR:-/root/context-repo}
CONTEXT_REPO_RUN_LOG=${CONTEXT_REPO_RUN_LOG:-/root/context-repo-run.log}
CONTEXT_REPO_RUN_FILE=${CONTEXT_REPO_RUN_FILE:-runcontext.sh}
CONTEXT_REPO_BRANCH=${CONTEXT_REPO_BRANCH:-master}
CONTEXT_REPO_WORK_DIR=${CONTEXT_REPO_WORK_DIR:-/root}

export HOME="/root"

if [ -z "${CONTEXT_REPO_URL}" ]; then
  echo "CONTEXT_REPO_URL context variable *must* be set - exiting" >> "${CONTEXT_REPO_RUN_LOG}"
  exit 1
fi

if [ ! -x "$(command -v git)" ]; then
  echo "Couldn't find git - installing" >> "${CONTEXT_REPO_RUN_LOG}"
  yum clean all &>> "${CONTEXT_REPO_RUN_LOG}"
  yum install -y git &>> "${CONTEXT_REPO_RUN_LOG}"
fi

if [ ! -e "${CONTEXT_REPO_DEST_DIR}" ]; then
  git clone -b "${CONTEXT_REPO_BRANCH}" "${CONTEXT_REPO_URL}" "${CONTEXT_REPO_DEST_DIR}" &>> "${CONTEXT_REPO_RUN_LOG}"
elif [ -d "${CONTEXT_REPO_DEST_DIR}/.git" ]; then
  cd "${CONTEXT_REPO_DEST_DIR}" && git pull
else
  echo "ERROR: ${CONTEXT_REPO_DEST_DIR} exists and is not a git repo - cant clone or pull" >> "${CONTEXT_REPO_RUN_LOG}"
  exit 1
fi

_RUN_FILE="${CONTEXT_REPO_DEST_DIR}/${CONTEXT_REPO_RUN_FILE}"

if [ -x "${_RUN_FILE}" ]; then
  echo "Running file: ${_RUN_FILE}" >> "${CONTEXT_REPO_RUN_LOG}"
  cd "${CONTEXT_REPO_WORK_DIR}"
  { time "${_RUN_FILE}" &>> "${CONTEXT_REPO_RUN_LOG}"; } 2>> "${CONTEXT_REPO_RUN_LOG}"
else
  echo "$_RUN_FILE does not exist or is not executable" >> "${CONTEXT_REPO_RUN_LOG}"
fi
