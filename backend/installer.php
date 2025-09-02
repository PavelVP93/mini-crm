<?php
// installer.php
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'POST') {
  header('Content-Type: text/plain; charset=utf-8');

  $DB_HOST = $_POST['DB_HOST'] ?? '127.0.0.1';
  $DB_NAME = $_POST['DB_NAME'] ?? 'fishingpos';
  $DB_USER = $_POST['DB_USER'] ?? 'root';
  $DB_PASS = $_POST['DB_PASS'] ?? '';
  $CORS    = $_POST['CORS_ALLOW_ORIGIN'] ?? '*';

  // 1) Пишем .env
  $env = "DB_HOST={$DB_HOST}\nDB_NAME={$DB_NAME}\nDB_USER={$DB_USER}\nDB_PASS={$DB_PASS}\nCORS_ALLOW_ORIGIN={$CORS}\n";
  if (@file_put_contents(__DIR__ . '/.env', $env) === false) {
    http_response_code(500);
    echo "Не удалось записать .env\n";
    exit;
  }
  echo "[OK] .env создан\n";

  // 2) Подключаемся к MySQL и накатываем схему
  try {
    $pdo = new PDO(
      "mysql:host={$DB_HOST};dbname={$DB_NAME};charset=utf8mb4",
      $DB_USER,
      $DB_PASS,
      [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
      ]
    );
  } catch (Throwable $e) {
    http_response_code(500);
    echo "[ERR] Подключение к БД: " . $e->getMessage() . "\n";
    exit;
  }
  echo "[OK] Подключение к БД\n";

  $schemaFile = __DIR__ . '/sql/schema.mysql.sql';
  if (!file_exists($schemaFile)) {
    http_response_code(500);
    echo "[ERR] Не найден файл схемы: $schemaFile\n";
    exit;
  }

  try {
    $sql = file_get_contents($schemaFile);
    $pdo->exec($sql);
    echo "[OK] Схема установлена\n";
  } catch (Throwable $e) {
    http_response_code(500);
    echo "[ERR] Ошибка применения схемы: " . $e->getMessage() . "\n";
    exit;
  }

  echo "Готово. Проверьте /health\n";
  exit;
}

// GET → HTML-форма
header('Content-Type: text/html; charset=utf-8');
$hasEnv = file_exists(__DIR__.'/.env');
?>
<!doctype html>
<html lang="ru">
<meta charset="utf-8">
<title>Fishing POS API — Installer</title>
<style>
  body{font-family:system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif; margin:2rem;}
  form{max-width:460px;background:#fafafa;border:1px solid #ddd;border-radius:10px;padding:16px}
  label{display:block;margin:8px 0}
  input{width:100%;padding:8px;border:1px solid #ccc;border-radius:8px}
  button{margin-top:12px;padding:10px 14px;border:0;border-radius:8px;background:#0ea5e9;color:#fff;cursor:pointer}
  .hint{color:#555;margin-top:10px}
  .ok{color:#16a34a}
</style>
<h2>Fishing POS API — Installer</h2>

<?php if ($hasEnv): ?>
  <p class="ok">Файл <code>.env</code> уже существует. При повторной установке он будет перезаписан.</p>
<?php endif; ?>

<form method="post">
  <label>DB_HOST
    <input name="DB_HOST" value="127.0.0.1" required>
  </label>
  <label>DB_NAME
    <input name="DB_NAME" value="fishingpos" required>
  </label>
  <label>DB_USER
    <input name="DB_USER" value="root" required>
  </label>
  <label>DB_PASS
    <input name="DB_PASS" type="password" value="root">
  </label>
  <label>CORS_ALLOW_ORIGIN
    <input name="CORS_ALLOW_ORIGIN" value="*">
  </label>
  <button type="submit">Install</button>
</form>

<p class="hint">После установки откройте <code>/health</code> — должен быть JSON со статусом.</p>
</html>
