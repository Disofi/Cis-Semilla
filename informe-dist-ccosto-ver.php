<?php
if ($_SESSION['emp']['id']=='')
	{
	print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
include('inc/funciones.php');
include('inc/funcion_est_resultado.php');

$tempor = $_REQUEST['temporada'];
$destin = $_REQUEST['destino'];

?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Informes &gt; Estado de Resultado</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
</div>
<div class="row" style="margin:10px;">
	<?php DistCCosto($tempor,$destin); ?>
</div>