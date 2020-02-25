#!/bin/bash

set -e
set -o errexit
set -o nounset
set -o pipefail

# The base dir is unique per deployment
DEPLOY_DIR="${SCAP_REV_PATH}"
VENV_DIR="${DEPLOY_DIR}/venv"
MJOLNIR_DIR="${DEPLOY_DIR}/src"
WHEEL_DIR="${DEPLOY_DIR}/artifacts"
REQUIREMENTS="${DEPLOY_DIR}/requirements-frozen.txt"
PYTHON="python3.7"

PIP="${VENV_DIR}/bin/pip"

# Ensure that the virtual environment exists. Don't recreate if already
# existing, as this will try and downgrade pip on debian jessie from the one
# installed later which then breaks pip.
if [ -e "$VENV_DIR" ]; then
    rm -rf "$VENV_DIR"
fi
mkdir -p "$VENV_DIR"
virtualenv --never-download --python "$PYTHON" $VENV_DIR || /bin/true

# Debian jessie based hosts need updated versions of pip and wheel or they will
# fail to install some binary packages (numpy, scipy, maybe others)
$PIP install \
    -vv \
    --no-index \
    --find-links "${WHEEL_DIR}" \
    --upgrade \
    --force-reinstall \
    pip wheel
# Install or upgrade our dependencies
$PIP install \
    -vv \
    --no-index \
    --find-links "${WHEEL_DIR}" \
    --upgrade \
    --force-reinstall \
    -r "${REQUIREMENTS}"
# Install mjolnir (why isn't this simply another package dependency?)
$PIP install \
    -vv \
    --no-index \
    --upgrade \
    --no-deps \
    "${MJOLNIR_DIR}"
