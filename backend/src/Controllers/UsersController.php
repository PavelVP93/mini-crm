<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class UsersController {
  public function list($req,$res){
    $st=DB::pdo()->query("SELECT u.id,u.fullName,u.email,GROUP_CONCAT(r.id) roleIds FROM users u LEFT JOIN user_roles ur ON ur.userId=u.id LEFT JOIN roles r ON r.id=ur.roleId GROUP BY u.id ORDER BY u.fullName");
    $rows=$st->fetchAll();
    foreach($rows as &$r){ $r['roles']=$r['roleIds']?explode(',',$r['roleIds']):[]; unset($r['roleIds']); }
    return json($res,$rows);
  }
  public function create($req,$res){
    $d=json_decode((string)$req->getBody(), true);
    if(json_last_error()!==JSON_ERROR_NONE){ return json($res,['error'=>'Invalid JSON'],400); }
    $d=(array)$d;
    $id='u_'.bin2hex(random_bytes(9));
    $passwordHash=$d['passwordHash']??(isset($d['password'])?password_hash((string)$d['password'],PASSWORD_DEFAULT):null);
    DB::pdo()->prepare("INSERT INTO users (id,fullName,email,passwordHash) VALUES (?,?,?,?)")
      ->execute([$id,$d['fullName'],$d['email']??null,$passwordHash]);
    if(!empty($d['roles'])){
      $ins=DB::pdo()->prepare("INSERT INTO user_roles (userId,roleId) VALUES (?,?)");
      foreach($d['roles'] as $r){ $ins->execute([$id,$r]); }
    }
    return json($res,['id'=>$id],201);
  }
  public function update($req,$res,$args){
    $id=$args['id'];
    $d=json_decode((string)$req->getBody(), true);
    if(json_last_error()!==JSON_ERROR_NONE){ return json($res,['error'=>'Invalid JSON'],400); }
    $d=(array)$d;
    $fields=[];$vals=[];
    foreach(['fullName','email'] as $f){ if(array_key_exists($f,$d)){ $fields[]="$f=?";$vals[]=$d[$f]; } }
    if(array_key_exists('password',$d)){ $fields[]="passwordHash=?";$vals[] = password_hash((string)$d['password'],PASSWORD_DEFAULT); }
    elseif(array_key_exists('passwordHash',$d)){ $fields[]="passwordHash=?";$vals[] = $d['passwordHash']; }
    if($fields){ $vals[]=$id; DB::pdo()->prepare("UPDATE users SET ".implode(',',$fields)." WHERE id=?")->execute($vals); }
    if(array_key_exists('roles',$d)){
      DB::pdo()->prepare("DELETE FROM user_roles WHERE userId=?")->execute([$id]);
      $ins=DB::pdo()->prepare("INSERT INTO user_roles (userId,roleId) VALUES (?,?)");
      foreach($d['roles'] as $r){ $ins->execute([$id,$r]); }
    }
    return json($res,['ok'=>true]);
  }
  public function delete($req,$res,$args){
    $id=$args['id'];
    DB::pdo()->prepare("DELETE FROM users WHERE id=?")->execute([$id]);
    return json($res,['ok'=>true]);
  }
}

