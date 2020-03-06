#!/usr/bin/env bash

set -e
set -o errexit
set -o nounset
set -o pipefail

BASE="$(realpath $(dirname $0))"
BUILD="${BASE}/_build"
VENV="${BUILD}/venv"
MJOLNIR="${BASE}/src"
WHEEL_DIR="${BASE}/artifacts"
REQUIREMENTS="${BASE}/requirements.txt"
REQUIREMENTS_FROZEN="${BASE}/requirements-frozen.txt"

PIP="${VENV}/bin/pip"

# Used by wheel >= 0.25 to normalize timestamps. Timestamp
# taken from original debian patch:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?att=1;bug=776026;filename=wheel_reproducible.patch;msg=5
export SOURCE_DATE_EPOCH=315576060

rm -rf "${BUILD}"
mkdir -p "${VENV}"
virtualenv --python "${PYTHON_PATH:-python3.7}" "${VENV}"
# PYTHON_PATH must refer to 3.7, it's the only one available on debian buster
test -x "${VENV}/bin/python3.7"

$PIP install -r "${REQUIREMENTS_FROZEN}"
$PIP install "${MJOLNIR}"
$PIP install -r "${REQUIREMENTS}"
$PIP freeze --local | grep -v mjolnir | grep -v pkg-resources > "${REQUIREMENTS_FROZEN}"
$PIP install pip wheel
# Debian jessie based hosts require updated pip and wheel packages or they will
# refuse to install some packages (numpy, scipy, maybe others)
$PIP wheel --find-links "${WHEEL_DIR}" \
        --wheel-dir "${WHEEL_DIR}" \
        pip wheel
$PIP wheel --find-links "${WHEEL_DIR}" \
        --wheel-dir "${WHEEL_DIR}" \
        --requirement "${REQUIREMENTS_FROZEN}"

