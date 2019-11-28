<?php

/* SANITIZAR ENTRADA DE DATOS */
function sanitize($input) 
	{
	if(is_array($input))
		{
		foreach($input as $var=>$val) { $output[$var] = sanitize($val); }
		}
	else
		{
		if (get_magic_quotes_gpc()) { $input = stripslashes($input); }
		$input  = cleanString($input);
		$output = mssql_escape($input);
		}
	return $output;
	}

/* ELIMINAR ETIQUETAS EN CADENAS DE TEXTO */
function cleanString($input) 
	{
	$search = array(
		'@<script [^>]*?>.*?@si',
		'@< [/!]*?[^<>]*?>@si',
		'@<style [^>]*?>.*?</style>@siU',
		'@< ![sS]*?--[ tnr]*>@'
		);
	$output = preg_replace($search, '', $input);
	return $output;
	}
	
/* Escapar cadenas de texto para SQL Server... */
function mssql_escape($str) 
	{
    if(get_magic_quotes_gpc()) { $str= stripslashes($str); }
	return str_replace("'", "''", $str);
	}

/* Truncar texto a una cadena de largo N */
function truncateText($string, $limit) 
	{
	$string = strip_tags($string);
	if(strlen($string) <= $limit) { Return $string; }
	else
		{
		$texto = split(' ',$string);
		$string = ''; $c = 0;
		while($limit >= strlen($string) + strlen($texto[$c]))
			{
			$string .= ' '.$texto[$c];
			$c = $c + 1;
			}
		return $string.'...';
		}
	}

/* Mostrar tamaño de un archivo como una cadena de texto... */
function format_filesize($peso , $decimales = 2) 
	{
	$clase = array(' Bytes', ' KB', ' MB', ' GB', ' TB');
	return round($peso / pow(1024,($i = floor(log($peso, 1024)))),$decimales ).$clase[$i];
	}

/* Convertir un valor numerico a una cadena con formato Precio (Ej: 99999 => $99.999) */
function formato_precio($valor)
	{
	return '$' . number_format($valor,0,'','.') . '-';
	}

/* Rellenar con X cantidad de ceros hacia la izquierda... */
function zerofill($valor, $longitud)
	{
	$res = str_pad($valor, $longitud, '0', STR_PAD_LEFT);
	return $res;
	}

/* Dar formato a una fecha para guardarla en la BD (31/12/2014 se convierte en 2014/31/12) */
function formatoFechaGuardar($fecha, $separador)
	{
	$f = explode($separador, $fecha);
	$fecha = $f[2] . $separador . $f[0] . $separador . $f[1];
	return $fecha;
	}

/* Dar formato a una fecha obtenida desde la BD (2014/31/12 se convierte en 31/12/2014) */
function formatoFechaLeer($fecha, $separador)
	{
	$fecha = date_format($fecha, 'd' . $separador . 'm' . $separador . 'Y');
	return $fecha;
	}

/* CONVERTIR FECHA 01/01/2015 A 01 ENERO 2015*/
function formatoFechaTexto($fecha, $separador)
	{
	$f = explode($separador, $fecha);
	$mes = $f[1];
	switch ($f[1])
		{
		case '01': $mes = 'Enero'; break;
		case '02': $mes = 'Febrero'; break;
		case '03': $mes = 'Marzo'; break;
		case '04': $mes = 'Abril'; break;
		case '05': $mes = 'Mayo'; break;
		case '06': $mes = 'Junio'; break;
		case '07': $mes = 'Julio'; break;
		case '08': $mes = 'Agosto'; break;
		case '09': $mes = 'Septiembre'; break;
		case '10': $mes = 'Octubre'; break;
		case '11': $mes = 'Noviembre'; break;
		case '12': $mes = 'Diciembre'; break;
		default: break;
		}
	$f[1] = $mes;
	$fecha = array('d' => $f[0], 'm' => $f[1], 'a' => $f[2]);
	return $fecha;
	}


function MesPal($mes)
	{
	if (($mes=='1')  or ($mes=='01')) { $varmes="Enero"; } 
	if (($mes=='2')  or ($mes=='02')) { $varmes="Febrero"; } 
	if (($mes=='3')  or ($mes=='03')) { $varmes="Marzo"; } 
	if (($mes=='4')  or ($mes=='04')) { $varmes="Abril"; } 
	if (($mes=='5')  or ($mes=='05')) { $varmes="Mayo"; } 
	if (($mes=='6')  or ($mes=='06')) { $varmes="Junio"; } 
	if (($mes=='7')  or ($mes=='07')) { $varmes="Julio"; } 
	if (($mes=='8')  or ($mes=='08')) { $varmes="Agosto"; } 
	if (($mes=='9')  or ($mes=='09')) { $varmes="Septiembre"; } 
	if (($mes=='10') or ($mes=='10')) { $varmes="Octubre"; } 
	if (($mes=='11') or ($mes=='11')) { $varmes="Noviembre"; } 
	if (($mes=='12') or ($mes=='12')) { $varmes="Diciembre"; }
	return $varmes;
	}

/* CONSULTA LOS MESES DE SOFTLAND */
function Meses()
	{
	include ('inc/conexion.php');
	
	$sel = "SELECT PpcAnoIni, PpcAno, PpcMes FROM ".$dbs .".[cwparam]";
	$res = sqlsrv_query($conn,$sel);
	
	while ($row = sqlsrv_fetch_array($res))
		{
		$ano_ini = $row['PpcAnoIni'];
		$mes_ini = $row['PpcMes'];
		}
	}

