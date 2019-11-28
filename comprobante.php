<?php
include('inc/funciones.php');

if (isset($_GET['a']))
{
	$cuentaNumero=$_REQUEST['a'];
	$mes=$_REQUEST['b'];
	$ano=$_REQUEST['c'];	
	$item = $_REQUEST['item'];
	$cc = $_REQUEST['cc'];
	$cc1 = $_REQUEST['cc1'];
}

$getDatosEmpresa = getDatosEmpresa_();
for($z=0; $z < count($getDatosEmpresa); $z++)
	{
	$NomB=$getDatosEmpresa[$z]['NomB'];
	$Giro=$getDatosEmpresa[$z]['Giro'];
	$Dire=$getDatosEmpresa[$z]['Dire'];
	$RutE=$getDatosEmpresa[$z]['RutE'];
	$Ciud=$getDatosEmpresa[$z]['Ciud'];
	}

$getDatosComprobanteNumero = getDatosComprobanteNumero_($cuentaNumero);
for($z=0; $z < count($getDatosComprobanteNumero); $z++)
	{
	$CpbGlo=$getDatosComprobanteNumero[$z]['CpbGlo'];
	$cpbfec=$getDatosComprobanteNumero[$z]['cpbfec'];
	$cpbtip=$getDatosComprobanteNumero[$z]['cpbtip'];
	}
?>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Comprobante &nbsp;&nbsp;<?php echo $CpbGlo;?></h2>
		<div class="col-md-2"><a href="javascript:close_window();" class="back icon_text">Cerrar Pesta&ntilde;a</a></div>
	</div>
</div>
<div class="clearing">&nbsp;</div>
<center>
<table width="800" class="tb_encabezado">
	<tr>
		<th nowrap="nowrap">Nombre</th>
		<td><strong><?php echo $NomB;?></strong></td>
		<th nowrap="nowrap">N&ordm; Comprobante</th>
		<td><?php echo $cuentaNumero;?></td>
	</tr>
	<tr>
		<th nowrap="nowrap">Giro</th>
		<td><?php echo $Giro;?></td>
		<th nowrap="nowrap">Tipo</th>
		<td><?php echo $cpbtip;?></td>
	</tr>
	<tr>
		<th nowrap="nowrap">Direccion</th>
		<td><?php echo $Dire;?></td>
		<th nowrap="nowrap">Fecha Comprobante</th>
		<td><?php echo $cpbfec;?></td>
	</tr>
	<tr>
		<th>Rut</th>
		<td><?=$RutE;?>
		<th>&nbsp;</th>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<th>Ciudad</th>
		<td><?php echo $Ciud;?></td>
		<th>&nbsp;</th>
		<td>&nbsp;</td>
	</tr>
</table>
</center>
<br /><br />
<div class="table-responsive">
	<?php echo getDetalleCuentasNumero($cuentaNumero,$mes,$ano,$item,$cc,$cc1);?>
</div>

<script>
function close_window() 
{
	close();
}
</script>
