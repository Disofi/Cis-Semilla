<?php
include('inc/conexion.php');
$valor1=$_POST['anoini'];
$valor2=$_POST['mesini'];
$valor3=$_POST['anoaingresar'];
$valor4=$_POST['mesaingresar'];


$sel="insert into DSCIS.dbo.DS_AGRUPACION_CUENTAS_CLON(idnivel,pccodi,desctitulo,bdsession,mes ,ano) select idnivel,pccodi,desctitulo,bdsession,mes ,ano from rsphola.dbo.DS_AgrupacionCuentas where mes='".$_POST['mesini']."' and ano='".$_POST['anoini']."'";
$sel22="insert into DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON(id,idcuenta,valor,codicc,idnivel,suma,bdsession ,ano ,mes) select id,idcuenta,valor,codicc,idnivel,suma,bdsession ,ano ,mes from DS_DistribucionCC where mes='".$_POST['mesini']."' and ano='".$_POST['anoini']."'";
sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
sqlsrv_query($conn, $sel22, array(), array('Scrollable' => 'buffered'));
$sel1="update DSCIS.dbo.DS_AGRUPACION_CUENTAS_CLON set mes='".$_POST['mesaingresar']."' , ano='".$_POST['anoaingresar']."'";
$sel23="update DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON set mes='".$_POST['mesaingresar']."' , ano='".$_POST['anoaingresar']."'";
 sqlsrv_query($conn, $sel1, array(), array('Scrollable' => 'buffered'));
sqlsrv_query($conn, $sel23, array(), array('Scrollable' => 'buffered'));
$sel3="insert into DSCIS.dbo.DS_AgrupacionCuentas (idnivel,pccodi,desctitulo,bdsession,mes ,ano) select idnivel,pccodi,desctitulo,bdsession,mes ,ano from  DSCIS.dbo.DS_AGRUPACION_CUENTAS_CLON";
 $sel33="insert into DSCIS.dbo.DS_DistribucionCC (idcuenta,valor,codicc,idnivel,suma,bdsession,mes ,ano) select idcuenta,valor,codicc,idnivel,suma,bdsession,mes ,ano from DSCIS.dbo.DS_DISTRIBUCION_CUENTAS_CLON";
sqlsrv_query($conn, $sel3, array(), array('Scrollable' => 'buffered'));
sqlsrv_query($conn, $sel33, array(), array('Scrollable' => 'buffered'));
$sel4="delete from  DSCIS.dbo.DS_AGRUPACION_CUENTAS_CLON";
 $sel44="delete from  DSCIS.dbo.DS_DISTRICION_CUENTAS_CLON";
sqlsrv_query($conn, $sel4, array(), array('Scrollable' => 'buffered'));
sqlsrv_query($conn, $sel44, array(), array('Scrollable' => 'buffered'));;

?>
	
	