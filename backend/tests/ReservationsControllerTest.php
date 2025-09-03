<?php
require_once __DIR__.'/TestSupport.php';

use App\Controllers\ReservationsController;
use App\DB;
use App\Time;

$_GET['from'] = 'bad';
$_GET['to'] = 'bad';

$fromInput = '2024-05-01T09:00:00Z';
$toInput = '2024-05-01T12:00:00Z';

DB::$pdo = new class {
    public $executed;
    public function prepare($sql){
        return new class($this) {
            private $parent;
            public function __construct($parent){ $this->parent=$parent; }
            public function execute($params){ $this->parent->executed=$params; }
            public function fetchAll(){ return []; }
        };
    }
    public function query($sql){
        return new class {
            public function fetchAll(){ return []; }
        };
    }
};

$req = new class($fromInput, $toInput) {
    private $params;
    public function __construct($from,$to){ $this->params=['from'=>$from,'to'=>$to]; }
    public function getQueryParams(){ return $this->params; }
};

$res = new \stdClass();

$controller = new ReservationsController();
$controller->list($req,$res);

$expected = [Time::fromClient($fromInput), Time::fromClient($toInput)];
assert(DB::$pdo->executed === $expected);
echo "ReservationsController tests passed\n";
