<?php
include 'inc/funciones.php';
include 'inc/funciones_rodrigo.php';
?>

<div class="content">
	<h3 class="addForm col-md-12 borde_gris2">Empresas</h3>
	<form id="selEmpresas" name="selEmpresas" method="post" class="col-md-12 mt10" >
		<h3 class="col-md-12 borde_gris2 mb30">&nbsp;</h3>
		<!-- Comienza la sección dinamica -->
		<div class="row col-md-12">
			<div class="col-md-5">
				<label>Seleccion de Empresas</label>
				<select name="origen[]" id="origen" multiple="multiple" size="9" tabindex="3">
					<?php echo empresasUse(); ?>
				</select>
			</div>
			<div class="col-md-2">
				<br />
				<input type="button" class="pasar izq" value=" Pasar » ">  <input type="button" class="quitar der" value=" « Quitar "><br /><br />
				<input type="button" class="pasartodos izq" value=" Todos » ">  <input type="button" class="quitartodos der" value=" « Todos  ">
			</div>
			<div  class="col-md-5">
				<label>Empresas Seleccionadas</label>
					<select name="destino[]" id="destino" multiple="multiple" size="9" tabindex="4">
					<?php echo empresasInUse(); ?>
					</select>
			</div>
		</div>
		<!-- Finaliza la sección dinamica -->
	   	<div class="col-sm-12 ta_r borde_gris2 mt10">
    		<input type="hidden" id="accion"   name="accion"  value="guardarClientes" />
			<!--<input type="hidden" id="seccion"  name="seccion" value="seccion" />--->
			<input type="button" id="enviarEmpresas" class="w130"   value="Enviar Empresas" />
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

/* Formato de traspaso grid */
$().ready(function() 
	{
		$('.pasar').click(function() { return !$('#origen option:selected').remove().appendTo('#destino'); });  
		$('.quitar').click(function() { return !$('#destino option:selected').remove().appendTo('#origen'); });
		$('.pasartodos').click(function() { $('#origen option').each(function() { $(this).remove().appendTo('#destino'); }); });
		$('.quitartodos').click(function() { $('#destino option').each(function() { $(this).remove().appendTo('#origen'); }); });
		$('.submit').click(function() { $('#destino option').prop('selected', 'selected'); });
	}
);


$(document).on('click', '#enviarEmpresas', function()
	{
	showMessage('div#mini-notification', '', 'loading', 'Procesando los datos, Por favor espere...');
	$('#destino option').prop('selected', 'selected');
	var n = $('#destino option').prop('selected', 'selected').length;
	
	var parametros = $('#selEmpresas').serialize();
	if(n == 0)
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar empresas');
		return false;
	}
	
	
	//alert(parametros);
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
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=empresas');}, 1000);	
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