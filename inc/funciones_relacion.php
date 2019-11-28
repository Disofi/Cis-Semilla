<?php
function RelacionesListado()
	{
	include('inc/conexion.php');
	
	$sel= " SELECT relacion.idUsuario as idUsuario , count(relacion.idBDatos) as registros, usuarios.Usuario as Usuario, usuarios.Nombres AS Nombres,  ";
	$sel.=" usuarios.Correo as Correo ";
	$sel.=" FROM ".$dba.".[UsuariosEmpresas] relacion ";
	$sel.=" LEFT JOIN ".$dba.".[Usuarios] usuarios on relacion.idUsuario = usuarios.ID ";
	$sel.=" GROUP BY idUsuario,Usuario,Nombres, Correo ";
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$j=1;
		
	if ($num > 0)
		{
		$salida = '
		<div class="col-sm-12 col-head">
			<div class="col-sm-1 blb">ID</div>
			<div class="col-sm-2 blb">Usuario</div>
			<div class="col-sm-3 blb">Nombres</div>
			<div class="col-sm-3 blb">Correo</div>
			<div class="col-sm-2 blb">Registros</div>
			<div class="col-sm-1">Acciones</div>
		</div>';
		while ($row=sqlsrv_fetch_array($res))
			{
			if ($j%2==0) { $col = 'col-par'; } else { $col = ''; }
			$salida .= '
			<div class="col-sm-12 col-body '.$col.'">
				<div class="col-sm-1 blr">'.$row['idUsuario'].'</div>
				<div class="col-sm-2 blr">'.$row['Usuario'].'</div>
				<div class="col-sm-3 blr">'.$row['Nombres'].'</div>
				<div class="col-sm-3 blr">'.$row['Correo'].'</div>
				<div class="col-sm-2 blr">'.$row['registros'].'</div>
				<div class="col-sm-1"><a href="index.php?mod=relacionUsuarioEmpresa&id='.$row['idUsuario'].'" class="edit iconacc tooltip_a" title="Editar: '.$row['Nombres'].'">      </a> 
				<a href="javascript:eliminar_registro(\''.$row['idUsuario'].'\', \'relaciones\', \'inc/funciones_relacion.php\', \'index.php?mod=relaciones_lis\');" class="delete iconacc tooltip_a" title="Eliminar: '.$row['Nombres'].'">     </a></div>
			</div>';
			$j++;
			}
		}
	echo $salida;
	}



function relacionUsuarios($id)
{
	//echo $id." relacionUSuarios.<br>";
include 'inc/conexion.php';
$a = 0;
if($id == '')
{
	$query = " SELECT id, usuario FROM ".$dba.".[usuarios] ";
}
else
{
	$query = " SELECT id, usuario FROM ".$dba.".[usuarios] WHERE id = '".$id."' ";
}
//echo $query."<br>";
$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		if($row['id'] == $id)
		{
			$opt.='<input type="checkbox" name="usuario" id="usuario" class="usuario_'.$a.'" value="'.$row['id'].'" onclick="selectUsuario('.$a.');" checked="checked"> '.$row['id'].'-'.$row['usuario'].'<br>';
		}
		else
		{
			$opt.='<input type="checkbox" name="usuario" id="usuario" class="usuario_'.$a.'" value="'.$row['id'].'" onclick="selectUsuario('.$a.');"> '.$row['id'].'-'.$row['usuario'].'<br>';
		}
		$a++;
	}		
print $opt;
}

function relacionEmpresas($id)
{
if($id == '')
{
	$id ='vacio';
}
include 'inc/conexion.php';
$id_excluir = "";

if($id == 'vacio')
{
	$query = "SELECT IdBDatos,Descripcion FROM ".$dba.".[Empresas] ORDER BY IdBDatos ";
	//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$opt.='<input type="checkbox" name="empresa[]" id="empresa[]" value="'.$row['IdBDatos'].'-'.$row['Descripcion'].'"> '.$row['IdBDatos'].'-'.$row['Descripcion'].'<br>';
	}
}
else
{
	$query_check = " select idUsuario, idBdatos, DesbDatos from ".$dba.".[usuariosEmpresas] where idusuario ='".$id."' ";
	//echo $query_check;
	$rec_2 = sqlsrv_query( $conn, $query_check , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row_2 = sqlsrv_fetch_array($rec_2))
	{
		//echo $row_2['idUsuario']." - ".$row_2['idBdatos']." - ".$row_2['DesbdDatos']."<br>";
		$id_excluir = $id_excluir.$row_2['idBdatos'].",";
		$opt.='<input type="checkbox" name="empresa[]" id="empresa[]" value="'.$row_2['idBdatos'].'-'.$row_2['DesbDatos'].'" checked="checked"> '.$row_2['idBdatos'].'-'.$row_2['DesbDatos'].'<br>';
	}
	$myString = substr($id_excluir, 0, -1);
	$query = "SELECT IdBDatos,Descripcion FROM ".$dba.".[Empresas] WHERE idBdatos NOT IN (".$myString.") ";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$opt.='<input type="checkbox" name="empresa[]" id="empresa[]" value="'.$row['IdBDatos'].'-'.$row['Descripcion'].'"> '.$row['IdBDatos'].'-'.$row['Descripcion'].'<br>';
	}
	//echo $query."<---";
}	
print $opt;
}

