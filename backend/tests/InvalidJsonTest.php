<?php
require_once __DIR__.'/TestSupport.php';

use App\Controllers\{
    CatalogController,
    CustomersController,
    LoyaltyController,
    OrdersController,
    ProductsController,
    ReservationsController,
    RolesController,
    UsersController
};
use App\DB;

$controllers = [
    new CatalogController(),
    new CustomersController(),
    new LoyaltyController(),
    new OrdersController(),
    new ProductsController(),
    new ReservationsController(),
    new RolesController(),
    new UsersController(),
];

foreach ($controllers as $ctrl) {
    DB::$pdo = new class {
        public function prepare($sql){ return new class { public function execute($params){} }; }
        public function query($sql){ return new class { public function fetchAll(){ return []; } }; }
        public function beginTransaction() {}
        public function commit() {}
        public function rollBack() {}
    };
    $req = new class {
        public function getBody(){ return '{'; }
    };
    $res = new \stdClass();
    $out = $ctrl->create($req, $res);
    assert($out->status === 400);
    assert($out->body === ['error'=>'Invalid JSON']);
}

echo "Invalid JSON tests passed\n";
