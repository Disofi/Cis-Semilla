<?php
include('inc/conexion.php');
$valor1=$_POST['anoini'];
$valor2=$_POST['anoaingresar'];
echo $valor1."anoini";
echo $valor2."anorecibe";
$sel22="insert into DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON(id,idcuenta,valor,codicc,idnivel,suma,bdsession ,ano ,mes) select id,idcuenta,valor,codicc,idnivel,suma,bdsession ,ano ,mes from DS_DistribucionCC where  ano='".$_POST['anoini']."'";
sqlsrv_query($conn, $sel22, array(), array('Scrollable' => 'buffered'));
$sel23="update DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON set   ano='".$_POST['anoaingresar']."'";
sqlsrv_query($conn, $sel23, array(), array('Scrollable' => 'buffered'));
$sel33="insert into DSCIS.dbo.DS_DistribucionCC (idcuenta,valor,codicc,idnivel,suma,bdsession,mes ,ano) select idcuenta,valor,codicc,idnivel,suma,bdsession,mes ,ano from DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON";
sqlsrv_query($conn, $sel33, array(), array('Scrollable' => 'buffered'));
$sel44="delete from  DSCIS.dbo.DS_DISTRICION_CUENTAS_CLON";
sqlsrv_query($conn, $sel44, array(), array('Scrollable' => 'buffered'));;
?>
	
	