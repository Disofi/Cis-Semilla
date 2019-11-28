<?php
$a = $_GET['a'];
$b = $_GET['b'];

include('conexion.php');

$sel = "SELECT EqmVal FROM ".$dbs.".[cwteqmo] WHERE CODMON='".$a."' And EQMFEC='".$b."'";
$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
$row = sqlsrv_fetch_array($res);
$vrd = $row['EqmVal'];
if ($vrd == '') { $vrd = '1'; }

echo $vrd;
?>