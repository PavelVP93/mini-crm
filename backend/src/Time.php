<?php
namespace App;
class Time {
    const TZ = 'Europe/Moscow';
    public static function fromClient(string $iso): string {
        $dt = new \DateTime($iso);
        $dt->setTimezone(new \DateTimeZone(self::TZ));
        return $dt->format('Y-m-d H:i:s');
    }
    public static function toClient(string $db): string {
        $dt = new \DateTime($db, new \DateTimeZone(self::TZ));
        return $dt->format(DATE_ATOM);
    }
}
