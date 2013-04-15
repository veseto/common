<?php
$mysql_hostname = "localhost";
$mysql_user = "fefe_expenses";
$mysql_password = "WH]y@CZUV(q*";
$mysql_database = "fefe_commonexpenses";
$prefix = "";
$bd = mysql_connect($mysql_hostname, $mysql_user, $mysql_password) or die("Could not connect database");
mysql_select_db($mysql_database, $bd) or die("Could not select database");
?>