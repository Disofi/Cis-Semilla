	<?php
include('inc/funciones.php');

if(!isset($_GET['id']))
	{
	$id = null;
	$accion = 'add';
	$row = array('Usuario' => '', 'Nombres' => '', 'Correo' => '', 'Tipo' => '');
	$placeholder = array('contrasena' => '');
	$titulo_form = array('texto' => 'Agregar Ubicación', 'css' => 'addForm');
	}
else	
	{
	$id = trim(sanitize($_GET['id']));
	$accion = 'edit';
	$row = ManDistLis($id);
	$titulo_form = array('texto' => 'Editar Ubicación', 'css' => 'editForm');
	}
?>
<div class="content">

	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Ubicación</h2>
		<div class="col-md-2"><a href="index.php?mod=mantenedor-usuarios" class="back icon_text">Volver</a></div>
	</div>

	<h3 class="<?php echo $titulo_form['css'];?> col-md-8 borde_gris2 mb10"><?php echo $titulo_form['texto'];?></h3>
	
	<form name="form_mantenedor_ubi" method="post" class="col-md-8" id="form_mantenedor_ubi">
		<!--
		<div class="row">
			<label class="col-sm-4">Centro de Costo *</label>
			<div class="col-sm-3"><input name="centro" type="text" id="centro" value="<?php echo $row['CodCC'];?>" maxlength="10" placeholder="M&aacute;ximo 10 caracteres" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Ubicación *</label>
			<div class="col-sm-8"><input name="mandet" type="text" id="mandet" value="<?php echo $row['Ubicacion'];?>" /></div>
		</div>
		-->
		<?php LisCenCos(); ?>
		
		<div class="row">
			<div class="col-sm-12">
				<input name="id" type="hidden" id="id" value="<?php echo $id;?>" />
				<input name="accion" type="hidden" id="accion" value="<?php echo $accion;?>" />
				<input type="hidden" name="seccion" id="seccion" value="mantenedor_ubicacion" />
				<input type="button" id="enviar" class="float_right margin_top_10" value="Guardar Datos" />
			</div>
		</div>
	</form>
</div>

<script type="text/javascript">
$(document).on('click', 'form#form_mantenedor_ubi input#enviar', function()
	{
	//var centro    = $('#centro').val();
	//var ubicacion = $('#ubicacion').val();
	var id	   = $('#id').val();
	var accion = $('#accion').val();

	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	enviarFormDeshabilitar();

	var parametros = $('form#form_mantenedor_ubi').serialize();

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
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-ubicacion');}, 2000);
				}
			}
		});
	return false;
	});
</script>