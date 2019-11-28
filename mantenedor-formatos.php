<?php
include('inc/funciones.php');
?>
<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Formatos de Estados de Resultados</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Listado de Cuentas Nivel</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="NUEVO NIVEL" class="w130" onClick="NLevel();" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
	</div>
        
	<div class="col-sm-12"><?php echo ManCtasListar(); ?></div>
</div>
</form>
<script>
function NLevel()
	{
	window.location.assign("index.php?mod=mantenedor-formatos-form");
	}
</script>
