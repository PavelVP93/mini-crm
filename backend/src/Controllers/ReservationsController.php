<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class ReservationsController {
  public function list($req,$res){
    $from=$_GET['from']??null; $to=$_GET['to']??null;
    if($from&&$to){
      $st=DB::pdo()->prepare("SELECT * FROM reservation WHERE startAt>=? AND endAt<=? ORDER BY startAt DESC");
      $st->execute([$from,$to]); return json($res,$st->fetchAll());
    }
    $st=DB::pdo()->query("SELECT * FROM reservation ORDER BY startAt DESC LIMIT 200");
    return json($res,$st->fetchAll());
  }
  public function create($req,$res){
    $d=(array) json_decode((string)$req->getBody(), true);
    $id='r_'.bin2hex(random_bytes(9));
    DB::pdo()->prepare("INSERT INTO reservation (id,resourceId,customerId,status,startAt,endAt,prepayAmount,notes) VALUES (?,?,?,?,?,?,?,?)")
      ->execute([$id,$d['resourceId'],$d['customerId'],$d['status']??'HELD',$d['startAt'],$d['endAt'],$d['prepayAmount']??null,$d['notes']??null]);
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id']; $d=(array) json_decode((string)$req->getBody(), true);
    $fields=[];$vals=[];
    foreach(['status','startAt','endAt','prepayAmount','notes'] as $f) if(array_key_exists($f,$d)){ $fields[]="$f=?"; $vals[]=$d[$f]; }
    if($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE reservation SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    return json($res,['ok'=>true]);
  }
}