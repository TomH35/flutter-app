<?php

// POST api/places/toggle_favorite.php?id=1

require_once __DIR__ . '/../../libs/core/api.php';
require_once __DIR__ . '/../../libs/controllers/PlaceController.php';

requireMethod('POST');

$controller = new PlaceController();
jsonResponse($controller->toggleFavorite(getIdParam()));
