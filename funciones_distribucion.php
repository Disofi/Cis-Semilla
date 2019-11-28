<?php

$valorcc=$_POST['codicc'];
echo $valorcc;


	function selectCC()
{
	include('inc/conexion.php');
	$salida = "";
	$query = " select CodiCC, DescCC from ".$dbs.".cwtccos where activo = 'S' and DescCC <> '' AND DescCC IS NOT NULL AND nivelCC = 1 ";
	//echo $query."<br>";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="CC" id="CC" class="form-control" onchange="Confirm(this.value);">';
	$salida.='<option value="0">Seleccione Centro de Costo</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' '.$row['DescCC'].' '.$valorcc.'</option>';
		
	}
	$salida.="</select>";
 
	echo $salida;
}

function MostrarDistribucionCC($valor)
{	

	include('inc/conexion.php');
	$sel ="select  DISTINCT a.idCuenta,b.descTitulo,codicc,a.BDSession ,valor from dscis.dbo.DS_DistribucionCC a join 
dscis.dbo.DS_AgrupacionCuentas b  on a.idCuenta=b.idNivel where descTitulo<>'TEST CDIAZ' AND CodiCC='".$valorcc."' order by a.idCuenta,b.descTitulo,codicc,a.BDSession ,valor asc";


	// $sel =" select idnivel, desctitulo,bdsession";
	// $sel.=" from ".$dba.".DS_AgrupacionCuentas WHERE bdsession = '".$_SESSION['emp']['id']."' group by idNivel, descTitulo,bdsession ";
	   //echo $sel;
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_fetch_array($res);
echo $valor;

	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="distribucion">
		<thead>
		<tr>
			<th>IDCUENTA</th>
			<th>VALOR</th>
			<th>CODI CC </th>

			<th>BASE DE DATOS</th>
			<th>ANO</th>
			<th>Valor<th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
		{
		
			$salida .= '
			<tr >
				<td >'.$row['descTitulo'].'</td>
				<td >'.$row['valor'].'</td>
				<td >'.$row['codicc'].'</td>
	
				<td >'.$row['bdsession'].'</td>
				<td >'.$row['ano'].'</td>
				<td ><input type="text"></td>
			</tr>';
			$j++;
		}
			$salida.= '</tbody></table>'; 
		}
    else
    {
        $salida="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	
    }
	echo $Centrocosto;
	
}
?>