if($_REQUEST['seccion'] == 'relaciones' )
{
	//echo $_REQUEST['id']." - ";
	$id = $_REQUEST['id'];
	include('conexion.php');
	
	$sql = "SELECT TOP 1 [IdUsuario] FROM ".$dba.".[UsuariosEmpresas] WHERE IdUsuario=" . $id . "";
	//echo $sql;
	$rec = sqlsrv_query( $conn, $sql, array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	if(sqlsrv_num_rows($rec) == 0){ 
		$salida = "RELACION_NO_EXISTE";
	}
	if(sqlsrv_num_rows($rec) > 0)
		{
		$queryDelete = "DELETE FROM ".$dba.".[UsuariosEmpresas] WHERE IdUsuario = ".$id;
		//echo $queryDelete;
		$rec2 = sqlsrv_query( $conn, $queryDelete, array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(!$rec2){	$salida = "RELACION_ERROR";	}
		if($rec2){ $salida = "RELACION_ELIMINADA_OK"; }
		}
		echo $salida;
}

	
	
function relacionInsertar($data)
{
	include('inc/conexion.php');
	$count_empresas = count($data['empresa']);
	$registros_existentes = 0;
	$registros_insertados = 0;
	$nombreBD_insert = "";
	$nombreBD_no_insert = "";
	
	$separado_por_comas = implode("-", $data['empresa']);
	$partes = explode("-", $separado_por_comas);
	for($a =0; $a <($count_empresas*2); $a++)
	{
		$query_insert = " INSERT INTO  ".$dba.".[UsuariosEmpresas] ([IdUsuario],[IdBDatos],[DesBDatos]) VALUES ('".$data['usuario']."','".$partes[$a]."', ";
		$query_existe = " SELECT COUNT(*) AS existe_relacion FROM ".$dba.".[UsuariosEmpresas] WHERE IdBDatos = '".$partes[$a]."' ";
		
		$a++;
				
		$query_insert.=" '".$partes[$a]."') ";
		$query_existe.=" and DesBDatos = '".$partes[$a]."' AND IdUsuario = '".$data['usuario']."' ";
		//echo $query_insert."<br>";
		//echo $query_existe."<br>";
			$rec = sqlsrv_query( $conn, $query_existe , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
			$row = sqlsrv_fetch_array($rec);	
			$existe_relacion = $row['existe_relacion'];
			if($existe_relacion == 0)
			{
				$rec = sqlsrv_query( $conn, $query_insert , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
				$registros_insertados++;
				//$nombreBD = $nombreBD.$partes[$a];
				$nombreBD_insert = $nombreBD_insert.$partes[$a]." , ";
				
			}
			else
			{
				$registros_existentes++;
				$nombreBD_no_insert = $nombreBD_no_insert.$partes[$a]." , ";
			}
			
	}

		$result = array(
			"registros_insertados" => $registros_insertados,
			"bd_insertados" => $nombreBD_insert,
			"registros_existentes" => $registros_existentes,
			"bd_existentes" => $nombreBD_no_insert,
		);	
		
		return $result;	
}	

function relacionEditar($data)
{
	include('inc/conexion.php');
	$count_empresas = count($data['empresa']);
	$registros_insertados = 0;
	$nombreBD_insert = "";
	
	$separado_por_comas = implode("-", $data['empresa']);
	$partes = explode("-", $separado_por_comas);	
	
	//echo $data['usuario'];
	
	$query_delete = " DELETE FROM ".$dba.".[UsuariosEmpresas] WHERE IdUsuario = '".$data['usuario']."'";
	sqlsrv_query( $conn, $query_delete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
	for($a =0; $a <($count_empresas*2); $a++)
	{
		$query_insert = " INSERT INTO  ".$dba.".[UsuariosEmpresas] ([IdUsuario],[IdBDatos],[DesBDatos]) VALUES ('".$data['usuario']."','".$partes[$a]."', ";
			$a++;
		$query_insert.=" '".$partes[$a]."') ";
		$rec = sqlsrv_query( $conn, $query_insert , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
			$registros_insertados++;
			$nombreBD_insert = $nombreBD_insert.$partes[$a].",";
	
	}
	
			$result = array(
			"registros_insertados" => $registros_insertados,
			"bd_insertados" => $nombreBD_insert,
			);	
		//var_dump($result);
		return $result;	
	
}

?>