<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use App\Time;
use function App\json;

class ReservationsController {
  public function list($req,$res){
    $from=$_GET['from']??null; $to=$_GET['to']??null;
    if($from&&$to){
      $st=DB::pdo()->prepare("SELECT * FROM reservation WHERE startAt>=? AND endAt<=? ORDER BY startAt DESC");
      $st->execute([Time::fromClient($from),Time::fromClient($to)]);
      $rows=$st->fetchAll();
    } else {
      $st=DB::pdo()->query("SELECT * FROM reservation ORDER BY startAt DESC LIMIT 200");
      $rows=$st->fetchAll();
    }
    foreach($rows as &$r){$r['startAt']=Time::toClient($r['startAt']);$r['endAt']=Time::toClient($r['endAt']);}
    return json($res,$rows);
  }
  public function create($req,$res){
    $d=(array) json_decode((string)$req->getBody(), true);
    $id='r_'.bin2hex(random_bytes(9));
    try{$start=Time::fromClient($d['startAt']);$end=Time::fromClient($d['endAt']);}catch(\Exception $e){return json($res,['error'=>'Invalid datetime'],400);}
    DB::pdo()->prepare("INSERT INTO reservation (id,resourceId,customerId,status,startAt,endAt,prepayAmount,notes) VALUES (?,?,?,?,?,?,?,?)")
      ->execute([$id,$d['resourceId'],$d['customerId'],$d['status']??'HELD',$start,$end,$d['prepayAmount']??null,$d['notes']??null]);
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id']; $d=(array) json_decode((string)$req->getBody(), true);
    $fields=[];$vals=[];
    foreach(['status','startAt','endAt','prepayAmount','notes'] as $f){
      if(array_key_exists($f,$d)){
        $fields[]="$f=?";
        if(in_array($f,['startAt','endAt'])){
          try{$vals[]=Time::fromClient($d[$f]);}catch(\Exception $e){return json($res,['error'=>'Invalid datetime'],400);} 
        } else $vals[]=$d[$f];
      }
    }
    if($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE reservation SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    return json($res,['ok'=>true]);
  }
}