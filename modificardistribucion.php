<?php

include ('inc/funciones_EERR.php');

?>
<style>
tr.sinBorde td 
{
  border: 0;
}

input[type=number] 
{
	text-align:right;
}
</style>

<div class="container">
<form id="distCC" name="distCC">
	<div class="form-group">
		<label class="control-label col-sm-2" for="ano">Seleccione A&ntilde;o desde donde desea clonar</label>
		<div class="col-sm-2">

			<?php echo selectAno(); ?>
		</div>
	</div>
	</br>
	</br>
	</br>
</br>
	</br>
	</br>

		<div class="form-group">
		<label class="control-label col-sm-2" for="ano">A&ntilde;o a Clonar</label>
		<div class="col-sm-2">
		
			<?php echo seleccionaAno(); ?>
		</div>
	</div>
	</br>
	</br>
	<input type="button" value="Clonar Distribucion" onclick="ClonarDistribucion();">
</div>


<script>
function Enviar_Valor()
{
	var resultado=document.getElementById("resultado");
	var xmlhttp;
	if(window.XMLHttpRequest)
	{
		xmlhttp=new XMLHttpRequest();
	}else
	{
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");				
	}
	var anodistribucion =document.getElementById("anodis").value;
	var informacionDelUsuario="ano="+anodistribucion;
	xmlhttp.onreadystatechange=function()
	{
		if(xmlhttp.readyState===4 && xmlhttp.status===200)
		{
			var mensaje=xmlhttp.responseText;
			resultado.innerHTML=mensaje;
			
		}
		
	}
		xmlhttp.open("POST","modificardistribucion.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.send(informacionDelUsuario);
	
}

</script>