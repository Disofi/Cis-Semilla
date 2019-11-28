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
	$row = ManFormLis($id);
	$placeholder = array('contrasena' => '(Dejar el campo vac&iacute;o si no se desea modificar)');
	$titulo_form = array('texto' => 'Editar usuario existente', 'css' => 'editForm');
	}
?>
<div class="content">

	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Formatos de Estados de Resultados</h2>
		<div class="col-md-2"><a href="index.php?mod=mantenedor-formatos" class="back icon_text">Volver</a></div>
	</div>

	<h3 class="<?php echo $titulo_form['css'];?> col-md-8 borde_gris2 mb10"><?php echo $titulo_form['texto'];?></h3>
	
	<form name="form_mantenedor_formatos" method="post" class="col-md-8" id="form_mantenedor_formatos">
		<div class="row">
			<label class="col-sm-4">Codigo de Nivel *</label>
			<div class="col-sm-3"><input name="codigo" type="text" id="codigo" value="<?php echo $row['CodNivel'];?>" maxlength="10" placeholder="M&aacute;ximo 10 caracteres" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Descripci&oacute;n de Nivel *</label>
			<div class="col-sm-8"><input name="descri" type="text" id="descri" value="<?php echo $row['DesNivel'];?>" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Tipo Nivel *</label>
			<div class="col-sm-8">
				<select name="tiponivel" id="tiponivel">
				<?php
				$tipo = $row['Tipo'];
				if ($tipo=='')
					{
					?>
					<option value="">Seleccione</option>
					<option value=""> -- </option>
					<option value="TI">Titulo</option>
					<option value="CT">Cuentas</option>
					<option value="SP">Subtotal Parcial</option>
					<option value="SF">Subtotal Final</option>
					<?php
					}
				else 
					{
					if ($tipo=='TI') { $destip = 'Titulo'; }
					if ($tipo=='CT') { $destip = 'Cuentas'; }
					if ($tipo=='SP') { $destip = 'Subtotal Parcial'; }
					if ($tipo=='SF') { $destip = 'Subtotal Final'; }
					?>
					<option value="<?php echo $tipo; ?>"><?php echo $destip; ?></option>
					<option value=""> -- </option>
					<option value="TI">Titulo</option>
					<option value="CT">Cuentas</option>
					<option value="SP">Subtotal Parcial</option>
					<option value="SF">Subtotal Final</option>
					<?php						
					}
				?>
				</select>
			</div>
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
$(document).on('click', 'form#form_mantenedor_formatos input#enviar', function()
	{
	var codigo	  = $('#codigo').val();
	var descri	  = $('#descri').val();
	var tiponivel = $('#tiponivel').val();
	var id		  = $('#id').val();
	var accion	  = $('#accion').val();

	if($.trim(codigo) == '') 
		{
		showMessage('div#mini-notification', '#codigo', 'error', 'Estimado usuarios, Ingrese el codigo que desea asignar');
		return false;
		}
	if($.trim(descri) == '') 
		{
		showMessage('div#mini-notification', '#descri', 'error', 'Estimado usuario, Ingrese la descripcion');
		return false;
		}
	if($.trim(tiponivel) == '') 
		{
		showMessage('div#mini-notification', '#tipo', 'error', 'Seleccione tipo de usuario');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	enviarFormDeshabilitar();

	var parametros = 
		{
		'codigo'	: codigo,
		'descri'	: descri,
		'tiponivel' : tiponivel,
		'id'		: id,
		'accion'	: accion,
		'seccion'	: 'mantenedor_formatos'
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
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-formatos');}, 2000);
				}
			}
		});
	return false;
	});
	

</script>