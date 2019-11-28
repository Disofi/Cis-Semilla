<?php
include('inc/funciones.php');
?>
<form name="compras_sel" method="post" class="col-sm-12" id="compras_sel">
<div class="content">
	<h3 class="addForm col-sm-12 borde_gris2">Facturas de Compra</h3>
	<div class="row col-sm-12">
		<label class="col-sm-1 text_align_right">Mes</label>
		<div class="col-sm-3 text_align_right"><?php echo SelMes(); ?></div>
		<label class="col-sm-1 text_align_right">A&ntilde;o</label>
		<div class="col-sm-3 text_align_right"><?php echo SelAno(); ?></div>
		<div class="col-sm-4 text_align_right"><input type="button" id="enviar" class="w130 float_right" value="Seleccionar" /></div>
	</div>

	<div class="linsep">&nbsp;</div>

	<div class="row col-sm-12">
    	<input type="button" id="VerConta" name="VerConta" class="w130" value="Ver Contabilización" />
		<input type="button" id="Agregar"  name="Agregar" class="w130" value="Agregar" />
	</div>

	<div class="linsep">&nbsp;</div>

	<div class="col-sm-12"><?php echo DocumentosListar('C'); ?></div>
</div>
</form>

<script type="text/javascript">
var mes = "<?php echo $_SESSION['mes']; ?>";
var ano = "<?php echo $_SESSION['ano']; ?>";

if (($.trim(mes) == '') || ($.trim(ano) == ''))
	{ 
	document.getElementById('VerConta').disabled = true; 
	document.getElementById('Agregar').disabled  = true; 
	}
else 
	{
	document.getElementById('VerConta').disabled = false; 
	document.getElementById('Agregar').disabled  = false; 
	}

/* Accion para el boton agregar (agrega nuevo documento de compra)  */
$(document).on('click', '#Agregar', function()
	{
	var mes = "<?php echo $_SESSION['mes']; ?>";
	var ano = "<?php echo $_SESSION['ano']; ?>";

	if (($.trim(mes) == '') || ($.trim(ano) == ''))
		{ 
		showMessage('div#mini-notification', '#mes', 'error', 'Debe seleccionar mes y año para poder continuar...'); 
		}
	else
		{		
		showMessage('div#mini-notification', '', 'loading', 'Ingresando Carga de Documentos...');
		enviarFormDeshabilitar();
		var parametros = 
			{
			'accion'  : 'agregar_docto',
			'seccion' : 'seccion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'LOGIN_OK')	
					{ 
					showMessage('div#mini-notification', '', 'ok', 'Datos Validos...'); 
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=' + json.url);}, 1000);
					}
				else if (json.tipo == 'ERROR') 	
					{
					showMessage('div#mini-notification', json.campo, 'error', json.mensaje);
					}
				else 
					{
					showMessage('div#mini-notification', json.campo, 'error', 'Proceso no completado / Contactar Administrador');
					}
				}
			});
		return false;
		}
	});

/* ACCION QUE ASIGNA EL MES Y AÑO EL CUAL SE VAN A INGRESAR DOCUEMENTOS */
$(document).on('click', '#enviar', function()
	{
	var mes = $('#mes').val();
	var ano = $('#ano').val();
	if($.trim(mes) == '')
		{
		showMessage('div#mini-notification', '#mes', 'error', 'No se ha indicado una direcci&oacute;n de despacho');
		ir_elemento('header');
		return false;
		}
	if ($.trim(ano) == '')
		{
		showMessage('div#mini-notification', '#ano', 'error', 'El usuario no tiene un mandante asociado, favor verificar en usuarios.');
		ir_elemento('header');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Verificando Datos...');
	enviarFormDeshabilitar();
	var parametros = 
		{
		'mes'     : mes,
		'ano'     : ano,
		'accion'  : 'periodo',
		'seccion' : 'seccion'
		};
	$.ajax({
		data:  parametros,
		url:   'ajax.process.php',
		type:  'post',
		success:  function(response)
			{
			var json = eval('(' + response + ')');
			if (json.tipo == 'LOGIN_OK')	
				{ 
				showMessage('div#mini-notification', '', 'ok', 'Datos Validos...'); 
				$('div#mini-notification').css('display', 'block');
				EnviarHabilita();
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=' + json.url);}, 1000);
				}
			else if (json.tipo == 'ERROR') 	
				{
				showMessage('div#mini-notification', json.campo, 'error', json.mensaje);
				}
			else 
				{
				showMessage('div#mini-notification', json.campo, 'error', 'Proceso no completado / Contactar Administrador');
				}
			}
		});
	return true;
	});
/* BOTON PARA VER CONTABILIZACION Y EXPORTAR A EXCEL-TXT-CSV */
$(document).on('click', '#VerConta', function()
	{
	var mes = "<?php echo $_SESSION['mes']; ?>";
	var ano = "<?php echo $_SESSION['ano']; ?>";

	if (($.trim(mes) == '') || ($.trim(ano) == ''))
		{ 
		showMessage('div#mini-notification', '#mes', 'error', 'Debe seleccionar mes y año para poder continuar...'); 
		}
	else
		{
		showMessage('div#mini-notification', '', 'loading', 'Cargando visualización de documentos...');
		enviarFormDeshabilitar();
		var parametros = 
			{
			'accion'  : 'ver_conta',
			'seccion' : 'seccion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',
			success:  function(response) { setTimeout(function(){ $(location).attr('href', 'index.php?mod=compras_app');}, 1000); }
			});
		return false;
		}
	});
</script>