/* SELECT MES PARA <select></select>*/
function SelMes($mes)
	{
		
		$nombre = "";
		
		//PHP VERSION 5=========================
		/*
		if($mes == 01){$nombre = "Enero";}
		if($mes == 02){$nombre = "Febrero";}
		if($mes == 03){$nombre = "Marzo";}
		if($mes == 04){$nombre = "Abril";}
		if($mes == 05){$nombre = "Mayo";}
		if($mes == 06){$nombre = "Junio";}
		if($mes == 07){$nombre = "Julio";}
		if($mes == 08){$nombre = "Agosto";}
		if($mes == 09){$nombre = "Septiembre";}
		if($mes == 10){$nombre = "Octubre";}
		if($mes == 11){$nombre = "Noviembre";}
		if($mes == 12){$nombre = "Diciembre";}
		*/
		//======================================
		//PHP VERSION 7=========================
		if($mes == 1){$nombre = "Enero";}
		if($mes == 2){$nombre = "Febrero";}
		if($mes == 3){$nombre = "Marzo";}
		if($mes == 4){$nombre = "Abril";}
		if($mes == 5){$nombre = "Mayo";}
		if($mes == 6){$nombre = "Junio";}
		if($mes == 7){$nombre = "Julio";}
		if($mes == 8){$nombre = "Agosto";}
		if($mes == 9){$nombre = "Septiembre";}
		if($mes == 10){$nombre = "Octubre";}
		if($mes == 11){$nombre = "Noviembre";}
		if($mes == 12){$nombre = "Diciembre";}
		if($mes <> '')
		{
			echo '<option value="'.$mes.'"> '.$mes.' - '.$nombre.' </option>';
		}
	echo '
	<option value="00">Seleccione Mes</option>
	<option value="00"> -- </option>
	<option value="01">Enero</option>
	<option value="02">Febrero</option>
	<option value="03">Marzo</option>
	<option value="04">Abril</option>
	<option value="05">Mayo</option>
	<option value="06">Junio</option>
	<option value="07">Julio</option>
	<option value="08">Agosto</option>
	<option value="09">Septiembre</option>
	<option value="10">Octubre</option>
	<option value="11">Noviembre</option>
	<option value="12">Diciembre</option>
	';
	}

/* Select de Ano para <select></select> */
function SelAno($ano)
	{
			
	include('inc/conexion.php');


		$sel ="select distinct ano from dscis.dbo.DS_DistribucionCC  where ano!=''";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	
	
	if ($num > 0)
		{
				$salida = '<option>Seleccione A&ntilde;o</option><option> -- </option>';
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida .= '<option value="'.$row['ano'].'">'.$row['ano'].'</option>';
			}
		}
		
	echo $salida;	
	}

