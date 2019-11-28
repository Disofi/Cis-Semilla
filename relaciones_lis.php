<?php
include('inc/funciones_relacion.php');
/*		
echo $_SESSION['emp']['id']."<br>";
echo $_SESSION['emp']['desc']."<br>";
echo $_SESSION['emp']['bd']."<br>";
*/
?>
<script>
function eliminar_registro(id, seccion, url_ajax, url_listado)
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 el elemento seleccionado.\u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var parametros = 
			{
			'id' : id,
			'accion' : 'delete',
			'seccion' : seccion
			};
		$.ajax({
			data:  parametros,
			url:   url_ajax,
			type:  'post',					
			success:  function(response)
				{
				//alert(response);
				//var json = eval('(' + response + ')');
				if(response == 'RELACION_NO_EXISTE')
					{
					showMessage('div#mini-notification', '', 'error', 'Relaci&oacute;n no existe. actualizar navegador');
					}
				else if(response == 'RELACION_ERROR')
					{
					showMessage('div#mini-notification', '', 'error', 'Consulta para eliminar no se ejecuto, intente nuevamente');
					}
				else if(response == '')
				{
					showMessage('div#mini-notification', '', 'error', 'Verifique su conexi&oacute;n');
				}
				else if(response == 'RELACION_ELIMINADA_OK')
					{
					showMessage('div#mini-notification', '', 'ok', 'Relaci&oacute;n eliminada correctamente');
					//$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', url_listado);}, 2000);
					}
				}
			});
		}
	}
function nuevaRelacion()
{
	$(location).attr('href', 'index.php?mod=relacionUsuarioEmpresa')
}
</script>



<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
<div class="content">
	<h3 class="userForm col-sm-12 borde_gris2">Listado de Relaci&oacute;n : Usuario - Empresa</h3>
    <div class="col-sm-12 ta_r padding_bottom_10 linsep">
		<input type="button" name="newuser" id="newuser" value="NUEVA RELACI&Oacute;N" class="w130" onclick="nuevaRelacion();"/>
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="atras();"/>
	</div>
        
	<div class="col-sm-12"><?php echo RelacionesListado(); ?></div>
</div>
</form>
