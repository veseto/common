<?php
	if (isset($_SESSION["uid"])) {
		echo "<a href='logout.php'> Log out </a><br>";
	} else {
?>
	<form method="post" action="usrlogin.php">
		Username: <input type="text" name="username"/> <br>
		Password: <input type="password" name="password"/> <br>
		<input type="submit" value="Log in"/>
	</form>
	<i> <a href="register.php"> Register </a> </i> <br>
<?php } 
?>