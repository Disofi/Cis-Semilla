<?php
include('inc/funciones.php');

if(!isset($_GET['id']))
	{
	$id = null;
	$accion = 'edit';
	$row = array('CodiCCAD' => '', 'CodiCC' => '', 'Porcen' => '');
	$placeholder = array('contrasena' => '');
	$titulo_form = array('texto' => 'Agregar Distribución', 'css' => 'addForm');
	}
else	
	{
	$id = trim(sanitize($_GET['id']));
	$accion = 'edit';
	$row = ManDistLis($id);
	$titulo_form = array('texto' => 'Editar Distribución', 'css' => 'editForm');
	}
?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Distribución</h2>
		<div class="col-md-2"><a href="index.php?mod=mantenedor-distribucion" class="back icon_text">Volver</a></div>
	</div>
	<h3 class="<?php echo $titulo_form['css'];?> col-md-12 borde_gris2 mb10"><?php echo $titulo_form['texto'];?></h3>
	<form name="form_mantenedor_dist" method="post" class="col-md-12" id="form_mantenedor_dist">
		<div class="row">
			<label class="col-sm-4">Centro de Costo *</label>
			<div class="col-sm-4"><select name="codiccad" id="codiccad" onblur="CargaCentros(this.value)" onmouseover="CargaCentros(this.value)"><?php echo CentrosCostos($id); ?></select></div>
		</div>

		<div id="carga" class="row"></div>

		<div class="row">
			<label class="col-sm-4">Total</label>
			<div class="col-sm-2"><input type="text" name="total" id="total" readonly></div>
		</div>

		<div class="row">
			<div class="col-md-12">
				<input name="id" type="hidden" id="id" value="<?php echo $id;?>" />
				<input name="accion" type="hidden" id="accion" value="edit" />
				<input name="seccion" type="hidden" id="seccion" value="mantenedor_distribucion" />
 				<input type="button" id="enviar" class="float_right margin_top_10" value="Guardar Datos" />
			</div>
		</div>
	</form>
</div>

<script type="text/javascript">
function CargaCentros(id)
	{
	var parametros = 
		{ 
		'id'  : id,
		'accion'  : 'cargar',
		'seccion' : 'mantenedor_distribucion' 
		}
	$.ajax({	
		data : parametros,
		url	 : 'ajax.process.mantenedores.php',
		type : 'post',
		success:  function(response) 
			{
			var json = eval('(' + response + ')');
			if (json.dato)
				{
					$('#carga').html(json.dato);	
				}
			else
				{
					alert ('VACIO');
				}
			}
		});
	}

function Sumax() 
	{
	total = 0;
	$(".porcen").each(function(index, value) 
		{
		total = total + eval($(this).val());
		});
	if (total>100)
		{
		showMessage('div#mini-notification', '#total', 'error', 'Estimado Usuario, La suma total de los porcentajes no puede superar el 100%.');
		}
	$("#total").val(total);
	}

$(document).on('click', 'form#form_mantenedor_dist input#enviar', function()
	{
	var codiccad = $('#codiccad').val();
	var id		 = $('#id').val();
	var accion	 = $('#accion').val();
	var total	 = $('#total').val();

	if($.trim(codiccad) == '') 
		{
		showMessage('div#mini-notification', '#cuenta', 'error', 'Estimado Usuario, Ingrese el Centro de Costo Principal');
		return false;
		}
	if (($.trim(total) == '') || ($.trim(total) > 100))
		{
		showMessage('div#mini-notification', '#total', 'error', 'Estimado Usuario, La suma total de los porcentajes no puede superar el 100%.');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	enviarFormDeshabilitar();

	var parametros = $('#form_mantenedor_dist').serialize();

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