<?php
session_start();
include('inc/conexion.php');
include('inc/funciones.php');

/* **************************************************** */
/*					MANTENEDOR USUARIOS					*/
/* **************************************************** */

if($_POST['seccion'] == 'mantenedor_usuarios')
	{
	$data = sanitize($_POST);
	$accion = $data['accion'];
	// Agregar registro
	if($accion == 'add')
		{
		$insertar = ManUserInsert($data);
		if ($insertar == 'ERROR_EXISTE_USUARIO') { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este nombre de usuario no se encuentra disponible', 'campo' => '#usuario'); }
		if ($insertar == 'ERROR_EXISTE_CORREO')  { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este correo electr&oacute;nico no se encuentra disponible', 'campo' => '#correo'); }
		if ($insertar == 'OK')                   { $status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha agregado correctamente un nuevo elemento'); }
		else { $status = array('tipo' => 'ERROR', 'mensaje' => 'Los datos no han podido ser cargados a la base, favor verificar datos', 'campo' => '#usuario'); }
		}
	if($accion == 'edit' || $accion == 'delete')
		{
		$id = sanitize($_POST['id']);
		// Editar registro
		if($accion == 'edit')
			{
			$editar = ManUserEdit($data, $id);
			if($editar == 'ERROR_EXISTE_USUARIO') { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este nombre de usuario no se encuentra disponible', 'campo' => '#usuario'); }
			if($editar == 'ERROR_EXISTE_CORREO')  { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este correo electr&oacute;nico no se encuentra disponible', 'campo' => '#correo'); }
			if($editar == 'OK') { $status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha editado correctamente el usuario seleccionado'); }
			}
		// Eliminar registro
		if($accion == 'delete')
			{
			ManUserDel($id);
			$status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha eliminado correctamente el usuario seleccionado');
			header('Location: index.php?mod=mantenedor-usuarios');
			}
		}
	$json_data = json_encode($status);  
	echo $json_data;
	}

/* **************************************************** */
/*					MANTENEDOR FORMATOS					*/
/* **************************************************** */

if($_POST['seccion'] == 'mantenedor_formatos')
	{
	$data = sanitize($_POST);
	$accion = $data['accion'];
	// Agregar registro
	if($accion == 'add')
		{
		$insertar = ManFormInsert($data);
		if ($insertar == 'ERROR_EXISTE_USUARIO') { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este nombre de usuario no se encuentra disponible', 'campo' => '#usuario'); }
		if ($insertar == 'ERROR_EXISTE_CORREO')  { $status = array('tipo' => 'ERROR', 'mensaje' => 'Este correo electr&oacute;nico no se encuentra disponible', 'campo' => '#correo'); }
		if ($insertar == 'OK')                   { $status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha agregado correctamente un nuevo elemento'); }
		else { $status = array('tipo' => 'ERROR', 'mensaje' => 'Los datos no han podido ser cargados a la base, favor verificar datos', 'campo' => '#usuario'); }
		}
	if($accion == 'edit' || $accion == 'delete')
		{
		$id = sanitize($_POST['id']);
		// Editar registro
		if($accion == 'edit')
			{
			$editar = ManFormEdit($data, $id);
			if($editar == 'OK') 
				{
				$status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha editado correctamente el usuario seleccionado');
				}
			else 
				{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Error al modificar los datos, Favor intentar nuevamente');
				}
			}
		// Eliminar registro
		if($accion == 'delete')
			{
			ManFormDel($id);
			$status = array('tipo' => 'OK', 'mensaje' => 'Se ha eliminado correctamente el nivel seleccionado', 'url' => 'mantenedor-formatos');
			}
		}
	$json_data = json_encode($status);  
	echo $json_data;
	}


/* **************************************************** */
/*					MANTENEDOR UBICACION				*/
/* **************************************************** */

if($_POST['seccion'] == 'mantenedor_ubicacion')
	{
	$data = sanitize($_POST);
	$accion = $data['accion'];
	// Agregar registro
	if($accion == 'add')
		{
		$insertar = ManUbiInsert($data);
		if ($insertar == 'OK')                   { $status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha agregado correctamente un nuevo elemento'); }
		else { $status = array('tipo' => 'ERROR', 'mensaje' => 'Los datos no han podido ser cargados a la base, favor verificar datos', 'campo' => '#usuario'); }
		}
	if($accion == 'edit' || $accion == 'delete')
		{
		$id = sanitize($_POST['id']);
		// Editar registro
		if($accion == 'edit')
			{
			$editar = ManUbiEdit($data, $id);
			if($editar == 'OK') 
				{
				$status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha editado correctamente el detalle seleccionado');
				}
			else 
				{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Error al modificar los datos, Favor intentar nuevamente');
				}
			}
		// Eliminar registro
		if($accion == 'delete')
			{
			ManUbiDel($id);
			$status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha eliminado correctamente el nivel seleccionado');
			header('Location: index.php?mod=mantenedor-formatos');
			}
		}

	$json_data = json_encode($status);
	echo $json_data;
	}
	
/* **************************************************** */
/*					MANTENEDOR UBICACION				*/
/* **************************************************** */

if($_POST['seccion'] == 'mantenedor_distribucion')
	{
	$data = sanitize($_POST);
	$accion = $data['accion'];
	$id = $data['id'];
	if($accion == 'edit' || $accion == 'delete')
		{
		// Editar registro
		if($accion == 'edit')
			{
			$editar = ManDistEdit($data);
			if($editar == 'OK') 
				{
				$status = array('tipo' => 'ACCION_OK', 'mensaje' => 'Se ha editado correctamente la distribuci&oacute;n seleccionada');
				}
			else 
				{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'Error al modificar los datos, Favor intentar nuevamente');
				}
			}
		// Eliminar registro
		if($accion == 'delete')
			{
			$delete = ManDistDel($id);
			if ($delete == 'OK')
				{
				$status = array('tipo' => 'OK', 'mensaje' => 'Se ha eliminado correctamente la Distribución');
				}
			else
				{
				$status = array('tipo' => 'ERROR', 'mensaje' => 'NO SE HA COMPLETADO LA OPERACION');
				}
			}
		}
	if ($accion == 'cargar')
		{
		$id = sanitize($_POST['id']);
		$dato = PorCenCos($id);
		$status = array('dato' => $dato);
		}	
	$json_data = json_encode($status);  
	echo $json_data;
	}


?>