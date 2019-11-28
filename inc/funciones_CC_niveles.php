<?php
session_start();
$accion = $_REQUEST['accion'];
function nivelesCuentasListar($nivel)
{	
	include('inc/conexion.php');

	$sel.=" select nivel.idnivel, nivel.tituloNivel, nivel.descripcionNivel,nivel.bdsession, cc.CodiCC, cc.DescCC, agrupado.idDS_AgrupacionCC  
	FROM ".$dba.".[DS_nivelesEERR] nivel
	inner join ".$dba.".[DS_AgrupacionCCNivel] agrupado on agrupado.idNivel = nivel.idnivel
	inner join ".$_SESSION['emp']['id'].".SOFTLAND.[cwtccos] cc on  cc.CodiCC collate Modern_Spanish_CI_AS = agrupado.CodiCC
	WHERE nivel.bdsession  = '".$_SESSION['emp']['id']."' and agrupado.bdsession = '".$_SESSION['emp']['id']."'
	group by nivel.idnivel, nivel.tituloNivel, nivel.descripcionNivel,nivel.bdsession, cc.CodiCC, cc.DescCC, idDS_AgrupacionCC
	order by nivel.idnivel "; 

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
			<th nowrap="nowrap">Cod. Centro de Costo</th>
			<th nowrap="nowrap">Centro de Costo</th>
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
				<td class="col-sm-1 blr">'.$row['CodiCC'].'</td>
				<td class="col-sm-1 blr">'.$row['DescCC'].'</td>
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




function deleteNivelEERR($nivel)
{
	include('inc/conexion.php');
	
	$queryDelete=" DELETE FROM [DSCIS].[dbo].[DS_nivelesEERR] where idNivel = '".$nivel."' AND bdsession = '".$_SESSION['emp']['id']."' ";
	echo $queryDelete."<br>";
	$rec = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
}






if($accion == "updateeerr")
{
	
	$cc = $_REQUEST['cc'];
	$niveleerr = $_REQUEST['nivel']; 
	include('conexion.php');
	$queryDelete=" update agrupado set agrupado.CodiCC = '".$cc."'
	from ".$dba.".[DS_AgrupacionCCNivel] agrupado  
	inner join ".$dba.".[DS_nivelesEERR] nivel on agrupado.idNivel = nivel.idnivel
	where agrupado.idnivel=".$niveleerr." and nivel.bdsession = '".$_SESSION['emp']['id']."' ";
	
	//echo $queryDelete."<br>";
	sqlsrv_query( $conn, $queryDelete);
	
	$status = array('tipo' => 'OK', 'mensaje' => 'Se Guardo Correctamente');
	$json_data = json_encode($status);
	echo $json_data;
	//echo "llego a la funcion?";
}

if($accion == "agregarccnivel")
{
	
	$cc = $_REQUEST['cc'];
	$niveleerr = $_REQUEST['nivel']; 
	include('conexion.php');
	$queryAdd=" insert into ".$dba.".[DS_AgrupacionCCNivel] ([CodiCC],[idnivel],[bdsession]) values ('".$cc."',".$niveleerr.", '".$_SESSION['emp']['id']."' )";
	
	echo $queryAdd."<br>";
	sqlsrv_query( $conn, $queryAdd);
	
	$status = array('tipo' => 'OK', 'mensaje' => 'Se Guardo Correctamente');
	$json_data = json_encode($status);
	echo $json_data;
	//echo "llego a la funcion?";
}


?>