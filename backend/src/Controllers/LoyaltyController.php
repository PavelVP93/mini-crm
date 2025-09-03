<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class LoyaltyController {
  public function list($req,$res){
    $q = DB::pdo()->query("SELECT * FROM loyalty_program ORDER BY name ASC");
    return json($res,$q->fetchAll());
  }
  public function create($req,$res){
    $d = (array) json_decode((string)$req->getBody(), true);
    $id = self::cuid('lp');
    DB::pdo()->prepare("INSERT INTO loyalty_program (id,name,discount) VALUES (?,?,?)")
      ->execute([$id,$d['name'],$d['discount']??null]);
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id']; $d=(array) json_decode((string)$req->getBody(), true);
    $fields=[];$vals=[];
    foreach(['name','discount'] as $f){ if(array_key_exists($f,$d)){ $fields[]="$f=?"; $vals[]=$d[$f]; } }
    if ($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE loyalty_program SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    return json($res,['ok'=>true]);
  }
  public function delete($req,$res,$args){
    $id=$args['id'];
    DB::pdo()->prepare("DELETE FROM loyalty_program WHERE id=?")->execute([$id]);
    return json($res,['ok'=>true]);
  }
  private static function cuid($p){ return $p.'_'.bin2hex(random_bytes(9)); }
}
