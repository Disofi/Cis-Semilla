<?php
if ($_SESSION['emp']['id']=='')
	{ 
		print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
//echo $_SESSION['emp']['id']."<br>";
//echo $_SESSION['emp']['bd']."<br>";
include('inc/funciones.php');
?>
<form name="estres" method="post" class="col-sm-12" id="estres" action="index.php?mod=estados-resultados-ver">
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Reportes &gt; Estados de Resultados</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	<h3 class="productsForm col-sm-12 borde_gris2 mb10">Seleccione Periodo a Consultar</h3>
	<div class="row col-sm-12">
		<label class="col-sm-4">* Mes Inico:</label>
		<div class="col-sm-4"><select name="mesini" id="mesini" tabindex="1" /><?php echo SelMes(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	<div class="row col-sm-12">
		<label class="col-sm-4">* Mes Término:</label>
		<div class="col-sm-4"><select name="mesfin" id="mesfin" tabindex="2" /><?php echo SelMes(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	<div class="row col-sm-12">
		<label class="col-sm-4">* A&ntilde;o:</label>
		<div class="col-sm-4"><select name="ano" id="ano" tabindex="3" /><?php echo SelAno(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	<div class="row col-sm-12">
		<label class="col-sm-4">Presupuesto:</label>
		<div class="col-sm-4"><select name="presup"><?php echo Presup(); ?></select></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
	<div class="row col-sm-12">
		<div class="col-sm-8"><input type="submit" id="enviar" class="w130 float_right" value="Seleccionar" onclick="return valestres();" tabindex="5" /></div>
		<div class="col-sm-4">&nbsp;</div>
	</div>
</div>
</form>
<script type="text/javascript">
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