<?php
use App\Controllers\CustomersController;
use App\Controllers\ProductsController;
use App\Controllers\LoyaltyController;
use App\Controllers\CatalogController;

$c = new CustomersController();
$app->get('/customers', [$c, 'list']);
$app->get('/customers/search', [$c, 'search']);
$app->post('/customers', [$c, 'create']);
$app->patch('/customers/{id}', [$c, 'update']);
$app->delete('/customers/{id}', [$c, 'destroy']);

$p = new ProductsController();
$app->get('/products', [$p, 'list']);
$app->post('/products', [$p, 'create']);
$app->put('/products/{id}', [$p, 'update']);
$app->delete('/products/{id}', [$p, 'delete']);

$l = new LoyaltyController();
$app->get('/loyalty', [$l, 'list']);
$app->post('/loyalty', [$l, 'create']);
$app->put('/loyalty/{id}', [$l, 'update']);
$app->delete('/loyalty/{id}', [$l, 'delete']);

$cat = new CatalogController();
$app->get('/catalog', [$cat, 'list']);
$app->post('/catalog', [$cat, 'create']);
$app->put('/catalog/{id}', [$cat, 'update']);
$app->delete('/catalog/{id}', [$cat, 'delete']);
