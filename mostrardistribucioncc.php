<?php
include('inc/funciones.php');
include('inc/funciones_agrupacion_cuentas.php');
//echo $_SESSION['emp']['id']."<----<br>";
?>

<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Cuentas Actuales</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	

	<div class="row">
	<div class="col-sm-12">
	<?php echo MostrarDistribucionCC(); ?>
	</div>
	</div>
	<div class="row col-sm-13">
</br>
</br>

		<div class="col-sm-2"><input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/></div>

<div class="col-sm-2"><input type="submit" id="enviar" class="w130 float_right" value="Modificar" onclick="return Modificar();"  name="envio" tabindex="5" /></div>
<div class="col-sm-2"><input type="submit" id="enviar" class="w130 float_right" value="Clonar" onclick="return Clonar();"  name="envio" tabindex="5" /></div>

	</div>

<script type="text/javascript">
/* Formato de traspaso grid */


function Confirmar()
{
	window.location.assign("index.php?mod=distribucion-eerr-form");	
}

function EERR()
{
	window.location.assign("index.php?mod=EERR");	
}


function Modificar()
{
	window.location.assign("index.php?mod=distribucion-eerr-form");	
}

function Clonar()
{
	window.location.assign("index.php?mod=clonardistribucion");	
	
}

</script>