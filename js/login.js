$(document).on('click', 'div#login form #enviar', function()
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
	showMessage('div#mini-notification', '', 'loading', 'Enviando, Espere...');
	var parametros = {
		'wuser' : wuser,
		'wpass' : wpass,
		'accion' : 'login'
		};
	$.ajax({
		data:  parametros,
		url:   'ajax.process.php',
		type:  'post',
		success:  function(response)
			{
			var json = eval('(' + response + ')');
			if(json.tipo == 'ERROR')
				{
				showMessage('div#mini-notification', json.campo, 'error', json.mensaje);
				}
			if(json.tipo == 'LOGIN_OK')
				{
				showMessage('div#mini-notification', '', 'loading', 'Iniciando sesi&oacute;n, Espere...');
				$('div#mini-notification').css('display', 'block');
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=' + json.url);}, 2000);
				}
			}
		});
	return false;
	});