/* SELECT DE TEMPORADAS */
function SelTemporada()
	{
	echo '
	<option value="00">Seleccione Temporada</option>
	<option value="00"> -- </option>
	<option value="06.2015-05.2016">2015 - 2016</option>
	<option value="06.2014-05.2015">2014 - 2015</option>
	<option value="06.2013-05.2014">2013 - 2014</option>
	<option value="06.2012-05.2013">2012 - 2013</option>
	';
	}
	
	function MostrarImpuesto()
	{
		
		
	}

	
 function ValorImpuesto()
	{
	include ('inc/conexion.php');
					$fechaactual="select month(GETDATE()) as mes, YEAR(GETDATE())  as ano";
					$registros_fecha=sqlsrv_query($conn,$fechaactual,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
					while($registro_fecha=sqlsrv_fetch_array($registros_fecha))
					{
					$ano1=$registro_fecha['ano'];
					$mes1=$registro_fecha['mes'];
	
		
					}
				
					$consultarimpuesto="select convert(float,(impuesto)) as impuesto from  parametros where mes='".$mes1."' and  ano='".$ano1."'";
					$consulta_impuesto2=sqlsrv_query($conn,$consultarimpuesto,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
						while($consulta_impuesto=sqlsrv_fetch_array($consulta_impuesto2))
						{
							$valorimpuesto=$consulta_impuesto['impuesto'];		
						}
					ECHO $valorimpuesto;
	}


/* Convertir un array en una cadena de texto con un separador... */
function arrayToString($array, $separador)
	{
	$string = '';
	for($i=0; $i < count($array); $i++) { $string .= $array[$i] . $separador; }
	$string = substr($string, 0 , - (strlen($separador)));
	return $string;
	}

/* Buscar Cuentas de softland */
function ConsultaCuentas($buscar)
	{
	include ('inc/conexion.php');
	$isAjax = isset($_SERVER['HTTP_X_REQUESTED_WITH']) AND strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest';
	if(!$isAjax)
		{
		$user_error = 'Access denied - not an AJAX request...';
		trigger_error($user_error, E_USER_ERROR);
		}
	$a_json = array();
	$a_json_row = array();
	$partes = explode(' ', $buscar);
	$p = count($partes);
	
	$sql = "SELECT PCCODI, PCDESC, PCCCOS, PCDETG FROM ".$dbs.".[cwpctas] WHERE PCACTI ='S' AND PCNIVEL=(SELECT MAX(PCNIVEL) FROM ".$dbs.".[cwpctas]) AND ";
	for($i = 0; $i < $p; $i++)
		{
		$sql .= " (replace(PCCODI,'-','') LIKE replace('".$partes[$i]."%','-','') OR PCDESC LIKE '%".$partes[$i]."%') AND ";
		}
	$sql = substr($sql, 0 ,-4);
	$sql .= " ORDER BY PCCODI";
	$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($rec);
	$c = 0;
	if($num > 0)
		{
		while($row = sqlsrv_fetch_array($rec))
			{
			$a_json_row['value']  = $row['PCCODI'].' - '.$row['PCDESC'];
			$a_json_row['codigo'] = $row['PCCODI'];
			$a_json_row['nombre'] = $row['PCDESC'];
			array_push($a_json, $a_json_row);
			$c = $c + 1;
			}
		}
	$json = json_encode($a_json);
	print $json;
	}

function SelEmpresa()
	{
	include('inc/conexion.php');

	//$sel = "SELECT IdBDatos as empresa, DesBDatos as desempresa FROM ".$dba.".[UsuariosEmpresas], ".$dba.".[Usuarios] WHERE Usuario='".$_SESSION['user']['nick']."' AND ID=IdUsuario";
	$sel = "SELECT name FROM master.dbo.sysdatabases";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$arrayBD = "";
	$indice = 0;
	$salida = '<option value="00">Seleccione Empresa</option><option value="00"> -- </option>';
	/*
	if ($num > 0)
		{
		while ($row=sqlsrv_fetch_array($res))
			{
				//$salida .= '<option value="'.$row['empresa'].'[||]'.$row['desempresa'].'">'.$row['empresa'].' - '.$row['desempresa'].'</option>';
				//$j++;
				$arrayBD[$indice] = $row['name'];
				$indice++;
			}
			
			for($a=0;$a<count($arrayBD);$a++)
			{
				//echo $a."<---<br>";
				$queryValida = "SELECT TOP 1 parver FROM ".$arrayBD[$a].".softland.cwparam ";
				//echo $queryValida."    ";
				$resValida = sqlsrv_query($conn, $queryValida, array(), array('Scrollable' => 'buffered'));
				$numValida = sqlsrv_num_rows($resValida);
				
				if($numValida == 1)
				{
					$salida .= '<option value="'.$arrayBD[$a].'[||]'.$arrayBD[$a].'">'.$arrayBD[$a].'</option>';
				}
				
				
			}
			
			
			//print_r($arrayBD);
		}
	*/
	
	$salida .= '<option value="CIS[||]CIS">CIS</option>';
	$salida .= '<option value="NUEVAHORNILLAS[||]NUEVAHORNILLAS">NUEVAHORNILLAS</option>';
	echo $salida;
	}

function CentrosCostos($id)
	{
	include('inc/conexion.php');

	if ($id!='')
		{
		$sel = "SELECT CodiCC, DescCC FROM ".$dbs.".[cwtccos] WHERE Activo='S' AND NivelCC=(SELECT MAX(NivelCC) FROM ".$dbs.".cwtccos) AND CodiCC='".$id."'";
		$salida = '';
		}
	else 
		{
		$sel = "SELECT CodiCC, DescCC FROM ".$dbs.".[cwtccos] WHERE Activo='S' AND NivelCC=(SELECT MAX(NivelCC) FROM ".$dbs.".cwtccos) ";
		$salida = '<option value="00">Seleccione Empresa</option><option value="00"> -- </option>';
		}
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	
	
	if ($num > 0)
		{
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida .= '<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' - '.$row['DescCC'].'</option>';
			$j++;
			}
		}
	echo $salida;	
	}

function PorCenCos($id)
	{
	include('inc/conexion.php');	
		
	$sel = " SELECT a.CodiCC, a.DescCC, ISNULL(b.Porcen,0) as Porcen ";
	$sel.= " FROM ".$dbs.".[cwtccos] as a "; 
	$sel.= " LEFT JOIN ".$dba.".[DistCC] as b ON a.CodiCC=b.CodiCC COLLATE Modern_Spanish_CI_AS ";
	$sel.= " WHERE a.NivelCC=(SELECT MAX(NivelCC) FROM ".$dbs.".[cwtccos]) and a.Activo='S' AND b.CodiCCAD='".$id."' ";
	$sel.= " ORDER BY CodiCC ";
	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$salida = '
		<div class="row col-md-12">
			<div class="col-md-2">C&oacute;digo C.C.</div>
			<div class="col-md-4">Descripci&oacute;n C.C.</div>
			<div class="col-md-2">Porcentaje</div>
		</div>';
	if ($num > 0)
		{
		$j=0;
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida.= '<div class="row">';
			$salida.= '<div class="col-sm-2"><input type="text" name="codicc['.$j.']" id="codicc" hidden value="'.$row['CodiCC'].'">'.$row['CodiCC'].'</div>';
			$salida.= '<div class="col-sm-4"><input type="text" name="desccc['.$j.']" id="desccc" hidden value="'.$row['DescCC'].'">'.$row['DescCC'].'</div>';
			$salida.= '<div class="col-sm-2"><input type="number" step="0.0001" min="0" max="100" name="porcen" id="porcen" value="'.$row['Porcen'].'" class="ta_r porcen" onblur="Sumax(this.value);"></div>';
			$salida.='</div>';
			$j++;
			}
		}
	return $salida;			
	}


/* ************************************************* */
/*          FUNCIONES MANTENEDORES USUARIOS          */
/* ************************************************* */

function ManUserInsert($data)  // INSERTA LOS USUARIOS A LA BASE DE DATOS
	{
	include('inc/conexion.php');
	$data['correo'] = trim(strtolower($data['correo']));
	$data['usuario'] = trim($data['usuario']);

	// Verificar si nombre de Usuario se encuentra disponible...
	$rec = sqlsrv_query($conn, "SELECT COUNT(*) AS existe_usuario FROM ".$dba.".[Usuarios] WHERE Usuario='".$data['usuario']."'");
	$row = sqlsrv_fetch_array($rec);
	$existe_usuario = $row['existe_usuario'];

	// Verificar si Correo electronico se encuentra disponible...
	$rec = sqlsrv_query($conn, "SELECT COUNT(*) AS existe_correo FROM ".$dba.".[Usuarios] WHERE Correo='".$data['correo']."'");
	$row = sqlsrv_fetch_array($rec);
	$existe_correo = $row['existe_correo'];

	if($existe_usuario > 0){ return 'ERROR_EXISTE_USUARIO';}
	if($existe_correo > 0){	return 'ERROR_EXISTE_CORREO';}
	else
		{
		$sql = "INSERT INTO ".$dba.".[Usuarios] ([Usuario], [Contrasena], [Nombres], [Correo], [Tipo],[esMandante]) VALUES "; 
		$sql.= "('".$data['usuario']."', PWDENCRYPT('".$data['contrasena']."'), '".$data['nombres']."', '".$data['correo']."','".$data['tipo']."','".$data['mandante']."')";
		$rec = sqlsrv_query($conn, $sql);
		return 'OK';
		}
	}

