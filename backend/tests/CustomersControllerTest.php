<?php
require_once __DIR__.'/TestSupport.php';

use App\Controllers\CustomersController;
use App\DB;

// Ensure superglobal is ignored
$_GET['q'] = 'wrong';

// Stub PDO to capture parameters
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

// Stub request with query parameters
$req = new class {
    public function getQueryParams(){ return ['q'=>'needle']; }
};

$res = new \stdClass();

$controller = new CustomersController();
$controller->search($req,$res);

assert(DB::$pdo->executed === ['%needle%','%needle%','%needle%']);
echo "CustomersController tests passed\n";
