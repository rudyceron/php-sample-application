<?php
#update host
return new PDO("mysql:host=ldb;dbname=sample", "sampleuser", "samplepass", [PDO::ATTR_PERSISTENT => true]);
