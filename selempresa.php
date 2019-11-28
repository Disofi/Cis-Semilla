<?php
require ('head.php');
include ('inc/funciones.php');
?>
<div class="content">
	<h3 class="addForm col-md-12 borde_gris2">Selección de Empresa</h3>
    <div class="row col-sm-12">&nbsp;</div>
	<form name="form" class="form-empresa" id="form" method="post">
	<div class="row col-sm-12">
		<label class="col-sm-4">Seleccione:</label>
		<div class="col-sm-4"><select name="empresa" id="empresa"><?php SelEmpresa(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
    <div class="row col-sm-12">&nbsp;</div>
	<div class="row col-sm-12">
		<div class="col-sm-4">&nbsp;</div>
		<div class="col-sm-4"><button name="enviar" id="enviar" type="submit" class="btn btn-lg btn-primary btn-block" value="login">Ingresar</button></div>
        <div class="col-sm-4">&nbsp;</div>
	</div>
	</form>
</div>
</body>
<script type="text/javascript">
$(document).on('click', '#enviar', function()
	{
	var empresa = $('#empresa').val();
	if($.trim(empresa) == '00')
		{
		showMessage('div#mini-notification', '#empresa', 'error', 'Debe seleccionar una empresa');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Enviando Espere...');
	var parametros = {
		'empresa' : empresa,
		'accion'  : 'empresa',
		'seccion' : 'seccion'
		};
	$.ajax(
		{
		data:  parametros,
		url:   'ajax.process.php',
		type:  'post',
		success:  function(response)
			{
			var json = eval('(' + response + ')');
			if (json.tipo == 'OK')	
				{ 
				showMessage('div#mini-notification', '', 'ok', 'Iniciando sesi&oacute;n, Espere... '); 
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
	});
</script>
