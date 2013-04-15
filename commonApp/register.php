<?php
	session_start();
	include("header.php");
	if(isset($_GET["msg"])) {
		echo $_GET["msg"];
	}
?>
	<form method="post" action="usrregister.php">
		Username: <input type="text" name="username"/> <br>
		E-mail: <input type="text" name="email"/> <br>
		Password: <input type="password" name="password"/> <br>
		Confirm password: <input type="password" name="confirm"/><br>
		<input type="submit" value="Register"/>
	</form>

<?php
	include("footer.php");
?>