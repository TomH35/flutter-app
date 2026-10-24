<?php

// DELETE api/places/delete.php?id=1

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('DELETE');

$controller = new PlaceController();
$controller->delete(getIdParam());
jsonResponse(null);
