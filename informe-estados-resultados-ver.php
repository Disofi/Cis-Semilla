<?php
if ($_SESSION['emp']['id']=='')
	{
		print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
include('inc/funciones.php');

$mesini = $_REQUEST['mesini'];
$mesfin = $_REQUEST['mesfin'];
$ano = $_REQUEST['ano'];
$pre = $_REQUEST['presup'];
?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Reportes &gt; Estados de Resultados</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	<h3 class="productsForm col-sm-12 borde_gris2 mb10">Periodo de consulta: Desde <?php echo $mesini.'/'.$ano; ?> al <?php echo $mesfin.'/'.$ano; ?></h3>
</div>
<div class="clearing">&nbsp;</div>
<?php EstadoResultado($mesini,$mesfin,$ano,$pre); ?>