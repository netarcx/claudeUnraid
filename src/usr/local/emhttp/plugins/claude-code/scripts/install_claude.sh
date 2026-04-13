#!/bin/bash
#
# install_claude.sh - Download and install Claude Code native binary
#
# Installs to /boot/config/plugins/claude-code/bin/ (persistent across reboots)
# and creates a symlink at /usr/local/bin/claude (available in PATH)
#

PLUGIN_NAME="claude-code"
FLASH_DIR="/boot/config/plugins/${PLUGIN_NAME}"
BIN_DIR="${FLASH_DIR}/bin"
CLAUDE_BIN="${BIN_DIR}/claude"
SYMLINK="/usr/local/bin/claude"

log() {
  echo "[${PLUGIN_NAME}] $1"
}

# Create persistent bin directory on USB flash
mkdir -p "${BIN_DIR}"

# Check if we already have the binary and it's working
if [ -x "${CLAUDE_BIN}" ]; then
  if "${CLAUDE_BIN}" --version >/dev/null 2>&1; then
    log "Claude Code is already installed: $(${CLAUDE_BIN} --version 2>&1)"
    # Ensure symlink exists
    ln -sf "${CLAUDE_BIN}" "${SYMLINK}"
    log "Symlink verified at ${SYMLINK}"
    exit 0
  else
    log "Existing binary is broken, reinstalling..."
    rm -f "${CLAUDE_BIN}"
  fi
fi

log "Downloading Claude Code..."

# Use Anthropic's official installer
# The installer puts the binary in ~/.claude/local/bin/claude by default
# We'll install it, then move the binary to our persistent location
export CLAUDE_INSTALL_DIR="/tmp/claude-code-install"
rm -rf "${CLAUDE_INSTALL_DIR}"
mkdir -p "${CLAUDE_INSTALL_DIR}"

# Download and run the installer, capturing output
if curl -fsSL https://claude.ai/install.sh | CLAUDE_CODE_SKIP_POSTINSTALL=1 bash 2>&1; then
  # Find the installed binary
  INSTALLED_BIN=""
  for candidate in \
    "${HOME}/.claude/local/bin/claude" \
    "${HOME}/.local/bin/claude" \
    "/usr/local/bin/claude" \
    "/root/.claude/local/bin/claude"; do
    if [ -x "${candidate}" ]; then
      INSTALLED_BIN="${candidate}"
      break
    fi
  done

  if [ -z "${INSTALLED_BIN}" ]; then
    # Try to find it via which
    INSTALLED_BIN="$(which claude 2>/dev/null)"
  fi

  if [ -n "${INSTALLED_BIN}" ] && [ -x "${INSTALLED_BIN}" ]; then
    # Copy to persistent location (don't move - installer may expect it there)
    cp "${INSTALLED_BIN}" "${CLAUDE_BIN}"
    chmod +x "${CLAUDE_BIN}"
    log "Claude Code binary saved to ${CLAUDE_BIN}"
  else
    log "ERROR: Installer ran but binary not found"
    exit 1
  fi
else
  log "ERROR: Failed to download Claude Code installer"
  exit 1
fi

# Create symlink in PATH
ln -sf "${CLAUDE_BIN}" "${SYMLINK}"
log "Symlink created at ${SYMLINK}"

# Verify
if "${CLAUDE_BIN}" --version >/dev/null 2>&1; then
  log "Installation successful: $(${CLAUDE_BIN} --version 2>&1)"
else
  log "WARNING: Binary installed but --version check failed. It may still work."
fi

exit 0
