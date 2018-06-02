<?php
$redis = new Redis();
//$redis->connect('127.0.0.1');
$redis->connect('/run/redis.sock');

$option = array('cost' => 12);
$hash = password_hash('rune', PASSWORD_BCRYPT, $option);

$redis->set('password', $hash);
