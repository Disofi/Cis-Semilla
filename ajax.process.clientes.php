<?php
session_start();
include('inc/conexion.php');
include('inc/funciones.php');

if(isset($_GET['term']))
	{
	$textoBuscar = trim(sanitize($_GET['term']));
	ConsultaClientes($textoBuscar);
	}
?>