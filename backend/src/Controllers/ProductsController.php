<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class ProductsController {
  public function list($req,$res){
    $q = DB::pdo()->prepare("SELECT p.*,
      (SELECT price FROM price WHERE productId=p.id AND (validTo IS NULL OR validTo>=NOW()) ORDER BY validFrom DESC LIMIT 1) AS currentPrice
      FROM product p WHERE isActive=1 ORDER BY name ASC");
    $q->execute();
    return json($res,$q->fetchAll());
  }
  public function create($req,$res){
    $d = (array) json_decode((string)$req->getBody(), true);
    $id = self::cuid('p');
    DB::pdo()->prepare("INSERT INTO product (id,name,sku,type,unit,isWeightable,isActive,taxCode,groupId) VALUES (?,?,?,?,?,?,?,?,?)")
      ->execute([$id,$d['name'],$d['sku']??null,$d['type'],$d['unit'],(int)($d['isWeightable']??0),(int)($d['isActive']??1),$d['taxCode']??null,$d['groupId']??null]);
    if (isset($d['price'])) {
      DB::pdo()->prepare("INSERT INTO price (id,productId,price,currency,validFrom) VALUES (?,?,?,?,NOW())")
        ->execute([self::cuid('pr'),$id,$d['price'],'RUB']);
    }
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id']; $d=(array) json_decode((string)$req->getBody(), true);
    $fields=[];$vals=[];
    foreach(['name','sku','type','unit','isWeightable','isActive','taxCode','groupId'] as $f){ if(array_key_exists($f,$d)){ $fields[]="$f=?"; $vals[]=$d[$f]; } }
    if ($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE product SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    if (isset($d['price'])) {
      DB::pdo()->prepare("UPDATE price SET validTo=NOW() WHERE productId=? AND validTo IS NULL")->execute([$id]);
      DB::pdo()->prepare("INSERT INTO price (id,productId,price,currency,validFrom) VALUES (?,?,?,?,NOW())")
        ->execute([self::cuid('pr'),$id,$d['price'],'RUB']);
    }
    return json($res,['ok'=>true]);
  }
  private static function cuid($p){ return $p.'_'.bin2hex(random_bytes(9)); }
}