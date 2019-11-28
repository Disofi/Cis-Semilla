<?php
session_start();

require('head.php');
if (empty($_SESSION['user']['id']))
	{
	header('Location: login.php');
	}
else
	{
	require ('menu.php');
	if (isset($_GET['mod']))
		{
		$pagina = $_GET['mod'];
		$pagina = $pagina.".php";
		require ($pagina);
		}
	else
		{
		require ('inicio.php');
		}
	}
require('footer.php');
?>