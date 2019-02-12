#!/bin/bash

set -e
set -o errexit
set -o nounset
set -o pipefail

# The base dir is unique per deployment
DEPLOY_DIR="${SCAP_REV_PATH}"
VENV="${DEPLOY_DIR}/venv"
OLD_VENV_DIR="/srv/deployment/search/mjolnir/venv"
MJOLNIR_DIR="${DEPLOY_DIR}/src"
WHEEL_DIR="${DEPLOY_DIR}/artifacts"
REQUIREMENTS="${DEPLOY_DIR}/requirements-frozen.txt"

PIP="${VENV}/bin/pip"

# Ensure that the virtual environment exists. Don't recreate if already
# existing, as this will try and downgrade pip on debian jessie from the one
# installed later which then breaks pip.
if [ ! -x "$PIP" ]; then
    mkdir -p "$VENV"
    virtualenv --never-download --python python3 $VENV || /bin/true
fi

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

# The systemd units running mjolnir daemons still refer to the old
# virtualenv location. Maintain both until the cleanups are deployed.
rm -rf "$OLD_VENV_DIR"
ln -s "$VENV_DIR" "$OLD_VENV_DIR"
