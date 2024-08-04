<?php
require_once __DIR__ . '/../vendor/autoload.php';

return new Service\TweetsService(
    require "../config-dev/db-connection.php"
);
