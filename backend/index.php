<?php
declare(strict_types=1);
require __DIR__ . '/vendor/autoload.php';

use Dotenv\Dotenv;
use Slim\Factory\AppFactory;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Psr7\Response;

// подхват .env (создастся позже installer.php)
if (file_exists(__DIR__.'/.env')) {
  Dotenv::createImmutable(__DIR__)->load();
}

$app = AppFactory::create();

/** CORS */
$app->add(function(Request $req, RequestHandlerInterface $handler) {
  $resp = $handler->handle($req);
  $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
  $allow = $_ENV['CORS_ALLOW_ORIGIN'] ?? $origin;
  $r = $resp->withHeader('Access-Control-Allow-Origin', $allow)
            ->withHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET,POST,PATCH,PUT,DELETE,OPTIONS')
            ->withHeader('Access-Control-Allow-Credentials', 'true');
  if ($req->getMethod()==='OPTIONS') return $r->withStatus(204);
  return $r;
});

$app->addRoutingMiddleware();
$error = $app->addErrorMiddleware(true, true, true);
$error->setDefaultErrorHandler(function($request, $e) {
  $res = new Response();
  $res->getBody()->write(json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE));
  return $res->withHeader('Content-Type','application/json')->withStatus(500);
});

/** Минимальный маршрут для проверки */
$app->get('/health', function($req,$res){
  $res->getBody()->write(json_encode(['status'=>'ok','time'=>date('c')], JSON_UNESCAPED_UNICODE));
  return $res->withHeader('Content-Type','application/json');
});

/** Если у тебя уже есть routes.php/контроллеры — подключай ниже */
$routes = __DIR__ . '/src/routes.php';
if (file_exists($routes)) { require $routes; }

$app->run();
