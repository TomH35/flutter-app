<?php

// PUT api/places/update.php?id=1   (JSON body)

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('PUT');

$controller = new PlaceController();
jsonResponse($controller->update(getIdParam(), getJsonBody()));
