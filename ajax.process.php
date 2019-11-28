<?php
session_start();
include('inc/conexion.php');
include('inc/funciones.php');
include('inc/funciones_rodrigo.php');
include('inc/funciones_relacion.php');
include('inc/funciones_agrupacion_cuentas.php');
include('inc/funciones_niveles.php');


if (isset($_POST['seccion']))
	{
	/* VALIDA NOMBRE DE USUARIO Y CONTRASEÑA */
	if($_POST['accion'] == 'login')
		{
		$wuser = sanitize($_POST['wuser']);
		$wpass = sanitize($_POST['wpass']);
		
		$sel =" SELECT ";
		$sel.=" usr.ID, usr.Usuario, usr.Nombres, usr.email, usr.tipoUsuario as Tipo, tip.tipoUsuario as Nombre ";
		$sel.=" FROM ".$dba.".[DS_Usuarios] AS usr ";
		$sel.=" LEFT JOIN ".$dba.".[DS_UsuariosTipos] as tip ON usr.tipoUsuario=tip.ID WHERE usr.Usuario='".$wuser."' AND PWDCOMPARE('".$wpass."',usr.Contrasena)=1";
				
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$row = sqlsrv_fetch_array($res);
		$num = sqlsrv_num_rows($res);
		if($num == 1)
			{
				$_SESSION['user']['id']		 = $row['ID'];
				$_SESSION['user']['nick']	 = $row['Usuario'];
				$_SESSION['user']['nombre']  = $row['Nombres'];
				$_SESSION['user']['codtipo'] = $row['Tipo'];
				$_SESSION['user']['destipo'] = $row['Nombre'];
			$status = array('tipo' => 'LOGIN_OK', 'url' => 'selempresa');
			}
		else
			{
			$status = array('tipo' => 'ERROR', 'mensaje' => 'Usuario/Contraseña incorrectos, por favor reintente', 'campo' => '#wpass' , 'SQL' => $sel);
			}
		}
		
	/* SELECCIONA LA EMPRESA DISPONIBLE PARA EL CLIENTE */
	else if($_POST['accion'] == 'empresa')
		{
		$data = $_POST['empresa'];
		$datx = explode("[||]",$data);

		$_SESSION['emp']['id']   = $datx[0];
		$_SESSION['emp']['desc'] = $datx[1];
		$_SESSION['emp']['bd'] = $datx[1].".softland";
		if (isset($_SESSION['emp']['id']))
			{
			$status = array('tipo' => 'OK', 'url' => 'inicio');
			}
		else
			{
			$status = array('tipo' => 'ERROR', 'mensaje' => 'No hay datos validos');
			}
		}
	/* REPORTES - SELECCIONA PERIODO ESTADO DE RESULTADO */
	else if($_POST['accion'] == 'estado-resultado')
		{
		$data = sanitize($_POST);
		$insertar = ManUserInsert($data);
		if ($insertar == 'ERROR_EXISTE_USUARIO') { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este nombre de usuario no se encuentra disponible', 'campo' => '#usuario'); }
		if ($insertar == 'ERROR_EXISTE_CORREO')  { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este correo electr&oacute;nico no se encuentra disponible', 'campo' => '#correo'); }
		if ($insertar == 'OK')                   { $status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha agregado correctamente un nuevo elemento'); }
		else { $status = array('tipo' => 'ERROR', 'mensaje' => 'Los datos no han podido ser cargados a la base, favor verificar datos', 'campo' => '#usuario'); }
		}
	

	/* Si no hay seleccion alguna, Error de entrada de datos */
	else
		{
		$status = array('tipo' => 'ERROR', 'mensaje' => 'Error 900, Usted, ¿Que hace aquí? Favor Contacte con el administrador, ajax.process.php - Linea 315');
		}
	$json_data = json_encode($status);
	echo $json_data;
	}
else
	{
	if(isset($_GET['term']))
		{
		$textoBuscar = trim(sanitize($_GET['term']));
		ConsultaAuxiliar($textoBuscar);
		}
		else if ($_POST['accion'] == 'guardarClientes')
		{
			$data = sanitize($_POST);
			$resultado =  empresasInsertar($data);
			if($resultado['registros_insertados'] > 0)
			{
				$status = array('tipo' => 'OK', 'mensaje' => 'Se han ingresado '.$resultado['bd_insertados'].' correctamente');
			}
			else if ($resultado['registros_insertados'] == 0)
			{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'no se han insertado '.$resultado['bd_existentes'].' ya estan ingresadas');
			}
			else
			{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Contactese con el Administrador ERROR 301');
			}
				
				$json_data = json_encode($status);
				echo $json_data;
		}
		else if ($_POST['accion'] == 'guardarRelacion')
		{
			$data = sanitize($_POST);
			$resultado =  relacionInsertar($data);
			
			if($resultado['registros_insertados'] > 0)
			{
				$status = array('tipo' => 'OK', 'mensaje' => 'Se han ingresado '.$resultado['bd_insertados'].' correctamente');
			}
			else if ($resultado['registros_insertados'] == 0)
			{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'no se han insertado '.$resultado['bd_existentes'].' ya estan ingresadas');
			}
			else
			{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Contactese con el Administrador ERROR 301');
			}
				$json_data = json_encode($status);
				echo $json_data;
		}
		else if ($_POST['accion'] == 'editarRelacion')
		{
			//echo "estoy editando";
			
			$data = sanitize($_POST);
			$resultado =  relacionEditar($data);
			
			if($resultado['registros_insertados'] > 0)
			{
				$status = array('tipo' => 'OK', 'mensaje' => 'Se han ingresado '.$resultado['bd_insertados'].' correctamente');
			}
			else
			{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Contactese con el Administrador ERROR 301');
			}
				$json_data = json_encode($status);
				echo $json_data;
		}
		else if ($_POST['accion'] == 'insertarReporte')
		{
			//echo "estoy insertando reporte";
			
			$data = sanitize($_POST);
			$resultado =  reportesInsertar($data);
            $status = array('tipo' => 'OK', 'mensaje' => 'Se ha ingresado correctamente el formato del Reporte');
			
            
				$json_data = json_encode($status);
				echo $json_data;
            
		}
		else if ($_POST['accion'] == 'editarReporte')
		{
			//echo "estoy editando reporte";
			
			$data = sanitize($_POST);
            $resultado = reportesEditar($data);
		
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha editado correctamente el formato del Reporte');
			$json_data = json_encode($status);
			echo $json_data;
			/*$resultado =  reportesInsertar($data);
            $status = array('tipo' => 'OK', 'mensaje' => 'Se ha ingresado correctamente el formato del Reporte');
			
            
				$json_data = json_encode($status);
				echo $json_data;
            */
		} 
		else if ($_POST['accion'] == 'insertAgrupacionCuentas')
		{
			$data = sanitize($_POST);
			$resultado = insertAgrupacionCuentas($data);
			
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha guardado la agrupacion de cuentas');
			$json_data = json_encode($status);
			echo $json_data;
		} 
		else if ($_POST['accion'] == 'updateAgrupacionCuentas')
		{
			$data = sanitize($_POST);
			$resultado = updateAgrupacionCuentas($data);
			
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha guardado la agrupacion de cuentas');
			$json_data = json_encode($status);
			echo $json_data;
		}
		else if ($_POST['accion'] == 'deleteAgrupacionCuentas')
		{
			$nivel = $_POST['nivel'];
			$resultado = deleteAgrupacionCuentas($nivel);
		}
		/*CUENTAS AGRUPADAS ==> NIVELES*/
		else if ($_POST['accion'] == 'insertNivel')
		{
			$data = sanitize($_POST);
			$resultado = insertNivelEERR($data);
			
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha guardado el Nivel del EERR correctamente');
			$json_data = json_encode($status);
			echo $json_data;
		}
		else if ($_POST['accion'] == 'updateNivel')
		{
			$data = sanitize($_POST);
			$resultado = updateNivelEERR($data);
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha guardado el Nivel del EERR correctamente');
			$json_data = json_encode($status);
			echo $json_data;
		}
		else if ($_POST['accion'] == 'deleteNivel')
		{
			$nivel = $_POST['nivel'];
			$resultado = deleteNivelEERR($nivel);
			
		}
		
		
    
    
	}
?>