<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class CatalogController {
  public function list($req,$res){
    $q = DB::pdo()->query("SELECT * FROM catalog_item ORDER BY name ASC");
    return json($res,$q->fetchAll());
  }
  public function create($req,$res){
    $d = (array) json_decode((string)$req->getBody(), true);
    $id = self::cuid('c');
    DB::pdo()->prepare("INSERT INTO catalog_item (id,name,code) VALUES (?,?,?)")
      ->execute([$id,$d['name'],$d['code']??null]);
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id']; $d=(array) json_decode((string)$req->getBody(), true);
    $fields=[];$vals=[];
    foreach(['name','code'] as $f){ if(array_key_exists($f,$d)){ $fields[]="$f=?"; $vals[]=$d[$f]; } }
    if($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE catalog_item SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    return json($res,['ok'=>true]);
  }
  public function delete($req,$res,$args){
    DB::pdo()->prepare("DELETE FROM catalog_item WHERE id=?")->execute([$args['id']]);
    return json($res,['ok'=>true]);
  }
  private static function cuid($p){ return $p.'_'.bin2hex(random_bytes(9)); }
}
