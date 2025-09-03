<?php
use App\Controllers\CustomersController;

$c = new CustomersController();

$app->get('/customers', [$c, 'list']);
$app->get('/customers/search', [$c, 'search']);
$app->post('/customers', [$c, 'create']);
$app->patch('/customers/{id}', [$c, 'update']);
$app->delete('/customers/{id}', [$c, 'destroy']);

