<?php
//session_start();
function empresasUse()
{
include 'inc/conexion.php';

$query = " SELECT name, dbid FROM master.dbo.sysdatabases WHERE dbid NOT IN (SELECT idbdatos FROM ".$dba.".[Empresas]) ";
echo $query;
$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$query_cwparam = " SELECT COUNT(*) AS existe from  ".$row['name'].".softland.cwparam ";
		//echo $query_cwparam."<br>";
		$rec_cwparam = sqlsrv_query( $conn, $query_cwparam , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		$row_cwparam = sqlsrv_fetch_array($rec_cwparam);
		{
			//echo $i ." --".$row_cwparam['existe']."<br>";
			if($row_cwparam['existe'] == 1 || $row_cwparam['existe'] == '1')
			{
				//echo $i." / ".$row['name']."<br>";
				//$opt.='<option value="'.$row['PCCODI'].'">'.$row['PCCODI'].' - '.$row['PCDESC'].'</option>';
				$opt.='<option value="'.$row['dbid'].'-'.$row['name'].'">'.$row['dbid'].' - '.$row['name'].'</option>';
			}
		}
	}		
print $opt;
}

function empresasInUse()
{
include 'inc/conexion.php';

$query = " SELECT name, dbid FROM master.dbo.sysdatabases WHERE dbid IN (SELECT idbdatos FROM ".$dba.".[Empresas]) ";
echo $query;
$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$query_cwparam = " SELECT COUNT(*) AS existe from  ".$row['name'].".softland.cwparam ";
		//echo $query_cwparam."<br>";
		$rec_cwparam = sqlsrv_query( $conn, $query_cwparam , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		$row_cwparam = sqlsrv_fetch_array($rec_cwparam);
		{
			//echo $i ." --".$row_cwparam['existe']."<br>";
			if($row_cwparam['existe'] == 1 || $row_cwparam['existe'] == '1')
			{
				//echo $i." / ".$row['name']."<br>";
				//$opt.='<option value="'.$row['PCCODI'].'">'.$row['PCCODI'].' - '.$row['PCDESC'].'</option>';
				$opt.='<option value="'.$row['dbid'].'-'.$row['name'].'">'.$row['dbid'].' - '.$row['name'].'</option>';
			}
		}
	}		
print $opt;
}

