<?php
	session_start();
	include("connection.php");
	$username=$_POST["username"];
	$password=$_POST["password"];
	if (!empty($username) && !empty($password)) {
		$result=mysql_query("SELECT * FROM user WHERE username='".mysql_real_escape_string($username)."' AND password='".sha1(mysql_real_escape_string($password))."'");
		$array=mysql_fetch_array($result);
		if (count($array) > 0) {
			if (isset($_POST["ios"])) {
				echo json_encode($array);
			} else {
				$_SESSION["uid"] = $array["userid"];
				header('Location: index.php') ;
			}
		}
	}
?>