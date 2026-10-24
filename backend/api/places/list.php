<?php

// GET api/places/list.php

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('GET');

$controller = new PlaceController();
jsonResponse($controller->getAll());
