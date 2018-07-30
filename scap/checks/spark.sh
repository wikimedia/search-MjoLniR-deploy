set -e
set -o errexit
set -o nounset
set -o pipefail

BASE_DIR="/srv/deployment/search/mjolnir"
VENV="${BASE_DIR}/venv"
MJOLNIR_ZIP="${BASE_DIR}/mjolnir_venv.zip"

# Deploy the current configuration for mjolnir's spark utility
cp "${BASE_DIR}/deploy/spark.yaml" /etc/mjolnir/spark.yaml

# Build a .zip of the virtualenv that can be shipped to spark workers if
# we are on a host with spark installed.
cd "${VENV}"
zip -qr "${MJOLNIR_ZIP}.tmp" .
# Atomically swap the zip
mv "${MJOLNIR_ZIP}.tmp" "${MJOLNIR_ZIP}"