function empresasInsertar($data)
	{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
	
	$registros = count($data['destino']);
	$b=0;
	$registros_existentes = 0;
	$registros_insertados = 0;
	$nombreBD_insert = "";
	$nombreBD_no_insert = "";
	$idBD = "";
	
	$query_delete = " DELETE FROM ".$dba.".[Empresas] ";
	sqlsrv_query( $conn, $query_delete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
	$partes = explode("-", $separado_por_comas);
	for($a =0; $a <($registros*2); $a++)
	{
		$query_insert = "INSERT INTO  ".$dba.".[Empresas] ([IdBDatos],[Descripcion]) VALUES ( '".$partes[$a]."', ";
		$query_existe = " SELECT COUNT(*) AS existe_empresa FROM ".$dba.".[Empresas] WHERE idbdatos = '".$partes[$a]."' ";
		$idBD = $idBD.$partes[$a].",";
		$a++;
				
		$query_insert.=" '".$partes[$a]."') ";
		$query_existe.=" and Descripcion = '".$partes[$a]."' ";
		//echo $query_insert;
		//echo $query_existe." -- ";
			$rec = sqlsrv_query( $conn, $query_existe , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
			$row = sqlsrv_fetch_array($rec);	
			$existe_empresa = $row['existe_empresa'];
			if($existe_empresa == 0)
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
	//echo $idBD;
	$deleteUltimoRegistro = substr($idBD, 0, -1);
	
	$query_delete = "DELETE FROM ".$dba.".[UsuariosEmpresas] WHERE idBdatos NOT IN (".$deleteUltimoRegistro.") ";
	//echo $query_delete;
	sqlsrv_query( $conn, $query_delete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	
		$result = array(
			"registros_insertados" => $registros_insertados,
			"bd_insertados" => $nombreBD_insert,
			"registros_existentes" => $registros_existentes,
			"bd_existentes" => $nombreBD_no_insert,
		);	
	return $result;
	}

function formatoReporteListar()
{
	include('inc/conexion.php');

	
	$sel =" SELECT cabecera.IdBdatos, bd.Descripcion AS desbd, cabecera.Indice, cabecera.Nivel, cabecera.Descripcion, cabecera.ManejaDet, ";
	$sel.=" cabecera.Tipo, cabecera.grupo  ";
	$sel.=" FROM ".$dba.".DS_PARAMRESULE cabecera ";
	$sel.=" LEFT JOIN ".$dba.".empresas bd ON bd.idBdatos = cabecera.IdBdatos ";
    $sel.=" WHERE cabecera.IdBdatos = '".$_SESSION['emp']['id']."' ";
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
			<th nowrap="nowrap">BD</th>
			<th nowrap="nowrap">Indice</th>
			<th nowrap="nowrap">Nivel</th>
			<th nowrap="nowrap">Descripcion</th>
			<th nowrap="nowrap">ManejaDet</th>
			<th nowrap="nowrap">Tipo</th>
			<th nowrap="nowrap">Grupo</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
			{
			if ($j%2==0) { $col = 'col-par'; } else { $col = ''; }
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-2 blr">'.$row['IdBdatos'].' - '.$row['desbd'].'</td>
				<td class="col-sm-1 blr">'.$row['Indice'].'</td>
				<td class="col-sm-1 blr">'.$row['Nivel'].'</td>
				<td class="col-sm-3 blr">'.$row['Descripcion'].'</td>
				<td class="col-sm-1 blr">'.$row['ManejaDet'].'</td>
				<td class="col-sm-1 blr">'.$row['Tipo'].'</td>
				<td class="col-sm-1 blr">'.$row['grupo'].'</td>
				<td class="col-sm-1">
					<a href="javascript:editarReporte(\''.$row['grupo'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:eliminarReporte(\''.$row['grupo'].'\');" class="icon delete">Eliminar</a>
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

function formatoReporteEditarCabecera($grupo)
{	
	include('inc/conexion.php');
	$sel =" SELECT TOP 1 * FROM ".$dba.".DS_PARAMRESULE cabecera ";
	$sel.=" LEFT JOIN ".$dba.".DS_PARAMRESULD detalle ON detalle.indice = cabecera.indice ";
	$sel.=" WHERE cabecera.grupo = '".$grupo."' ORDER BY cabecera.Indice ASC ";
		//echo $sel."<br>";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$cont = 0;
	$salida = "";
	while ($row=sqlsrv_fetch_array($res))
	{
		$salida.= " <input type='text' value='texto cabecera'> <br>";		
	}
	//echo $salida;
}

function cuentasUse()
{
include 'inc/conexion.php';

//$query = " SELECT pccodi, pcdesc FROM ".$dbs.".cwpctas ";
$query =" SELECT pccodi,pcdesc FROM ".$dbs.".cwpctas ";
$query.=" WHERE pccodi collate Modern_Spanish_CI_AS NOT IN  ";
$query.=" (select pctcod from ".$dba.".DS_PARAMRESULD ) ";
$query.=" order by pccodi ASC ";
//echo $query;
$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		//$query_cwparam = " SELECT COUNT(*) AS existe from  ".$row['name'].".softland.cwparam ";
		//echo $query_cwparam."<br>";
		//$rec_cwparam = sqlsrv_query( $conn, $query_cwparam , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		//$row_cwparam = sqlsrv_fetch_array($rec_cwparam);
		//{
			//echo $i ." --".$row_cwparam['existe']."<br>";
			//if($row_cwparam['existe'] == 1 || $row_cwparam['existe'] == '1')
			//{
				//echo $i." / ".$row['name']."<br>";
				//$opt.='<option value="'.$row['PCCODI'].'">'.$row['PCCODI'].' - '.$row['PCDESC'].'</option>';
				//$opt.='<option value="'.$row['pccodi'].'">'.$row['pccodi'].' - '.$row['pcdesc'].'</option>';
			//}
		//}
		$opt.='<option value="'.$row['pccodi'].'">'.$row['pccodi'].' - '.$row['pcdesc'].'</option>';
	}		
print $opt;
}

function cuentasInUse($grupo)
{
include 'inc/conexion.php';

//$query = " SELECT pccodi, pcdesc FROM ".$dbs.".cwpctas WHERE pccodi IN (SELECT idbdatos FROM ".$dba.".[Empresas]) ";
    
$query =" SELECT pccodi,pcdesc FROM ".$dbs.".cwpctas  ";
$query.=" WHERE pccodi collate Modern_Spanish_CI_AS IN ";
$query.=" (SELECT pctcod FROM ".$dba.".[DS_PARAMRESULE] cabecera  ";
$query.=" left join ".$dba.".DS_PARAMRESULD detalle  ON cabecera.indice = detalle.indice  ";
$query.=" WHERE cabecera.grupo = '".$grupo."' collate Modern_Spanish_CI_AS)  ";
//echo $query;
$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
        //echo $i." / ".$row['name']."<br>";
        //$opt.='<option value="'.$row['PCCODI'].'">'.$row['PCCODI'].' - '.$row['PCDESC'].'</option>';
        $opt.='<option value="'.$row['pccodi'].'">'.$row['pccodi'].' - '.$row['pcdesc'].'</option>';

	}		
print $opt;
}

function borrarGrupoReporte($grupo)
{
        include 'inc/conexion.php';
        $query_indice =" select  distinct cabecera.indice from ".$dba.".[DS_PARAMRESULE] cabecera ";
        $query_indice.=" left join ".$dba.".DS_PARAMRESULD detalle ON cabecera.indice = detalle.indice ";
        $query_indice.=" WHERE cabecera.grupo = '".$grupo."'";
            //echo $query_indice."<br>";
        $rec = sqlsrv_query( $conn, $query_indice , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            while($row = sqlsrv_fetch_array($rec))
            {
                $query_delete = " DELETE FROM ".$dba.".[DS_PARAMRESULE] WHERE indice = '".$row['indice']."'  ";
                    //echo $query_delete."<--<br>";
                    $rec2 = sqlsrv_query( $conn, $query_delete, array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
                
                $query_delete_b = " DELETE FROM ".$dba.".[DS_PARAMRESULD] WHERE indice = '".$row['indice']."'  ";
                    //echo $query_delete_b."<-- <br>";
                    $rec2_b = sqlsrv_query( $conn, $query_delete_b, array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            }
    echo "OK";
        /*
		$queryDelete = "DELETE FROM ".$dbs.".[UsuariosEmpresas] WHERE IdUsuario = ".$id;
		//echo $queryDelete;
		$rec2 = sqlsrv_query( $conn, $queryDelete, array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(!$rec2){	$salida = "GRUPO_ERROR";	}
		if($rec2){ $salida = "GRUPO_DELETE_OK"; }
        */
}

function reportesInsertar($data)
{
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    $nivel = 1;
    $correlativo = 1;
    $query_indice = " SELECT  max(indice)+1 as indice from ".$dba.".[DS_PARAMRESULE]";
        $rec = sqlsrv_query( $conn, $query_indice , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            while($row = sqlsrv_fetch_array($rec))
            {
                $indice =  $row['indice'];
            }

    $query_grupo = " SELECT  max(grupo)+1 as grupo FROM ".$dba.".[DS_PARAMRESULE]";
        $rec_b = sqlsrv_query( $conn, $query_grupo , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
            while($row = sqlsrv_fetch_array($rec_b))
            {
                $grupo =  $row['grupo'];
            }    
      
    //echo $data['titulo']."<--titulo <br>";
    //echo $data['descripcion']."<--descripcion <br>";
    //echo $registros."<-- registros<br>";
    //echo $indice."<-- indice<br>";
    //echo $grupo."<-- grupo<br>";
    
    $insert_1a ="INSERT INTO ".$dba.".[DS_PARAMRESULE] ([IdBDatos],[Indice],[Nivel],[Descripcion],[ManejaDet],[Tipo],[grupo]) ";
    $insert_1a.=" VALUES ";
    $insert_1a.=" ('".$_SESSION['emp']['id']."','".$indice."','".$nivel."','".$data['titulo']."','N','G','".$grupo."' ) ";
    $rec_a = sqlsrv_query( $conn, $insert_1a , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    //echo $insert_1a." A<--- <br>";
    
    $indice++;
    $nivel++;
    
    $insert_1b ="INSERT INTO ".$dba.".[DS_PARAMRESULE] ([IdBDatos],[Indice],[Nivel],[Descripcion],[ManejaDet],[Tipo],[grupo]) ";
    $insert_1b.=" VALUES ";
    $insert_1b.=" ('".$_SESSION['emp']['id']."','".$indice."','".$nivel."','detalle','N','G','".$grupo."' ) ";    
        //echo $insert_1b."<--- B <br>";
        $rec_b = sqlsrv_query( $conn, $insert_1b , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    for($a =0; $a <($registros); $a++)
    {
        //echo $data['destino'][$a]." A <--<br>";   
        $insert_2 ="INSERT INTO ".$dba.".[DS_PARAMRESULD] ([IdBDatos],[Indice],[Nivel],[Corr],[pctcod]) ";
        $insert_2.=" VALUES ";
        $insert_2.=" ('".$_SESSION['emp']['id']."', '".$indice."', '".$nivel."', '".$correlativo."', '".$data['destino'][$a]."') ";
        $rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
        //echo $insert_2." insert_2<br>";
        $correlativo++;
    }
    
    $indice++;
    $nivel++;
    
    $insert_1c =" INSERT INTO ".$dba.".[DS_PARAMRESULE] ([IdBDatos],[Indice],[Nivel],[Descripcion],[ManejaDet],[Tipo],[grupo]) ";
    $insert_1c.=" VALUES ";
    $insert_1c.=" ('".$_SESSION['emp']['id']."','".$indice."','".$nivel."','".$data['descripcion']."','N','G','".$grupo."' ) ";
    $rec_c = sqlsrv_query( $conn, $insert_1c , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    //echo $insert_1c." C<-- <br>";
    //echo "OK";
}

function datosReporteTitulo($grupo)
{
        include('inc/conexion.php');
		$sql =" SELECT descripcion FROM ".$dba.".[DS_PARAMRESULE] WHERE grupo = '".$grupo."' AND indice = '1' " ;
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}

function datosReporteIndice($grupo)
{
        include('inc/conexion.php');
		$sql =" SELECT indice FROM ".$dba.".[DS_PARAMRESULE] WHERE grupo = '".$grupo."' AND nivel = '2' " ;
    
		echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}

function datosReporteDescripcion($grupo)
{
        include('inc/conexion.php');
		$sql =" SELECT descripcion FROM ".$dba.".[DS_PARAMRESULE] WHERE grupo = '".$grupo."' AND indice = '3' " ;
		//echo $sql;
		$rec = sqlsrv_query( $conn, $sql , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		if(sqlsrv_num_rows($rec) == 0)	{ return 'SIN_DATOS';}
		if(sqlsrv_num_rows($rec) > 0) 	{ $row = sqlsrv_fetch_array($rec); return $row; }
    
}

function reportesEditar($data)
{
    //echo "<br>";
	include('inc/conexion.php');
	$separado_por_comas = implode("-", $data['destino']);
    $registros = count($data['destino']);
    $correlativo = 1;
    //echo $data['titulo']."<br>";
    //echo $data['descripcion']."<br>";
    //echo $data['grupo']."<br>";
    //echo $data['indice_temp']."<br>";

    $query_update_a = "UPDATE ".$dba.".[DS_PARAMRESULE] SET descripcion = '".$data['titulo']."' WHERE grupo = '".$data['grupo']."' AND indice = '1' ";
        //echo $query_update_a."<br>";
        $rec_a = sqlsrv_query( $conn, $query_update_a , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    $query_update_b = "UPDATE ".$dba.".[DS_PARAMRESULE] SET descripcion = '".$data['descripcion']."' WHERE grupo = '".$data['grupo']."' AND indice = '3' ";
        //echo $query_update_b."<br>";
        $rec_b = sqlsrv_query( $conn, $query_update_b , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    
    
    $delete_row_actual =" DELETE FROM ".$dba.".DS_PARAMRESULD WHERE pctcod IN ";
    $delete_row_actual.=" ( ";
    $delete_row_actual.=" select detalle.pctcod from ".$dba.".DS_PARAMRESULD detalle ";
    $delete_row_actual.=" left join ".$dba.".[DS_PARAMRESULE] cabecera on cabecera.indice = detalle.indice ";
    $delete_row_actual.=" WHERE cabecera.grupo = '".$data['grupo']."' ";
    $delete_row_actual.=" ) ";
        //echo $delete_row_actual."<br>";
        $rec_delete = sqlsrv_query( $conn, $delete_row_actual , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
    
    
    
    
    for($a =0; $a <($registros); $a++)
    {
        //echo $data['destino'][$a]." A <--<br>";   
        $insert_2 ="INSERT INTO ".$dba.".[DS_PARAMRESULD] ([IdBDatos],[Indice],[Nivel],[Corr],[pctcod]) ";
        $insert_2.=" VALUES ";
        $insert_2.=" ('".$_SESSION['emp']['id']."', '".$data['indice_temp']."', '2', '".$correlativo."', '".$data['destino'][$a]."') ";
        $rec__ = sqlsrv_query( $conn, $insert_2 , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
       //echo $insert_2." insert_2<br>";
        $correlativo++;
    }
    
    
    
    
    //echo $insert_1c." C<-- <br>";
    //echo "OK";
}

?>