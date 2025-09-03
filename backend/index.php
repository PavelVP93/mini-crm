<?php
declare(strict_types=1);

// Временное раскрытие ошибок (можно убрать после починки)
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);
set_error_handler(function($severity,$message,$file,$line){ throw new ErrorException($message,0,$severity,$file,$line); });

try {
  require __DIR__ . '/vendor/autoload.php';
} catch (Throwable $e) {
  http_response_code(500);
  header('Content-Type: text/plain; charset=utf-8');
  echo "Autoload error: " . $e->getMessage() . "\n";
  echo "Check that vendor/autoload.php exists and permissions 644/755.\n";
  exit;
}

use Slim\Factory\AppFactory;
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Psr7\Response;

// env (могут не быть на этапе до installer)
if (file_exists(__DIR__ . '/.env')) {
  try {
    (Dotenv\Dotenv::createImmutable(__DIR__))->load();
  } catch (Throwable $e) {
    // не критично для стартовой страницы
  }
}

$app = AppFactory::create();

// CORS
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

// Маршрутизация и обработчик ошибок
$app->addRoutingMiddleware();
$error = $app->addErrorMiddleware(true, true, true);
$error->setDefaultErrorHandler(function($request, $e) {
  $res = new Response();
  $res->getBody()->write(json_encode(['error'=>$e->getMessage()], JSON_UNESCAPED_UNICODE));
  return $res->withHeader('Content-Type','application/json')->withStatus(500);
});

// Базовый маршрут (чтобы проверить без БД)
$app->get('/health', function($req,$res){
  $res->getBody()->write(json_encode(['status'=>'ok','time'=>date('c')], JSON_UNESCAPED_UNICODE));
  return $res->withHeader('Content-Type','application/json');
});

// Подключаем твои файлы, если есть
$helpers = __DIR__.'/src/helpers.php';
$db      = __DIR__.'/src/db.php';
$routes  = __DIR__.'/src/routes.php';
if (file_exists($helpers)) require $helpers;
if (file_exists($db))      require $db;
if (file_exists($routes))  require $routes;

$app->run();
