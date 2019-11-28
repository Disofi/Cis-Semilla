<?php
$a = $_GET['a'];

include('conexion.php');

$sel = "SELECT codaux FROM ".$dbs.".[cwtauxi] where CodAux='".$a."'";
$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
$num = sqlsrv_num_rows($res);
if($num==0 ) 
    { 
    $vrd = '0';
    }
else 
    { 
    $vrd = '1';
    }
echo $vrd;
?>