function ManUserEdit($data, $id)
	{
	include('inc/conexion.php');
	$data['correo'] = trim(strtolower($data['correo']));
	$data['usuario'] = trim($data['usuario']);

	// Verificar si nombre de Usuario se encuentra disponible...
	$rec = sqlsrv_query($conn, "SELECT COUNT(*) AS existe_usuario FROM ".$dba.".[Usuarios] WHERE id <> ".$id." AND Usuario='".$data['usuario']."'");
	$row = sqlsrv_fetch_array($rec);
	$existe_usuario = $row['existe_usuario'];

	// Verificar si Correo electronico se encuentra disponible...
	$rec = sqlsrv_query($conn, "SELECT COUNT(*) AS existe_correo FROM ".$dba.".[Usuarios] WHERE id <> ".$id." AND Correo='".$data['correo']."'");
	$row = sqlsrv_fetch_array($rec);
	$existe_correo = $row['existe_correo'];

	if($existe_usuario > 0){ return 'ERROR_EXISTE_USUARIO';}
	if($existe_correo > 0){	return 'ERROR_EXISTE_CORREO';}
	else
		{
		$sql = "UPDATE ".$dba.".[Usuarios] SET Nombres='".$data['nombres']."', Usuario='".$data['usuario']."', ";
		$sql.= "Correo='".$data['correo']."', Tipo='".$data['tipo']."', EsMandante='".$data['mandante']."' WHERE id=".$id;
		$rec = sqlsrv_query($conn, $sql);
		// Si la contrasena fue modificada...
		if($data['contrasena'])
			{
			$sql = "UPDATE ".$dba.".[Usuarios] SET Contrasena=PWDENCRYPT('".$data['contrasena']."') WHERE id=".$id;
			$rec = sqlsrv_query($conn, $sql);
			}
		return 'OK';
		}
	}

function ManUserDel($id)
	{
	include('inc/conexion.php');
	$sql = "DELETE FROM ".$dba.".[Usuarios] WHERE id=".$id;	
	$rec = sqlsrv_query($conn, $sql);
	}


function ManUserLis($id)
	{
	include('inc/conexion.php');

	$sel = "SELECT Usuario, Nombres, Correo, Tipo, esMandante FROM ".$dba.".[Usuarios] Where ID='".$id."'";
	$res = sqlsrv_query($conn, $sel);
	$row = sqlsrv_fetch_array($res);
	return $row;
	}

function UsuariosListado() // LISTADO DE LOS USUARIOS INGRESADOS
	{
	include('inc/conexion.php');

	$sel = "SELECT a.ID, a.Usuario, a.Nombres, a.Correo, b.Nombre FROM ".$dba.".[Usuarios] AS a, ".$dba.".[UsuariosTipos] AS b Where a.Tipo=b.ID";
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
			<th nowrap="nowrap">Usuario</th>
			<th nowrap="nowrap">Nombres</th>
			<th nowrap="nowrap">Correo</th>
			<th nowrap="nowrap">Tipo</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
			{
			if ($j%2==0) { $col = 'col-par'; } else { $col = ''; }
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-1 blr">'.$row['ID'].'</td>
				<td class="col-sm-2 blr">'.$row['Usuario'].'</td>
				<td class="col-sm-3 blr">'.$row['Nombres'].'</td>
				<td class="col-sm-3 blr">'.$row['Correo'].'</td>
				<td class="col-sm-2 blr">'.$row['Nombre'].'</td>
				<td class="col-sm-1">
					<a href="javascript:EdiUser(\''.$row['ID'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:DelUser(\''.$row['ID'].'\');" class="icon delete">Eliminar</a>
				</td>
			</tr>';
			$j++;
			}
		$salida.= '</tbody></table>'; 
		}
	echo $salida;
	}

function ManUserTip($tip) // LISTADO DE TIPOS DE USUARIOS
	{
	include('inc/conexion.php');
	$salida = '<select name="tipo" id="tipo">';
	if ($tip=='0')
		{
		$salida.= '<option value="">Seleccione Tipo de Usuario</option><option>--</option>';
		}
	else
		{
		$sela = "SELECT ID, Nombre FROM ".$dba.".[UsuariosTipos] where ID='".$tip."'";
		$resa = sqlsrv_query($conn, $sela);
		$rowa = sqlsrv_fetch_array($resa);
		$salida.= '<option value="'.$rowa['ID'].'">'.$rowa['Nombre'].'</option><option>--</option>';
		} 
	$sel = "SELECT ID, Nombre FROM ".$dba.".[UsuariosTipos]";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	while ($row=sqlsrv_fetch_array($res))
		{
		$salida.= '<option value="'.$row['ID'].'">'.$row['Nombre'].'</option>';
		}
	$salida.='</select>';
	return $salida;
	}

