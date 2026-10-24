<?php

// GET api/places/get.php?id=1

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('GET');

$controller = new PlaceController();
jsonResponse($controller->getById(getIdParam()));
