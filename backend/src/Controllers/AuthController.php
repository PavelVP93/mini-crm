<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;
class AuthController {
  public function login($req,$res){
    $d=json_decode((string)$req->getBody(), true);
    if(json_last_error()!==JSON_ERROR_NONE){ return json($res,['error'=>'Invalid JSON'],400); }
    $d=(array)$d;
    $email=$d['email']??'';
    $password=$d['password']??'';
    $st=DB::pdo()->prepare("SELECT id,passwordHash FROM users WHERE email=?");
    $st->execute([$email]);
    $u=$st->fetch();
    if(!$u||!password_verify($password,$u['passwordHash']??'')){
      return json($res,['error'=>'Unauthorized'],401);
    }
    $token=base64_encode(random_bytes(24));
    $res=$res->withHeader('Set-Cookie',"token={$token}; Path=/; HttpOnly; Secure");
    return json($res,['token'=>$token]);
  }
}
