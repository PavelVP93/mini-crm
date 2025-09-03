<?php
namespace App;

if (!function_exists(__NAMESPACE__.'\\json')) {
    function json($res, $data, $status = 200) {
        $res->body = $data;
        $res->status = $status;
        return $res;
    }
}

if (!class_exists(__NAMESPACE__.'\\DB')) {
    class DB {
        public static $pdo;
        public static function pdo() {
            return self::$pdo;
        }
    }
}
