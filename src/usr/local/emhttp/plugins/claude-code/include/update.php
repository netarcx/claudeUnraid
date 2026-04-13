<?php
header('Content-Type: application/json');

$plugin = "claude-code";
$cfg_file = "/boot/config/plugins/{$plugin}/{$plugin}.cfg";

// Read POST values with sanitization
$port = intval($_POST['PORT'] ?? 7682);
if ($port < 1024 || $port > 65535) {
  $port = 7682;
}

$workspace = $_POST['WORKSPACE'] ?? '/mnt/user/';
$workspace = rtrim($workspace, '/') . '/';
// Basic path validation - must start with /
if ($workspace[0] !== '/') {
  $workspace = '/mnt/user/';
}

$service = ($_POST['SERVICE'] ?? 'disable') === 'enable' ? 'enable' : 'disable';
$api_key = $_POST['API_KEY'] ?? '';

// Write config
$config_lines = [
  'SERVICE="' . $service . '"',
  'PORT="' . $port . '"',
  'WORKSPACE="' . addcslashes($workspace, '"') . '"',
  'API_KEY="' . addcslashes($api_key, '"') . '"',
];

// Ensure config directory exists
@mkdir(dirname($cfg_file), 0700, true);

if (file_put_contents($cfg_file, implode("\n", $config_lines) . "\n") === false) {
  echo json_encode(['error' => 'Failed to write config file']);
  http_response_code(500);
  exit;
}

// If service is running, restart to pick up new settings
$status = trim(shell_exec("/etc/rc.d/rc.{$plugin} status 2>/dev/null") ?? '');
if ($status === 'running') {
  shell_exec("/etc/rc.d/rc.{$plugin} restart >/dev/null 2>&1 &");
}

echo json_encode(['status' => 'ok', 'message' => 'Settings saved']);
