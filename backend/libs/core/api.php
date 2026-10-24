<?php

/**
 * Shared setup for every endpoint in the api/ folder:
 * CORS + JSON headers, preflight handling and JSON error responses.
 */

require_once __DIR__ . '/ApiException.php';

ini_set('display_errors', '0');

function jsonResponse(mixed $data, int $status = 200): never
{
    http_response_code($status);
    echo json_encode(['data' => $data], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function errorResponse(string $message, int $status): never
{
    http_response_code($status);
    echo json_encode(['error' => $message], JSON_UNESCAPED_UNICODE);
    exit;
}

function requireMethod(string $method): void
{
    if ($_SERVER['REQUEST_METHOD'] !== $method) {
        header('Allow: ' . $method);
        errorResponse('Method not allowed', 405);
    }
}

function getJsonBody(): array
{
    $data = json_decode(file_get_contents('php://input'), true);

    if (!is_array($data)) {
        throw new ApiException('Request body must be a JSON object');
    }

    return $data;
}

function getIdParam(): int
{
    $id = $_GET['id'] ?? '';

    if (!ctype_digit((string) $id) || (int) $id <= 0) {
        throw new ApiException('Missing or invalid id parameter');
    }

    return (int) $id;
}

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

set_exception_handler(function (Throwable $e) {
    if ($e instanceof ApiException) {
        errorResponse($e->getMessage(), $e->getStatus());
    }

    error_log((string) $e);
    errorResponse('Internal server error', 500);
});
