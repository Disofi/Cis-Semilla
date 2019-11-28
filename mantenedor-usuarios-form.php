<?php
include('inc/funciones.php');

if(!isset($_GET['id']))
	{
	$id = null;
	$accion = 'add';
	$row = array('Usuario' => '', 'Nombres' => '', 'Correo' => '', 'Tipo' => '');
	$placeholder = array('contrasena' => '');
	$titulo_form = array('texto' => 'Agregar nuevo usuario', 'css' => 'addForm');
	}
else	
	{
	$id = trim(sanitize($_GET['id']));
	$accion = 'edit';
	$row = ManUserLis($id);
	$placeholder = array('contrasena' => '(Dejar el campo vac&iacute;o si no se desea modificar)');
	$titulo_form = array('texto' => 'Editar usuario existente', 'css' => 'editForm');
	}
?>
<div class="content">

	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Usuarios</h2>
		<div class="col-md-2"><a href="index.php?mod=mantenedor-usuarios" class="back icon_text">Volver</a></div>
	</div>

	<h3 class="<?php echo $titulo_form['css'];?> col-md-8 borde_gris2 mb10"><?php echo $titulo_form['texto'];?></h3>
	
	<form name="form_mantenedor_usuarios" method="post" class="col-md-8" id="form_mantenedor_usuarios">
		<div class="row">
			<label class="col-sm-4">Usuario *</label>
			<div class="col-sm-3"><input name="usuario" type="text" id="usuario" value="<?php echo $row['Usuario'];?>" maxlength="10" placeholder="M&aacute;ximo 10 caracteres" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Nombres *</label>
			<div class="col-sm-8"><input name="nombres" type="text" id="nombres" value="<?php echo $row['Nombres'];?>" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Contrase&ntilde;a *</label>
			<div class="col-sm-3"><input name="contrasena" type="password" id="contrasena" /></div>
			<div class="col-sm-5" style="font-size:9pt; padding-left:10px !important;"><?php echo $placeholder['contrasena'];?></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Correo *</label>
			<div class="col-sm-8"><input name="correo" type="text" id="correo" value="<?php echo $row['Correo'];?>" placeholder="ejemplo@ejemplo.cl" /></div>
		</div>	
		<div class="row">
			<label class="col-sm-4">Tipo usuario *</label>
			<div class="col-sm-8"><?php echo ManUserTip($row['Tipo']); ?></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Nombre Mandante *</label>
			<div class="col-sm-8"><?php echo ManUserEmp();?></div>
		</div>
		<div class="row">
			<div class="col-sm-12">
				<input name="id" type="hidden" id="id" value="<?php echo $id;?>" />
				<input name="accion" type="hidden" id="accion" value="<?php echo $accion;?>" />
				<input type="button" id="enviar" class="float_right margin_top_10" value="Guardar Datos" />
			</div>
		</div>
	</form>
</div>

<script type="text/javascript">
$(document).on('click', 'form#form_mantenedor_usuarios input#enviar', function()
	{
	var nombres		= $('#nombres').val();
	var usuario		= $('#usuario').val();
	var contrasena	= $('#contrasena').val();
	var correo		= $('#correo').val();
	var tipo		= $('#tipo').val();
	var mandante	= $('#mandante').val();;
	var id			= $('#id').val();
	var accion		= $('#accion').val();

	if($.trim(nombres) == '') 
		{
		showMessage('div#mini-notification', '#nombres', 'error', 'Ingrese nombre completo del usuario');
		return false;
		}
	if($.trim(usuario) == '') 
		{
		showMessage('div#mini-notification', '#usuario', 'error', 'Ingrese nombre de usuario del sistema');
		return false;
		}
	if(accion == 'add') 
		{
		if($.trim(contrasena) == '') 
			{
			showMessage('div#mini-notification', '#contrasena', 'error', 'Ingrese contrase&ntilde;a del usuario');
			return false;
			}
		}
	if($.trim(correo) == '') 
		{
		showMessage('div#mini-notification', '#correo', 'error', 'Ingrese correo electr&oacute;nico del usuario');
		return false;
		}
	if($.trim(correo) != '') 
		{
		if (!correo.match(/^[a-zA-Z0-9\._-]+@[a-zA-Z0-9-]{2,}[.][a-zA-Z]{2,4}$/)) 
			{
			showMessage('div#mini-notification', '#correo', 'error', 'El correo electr&oacute;nico no es v&aacute;lido');
			return false;
			}	
		}
	if($.trim(tipo) == '') 
		{
		showMessage('div#mini-notification', '#tipo', 'error', 'Seleccione tipo de usuario');
		return false;
		}
	if($.trim(mandante) == '') 
		{
		showMessage('div#mini-notification', '#mandante', 'error', 'Seleccione el nombre del mandante');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	enviarFormDeshabilitar();

	var parametros = 
		{
		'nombres'	 : nombres,
		'usuario'	 : usuario,
		'contrasena' : contrasena,
		'correo'	 : correo,
		'tipo'		 : tipo,
		'mandante'	 : mandante,
		'id'		 : id,
		'accion'	 : accion,
		'seccion'	 : 'mantenedor_usuarios'
		};
	$.ajax({
		data:  parametros,
		url:   'ajax.process.mantenedores.php',
		type:  'post',					
		success:  function(response) 
			{
			var json = eval('(' + response + ')');
			if (json.tipo == 'ERROR') 
				{
				showMessage('div#mini-notification', json.campo, 'error', json.mensaje);
				enviarFormHabilitar();
				}
			if (json.tipo == 'ACCION_OK')
				{
				showMessage('div#mini-notification', '', 'ok', json.mensaje);
				$('div#mini-notification').css('display', 'block');
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-usuarios');}, 2000);
				}
			}
		});
	return false;
	});
</script>