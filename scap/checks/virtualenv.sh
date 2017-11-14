set -e
set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="/srv/deployment/search/mjolnir"
VENV="${BASE_DIR}/venv"
DEPLOY_DIR="${BASE_DIR}/deploy"
MJOLNIR_DIR="${BASE_DIR}/deploy/src"
WHEEL_DIR="${DEPLOY_DIR}/artifacts"
REQUIREMENTS="${DEPLOY_DIR}/requirements-frozen.txt"
MJOLNIR_ZIP="${BASE_DIR}/mjolnir_venv.zip"

PIP="${VENV}/bin/pip"

# Ensure that the virtual environment exists
mkdir -p "$VENV"
virtualenv --never-download --python python2.7 $VENV || /bin/true

# Install or upgrade our packages
$PIP install \
    --no-index \
    --find-links "${WHEEL_DIR}" \
    --upgrade \
    --force-reinstall \
    -r "${REQUIREMENTS}"

$PIP install --upgrade --no-deps "${MJOLNIR_DIR}"

# Build a .zip of the virtualenv that can be shipped to spark workers
cd "${VENV}"
zip -qr ${MJOLNIR_ZIP}.tmp .
mv -T ${MJOLNIR_ZIP}.tmp ${MJOLNIR_ZIP}
