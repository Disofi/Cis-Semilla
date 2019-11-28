<?php
include('inc/funciones.php');
include('inc/funciones_agrupacion_cuentas.php');
//echo $_SESSION['emp']['id']."<----<br>";
?>
<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Agrupaci&oacute;n de Cuentas</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Agrupaci&oacute;n de Cuentas</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="Nueva Agrupaci&oacute;n" class="w130" onClick="NLevel();" />
		<!--
		<input type="button" name="volver"  id="volver"  value="<< Volver" class="w130" onclick="javascript:window.history.back();"/>
		-->
	</div>
        
	<div class="col-sm-12">
	<?php echo agrupacionCuentasListar(); ?>
	</div>
</div>
</form>
<script>
function NLevel()
{
	window.location.assign("index.php?mod=mantenendor-cuentas-form");
}
function editarReporte(nivel,bd)
{
	window.location.assign("index.php?mod=mantenendor-cuentas-form&nivel="+nivel);
	//alert("editar Agrupacion de cuentas");
}

function eliminarReporte(grupo)
{
	//alert("Eliminar Agrupacion de cuentas");

	var r = confirm("Desea eliminar el grupo ["+ grupo +"] de registros del mantenedor?");

	if (r == true) 
	{
		//x = "You pressed OK!";
		
		var parametros = 
			{
				'accion'  : 'deleteAgrupacionCuentas',
				'nivel'   : grupo
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',					
			success:  function(response) 
				{
					showMessage('div#mini-notification', '', 'ok', 'Grupo eliminado Correctaente');
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-cuentas');}, 2000);
					
				}
			});
		
	} 

}

</script>
