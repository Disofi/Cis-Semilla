<?php
//include('inc/funciones.php');
include('inc/funcion_eerr.php');
/*
if (isset($_GET['a']))
{
	$cta=$_REQUEST['a'];
	$mes=$_REQUEST['b'];
	$ano=$_REQUEST['c'];
	$ccs=$_REQUEST['d'];
	$id = $_REQUEST['id'];
}
*/
	$mes=$_REQUEST['b'];
	$ano=$_REQUEST['c'];
	$id = $_REQUEST['id'];
	$cc = $_REQUEST['cc'];
	//<a href="javascript:close_window();">close</a>
?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mayor Contable</h2>
		<div class="col-md-2">
			<a href="javascript:close_window();" class="back icon_text">Cerrar Pestaña</a>
		</div>
	</div>
</div>
<div class="clearing">&nbsp;</div>
<div class="table-responsive">
	<?php 
		//echo DetalleCuentasSaldos($cta,$mes,$ano,$ccs); 
		echo DetalleCuentasSaldos($id,$mes,$ano,$cc); 
	?>
</div>
<div class="clearing">&nbsp;</div>

<script>
function close_window() 
{
	close();
}
</script>