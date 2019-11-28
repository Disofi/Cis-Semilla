<?php
include('inc/funciones.php');
include('inc/funciones_CC_niveles.php');
//echo $_SESSION['emp']['id']."<----<br>";
?>
<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedor &gt; Centro de Costo y Niveles EERR</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Centro de Costo y Niveles EERR</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="Nuevo CC por Nivel"  class="w130" onClick="nuevoccnivel();" />
		<!--
			<input type="button" name="volver"  id="volver"  value="<< Volver" class="w130" onclick="javascript:window.history.back();"/>
			-->
	</div>
        
	<div class="col-sm-12">
	<?php 
		echo nivelesCuentasListar(); 
	?>
	</div>
</div>
</form>
<script>
function NLevel()
{
	
	window.location.assign("index.php?mod=mantenedor-CC-Cuenta-form");
}
function nuevoccnivel()
{
	window.location.assign("index.php?mod=mantenedor-CC-Cuenta-nuevo");
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
				'accion'  : 'deleteNivel',
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
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-niveles-eerr');}, 2000);
					
				}
			});
		
	} 

}

</script>
