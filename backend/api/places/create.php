<?php

// POST api/places/create.php   (JSON body)

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('POST');

$controller = new PlaceController();
jsonResponse($controller->create(getJsonBody()), 201);
