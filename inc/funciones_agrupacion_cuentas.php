<?php
//session_start();
function agrupacionCuentasListar()
{	
	include('inc/conexion.php');

	$sel =" select idnivel, desctitulo,bdsession";
	$sel.=" from ".$dba.".DS_AgrupacionCuentas WHERE bdsession = '".$_SESSION['emp']['id']."' group by idNivel, descTitulo,bdsession ";
	   //echo $sel;
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$j=1;

	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="dataTable">
		<thead>
		<tr>
			<th nowrap="nowrap">ID</th>
			<th nowrap="nowrap">Titulo Agrupaci&oacute;n Cuenta</th>
			<th nowrap="nowrap">Base de Datos</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
		{
			if ($j%2==0) { $col = 'col-par'; } else { $col = ''; }
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-2 blr">'.$row['idnivel'].'</td>
				<td class="col-sm-1 blr">'.$row['desctitulo'].'</td>
				<td class="col-sm-1 blr">'.$row['bdsession'].'</td>
				<td class="col-sm-1">
					<a href="javascript:editarReporte(\''.$row['idnivel'].'\',\''.$row['bdsession'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:eliminarReporte(\''.$row['idnivel'].'\');" class="icon delete">Eliminar</a>
				</td>
			</tr>';
			$j++;
		}
			$salida.= '</tbody></table>'; 
		}
    else
    {
        $salida="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	
    }
	echo $salida;
	
}


function MostrarCuentasActuales()
{	
	include('inc/conexion.php');
	$sel ="select desctitulo,a.pccodi ,b.pcdesc ,BDSession,mes,ano from rsphola.DBO.DS_AGRUPACIONCUENTAS a  join  cis.softland.cwpctas b   on a.pccodi  collate  Modern_Spanish_CI_AS=b.PCCODI  collate  Modern_Spanish_CI_AS  and bdsession='CIS' order by a.idnivel asc ";

	
	// $sel =" select idnivel, desctitulo,bdsession";
	// $sel.=" from ".$dba.".DS_AgrupacionCuentas WHERE bdsession = '".$_SESSION['emp']['id']."' group by idNivel, descTitulo,bdsession ";
	   echo $sel;
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);


	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="dataTable">
		<thead>
		<tr>
		
			<th>DESCRIPCION</th>
			<th>CUENTA SOFTLAND</th>
			<th>CUENTA CONTABLE</th>
			<th>BASE DE DATOS</th>
			<th>MES</th>
			<th>ANO</th>

		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
		{
		
			$salida .= '
			<tr >
				
				<td >'.$row['desctitulo'].'</td>
				<td >'.$row['pccodi'].'</td>
				<td >'.$row['pcdesc'].'</td>
				<td >'.$row['BDSession'].'</td>
				<td >'.$row['mes'].'</td>
		<td >'.$row['ano'].'</td>
			
			</tr>';
			$j++;
		}
			$salida.= '</tbody></table>'; 
		}
    else
    {
        $salida="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	
    }
	echo $salida;
	
}


function MostrarDistribucionCC()
{	
	include('inc/conexion.php');
	$sel ="select distinct  b.descTitulo,valor,codicc,a.idnivel,a.bdsession,a.ano from dscis.DBO.DS_DistribucionCC a  join dscis.dbo.DS_AgrupacionCuentas b on a.idCuenta=b.idNivel where a.ano='2019' and a.codicc>'00-000'  and b.descTitulo<>'TEST CDIAZ' AND CodiCC not in('01-000','11-000','12-000') group by b.descTitulo,idcuenta,valor,codicc,a.idnivel,a.bdsession,a.ano order by a.idNivel, b.descTitulo,codicc,valor,a.bdsession,a.ano asc";


	// $sel =" select idnivel, desctitulo,bdsession";
	// $sel.=" from ".$dba.".DS_AgrupacionCuentas WHERE bdsession = '".$_SESSION['emp']['id']."' group by idNivel, descTitulo,bdsession ";
	   //echo $sel;
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_fetch_array($res);


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

			</tr>';
			$j++;
		}
			$salida.= '</tbody></table>'; 
		}
    else
    {
        $salida="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	
    }
	echo $salida;
	
}



function cuentasUseCis()
{
	include 'inc/conexion.php';


	/*
	$query =" SELECT pccodi,pcdesc FROM ".$dbs.".cwpctas ";
	$query.=" WHERE pccodi collate Modern_Spanish_CI_AS NOT IN  ";
	$query.=" (select PCCODI from ".$dba.".DS_AgrupacionCuentas ) ";
	$query.=" AND PCNIVEL = '4' order by pccodi ASC ";
	*/
	$query =" SELECT pccodi,pcdesc FROM ".$dbs.".cwpctas ";
	$query.=" WHERE ";
	$query.=" PCNIVEL = '4' order by pccodi ASC ";
	
		//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($row = sqlsrv_fetch_array($rec))
		{
			
			$opt.='<option value="'.$row['pccodi'].'">'.$row['pccodi'].' - '.$row['pcdesc'].'</option>';
		}		
	print $opt;
}


