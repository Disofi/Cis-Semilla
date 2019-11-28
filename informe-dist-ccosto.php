<?php
if ($_SESSION['emp']['id']=='')
	{ 
	print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
include('inc/funciones.php');
?>
<form name="estres" method="post" class="col-sm-12" id="estres" action="index.php?mod=informe-dist-ccosto-ver">
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Informes &gt; Estado de Resultado</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	<h3 class="productsForm col-sm-12 borde_gris2 mb10">Seleccione Periodo a Consultar</h3>
	<div class="row col-sm-12">
		<label class="col-sm-4">* Temporada:</label>
		<div class="col-sm-4"><select name="temporada" id="temporada" tabindex="1" /><?php echo SelTemporada(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	
	<div class="row col-sm-12">
		<div class="col-sm-12">
			<div class="col-sm-5">
				<label>C.Costos Disponibles</label>
				<select name="origen[]" id="origen" multiple="multiple" size="8">
					<?php echo SelCenCos(''); ?>
				</select>
			</div>
			<div class="col-sm-2">
				<br /><br />
				<input type="button" class="pasar izq" value="Pasar &raquo;"><input type="button" class="quitar der" value="&laquo; Quitar">
			</div>
			<div class="col-sm-5">
				<label>C.Costos Seleccionados</label>
				<select name="destino[]" id="destino" multiple="multiple" size="8"></select>
			</div>
		</div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	
	<div class="row col-sm-12">
		<div class="col-sm-8"><input type="submit" id="enviar" class="w130 float_right" value="Seleccionar" onclick="return valestres();" tabindex="5" /></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
</div>
</form>
<script type="text/javascript">
$().ready(function() 
	{
	$('.pasar').click(function() { return !$('#origen option:selected').remove().appendTo('#destino'); });  
	$('.quitar').click(function() { return !$('#destino option:selected').remove().appendTo('#origen'); });
	$('.pasartodos').click(function() { $('#origen option').each(function() { $(this).remove().appendTo('#destino'); }); });
	$('.quitartodos').click(function() { $('#destino option').each(function() { $(this).remove().appendTo('#origen'); }); });
	$('.submit').click(function() { $('#destino option').prop('selected', 'selected'); });
	}); 

function valestres()
	{
	var mesini = $.trim($('#mesini').val());
	var mesfin = $.trim($('#mesfin').val());
	var ano    = $.trim($('#ano').val());
	var presup = $.trim($('#presup').val());

	if ($.trim(mesini) == '00')
		{
		showMessage('div#mini-notification', '#mesini', 'error', 'Estimado Usuario, Debe seleccionar un Mes de Inicio, gracias.');
		return false;
		}
	else if ($.trim(mesfin) == '00')
		{
		showMessage('div#mini-notification', '#mesfin', 'error', 'Estimado Usuario, Debe seleccionar un Mes de Término, gracias.');
		return false;
		}
	else if ($.trim(ano) == '00')
		{
		showMessage('div#mini-notification', '#ano', 'error', 'Estimado Usuarios, Debe seleccionar el Año de la consulta, gracias.');
		return false;
		}
	else
		{
		return true;
		}
	}
</script>