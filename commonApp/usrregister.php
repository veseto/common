<?php
	session_start();
	$message="";
	$ios=$_POST["ios"];
	if (!empty($_POST["username"]) && !empty($_POST["email"]) && !empty($_POST["password"]) && !empty($_POST["confirm"])) {
		$username=$_POST["username"];
		$email=$_POST["email"];
		$password=$_POST["password"];
		$confirm=$_POST["confirm"];
		if ($password == $confirm) {
			include("connection.php");
			$result=mysql_query("SELECT * FROM user WHERE username='".mysql_real_escape_string($username)."' OR email='".mysql_real_escape_string($email)."'");
			$array=mysql_fetch_array($result);
			if ($array['username'] == $username) {
				$message = "Username already exists";
			} else if ($array['email'] == $email) {
				$message = "Email already in use";
			} else {
				mysql_query("INSERT INTO user (username, password, email) VALUES ('".mysql_real_escape_string($username)."','".sha1(mysql_real_escape_string($password))."','".mysql_real_escape_string($email)."')");
				$result=mysql_query("SELECT * FROM user WHERE username='".mysql_real_escape_string($username)."'");
				$array=mysql_fetch_array($result);
				if (isset($ios)){
					$response = array('userid' => $array["userid"], 'username' => $array["username"], 'email' => $array["email"], 'password' => $array["password"]);
					echo json_encode($response);
				} else {
					$_SESSION["uid"] = $array["userid"];
					$message = "OK";
				}
			}
		} else {
			$message = "Passwords don't match";
		}
	} else {
		$message = "Fill all fields";
	}
	if (!isset($ios)) {
		header("Location: register.php?msg=".urldecode($message));
	}
?>