function cuentasInUseCis($nivel)
{
	include 'inc/conexion.php';		
	if($nivel == "")
	{
		

	}
	else
	{
		$query =" SELECT pccodi,pcdesc FROM ".$dbs.".cwpctas   ";
		$query.=" WHERE pccodi collate Modern_Spanish_CI_AS IN   ";
		$query.=" ( ";
		$query.=" 	SELECT PCCODI FROM ".$dba.".[DS_AgrupacionCuentas] WHERE BDSession = '".$_SESSION['emp']['id']."' AND idNivel = '".$nivel."' ";
		$query.=" )  				 ";
	}
	
	//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($row = sqlsrv_fetch_array($rec))
		{
			$opt.='<option value="'.$row['pccodi'].'">'.$row['pccodi'].' - '.$row['pcdesc'].'</option>';

		}		
	print $opt;
}

function insertAgrupacionCuentas($data)
{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    $nivel = 1;
    $correlativo = 1;
	
    $query_grupo = " SELECT  max(idNivel)+1 as idNivel FROM ".$dba.".[DS_AgrupacionCuentas] WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	//echo $query_grupo."<br>";
        $rec_b = sqlsrv_query( $conn, $query_grupo , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            while($row = sqlsrv_fetch_array($rec_b))
            {
                $idNivel =  $row['idNivel'];
            }    
    for($a =0; $a <($registros); $a++)
    {
        //echo $data['destino'][$a]." A <--<br>";   
        $insert_2 ="INSERT INTO ".$dba.".[DS_AgrupacionCuentas] 
		([idNivel],[PCCODI],[descTitulo],[descTotal],[BDSession]) ";
        $insert_2.=" VALUES ";
        //$insert_2.=" ('".$_SESSION['emp']['id']."', '".$indice."', '".$nivel."', '".$correlativo."', '".$data['destino'][$a]."') ";
		$insert_2.=" ('".$idNivel."', '".$data['destino'][$a]."', '".$data['titulo']."', '".$data['descripcion']."', '".$_SESSION['emp']['id']."') ";
        $rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
       //echo $insert_2." insert_2<br>";       
    }

}

function updateAgrupacionCuentas($data)
{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    //$nivel = 1;
    $correlativo = 1;
	$nivel = $data['grupo'];
	//echo $nivel."<<---";
	//print_r($data);
	
	
	$queryDelete = "DELETE FROM ".$dba.".[DS_AgrupacionCuentas] WHERE idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."'  ";
	//echo $queryDelete."\n";
	$recDelete = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
     
    for($a =0; $a <($registros); $a++)
    {
        //echo $data['destino'][$a]." A <--<br>";   
        $insert_2 ="INSERT INTO ".$dba.".[DS_AgrupacionCuentas] ([idNivel],[PCCODI],[descTitulo],[descTotal],[BDSession]) ";
        $insert_2.=" VALUES ";
		//$insert_2.=" ('".$idNivel."', '".$data['destino'][$a]."', '".$nivel."', '".$correlativo."', '".$_SESSION['emp']['id']."') ";
		$insert_2.=" ('".$nivel."', '".$data['destino'][$a]."', '".$data['titulo']."', '".$data['descripcion']."', '".$_SESSION['emp']['id']."') ";
        $rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
       //echo $insert_2." insert_2<br>";       
    }

}

function deleteAgrupacionCuentas($nivel)
{
	include('inc/conexion.php');
	$queryDelete = "DELETE FROM ".$dba.".[DS_AgrupacionCuentas] WHERE idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."'  ";
	
	$recDelete = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
}




function agrupacionCuentaTitulo($nivel)
{
        include('inc/conexion.php');
		//$sql =" SELECT descripcion FROM ".$dba.".[DS_PARAMRESULE] WHERE grupo = '".$grupo."' AND indice = '1' " ;
		$sql =" select descTitulo from ".$dba.".[DS_AgrupacionCuentas]  ";
		$sql.=" where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."' group by descTitulo " ;
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}
function agrupacionCuentaDesc($nivel)
{
        include('inc/conexion.php');
		$sql =" select desctotal from ".$dba.".[DS_AgrupacionCuentas]  ";
		$sql.=" where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."' group by desctotal " ;
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}



?>