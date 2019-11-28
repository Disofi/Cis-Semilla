<?php
if ($_SESSION['emp']['id']=='')
	{
		print '<meta http-equiv="Refresh" content="0;url=index.php?mod=selempresa" />';
	}
include('inc/funciones.php');
include('inc/funciones_EERR.php');
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);
$mesini = $_REQUEST['mesini'];
$mesfin = $_REQUEST['mesfin'];
$ano = $_REQUEST['ano'];
$pre = $_REQUEST['presup'];
$cc = $_REQUEST["destino"];
$query_date = $ano."-".$mesini."-01";
$acumulado = $_REQUEST['acumulado'];
//echo $mesini."MES INI <br>";
//echo $mesfin."MES FIN <br>";
// First day of the month.
//echo date('Y-m-01', strtotime($query_date))." PRIMER DIA<br>";

// Last day of the month.
//echo date('Y-m-t', strtotime($query_date))."ULTIMO DIA <br>";
$primerDia = date('01/m/Y', strtotime($query_date));
$ultimoDia = date('t/m/Y', strtotime($query_date));
$inicioAcumulado = "01/01/".$ano;
$finAcumulado = $ultimoDia;
//echo $primerDia."<--- primer dia <br>";
//echo $ultimoDia."<--- ultimoq dia <br>";
//echo $inicioAcumulado."<--- inicioAcumulado  <br>";
//echo $finAcumulado."<--- finAcumulado  <br>";
//echo $acumulado."<-----<br>";

if($acumulado == 1)
{
	$texto = "Acumulado Al: ";
}
//.positivo {color:#333 !important;}
//.hrefPositivo {color:#333 !important;}
//.positivoTotal {color:#333 !important; font-weight: 900;}
?>
<style>
.negativo {color:#FF0000 !important; }
.hrefNegativo {color:#FF0000 !important;}
.negativoTotal {color:#FF0000 !important; font-weight: 900;}
</style>
<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">Reportes &gt; Forecast</h2>
		<div class="col-md-2">
			<a href="index.php?mod=FORECAST&ano=<?php echo $ano;?>&pre=<?php echo $pre;?>&mes=<?php echo $mesini;?>" class="back icon_text">Volver</a>
		</div>
	</div>
	<h3 class="productsForm col-sm-12 borde_gris2 mb10">Periodo de consulta:  <?php echo $texto." ".$mesini.'/'.$ano; ?> </h3>
</div>
<div class="clearing">&nbsp;</div>
<?php 
	//EstadoResultado($mesini,$mesfin,$ano,$pre);

	
		//echo number_format(1234567);
	//echo $ano." AÑO <br>";
	//echo $primerDia." primerDia <br>";
	//echo $ultimoDia." ultimoDia <br>";
	//echo $inicioAcumulado." inicioAcumulado <br>";
	//echo $finAcumulado." finAcumulado <br>";
	//echo $cc." cc <br>";
	//echo $pre." pre <br>";
	//echo $mesini." mesini <br>";

	Forecast($ano,$primerDia,$ultimoDia,$inicioAcumulado,$finAcumulado,$cc,$pre,$mesini);
?>	