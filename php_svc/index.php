<?php
// Set error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Log the request
file_put_contents('php://stderr', 'Received request: ' . $_SERVER['REQUEST_URI'] . "\n");

header('Content-Type: application/json');

$request_uri = $_SERVER['REQUEST_URI'];

switch ($request_uri) {
    case '/':
    case '/api':
        $response = [
            'message' => 'Hello from the PHP API!',
            'timestamp' => date('Y-m-d H:i:s'),
            'php_version' => PHP_VERSION
        ];
        echo json_encode($response);
        break;
    
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Not Found', 'path' => $request_uri]);
        break;
}