function ManUserEmp() // LISTADOS DE EMPRESAS RELACIONADAS
	{
	include('inc/conexion.php');

	$salida = '<select name="mandante" id="mandante">';
	$sel = "SELECT IdBDatos as empresa, DesBDatos as desempresa FROM ".$dba.".[UsuariosEmpresas], ".$dba.".[Usuarios] WHERE Usuario='".$_SESSION['user']['nick']."' AND ID=IdUsuario";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$salida.= '<option value="">Seleccione Empresa</option><option value=""> -- </option>';
	if ($num > 0)
		{
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida.= '<option value="'.$row['empresa'].'">'.$row['desempresa'].'</option>';
			$j++;
			}
		}
	$salida.='</select>';
	echo $salida;
	}


/* ************************************************* */
/*          FUNCIONES MANTENEDORES FORMATOS          */
/* ************************************************* */

function ManCtasListar() // LISTADO DE NIVELES
	{
	include('inc/conexion.php');

	$sel = "SELECT CodNivel, DesNivel, Tipo FROM ".$dba.".[Niveles]";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$j=1;

	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="dataTable">
		<thead>
		<tr>
			<th nowrap="nowrap">Codigo</th>
			<th nowrap="nowrap">Descripci&oacute;n</th>
			<th nowrap="nowrap">Tipo</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-3 blr">'.$row['CodNivel'].'</td>
				<td class="col-sm-5 blr">'.$row['DesNivel'].'</td>
				<td class="col-sm-2 blr">'.$row['Tipo'].'</td>
				<td class="col-sm-2">
					<a href="javascript:EdiForm(\''.$row['CodNivel'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:DelForm(\''.$row['CodNivel'].'\');" class="icon delete">Eliminar</a>
				</td>
			</tr>';
			$j++;
			}
		$salida.= '</tbody></table>'; 
		}
	echo $salida;
	}

function ManFormInsert($data)  // INSERTA LOS FORMATOS A LA BASE
	{
	include('inc/conexion.php');

	$sql = "INSERT INTO ".$dba.".[Niveles] (CodNivel, DesNivel, Tipo) VALUES "; 
	$sql.= "('".$data['codigo']."', '".$data['descri']."', '".$data['tiponivel']."')";
	$rec = sqlsrv_query($conn, $sql);
	if ($rec)
		{
		return 'OK';
		}
	else
		{
		return 'ERROR';
		}
	}

function ManFormEdit($data, $id)
	{
	include('inc/conexion.php');

	$sql = "UPDATE ".$dba.".[Niveles] SET DesNivel='".$data['descri']."', Tipo='".$data['tiponivel']."' WHERE CodNivel='".$id."'";
	$rec = sqlsrv_query($conn, $sql);
	if ($rec)
		{
		return 'OK';
		}
	else 
		{
		return 'ERROR';	
		}
	}

function ManFormDel($id)
	{
	include('inc/conexion.php');
	$sql = "DELETE FROM ".$dba.".[Niveles] WHERE CodNivel=".$id;	
	$rec = sqlsrv_query($conn, $sql);
	}


function AnoEERR()
{
	include 'inc/conexion.php';
	$query =" SELECT distinct ano FROM rsphola.dbo.ds_agrupacioncuentas ";

	
		//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($row = sqlsrv_fetch_array($rec))
		{
			
			$opt.='<option value="'.$row['ano'].'">'.$row['ano'].'</option>';
		}		
	print $opt;
}


function MesesEERR()
{
	include 'inc/conexion.php';
	$query =" select distinct cpbmes from cis.softland.cwmovim where CpbMes not in ('00')";

	
		//echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($row = sqlsrv_fetch_array($rec))
		{
			
			$opt.='<option value="'.$row['cpbmes'].'">'.$row['cpbmes'].'</option>';
		}		
	print $opt;
}
	 
function ManFormLis($id)
	{
	include('inc/conexion.php');

	$sel = "SELECT CodNivel, DesNivel, Tipo FROM ".$dba.".[Niveles] Where CodNivel='".$id."'";
	$res = sqlsrv_query($conn, $sel);
	$row = sqlsrv_fetch_array($res);
	return $row;
	}

/* ************************************************* */
/*        FUNCIONES MANTENEDORES DISTRIBUCION        */
/* ************************************************* */

function DistListado() // LISTADO DE NIVELES
	{
	include('inc/conexion.php');

	$sel = " SELECT a.CodiCCAD, b.DescCC as DescAD, a.CodiCC, c.DescCC as DescCC, a.Porcen "; 
	$sel.= " FROM ".$dba.".[DistCC] AS a ";
	$sel.= " LEFT JOIN ".$dbs.".cwtccos AS b ON a.CodiCCAD=b.CodiCC COLLATE Modern_Spanish_CI_AS ";
	$sel.= " LEFT JOIN ".$dbs.".cwtccos AS c ON a.CodiCC=c.CodiCC COLLATE Modern_Spanish_CI_AS ";
	$sel.= " WHERE porcen!='0' ORDER BY CodiCCAD ";
	
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
			<th nowrap="nowrap">C.Costo</th>
			<th nowrap="nowrap">Descripci&oacute;n</th>
			<th nowrap="nowrap">C.Costo Dist.</th>
			<th nowrap="nowrap">Descripci&oacute;n</th>
			<th nowrap="nowrap">Porcentaje</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-2 blr">'.$row['CodiCCAD'].'</td>
				<td class="col-sm-6 blr">'.$row['DescAD'].'</td>
				<td class="col-sm-1 blr">'.$row['CodiCC'].'</td>
				<td class="col-sm-1 blr">'.$row['DescCC'].'</td>
				<td class="col-sm-5 blr ta_r">'.$row['Porcen'].'</td>
				<td class="col-sm-1">
					<a href="javascript:EdiDist(\''.$row['CodiCCAD'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:DelDist(\''.$row['CodiCCAD'].'\');" class="icon delete">Eliminar</a>
				</td>
			</tr>';
			$j++;
			}
		$salida.= '</tbody></table>'; 
		}
	else
		{
		$salida="<h1>Sin Datos para mostrar</h1>";	
		}
	echo $salida;
	}

