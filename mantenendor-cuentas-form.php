<?php
include('inc/funciones_agrupacion_cuentas.php');
$grupo = $_REQUEST['nivel'];
//echo $_SESSION['emp']['id']."<----<br>";
if($grupo == '')
{
    $accion = 'insertAgrupacionCuentas';
}
else
{
    $accion = 'updateAgrupacionCuentas';
	$datosTitulo = agrupacionCuentaTitulo($grupo);
    //$datosDescripcion = datosReporteDescripcion($grupo);
	$datosDescripcion = agrupacionCuentaDesc($grupo);
    //$datosIndice = datosReporteIndice($grupo);
    //print_r($datosDescripcion);
}
?>
<form name="mantenedorReporte" method="post" class="col-sm-12" id="mantenedorReporte">
<div class="content">
	<input name="accion" type="hidden" id="accion" value="<?php echo $accion;?>"/>
    <input name="grupo" type="hidden" id="grupo" value="<?php echo $grupo;?>"/>
    <input name="indice_temp" type="hidden" id="indice_temp" value="<?php echo $datosIndice[0];?>"/>
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Agrupaci&oacute;n de Cuentas</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Agrupaci&oacute;n de Cuentas</h3>
	    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="reporte" id="reporte" value="Confirmar" class="w130 submit" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
	</div>
	<div class="row col-md-12">
		<div class="row">
			<label class="col-sm-4">Titulo *</label>
			<div class="col-sm-3"><input name="titulo" type="text" id="titulo" value="<?php echo $datosTitulo[0];?>" maxlength="49" placeholder="M&aacute;ximo 10 caracteres" /></div>
		</div>
		<!--
		<div class="row">
			<label class="col-sm-4">Descripción del Total *</label>
			<div class="col-sm-3"><input name="descripcion" type="text" id="descripcion" value="<?php echo $datosDescripcion[0];?>" maxlength="20" placeholder="M&aacute;ximo 20 caracteres" /></div>
		</div>
		-->
		<div class="col-md-5">
			<label>Seleccion de Cuentas</label>
			<select name="origen[]" id="origen" multiple="multiple" size="15" tabindex="3">
				<?php echo cuentasUseCis($grupo); ?>
			</select>
		</div>
		<div class="col-md-2">
			<br />
			<input type="button" class="pasar izq" value=" Pasar &#187; ">  <input type="button" class="quitar der" value=" &#171; Quitar "><br /><br />
			<input type="button" class="pasartodos izq" value=" Todos &#187; ">  <input type="button" class="quitartodos der" value=" &#171; Todos  ">
		</div>
		<div  class="col-md-5">
			<label>Cuentas Seleccionadas</label>
				<select name="destino[]" id="destino" multiple="multiple" size="15" tabindex="4">
				<?php echo cuentasInUseCis($grupo); ?>
				</select>
		</div>
	</div>
</div>	
</form>
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


$(document).on('click', '#reporte', function()
{
	showMessage('div#mini-notification', '', 'loading', 'Procesando los datos, Por favor espere...');
	$('#destino option').prop('selected', 'selected');
	var n = $('#destino option').prop('selected', 'selected').length;
	var titulo = $('#titulo').val();
    var descripcion = $('#descripcion').val();
	
    
	if(n == 0)
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar al menos una cuenta');
		return false;
	}
    if(titulo == '')
	{
		showMessage('div#mini-notification', '#titulo', 'error', 'Debe ingresar Titulo');
		return false;
	}
    /*
	if(descripcion == '')
	{
		showMessage('div#mini-notification', '#descripcion', 'error', 'Debe ingresar Descripcion');
		return false;
	}
	*/
	var parametros = $('#mantenedorReporte').serialize();
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
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-cuentas');}, 1000);	
				}
			else
				{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					//enviarFormHabilitar();
				}
			
			}
		});
    	
	return false;
}); 	

</script>