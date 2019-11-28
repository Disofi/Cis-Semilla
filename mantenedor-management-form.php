<?php
include('inc/funciones.php');
if(!isset($_GET['id']))
	{
	$id = null;
	$accion = 'add';
	$row = array('M1'=>'','M2'=>'','M3'=>'','M4'=>'','M5'=>'','M6'=>'','M7'=>'','M8'=>'','M9'=>'','M10'=>'','M11'=>'','M12'=>'','ANO'=>'');
	$titulo_form = array('texto' => 'Agregar Management', 'css' => 'addForm');
	}
else	
	{
	$id = trim(sanitize($_GET['id']));
	$accion = 'edit';
	$row = ManDistLis($id);
	$titulo_form = array('texto' => 'Editar Management', 'css' => 'editForm');
	}
?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Manamegent Fee</h2>
		<div class="col-md-2"><a href="index.php?mod=mantenedor-distribucion" class="back icon_text">Volver</a></div>
	</div>

	<h3 class="<?php echo $titulo_form['css'];?> col-md-8 borde_gris2 mb10"><?php echo $titulo_form['texto'];?></h3>
	
	<form name="form_mantenedor_dist" method="post" class="col-md-8" id="form_mantenedor_dist">
		<div class="row">
			<label class="col-sm-4">Centro de Costo *</label>
			<div class="col-sm-4"><?php echo SelCenCos($id); ?></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Maneja Detalle *</label>
			<div class="col-sm-4">
				<select name="mandet" id="mandet">
					<?php 
					if ($mandet=='') { ?>
						<option value="">Seleccionar</option>
						<option value=""> -- </option>
						<?php
						}
					else {
						if ($mandet=='1') { $mandetdes='SI'; }
						if ($mandet=='2') { $mandetdes='NO'; }
						echo '<option value="'.$mandet.'">'.$mandetdes.'</option><option value=""> -- </option>';
						}
					?>
					<option value="1">SI</option>
					<option value="2">NO</option>
				</select></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Maneja IVA *</label>
			<div class="col-sm-4">
				<select name="maniva" id="maniva">
					<?php 
					if ($maniva=='') { ?>
						<option value="">Seleccionar</option>
						<option value=""> -- </option>
						<?php
						}
					else {
						if ($maniva=='1') { $manivades='SI'; }
						if ($maniva=='2') { $manivades='NO'; }
						echo '<option value="'.$maniva.'">'.$manivades.'</option><option value=""> -- </option>';
						}
					?>
					<option value="1">SI</option>
					<option value="2">NO</option>					
				</select></div>
		</div>	
		<div class="row">
			<label class="col-sm-4">Posici&oacute;n *</label>
			<div class="col-sm-1"><input name="posicion" type="text" id="posicion" value="<?php echo $row['posicion'];?>" maxlength="2" /></div>
		</div>
		<div class="row">
			<label class="col-sm-4">Gasto Administraci&oacute;n *</label>
			<div class="col-sm-1"><?php echo $gasad; ?></div>
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
$(document).on('click', 'form#form_mantenedor_dist input#enviar', function()
	{
	var cuenta	 = $('#cuenta').val();
	var mandet	 = $('#mandet').val();
	var maniva	 = $('#maniva').val();
	var posicion = $('#posicion').val();
	if (document.getElementById('gasad').checked) { var gasad = '1'; } else { var gasad = '0'; }
	var id		 = $('#id').val();
	var accion	 = $('#accion').val();

	if($.trim(cuenta) == '') 
		{
		showMessage('div#mini-notification', '#cuenta', 'error', 'Estimado Usuario, Ingrese la cuenta contable');
		return false;
		}
	if($.trim(mandet) == '') 
		{
		showMessage('div#mini-notification', '#mandet', 'error', 'Estimado Usuario, Seleccione si maneja o no detalle');
		return false;
		}
	if($.trim(maniva) == '') 
		{
		showMessage('div#mini-notification', '#maniva', 'error', 'Estimado Usuario, Seleccione si maneja Iva');
		return false;
		}
	if($.trim(posicion) == '') 
		{
		showMessage('div#mini-notification', '#posicion', 'error', 'Estimado Usuario, Indique una ubicacion dentro del Estado de Resultado.');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	enviarFormDeshabilitar();

	var parametros = 
		{
		'cuenta'   : cuenta,
		'mandet'   : mandet,
		'maniva'   : maniva,
		'posicion' : posicion,
		'gasad'	   : gasad,
		'id'	   : id,
		'accion'   : accion,
		'seccion'  : 'mantenedor_distribucion'
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
				showMessage('div#mini-notification', json.campo, 'ok', json.mensaje);
				$('div#mini-notification').css('display', 'block');
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-distribucion');}, 2000);
				}
			}
		});
	return false;
	});
</script>