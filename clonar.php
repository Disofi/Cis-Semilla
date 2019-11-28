<?php
include('inc/funciones.php');
include('inc/funciones_agrupacion_cuentas.php');
//echo $_SESSION['emp']['id']."<----<br>";
?>

<div class="content">
	<div class="titulo_pagina">
		<h2 class="col-md-10">CLONAR PERIODO</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
</div>
<div class="content">


<div class="content">

<fieldset name="" class="col-sm-8"  >
	<legend class="border p-2" >Seleccione Periodo</legend>
		<div class="row">		
	
		<label class="col-sm-6"> Ano: *</label>
			<div class="col-sm-6">
			<select name="anoini" id="anoini"/>
				<?php echo AnoEERR(); ?>
			</select>
			</div>
		</div>
		</br>
		</br>
		<div class="row">		
		<label class="col-sm-6"> Mes: *</label>
			<div class="col-sm-6">
			<select name="mesini" id="mesini"/>
				<?php echo MesesEERR();?>
			</select>
			</div>
		</div>
<br/> 
<br/> 
<fieldset>
</div>
<br>
<br>
<br>
<div class="content">

<fieldset name="" class="col-sm-8"  >
<legend class="border p-2" >Ingrese Periodo a Clonar</legend>
		<div class="row">		
		
		<label class="col-sm-6"> Ano: *</label>
			<div class="col-sm-6">
			<input type="text" name="anoaingresar" id="anoaingresar" class="col-md-2">
			</div>
		</div>
<br/> 
<br/> 
		<div class="row">			
		<label class="col-sm-6"> Mes: *</label>
			<div class="col-sm-6">
		<input type="text" name="mesaingresar" id="mesaingresar" class="col-md-2">
			</div>
		</div>
	
	<br/> 
	<br/> 
<div class="row col-sm-12">
	<div class="col-sm-4"><input type="submit" id="enviar" class="w130 float_right" value="Clonar" onclick="ajax_post();" tabindex="5" /></div>
		<div class="col-sm-4"><input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/></div>
		</div>
		
<fieldset>
</div>
	<div id="info"></div>
</div>


<script>

function ajax_post()
{
	alert("EL MES HA SIDO CLONADO");
	var resultado=document.getElementById("info");
	var xmlhttp;
	if(window.XMLHttpRequest)
	{
		xmlhttp=new XMLHttpRequest();
	}else
	{
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");				
	}
	var a =document.getElementById("anoini").value;
	var b =document.getElementById("mesini").value;
	var c =document.getElementById("anoaingresar").value;
	var d =document.getElementById("mesaingresar").value;
	var informacionDelUsuario="anoini="+a+"&mesini="+b+"&anoaingresar="+c+"&mesaingresar="+d;
	xmlhttp.onreadystatechange=function()
	{
		if(xmlhttp.readyState===4 && xmlhttp.status===200)
		{
			var mensaje=xmlhttp.responseText;
			resultado.innerHTML=mensaje;
			
		}
		
	}

	xmlhttp.open("POST","accionclonar.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.send(informacionDelUsuario);
}
	


</script>

