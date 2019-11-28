<?php
error_reporting(0);

$srv = 'srv-disofi';
$usr = 'sa';
$pwd = 'Softland2018';

$dba = '[DSCIS].[dbo]';
$dbs2 = '[CIS].[softland]';
if($_SESSION['emp']['id'] == '') 
	{
		$dbs = '[CIS].[softland]'; 
	}
else 
	{
		$dbs = $_SESSION['emp']['bd']; 
	}

$cnx = array ( 'UID' => $usr, 'PWD' => $pwd, 'CharacterSet' => 'UTF-8', 'Database' => 'DSCIS' );
$conn = sqlsrv_connect($srv, $cnx);
if( $conn === false )
	{
	echo 'No es posible conectarse al servidor :<br />';
	die(print_r(sqlsrv_errors(), true));
	}
?>