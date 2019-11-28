<?php
include ('inc/conexion.php');

$sel = "SELECT * FROM ".$dbs.".[cwtdetl] WHERE Libro='C'";
$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
while ($rowa = sqlsrv_fetch_array($res))
	{
	//1
	$DetLi[1]   = $rowa['DetLi1'];
	$DetCol[1]  = $rowa['DetCol1'];
	$DetTi[1]   = $rowa['DetTi1'];
	$PcCodi[1]  = $rowa['PcCodi1'];
	$afecIVA[1] = $rowa['afecIVA1'];
	$EsNeto[1]  = $rowa['EsNeto1'];
	//2 
	$DetLi[2]   = $rowa['DetLi2'];
	$DetCol[2]  = $rowa['DetCol2'];
	$DetTi[2]   = $rowa['DetTi2']; 
	$PcCodi[2]  = $rowa['PcCodi2'];
	$afecIVA[2] = $rowa['afecIVA2'];
	$EsNeto[2]  = $rowa['EsNeto2'];
	//3
	$DetLi[3]   = $rowa['DetLi3'];
	$DetCol[3]  = $rowa['DetCol3'];
	$DetTi[3]   = $rowa['DetTi3']; 
	$PcCodi[3]  = $rowa['PcCodi3'];
	$afecIVA[3] = $rowa['afecIVA3'];
	$EsNeto[3]  = $rowa['EsNeto3'];
	//4
	$DetLi[4]   = $rowa['DetLi4'];
	$DetCol[4]  = $rowa['DetCol4'];
	$DetTi[4]   = $rowa['DetTi4']; 
	$PcCodi[4]  = $rowa['PcCodi4'];
	$afecIVA[4] = $rowa['afecIVA4'];
	$EsNeto[4]  = $rowa['EsNeto4'];
	//5
	$DetLi[5]   = $rowa['DetLi5'];
	$DetCol[5]  = $rowa['DetCol5'];
	$DetTi[5]   = $rowa['DetTi5']; 
	$PcCodi[5]  = $rowa['PcCodi5'];
	$afecIVA[5] = $rowa['afecIVA5'];
	$EsNeto[5]  = $rowa['EsNeto5'];
	//6
	$DetLi[6]   = $rowa['DetLi6'];
	$DetCol[6]  = $rowa['DetCol6'];
	$DetTi[6]   = $rowa['DetTi6']; 
	$PcCodi[6]  = $rowa['PcCodi6'];
	$afecIVA[6] = $rowa['afecIVA6'];
	$EsNeto[6]  = $rowa['EsNeto6'];
	//7
	$DetLi[7]   = $rowa['DetLi7'];
	$DetCol[7]  = $rowa['DetCol7'];
	$DetTi[7]   = $rowa['DetTi7']; 
	$PcCodi[7]  = $rowa['PcCodi7'];
	$afecIVA[7] = $rowa['afecIVA7'];
	$EsNeto[7]  = $rowa['EsNeto7'];
	//8
	$DetLi[8]   = $rowa['DetLi8'];
	$DetCol[8]  = $rowa['DetCol8'];
	$DetTi[8]   = $rowa['DetTi8']; 
	$PcCodi[8]  = $rowa['PcCodi8'];
	$afecIVA[8] = $rowa['afecIVA8'];
	$EsNeto[8]  = $rowa['EsNeto8'];
	//9
	$DetLi[9]   = $rowa['DetLi9'];
	$DetCol[9]  = $rowa['DetCol9'];
	$DetTi[9]   = $rowa['DetTi9']; 
	$PcCodi[9]  = $rowa['PcCodi9'];
	$afecIVA[9] = $rowa['afecIVA9'];
	$EsNeto[9]  = $rowa['EsNeto9'];
	//GRALES
	$ColIVA   	 = $rowa['ColIVA'];
	$ColLey18211 = $rowa['ColLey18211'];
	}
if ($res)
	{
	for ($xx=1;$xx<10;$xx++)
		{
		$sela = "SELECT PCCCOS, PCDETG FROM ".$dbs.".[cwpctas] where PCCODI='".$PcCodi[1]."'";
		$resa = sqlsrv_query($conn, $sela, array(), array('Scrollable' => 'buffered'));
		$rowa = sqlsrv_fetch_array($resa);
		$PcCcos[$xx] = $rowa['PCCCOS'];
		$PcDetg[$xx] = $rowa['PCDETG'];
		}
	}