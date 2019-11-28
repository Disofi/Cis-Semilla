<?php
include('inc/funciones.php');
include('inc/funciones_agrupacion_cuentas.php');
//echo $_SESSION['emp']['id']."<----<br>";
?>

<div class="content">
	<div class="row">
<div class="col-sm-2"><input type="submit" id="enviar" class="w130 float_right" value="Mantenedor  Cuentas" onclick="return Modificar();"  name="envio" tabindex="5" /></div>
<!--<div class="col-sm-2"><input type="submit" id="enviar" class="w130 float_right" value="Mostrar Distribucion CC" onclick="return CentroCosto();"  name="envio" tabindex="5" /></div>-->

		<div class="col-sm-2"><input type="button" name="volver"  id="volver"  value="Mantenedor Distribucion " class="w130" onclick="MantenedorCC();"/></div>
		<div class="col-sm-2"><input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/></div>
		</div>
		<br/>
		
		<br/>
	<div class="titulo_pagina">
		<h2 class="col-md-10">Cuentas Actuales Que Se Consideran Para Cada Nivel del EERR</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	

	<div class="row">
	<div class="col-sm-12">
	<?php echo MostrarCuentasActuales(); ?>
	</div>
	</div>
	<div class="row col-sm-13">
</br>
</br>


	</div>

<script type="text/javascript">
/* Formato de traspaso grid */
function Modificar()
{
	window.location.assign("index.php?mod=muestracuentasnuevas");	
}

function Confirmar()
{
	window.location.assign("index.php?mod=EERR");	
}

function CentroCosto()
{
	window.location.assign("index.php?mod=mostrardistribucioncc");	
}
function MantenedorCC()
{
	window.location.assign("index.php?mod=mantenedorcc");	
}


</script>