#!/bin/bash
#
# pkg_build.sh - Build the claude-code.txz Slackware package
#
# Run this script from the repository root to create the .txz package
# that the PLG installer downloads and installs.
#
# Requirements: makepkg (available on Slackware/Unraid systems)
# On non-Slackware systems, you can use: tar cJf instead
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE_DIR="${SCRIPT_DIR}/archive"
SRC_DIR="${SCRIPT_DIR}/src"
PKG_NAME="claude-code"

echo "Building ${PKG_NAME}.txz..."

# Create archive directory
mkdir -p "${ARCHIVE_DIR}"

# Check if we're on a Slackware system (has makepkg)
if command -v makepkg >/dev/null 2>&1; then
  echo "Using makepkg (Slackware native)..."
  cd "${SRC_DIR}"
  makepkg -l y -c n "${ARCHIVE_DIR}/${PKG_NAME}.txz"
else
  echo "makepkg not found, using tar (cross-platform fallback)..."
  # Ensure install/ directory is included in the package
  if [ -d "${SCRIPT_DIR}/install" ]; then
    cp -r "${SCRIPT_DIR}/install" "${SRC_DIR}/"
  fi
  cd "${SRC_DIR}"
  tar cJf "${ARCHIVE_DIR}/${PKG_NAME}.txz" .
  # Clean up copied install dir
  rm -rf "${SRC_DIR}/install"
fi

echo ""
echo "Package built: ${ARCHIVE_DIR}/${PKG_NAME}.txz"
echo ""

# Compute MD5 for the PLG file
MD5=$(md5sum "${ARCHIVE_DIR}/${PKG_NAME}.txz" | awk '{print $1}')
echo "MD5: ${MD5}"
echo ""
echo "Update the &md5; entity in ${PKG_NAME}.plg if using MD5 verification."
