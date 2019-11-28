<?php
if ($_SESSION['emp']['id']=='')
	{ 
		print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
//echo $_SESSION['emp']['id']."<br>";
//echo $_SESSION['emp']['bd']."<br>";
include('inc/funciones.php');

$ano = $_REQUEST['ano'];
$pre = $_REQUEST['pre'];
$mes = $_REQUEST['mes'];

//echo $ano." // ".$pre." // ".$mes."<br><br>";

?>
<form name="estres" method="post" class="col-sm-12" id="estres" action="index.php?mod=FORECAST-ver">
<div class="content">

	<div class="titulo_pagina">
		<br>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Forecast</h3>
	
	
	<div class="row col-md-12">
		<div class="row">
		<br>
			<label class="col-sm-4"> Mes: *</label>
			<div class="col-sm-3">
			<select name="mesini" id="mesini"/>
				<?php echo SelMes($mes); ?>
			</select>
			</div>
		</div>
		
		<div class="row">
			<label class="col-sm-4">A&ntilde;o *</label>
			<div class="col-sm-3">
				<select name="ano" id="ano"/>
					<?php echo SelAno($ano); ?>
				</select>
			</div>
		</div>
		
		<div class="row">
			<label class="col-sm-4">Presupuesto *</label>
			<div class="col-sm-3">
				<select name="presup"><?php echo Presup($pre); ?></select>
			</div>
		</div>
		
		<div class="col-md-5">
			<label>Seleccion de Centro de Costo </label>
			<select name="origen[]" id="origen" multiple="multiple" size="9" tabindex="3">
				<?php 
					echo CCostoListar();
				?>
			</select>
		</div>
		<div class="col-md-3">
			<br />
			<input type="button" class="pasar izq" value=" Pasar &#187; ">  <input type="button" class="quitar der" value=" &#171; Quitar "><br /><br />
			<input type="button" class="pasartodos izq" value=" Todos &#187; ">  <input type="button" class="quitartodos der" value=" &#171; Todos  ">
		</div>
		<div  class="col-md-4">
			<label>Centro de Costo Seleccionado(s)</label>
				<select name="destino[]" id="destino" multiple="multiple" size="9" tabindex="4">
				<?php 
					//echo cuentasNivelesEERRInUse($grupo); 
				?>
				</select>
		</div>
		<!--
		<div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="reporte" id="reporte" value="Confirmar" class="w130 submit" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
		</div>
		-->
		<div class="row col-sm-12">
		<div class="col-sm-10"><input type="submit" id="enviar" class="w130 float_right" value="Confirmar" onclick="return valestres();" tabindex="5" /></div>
		<div class="col-sm-2"><input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/></div>
		
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
function valestres()
	{
	var mesini = $.trim($('#mesini').val());
	var mesfin = $.trim($('#mesfin').val());
	var ano    = $.trim($('#ano').val());
	var presup = $.trim($('#presup').val());
	var n = $('#destino option').prop('selected', 'selected').length;
	   
	if(n == 0)
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar al menos un Centro de Costo');
		return false;
	}
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