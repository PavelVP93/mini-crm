<?php
require __DIR__.'/../vendor/autoload.php';
require __DIR__.'/../src/Time.php';
use App\Time;
assert(Time::fromClient('2024-05-01T09:00:00Z')==='2024-05-01 12:00:00');
assert(Time::toClient('2024-05-01 12:00:00')==='2024-05-01T12:00:00+03:00');
echo "Time tests passed\n";