function ManDistInsert($data)  // INSERTA LOS FORMATOS A LA BASE
	{
	include('inc/conexion.php');

	$sql = "INSERT INTO ".$dba.".[DistCC] (CodiCCAD, CodiCC, Porcen) VALUES "; 
	$sql.= "('".$data['codiccad']."', '".$data['mandet']."', '".$data['maniva']."','".$data['posicion']."', '".$data['gasad']."')";
	$rec = sqlsrv_query($conn, $sql);
	if ($rec)
		{
		return 'OK';
		}
	else
		{
		return 'ERROR';
		}
	}

function ManDistEdit($data)
	{
	include('inc/conexion.php');

	$codi = $data['codicc'];
	$porc = $data['porcen'];
	$ccad = $data['codiccad'];
	
	$cant = sizeof($codi);

	for ($i=0;$i<$cant;$i++)
		{
	  	$upd = "UPDATE ".$dba.".[DistCC] SET porcen='".$porc[$i]."' WHERE CodiCCAD='".$ccad."' AND CodiCC='".$codi[$i]."'";
		$res = sqlsrv_query($conn, $upd);
		if ($res)
			{
			$status = 'OK';	
			}
		else 
			{
			$status = 'ERROR';
			$i=$cant;
			}
		}
	return $status;	
	}

function ManDistDel($id)
	{
	include('inc/conexion.php');
	
	$sql = " UPDATE ".$dba.".[DistCC] SET Porcen='0' WHERE CodiCCAD='".$id."' ";
	$rec = sqlsrv_query($conn, $sql);
	if ($rec)
		{
		return 'OK';
		}
	else 
		{
		return 'ERROR';	
		}
	}

function ManDistLis($id)
	{
	include('inc/conexion.php');

	$sel = "SELECT PctCod, ManejaDet, ManejaIVA, posicion, gasad FROM ".$dba.".[DistCC] Where PctCod='".$id."'";
	$res = sqlsrv_query($conn, $sel);
	$row = sqlsrv_fetch_array($res);
	return $row;
	}

/* ************************************************* */
/*        FUNCIONES MANTENEDORES DISTRIBUCION        */
/* ************************************************* */

function UbiListado() // LISTADO DE NIVELES
	{
	include('inc/conexion.php');

	$sel = "SELECT ub.CodCC, cc.DescCC, ub.Ubicacion FROM ".$dba.".[UbiCC] AS ub ";
	$sel.= "LEFT JOIN ".$dbs.".[cwtccos] AS cc ON ub.CodCC=cc.CodiCC COLLATE Modern_Spanish_CI_AS";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	$j=1;

	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="dataTable">
		<thead>
		<tr>
			<th nowrap="nowrap">Codigo</th>
			<th nowrap="nowrap">Centro Costo</th>
			<th nowrap="nowrap">Sucursal / Casa Matriz</th>
			<th nowrap="nowrap">&nbsp;</th>
		</tr>
		</thead>
		<tbody>';
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida .= '
			<tr id="tr_'.$j.'">
				<td class="col-sm-3 blr">'.$row['CodCC'].'</td>
				<td class="col-sm-3 blr">'.$row['DescCC'].'</td>
				<td class="col-sm-5 blr">'.$row['Ubicacion'].'</td>
				<td class="col-sm-2">
					<a href="javascript:EdiUbi(\''.$row['CodCC'].'\');" class="icon edit">Modificar</a>
					<a href="javascript:DelUbi(\''.$row['CodCC'].'\');" class="icon delete">Eliminar</a>
				</td>
			</tr>';
			$j++;
			}
		$salida.= '</tbody></table>'; 
		}
	echo $salida;
	}

function ManUbiInsert($data)  // INSERTA LOS FORMATOS A LA BASE
	{
	include('inc/conexion.php');

	$num = $data['num'];
	$cod = $data['codicc'];
	$rad = $data['rad'];
	
	$dol = "DELETE FROM ".$dba.".[UbiCC]";
	$sol = sqlsrv_query($conn, $dol);
		
	
	for ($i=0; $i<$num; $i++)
		{
		if (!empty($rad[$i]))
			{
			$sql = "INSERT INTO ".$dba.".[UbiCC] (CodCC, Ubicacion) VALUES "; 
			$sql.= "('".$cod[$i]."', '".$rad[$i]."')";
			$rec = sqlsrv_query($conn, $sql);
			}
		}
	return 'OK';
	}

function ManUbiEdit($data, $id)
	{
	include('inc/conexion.php');

	$sql = "UPDATE ".$dba.".[UbiCC] SET Ubicacion='".$data['ubicacion']."' WHERE CodCC='".$id."'";
	$rec = sqlsrv_query($conn, $sql);
	if ($rec)
		{
		return 'OK';
		}
	else 
		{
		return 'ERROR';	
		}
	}

function ManUbiDel($id)
	{
	include('inc/conexion.php');
	$sql = "DELETE FROM ".$dba.".[UbiCC] WHERE CodCC=".$id;	
	$rec = sqlsrv_query($conn, $sql);
	}


function ManUbiLis($id)
	{
	include('inc/conexion.php');

	$sel = "SELECT CodCC, Ubicacion FROM ".$dba.".[UbiCC] Where CodCC='".$id."'";
	$res = sqlsrv_query($conn, $sel);
	$row = sqlsrv_fetch_array($res);
	return $row;
	}

