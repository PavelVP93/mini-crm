<?php
declare(strict_types=1);
namespace App\Controllers;
use App\DB;
use function App\json;

class OrdersController {
  public function list($req,$res){
    $st=DB::pdo()->query("SELECT * FROM `order` ORDER BY createdAt DESC LIMIT 200");
    return json($res,$st->fetchAll());
  }
  public function create($req,$res){
    $d=json_decode((string)$req->getBody(), true);
    if(json_last_error()!==JSON_ERROR_NONE){ return json($res,['error'=>'Invalid JSON'],400); }
    $d=(array)$d;
    $pdo=DB::pdo();
    $pdo->beginTransaction();
    try{
      $oid='o_'.bin2hex(random_bytes(9));
      $number=$d['number']??('POS-'.date('Ymd').'-'.str_pad((string)random_int(0,999),3,'0',STR_PAD_LEFT));

      $grand=0;
      foreach($d['items'] as &$it){
        $qty = $it['weightKg'] ?? ($it['qty']??1);
        $unitPrice = $it['unitPrice']??0;
        $it['total'] = $unitPrice * $qty;
        $grand += $it['total'];
      }
      unset($it);

      $pdo->prepare("INSERT INTO `order` (id,number,customerId,cashierId,shiftId,status,createdAt,paidAt,grandTotal) VALUES (?,?,?,?,?,?,?,?,?)")
          ->execute([$oid,$number,$d['customerId']??null,$d['cashierId']??'u_anon',$d['shiftId']??null,$d['status']??'PAID',date('c'),date('c'),$grand]);

      foreach($d['items'] as $it){
        $pdo->prepare("INSERT INTO order_item (id,orderId,productId,qty,weightKg,unitPrice,discountAbs,discountPct,total) VALUES (?,?,?,?,?,?,?,?,?)")
            ->execute(['i_'.bin2hex(random_bytes(9)),$oid,$it['productId'],$it['qty']??1,$it['weightKg']??null,$it['unitPrice']??0,$it['discountAbs']??null,$it['discountPct']??null,$it['total']]);
      }
      foreach($d['payments'] as $p){
        $pdo->prepare("INSERT INTO payment (id,orderId,method,amount) VALUES (?,?,?,?)")
            ->execute(['pay_'.bin2hex(random_bytes(9)),$oid,$p['method'],$p['amount']]);
      }
      $pdo->commit();
      return json($res,['id'=>$oid,'number'=>$number],201);
    }catch(\Throwable $e){ $pdo->rollBack(); throw $e; }
  }
}
