<?php
header('Content-Type: application/json');

$action = $_POST['action'] ?? '';
$valid_actions = ['start', 'stop', 'restart', 'update'];

if (!in_array($action, $valid_actions, true)) {
  echo json_encode(['error' => 'Invalid action']);
  http_response_code(400);
  exit;
}

$output = shell_exec("/etc/rc.d/rc.claude-code " . escapeshellarg($action) . " 2>&1");

echo json_encode([
  'status' => 'ok',
  'action' => $action,
  'output' => trim($output)
]);
