<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class CustomersController {
  public function list($req,$res){
    $q=$_GET['q']??'';
    if($q){
      $st=DB::pdo()->prepare("SELECT * FROM customer WHERE fullName LIKE ? OR phone LIKE ? ORDER BY createdAt DESC LIMIT 200");
      $st->execute(["%$q%","%$q%"]);
      return json($res,$st->fetchAll());
    }
    $st=DB::pdo()->query("SELECT * FROM customer ORDER BY createdAt DESC LIMIT 200");
    return json($res,$st->fetchAll());
  }
  public function create($req,$res){
    $d=(array) json_decode((string)$req->getBody(), true);
    $phone=$d['phone']??'';
    if(!preg_match('/^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$/',$phone)){
      return json($res,['error'=>'Invalid phone'],400);
    }
    $id='c_'.bin2hex(random_bytes(9));
    DB::pdo()->prepare("INSERT INTO customer (id,fullName,phone,email,birthday,notes,createdAt) VALUES (?,?,?,?,?,?,NOW())")
      ->execute([$id,$d['fullName'],$phone,$d['email']??null,$d['birthday']??null,$d['notes']??null]);
    return json($res,['id'=>$id],201);
  }
}