<?php
include 'inc/funciones_relacion.php';
$id = $_REQUEST['id'];

if($id == '')
{
	$accion = 'guardarRelacion';
}
else
{
	$accion = 'editarRelacion';
}

?>
<div class="content">
	<h3 class="addForm col-md-12 borde_gris2">Relaci&oacute;n : Usuario - Empresa</h3>
	<form id="relacionUsuarios" name="relacionUsuarios" method="post" class="col-md-12 mt10" >
		<h3 class="col-md-12 borde_gris2 mb30">&nbsp;</h3>
		<!-- Comienza la sección dinamica -->
		<div class="row col-md-12">
			<div class="col-md-5" id="usuarios">
				<label>Seleccion de Usuario</label>
				<br>
				<!-- <select name="origen[]" id="origen" multiple="multiple" size="9" tabindex="3"> -->
					<?php echo relacionUsuarios($id); ?>
				<!---</select> --->
			</div>
			<div  class="col-md-5" id="empresas">
				<label>Empresas Seleccionadas</label><br>
					<!--<select name="destino[]" id="destino" multiple="multiple" size="9" tabindex="4">
					</select>--->
					<div class="divEmpresas">
				<?php echo relacionEmpresas($id); ?>	
					</div>
					
			</div>
		</div>
		<!-- Finaliza la sección dinamica -->
	   	<div class="col-sm-12 ta_r borde_gris2 mt10">
    		<input type="hidden" id="accion"  name="accion"  value="<?php echo $accion; ?>" />
			<!--<input type="hidden" id="seccion"  name="seccion" value="seccion" />--->
			<input type="button" id="enviarRelacion" class="w130"   value="Enviar Datos" />
			<input type="button" id="volver"   name="volver"  value="Salir" class="w130 mb10" onClick="atras();"/>
		</div>
    </form>
</div>
<style>
	select { width:180px; margin:0 0 50px 0; border:1px solid #ccc; }
	.clear { clear:both; text-align:center; }
	.izq   { border-radius:10px 0 0 10px; }
	.der   { border-radius:0 10px 10px 0; }
</style>
<script type="text/javascript">

function selectUsuario(id)
{
	//alert('alerta');
	//var n = $('#usuarios option').prop('selected', 'selected').length;
	var n = $('#usuarios input:checkbox:checked').length;
	var id_usuario = $('#usuarios input:checkbox:checked').val();
	//alert(id_usuario);
	//alert(n);
	if(n > 1)
	{
		$('.usuario_'+id).prop('checked', false);
		showMessage('div#mini-notification', '', 'error', 'Solo puede seleccionar un usuario');
		return false;
	}
}

$(document).on('click', '#enviarRelacion', function()
	{
	var parametros = $('#relacionUsuarios').serialize();
	var m = $('#empresas input:checkbox:checked').length;
	var n = $('#usuarios input:checkbox:checked').length;
	//alert(m);
	if(n == 0 || n == '0')
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar un usuario');
		return false;		
	}	
	if(m == 0 || m == '0')
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar al menos una empresa para este usuario');
		return false;
	}

	$.ajax({
		data:parametros,
		url:'ajax.process.php',
		type:'post',					
		success:  function(response)
			{
			//alert(response);
			var json = eval('(' + response + ')');
			if (json.tipo == 'OK')
				{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=relaciones_lis');}, 4000);	
				}
			else
				{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					enviarFormHabilitar();
				}
			
			}
		});
		
	return false;
	}); 	

</script>