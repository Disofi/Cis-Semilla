<?php
//session_start();
function nivelesCuentasListar($nivel)
{	
	include('inc/conexion.php');

	$sel.=" select idnivel, tituloNivel, descripcionNivel,bdsession "; 
	$sel.=" FROM ".$dba.".DS_nivelesEERR WHERE bdsession = '".$_SESSION['emp']['id']."'";
	$sel.=" GROUP BY idNivel,tituloNivel,descripcionNivel,bdsession ";
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
				<td class="col-sm-1 blr">'.$row['tituloNivel'].'</td>
				<td class="col-sm-1 blr">'.$row['descripcionNivel'].'</td>
				<td class="col-sm-1">
					<a href="javascript:editarReporte(\''.$row['idnivel'].'\',\''.$row['bdsession'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:eliminarReporte(\''.$row['idnivel'].'\',\''.$row['bdsession'].'\');" class="icon delete">Eliminar</a>
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

function cuentasNivelesEERR($nivel)
{
	include 'inc/conexion.php';

	if($nivel == "")
	{
		
		$query =" SELECT idNivel,descTitulo  FROM ".$dba.".[DS_AgrupacionCuentas]  ";
		$query.=" WHERE idNivel  NOT IN  ";
		$query.=" ( ";
		$query.=" 	SELECT idCuenta  FROM ".$dba.".DS_nivelesEERR WHERE BDSession = '".$_SESSION['emp']['id']."' ";
		$query.=" ) AND BDSession = '".$_SESSION['emp']['id']."' ";
		$query.=" group by idNivel, descTitulo ";
		
	}
	else
	{	
		$query =" SELECT idNivel,descTitulo  FROM ".$dba.".[DS_AgrupacionCuentas]  ";
		$query.=" WHERE idNivel  NOT IN  ";
		$query.=" ( ";
		$query.=" 	SELECT idCuenta  FROM ".$dba.".DS_nivelesEERR  WHERE BDSession = '".$_SESSION['emp']['id']."'  ";
		$query.=" ) AND BDSession = '".$_SESSION['emp']['id']."'";
		$query.=" group by idNivel, descTitulo ";
		
		
		
	}
		echo $query;
		$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($row = sqlsrv_fetch_array($rec))
	{
		$opt.='<option value="'.$row['idNivel'].'">'.$row['idNivel'].' - '.$row['descTitulo'].'</option>';
	}		
		print $opt;
}


function cuentasNivelesEERRInUse($nivel)
{
	include 'inc/conexion.php';

	if($nivel == "")
	{
		/*
		$query =" SELECT idNivel,descTitulo  FROM ".$dba.".[DS_AgrupacionCuentas]  ";
		$query.=" WHERE idNivel NOT IN  ";
		$query.=" ( ";
		$query.=" 	SELECT idCuenta  FROM ".$dba.".DS_nivelesEERR ";
		$query.=" ) ";
		$query.=" group by idNivel, descTitulo ";
		*/
	}
	else
	{
		$query.=" SELECT idNivel,descTitulo  FROM ".$dba.".[DS_AgrupacionCuentas]  ";
		$query.=" WHERE idNivel  IN  ";
		$query.=" ( ";
		$query.=" 	SELECT idCuenta  FROM ".$dba.".DS_nivelesEERR where idNivel = ".$nivel." AND BDSession = '".$_SESSION['emp']['id']."'  ";
		$query.=" ) AND BDSession = '".$_SESSION['emp']['id']."' ";
		$query.=" group by idNivel, descTitulo ";
	}
		//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$opt.='<option value="'.$row['idNivel'].'">'.$row['idNivel'].' - '.$row['descTitulo'].'</option>';
	}		
		print $opt;
}

function nivelesTituloEERR($nivel)
{
        include('inc/conexion.php');
		$sql.=" select tituloNivel from ".$dba.".DS_nivelesEERR ";
		$sql.=" where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."'  group by tituloNivel ";		
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}
function nivelesDescEERR($nivel)
{
        include('inc/conexion.php');
		$sql.=" select descripcionNivel from ".$dba.".DS_nivelesEERR ";
		$sql.=" where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."'  group by descripcionNivel ";		
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}


function insertNivelEERR($data)
{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    $nivel = 1;
    $correlativo = 1;
	$orden = 1;
	
    $query_grupo = " SELECT  max(idNivel)+1 as idNivel FROM ".$dba.".[DS_nivelesEERR] WHERE bdsession = '".$_SESSION['emp']['id']."' ";
		//echo $query_grupo."<br>";
        $rec_b = sqlsrv_query( $conn, $query_grupo , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            while($row = sqlsrv_fetch_array($rec_b))
            {
                $idNivel =  $row['idNivel'];
            }
			
    for($a =0; $a <($registros); $a++)
    {	
		$insert_2 =" INSERT INTO ".$dba.".[DS_nivelesEERR] ";
		$insert_2.=" ( ";
		$insert_2.=" 	[idNivel],[idCuenta],[tituloNivel],[descripcionNivel],[orden],[BDSession] ";
		$insert_2.=" )  ";
		$insert_2.=" VALUES  ";
		$insert_2.=" ( ";
		$insert_2.=" 	'".$idNivel."', '".$data['destino'][$a]."', '".$data['titulo']."','".$data['descripcion']."','".$orden."', '".$_SESSION['emp']['id']."' ";
		$insert_2.=" )  ";
		$orden++;
		//echo $insert_2."<br>";
		$rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		
    }

}

function updateNivelEERR($data)
{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    $nivel = 1;
    $correlativo = 1;
	$orden = 1;
	$dataNivel = $data['grupo'];
	
	$queryDelete = "DELETE FROM ".$dba.".[DS_nivelesEERR] where idNivel = '".$dataNivel."' AND bdsession = '".$_SESSION['emp']['id']."'  ";
		//echo $queryDelete."<br>";
		$rec = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
	
	for($a =0; $a <($registros); $a++)
    {	
		$insert_2 =" INSERT INTO ".$dba.".[DS_nivelesEERR] ";
		$insert_2.=" ( ";
		$insert_2.=" 	[idNivel],[idCuenta],[tituloNivel],[descripcionNivel],[orden],[BDSession] ";
		$insert_2.=" )  ";
		$insert_2.=" VALUES  ";
		$insert_2.=" ( ";
		$insert_2.=" 	'".$dataNivel."', '".$data['destino'][$a]."', '".$data['titulo']."','".$data['descripcion']."','".$orden."', '".$_SESSION['emp']['id']."' ";
		$insert_2.=" )  ";
		$orden++;
		//echo $insert_2."<br>";
		$rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
    }

}

function deleteNivelEERR($nivel)
{
	include('inc/conexion.php');
	
	$queryDelete=" DELETE FROM [DSCIS].[dbo].[DS_nivelesEERR] where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."' ";
	echo $queryDelete."<br>";
	$rec = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
}


?>