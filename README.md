# Claude Code for Unraid

Run [Claude Code](https://claude.ai/code) (Anthropic's CLI) directly on your Unraid server with a web-based terminal interface.

## Features

- Claude Code installed bare metal on Unraid (not in Docker)
- Web terminal powered by Unraid's built-in ttyd
- Settings page under **Settings > Utilities > Claude Code**
- Embedded terminal iframe in the Unraid web UI
- Configurable API key, port, and workspace directory
- Auto-start on array start
- Persistent across reboots (binary stored on USB flash)

## Installation

1. In the Unraid web UI, go to **Plugins > Install Plugin**
2. Paste the following URL and click Install:
   ```
   https://raw.githubusercontent.com/netarcx/claudeUnraid/main/claude-code.plg
   ```
3. Wait for the installation to complete (first install downloads the Claude Code binary)

## Setup

1. Navigate to **Settings > Utilities > Claude Code**
2. Enter your Anthropic API key
3. Adjust the port and workspace path if desired (defaults: port 7682, workspace `/mnt/user/`)
4. Click **Apply**
5. Click **Start**
6. Use the embedded terminal or click "Open in new tab" to launch Claude Code

## Uninstalling

Go to **Plugins > Installed Plugins**, find Claude Code, and click Remove.

## Troubleshooting

If you encounter issues after updating, clear the cached files on your Unraid terminal and reinstall:

```bash
rm -f /boot/config/plugins/claude-code/claude-code.txz
rm -f /boot/config/plugins/claude-code/bin/claude
rm -f /usr/local/bin/claude
```

Then reinstall from the plugin URL above.
