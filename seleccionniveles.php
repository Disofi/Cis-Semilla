<?php
include('inc/funciondistribucion.php');
$respuestasi=$_REQUEST['respuesta'];
$centrocosto=$_REQUEST['cc'];
if(isset($_POST['valor_1']))
{
	$nivel1=$_POST['valor_1'];	

	
}
if(isset($_POST['valor_2']))
{
	$nivel2=$_POST['valor_2'];

}
if(isset($_POST['valor_3']))
{
	$nivel3=$_POST['valor_3'];	

	}
if(isset($_POST['valor_4']))
{
	$nivel4=$_POST['valor_4'];	
	
}
if(isset($_POST['valor_5']))
{
	$nivel5=$_POST['valor_5'];
	
}
?>



<form name="estres" method="post"  id="estres" action="#" >
	
		<div class="row">
			<label class="col-sm-4">Seleccione Donde Se distribuye</label>
	</div>
	<br/>
	<br/>
	<div class="row">
			<div class="col-sm-4" style="margin-left:500px;">
		
					<?php echo MostrarDistribucionCC($centrocosto,$nivel1,$nivel2,$nivel3,$nivel4,$nivel5); ?>
	
			</div>
			</div>
		
		</form>
		<script>
		function Volver()
		{
				window.location.assign("index.php?mod=mantenedorcc");
		}
		</script>
	
