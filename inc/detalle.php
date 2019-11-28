<?php
include ('conexion.php');
session_start();
$a = $_GET['a'];
$b = $_GET['b'];
if (isset($_GET['c']))
	{
	$c = $_GET['c'];
	$d = $_GET['d'];
	$sel = "SELECT numdet, pctcod, dgacod, cccod, linea, monto FROM ".$dba.".[cwdetingdoc] WHERE linea!='0' AND CodAux='".$a."' AND ttdCod='".$b."' AND NumDoc='".$c."' AND MovNum='".$d."'";
	}
else
	{
	$sel = "SELECT numdet, pctcod, dgacod, cccod, linea FROM ".$dba.".[DetLibro] WHERE empresa='".$_SESSION['emp']['id']."' AND codaux='".$b."' AND ttdcod='".$a."'";
	}
//print $sel;
$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
$num = sqlsrv_num_rows($res);
if ($num > 0)
	{
	$j=0;
	while ($row = sqlsrv_fetch_array($res))
		{
		$numdet[$j] = $row['numdet'];
		$pctcod[$j] = $row['pctcod'];
		$dgacod[$j] = $row['dgacod'];
		$cccod[$j]  = $row['cccod'];
		$lineas[$j] = $row['linea'];
		if (isset($_GET['c']))
			{
			$monto[$j]  = $row['monto'];
			}
		$j++;
		}
	if (isset($_GET['c']))
		{
		$respuesta = array('valor' => '1', 'numdet' => $numdet, 'pctcod' => $pctcod, 'dgacod' => $dgacod, 'cccod' => $cccod, 'lineas' => $lineas, 'monto' => $monto);
		}
	else
		{
		$respuesta = array('valor' => '1', 'numdet' => $numdet, 'pctcod' => $pctcod, 'dgacod' => $dgacod, 'cccod' => $cccod, 'lineas' => $lineas );
		}
	}
else 
	{
	$respuesta = array('valor' => '0');
	}

echo json_encode($respuesta);