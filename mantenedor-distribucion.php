<?php
include('inc/funciones.php');
?>
<form name="dist_ing" method="post" class="col-sm-12" id="dist_ing">
<div class="content">
	<h3 class="userForm col-sm-12 borde_gris2">Listado Cuentras con Distribución</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="NUEVA DISTRIBUCION" class="w130" onClick="NUser();" />
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="atras();"/>
	</div>

	<div class="col-sm-12"><?php echo DistListado(); ?></div>
</div>
</form>
<script>
function NUser()
	{
	window.location.assign("index.php?mod=mantenedor-distribucion-form");
	}
</script>
