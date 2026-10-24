<?php

// POST api/places/upload_photo.php   (multipart/form-data, field "photo")

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('POST');

$controller = new PlaceController();
jsonResponse(['photo' => $controller->uploadPhoto($_FILES['photo'] ?? null)], 201);
