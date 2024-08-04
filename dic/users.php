<?php
require_once __DIR__ . '/../vendor/autoload.php';

return new Service\UsersService(
    require "../config-dev/db-connection.php"
);
