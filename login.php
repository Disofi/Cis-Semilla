<?php
require ('head.php');
?>
<div id="login">
	<form name="form" class="form-signin" id="form" method="post">
		<h2 class="form-signin-heading"><img src="imgs/logo.png" /></h2>
		<input type="text"     id="wuser" class="form-control" placeholder="Usuario" required autofocus>
		<input type="password" id="wpass" class="form-control" placeholder="Contrase&ntilde;a" required>
		<button name="enviar" type="submit" class="btn btn-lg btn-primary btn-block" id="enviar" value="login">Ingresar</button>
        <center><h5>Versi&oacute;n 1.0</h5></center>
	</form>
</div>
</body>
<script type="text/javascript">
$(document).on('click', '#enviar', function()
	{
	var wuser = $('#wuser').val();
	var wpass = $('#wpass').val();
	if($.trim(wuser) == '')
		{
		showMessage('div#mini-notification', '#wuser', 'error', 'Ingrese nombre de usuario');
		return false;
		}
	if($.trim(wpass) == '')
		{
		showMessage('div#mini-notification', '#wpass', 'error', 'Ingrese su contrase&ntilde;a');
		return false;
		}
	showMessage('div#mini-notification', '', 'loading', 'Enviando Espere...');
	var parametros = {
		'wuser'   : wuser,
		'wpass'   : wpass,
		'accion'  : 'login',
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
			if (json.tipo == 'LOGIN_OK')	
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
