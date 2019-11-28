<?php
$a = $_GET['a'];
$b = $_GET['b'];
$c = $_GET['c'];

include('conexion.php');

$sel = "SELECT codaux FROM ".$dbs.".[cwingdoccv] where CodAux='".$b."' AND TtdCod='".$c."' and NumDoc=".floatval($a)."";
$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
$num = sqlsrv_num_rows($res);

$sel1 = "SELECT codaux FROM ".$dba.".[cwingdoccv] where CodAux='".$b."' AND TtdCod='".$c."' and NumDoc=".floatval($a)."";
$res1 = sqlsrv_query($conn, $sel1, array(), array('Scrollable' => 'buffered'));
$num1 = sqlsrv_num_rows($res1);

if($num==0 && $num1 ==0) 
    { 
    $vrd = '0';
    }
else 
    { 
    $vrd = '1';
    }
echo $vrd;
?>