function LisCenCos()
	{
	include('inc/conexion.php');

	$sel = "SELECT CodiCC, DescCC FROM ".$dbs.".[cwtccos] ";
	$sel.= "where NivelCC=(SELECT MAX(NivelCC) FROM ".$dbs.".[cwtccos]) and Activo='S' and DescCC!=''";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_num_rows($res);
	if ($res)
		{
		$salida = '
		<div class="row borde_gris2">
				<label class="col-sm-6">CENTRO DE COSTO</label>
				<div class="col-sm-2 ta_c">SUCURSAL</div>
				<div class="col-sm-2 ta_c">CASA MATRIZ</div>
				<input type="hidden" name="num" id="num" value="'.$num.'" />
			</div>
		';
		$i=0;
		while($row=sqlsrv_fetch_array($res))
			{
			$salida.= '
			<div class="row">
				<label class="col-sm-6">'.$row['CodiCC'].' -- '.$row['DescCC'].'</label>
				<input type="hidden" value="'.$row['CodiCC'].'" id="codicc['.$i.']" name="codicc['.$i.']" />
				<div class="col-sm-2 ta_c"><input type="radio" id="rad['.$i.']" name="rad['.$i.']" value="S"></div>
				<div class="col-sm-2 ta_c"><input type="radio" id="rad['.$i.']" name="rad['.$i.']" value="C"></div>
			</div>
			';
			$i++;
			}	
		}
	echo $salida;
	}
	
/* PRESUPUESTOS */

function Presup($pre)
	{
	include('inc/conexion.php');

	$sel = "SELECT distinct Preop_id FROM ".$dbs.".[cwpreop] ";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	if ($res)
		{
		$salida = '<option>Seleccione Presupuesto</option><option> -- </option>';
		while ($row=sqlsrv_fetch_array($res))
			{
				if($pre == $row['Preop_id'])
				{
					$salida.= '<option valuie="'.$row['Preop_id'].'" selected="selected">'.$row['Preop_id'].'</option>';
				}
				else
				{
					$salida.= '<option valuie="'.$row['Preop_id'].'">'.$row['Preop_id'].'</option>';
				}
				
			}
		}
	return $salida;
	}

// ****************************************************************** //
//               FUNCIONES ASIGNACION DE MANAGEMENT FEE               //
// ****************************************************************** //		
function DistManagement()
	{
	include ('inc/conexion.php');
	
	$sel = "SELECT CodCC,M1,M2,M3,M4,M5,M6,M7,M8,M9,M10.M11.M12 FROM ".$dba.".[Management] order by ANO AND CodCC";	
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	if ($res)
		{
		while ($row=sqlsrv_fetch_array($res))
			{
			
			}
		}
	else 
		{
		echo "<h1> SIN DATOS PARA MOSTRAR </h1>";
		}
	}

function InsManagement() 
	{
		
	}
function DelManagement()
	{
		
	}

function ListManagement($id,$ano)
	{
	include('inc/conexion.php');
	$sel = "SELECT * FROM ".$dba.".[Management] where ANO='' and CodCC='".$id."'";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$row = sqlsrv_fetch_array($res);
	return $row;
	}

function SelCenCos()
	{
	include('inc/conexion.php');	
		
	$sel = " SELECT CodiCC, DescCC FROM ".$dbs.".[cwtccos] ";
	$sel.= " WHERE Activo='S' and NivelCC=(SELECT MAX(NivelCC) FROM AVC2.softland.cwtccos) AND DescCC!=''";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	if ($res)
		{
		$salida = "<option value='A999'>Todos los Centros de Costos</option>";
		$salida.= "<option value='A000'>Total General</option>";
		while ($row=sqlsrv_fetch_array($res))
			{
			$salida.= "<option value='".$row['CodiCC']."'>".$row['CodiCC']." - ".$row['DescCC']."</option>";
			}	
		}
	else
		{
		$salida="<option value=''> - SIN DATOS - </option>";
		}
	echo $salida;
	}	

function CCostoListar()//$nivel
{
	include 'inc/conexion.php';		
	$opt = "";
	
	$query = " SELECT CodiCC, DescCC FROM ".$dbs.".cwtccos where DescCC <> '' AND Activo = 'S' and nivelCC = '1' and CodiCC not in ('01-000','11-000','12-000','02-000')";

		echo $query;
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec))
	{
		$opt.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' - '.$row['DescCC'].'</option>';
	}		
		print $opt;
}

function getDatosEmpresa_()
	{
	include('inc/conexion.php');
	
	$sql = " SELECT NomB,Giro,Dire,RutE,Ciud FROM ".$dbs.".[soempre] ";
	$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
	$DatosEmpresa = array();
	$num_rows = sqlsrv_num_rows($rec);
	//echo $sql;
	$p = 0;
	if($num_rows > 0)
		{
		while($row = sqlsrv_fetch_array($rec))
			{
			$DatosEmpresa[$p] = array(		
				'NomB' => $row['NomB']	,
				'Giro' => $row['Giro']	,
				'Dire' => $row['Dire']	,
				'RutE' => $row['RutE']	,
				'Ciud' => $row['Ciud']	
				);
			$p = $p + 1;
			}
		}	
	return $DatosEmpresa;
	}
	function getDatosComprobanteNumero_($cpbnum)
	{
	include('inc/conexion.php');
	
	$sql = " SELECT CpbGlo, convert(varchar(20),(cpbfec),103) as cpbfec, cpbtip FROM ".$dbs.".cwcpbte WHERE cpbnum='".$cpbnum."' ";
	$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
	
	$DatosComprobanteNumero = array();
	$num_rows = sqlsrv_num_rows($rec);
	$p = 0;
	if($num_rows > 0)
		{
		while($row = sqlsrv_fetch_array($rec))
			{
			$DatosComprobanteNumero[$p] = array(		
				'CpbGlo' => $row['CpbGlo']	,
				'cpbfec' => $row['cpbfec'],
				'cpbtip' => $row['cpbtip']		
				);
			$p = $p + 1;
			}
		}
	return $DatosComprobanteNumero;
	}

