<?php
require_once __DIR__.'/TestSupport.php';

use App\Controllers\ReservationsController;
use App\DB;

$body = json_encode([
    'resourceId' => 'g1',
    'customerId' => 'c1',
    'startAt' => '2024-05-01T09:00:00Z',
    'endAt'   => '2024-05-01T10:00:00Z'
]);

DB::$pdo = new class {
    public $executed;
    public function prepare($sql){
        return new class($this) {
            private $parent;
            public function __construct($parent){ $this->parent = $parent; }
            public function execute($params){ $this->parent->executed = $params; }
        };
    }
};

$req = new class($body) {
    private $body;
    public function __construct($body){ $this->body = $body; }
    public function getBody(){ return $this->body; }
};

$res = new \stdClass();

$controller = new ReservationsController();
$out = $controller->create($req, $res);

assert($out->status === 201);
assert(isset($out->body['id']));
assert(DB::$pdo->executed[2] === 'c1');

echo "ReservationsController create test passed\n";
