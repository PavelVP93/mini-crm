<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class CustomersController {
  public function list($req,$res){
    $params=$req->getQueryParams();
    $q=$params['q']??'';
    if($q){
      $st=DB::pdo()->prepare("SELECT c.*,GROUP_CONCAT(cp.phone) phones FROM customer c LEFT JOIN customer_phones cp ON cp.customerId=c.id WHERE c.fullName LIKE ? OR c.phone LIKE ? OR cp.phone LIKE ? GROUP BY c.id ORDER BY c.createdAt DESC LIMIT 200");
      $st->execute(["%$q%","%$q%","%$q%"]); 
    } else {
      $st=DB::pdo()->query("SELECT c.*,GROUP_CONCAT(cp.phone) phones FROM customer c LEFT JOIN customer_phones cp ON cp.customerId=c.id GROUP BY c.id ORDER BY c.createdAt DESC LIMIT 200");
    }
    $rows=$st->fetchAll();
    foreach($rows as &$r){ $r['phones']=$r['phones']?explode(',',$r['phones']):[]; }
    return json($res,$rows);
  }
  public function search($req,$res){
    $params=$req->getQueryParams();
    $q=$params['q']??'';
    if(!$q){ return json($res,[]); }
    $st=DB::pdo()->prepare("SELECT c.*,GROUP_CONCAT(cp.phone) phones FROM customer c LEFT JOIN customer_phones cp ON cp.customerId=c.id WHERE c.fullName LIKE ? OR c.phone LIKE ? OR cp.phone LIKE ? GROUP BY c.id ORDER BY c.fullName LIMIT 200");
    $like="%$q%";
    $st->execute([$like,$like,$like]);
    $rows=$st->fetchAll();
    foreach($rows as &$r){ $r['phones']=$r['phones']?explode(',',$r['phones']):[]; }
    return json($res,$rows);
  }
  public function create($req,$res){
    $d=(array) json_decode((string)$req->getBody(), true);
    $phones=$d['phones']??(isset($d['phone'])?[$d['phone']]:[]);
    $phones=array_values(array_filter($phones));
    if(!$phones){ return json($res,['error'=>'Phone required'],400); }
    foreach($phones as $p){ if(!preg_match('/^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$/',$p)){ return json($res,['error'=>'Invalid phone'],400); } }
    $id='c_'.bin2hex(random_bytes(9));
    DB::pdo()->prepare("INSERT INTO customer (id,fullName,phone,email,birthday,notes,createdAt) VALUES (?,?,?,?,?,?,NOW())")
      ->execute([$id,$d['fullName'],$phones[0],$d['email']??null,$d['birthday']??null,$d['notes']??null]);
    $ins=DB::pdo()->prepare("INSERT INTO customer_phones (customerId,phone) VALUES (?,?)");
    foreach($phones as $p){ $ins->execute([$id,$p]); }
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id'];
    $d=(array) json_decode((string)$req->getBody(), true);
    $phones=$d['phones']??(isset($d['phone'])?[$d['phone']]:null);
    if($phones!==null){
      $phones=array_values(array_filter($phones));
      if(!$phones){ return json($res,['error'=>'Phone required'],400); }
      foreach($phones as $p){ if(!preg_match('/^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$/',$p)){ return json($res,['error'=>'Invalid phone'],400); } }
    }
    $fields=[];$vals=[];
    foreach(['fullName','email','birthday','notes'] as $f){ if(array_key_exists($f,$d)){ $fields[]="$f=?"; $vals[]=$d[$f]; } }
    if($phones!==null){ $fields[]='phone=?'; $vals[]=$phones[0]; }
    if($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE customer SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    if($phones!==null){
      DB::pdo()->prepare("DELETE FROM customer_phones WHERE customerId=?")->execute([$id]);
      $ins=DB::pdo()->prepare("INSERT INTO customer_phones (customerId,phone) VALUES (?,?)");
      foreach($phones as $p){ $ins->execute([$id,$p]); }
    }
    return json($res,['ok'=>true]);
  }
  public function destroy($req,$res,$args){
    $id=$args['id'];
    DB::pdo()->prepare("DELETE FROM customer WHERE id=?")->execute([$id]);
    return json($res,['ok'=>true]);
  }
}