function getDetalleCuentasNumero($cuentaNumero,$mes,$ano,$item,$cc,$cc1)
	{
	include('inc/conexion.php');
	
	/*
	$sql = " SELECT m.PctCod, pc.pcdesc, cccod, TtdCod, NumDoc, MovTipDocRef, MovNumDocRef, MovDebeMa, MovDebeMa, MovDebe, ";
	$sql.= " Movhaber, MovhaberMA, MovGlosa FROM ".$dbs.".cwmovim m INNER JOIN ".$dbs.".[cwpctas] pc on pc.PCCODI=m.PctCod ";
	$sql.= " WHERE cpbnum='".$cuentaNumero."' and cpbmes='".$mes."' AND cpbano='".$ano."' ";
	*/
	/* $sql="SELECT m.PctCod, p.pcdesc, cccod, TtdCod, NumDoc, MovTipDocRef, MovNumDocRef, MovDebeMa, MovDebeMa, MovDebe, Movhaber, MovhaberMA, MovGlosa,m.cpbmes
 FROM ".$_SESSION['emp']['id'].".softland.cwmovim m INNER JOIN ".$_SESSION['emp']['id'].".softland.[cwpctas] p
 on p.PCCODI=m.PctCod 
 inner join cis.softland.cwcpbte cpbte
 on  m.CpbNum=cpbte.CpbNum
 WHERE m.cpbnum='".$cuentaNumero."' and m.cpbmes between 00 and '".$mes."' AND m.cpbano='".$ano."' and cccod='".$cc."' and  cpbte.CpbEst='V'";*/
	$centro=substr($cc, 0, -1);

	$sql =" SELECT m.PctCod, pc.pcdesc, cccod, TtdCod, NumDoc, MovTipDocRef, MovNumDocRef, MovDebeMa, MovDebeMa, MovDebe, ";
	$sql.=" Movhaber, MovhaberMA, MovGlosa FROM ".$_SESSION['emp']['id'].".softland.cwmovim m ";
	$sql.=" INNER JOIN ".$_SESSION['emp']['id'].".softland.[cwpctas] pc on pc.PCCODI=m.PctCod ";
	$sql.=" WHERE cpbnum='".$cuentaNumero."' and cpbmes between 00 and '".$mes."' AND cpbano='".$ano."' and cccod like '".$centro."1'";
echo $sql;
 
	//$sql.=" and m.CCCod = '".$cc."' ";
	//echo $sql." ----<br>";
	$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
	$totalDebe = 0;
	$totalHaber = 0;
	$num_rows = sqlsrv_num_rows($rec);
	if($num_rows > 0)
		{
		$salida = '
		<table align="center" border="1" class="boxedb">
			<thead>
				<tr class="tit">
					<th width="100" align="center">&nbsp;Cod. Cuenta</th>
					<th width="120" align="center">&nbsp;Descripcion Cta.</th>
					<th width="100" align="center">&nbsp;Centro Costo</th>
					<th width="50" align="center">&nbsp;Tipo Doc</th>
					<th width="100" align="center">&nbsp;Num Doc</th>
					<th width="50" align="center">&nbsp;Doc. Referencia</th>
					<th width="100" align="center">&nbsp;N° Doc Ref</th>
					<th width="100" align="center">&nbsp;Debe</th>
					<th width="100" align="center">&nbsp;Haber</th>
					<th width="280" align="center">&nbsp;Descripci&oacute;n</th>
				</tr>
			</thead>
		<tbody>';
		while($row = sqlsrv_fetch_array($rec))
			{
			$salida .= '
			<tr>
				<td align="center">'.$row['PctCod'].'</td>
				<td align="left">'.$row['pcdesc'].'</td>
				<td align="center">'.$row['cccod'].'</td>
				<td align="center">'.$row['TtdCod'].'</td>				
				<td align="center">'.$row['NumDoc'].'</td> 
				<td align="center">'.$row['MovTipDocRef'].'</td>
				<td align="center">'.$row['MovNumDocRef'].'</td>
				<td align="right">$ '.number_format($row['MovDebe'], 2, ",", ".").'</td>			
				<td align="right">$ '.number_format($row['Movhaber'], 2, ",", ".").'</td>
				<td align="left">'.$row['MovGlosa'].'</td> 
			</tr>';
			
				$totalDebe += $row['MovDebe'];
				$totalHaber += $row['Movhaber'];			
			}
			
			$salida .= '
			<tr>
				<td align="center">TOTAL</td>
				<td align="left">&nbsp;</td>
				<td align="center">&nbsp;</td>
				<td align="center">&nbsp;</td>				
				<td align="center">&nbsp;</td> 
				<td align="center">&nbsp;</td>
				<td align="center">&nbsp;</td>
				<td align="right">$ '.number_format($totalDebe, 2, ",", ".").'</td>			
				<td align="right">$ '.number_format($totalHaber, 2, ",", ".").'</td>
				<td align="left">'.$row['MovGlosa'].'</td> 
			</tr>';	
			
			
		$salida .= '</tbody>
		</table>
		</center>
		<br/><br/><br/>';
		}
	if($num_rows == 0)
		{
		$salida = '<div class="message_info"><p>No se han encontrado elementos en esta secci&oacute;n</p></div>';
		}
	return $salida;
	}	
?>