<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class RolesController {
  public function list($req,$res){
    $st=DB::pdo()->query("SELECT * FROM roles ORDER BY name");
    return json($res,$st->fetchAll());
  }
  public function create($req,$res){
    $d=(array) json_decode((string)$req->getBody(), true);
    $id='r_'.bin2hex(random_bytes(9));
    DB::pdo()->prepare("INSERT INTO roles (id,name) VALUES (?,?)")->execute([$id,$d['name']]);
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id'];
    $d=(array) json_decode((string)$req->getBody(), true);
    DB::pdo()->prepare("UPDATE roles SET name=? WHERE id=?")->execute([$d['name'],$id]);
    return json($res,['ok'=>true]);
  }
  public function delete($req,$res,$args){
    $id=$args['id'];
    DB::pdo()->prepare("DELETE FROM roles WHERE id=?")->execute([$id]);
    return json($res,['ok'=>true]);
  }
}

