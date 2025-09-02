<?php
@ini_set('max_execution_time', 0);
header('Content-Type: text/plain; charset=utf-8');
$zipFile = __DIR__ . '/site.zip';
if (!file_exists($zipFile)) { http_response_code(400); echo "site.zip not found\n"; exit; }
$zip = new ZipArchive();
if ($zip->open($zipFile) === TRUE) {
  $zip->extractTo(__DIR__);
  $zip->close();
  echo "Unpacked site.zip\n";
  $ht = __DIR__.'/.htaccess';
  if (!file_exists($ht)) {
    file_put_contents($ht, "AddType application/javascript .js\nAddType text/css .css\nAddType text/html .html\nAddDefaultCharset utf-8\n");
  }
  echo "Done.\n";
} else {
  http_response_code(500);
  echo "Failed to open site.zip\n";
}
