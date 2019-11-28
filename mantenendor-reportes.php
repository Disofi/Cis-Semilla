<?php
include('inc/funciones.php');
include('inc/funciones_rodrigo.php');
?>
<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Formatos de Reportes</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Formato de Reporte</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="NUEVO NIVEL" class="w130" onClick="NLevel();" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
	</div>
        
	<div class="col-sm-12">
	<?php echo formatoReporteListar(); ?>
	</div>
</div>
</form>
<script>
function NLevel()
{
	window.location.assign("index.php?mod=mantenendor-reportes-form");
}
function editarReporte(grupo)
{
	window.location.assign("index.php?mod=mantenendor-reportes-form&grupo="+grupo);
}

function eliminarReporte(grupo)
{
var r = confirm("Desea eliminar el grupo ["+ grupo +"] de registros del mantenedor?");
if (r == true) {
    //x = "You pressed OK!";
    
    var parametros = 
		{
		'grupo'   : grupo,
		'accion'  : 'delete',
        'seccion'  : 'reporte'
		};
	$.ajax({
		data:  parametros,
		url:   'ajax.process.mantenedor.reporte.php',
		type:  'post',					
		success:  function(response) 
			{
				showMessage('div#mini-notification', '', 'ok', 'Grupo eliminado Correctaente');
				$('div#mini-notification').css('display', 'block');
				setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenendor-reportes');}, 2000);
				
			}
		});
    
} 

}

</script>
