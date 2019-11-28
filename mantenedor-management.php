<?php
include('inc/funciones.php');
?>
<form name="dist_ing" method="post" class="col-sm-12" id="dist_ing">
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-12">Mantenedores &gt; Manamegent Fee</h2>
	</div>

	<h3 class="userForm col-sm-12 borde_gris2">Listado Management Fee</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="AGREGAR" class="w130" onClick="NUser();" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="atras();"/>
	</div>

	<div class="col-sm-12"><?php echo DistManagement(); ?></div>
</div>
</form>
<script>
function NUser()
	{
	window.location.assign("index.php?mod=mantenedor-management-form");
	}
</script>
