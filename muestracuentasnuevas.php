<?php
include('inc/funciones.php');
include('inc/funciones_agrupacion_cuentas.php');
//echo $_SESSION['emp']['id']."<----<br>";
$val=$_POST['mesini'];
$val2=$_POST['ano'];
echo $val;
echo $val2;
?>

<form name="estres" method="post"  id="estres" action="#" >
<div class="content">
	<h3 class="userForm col-sm-12 borde_gris2">Buscar Periodos</h3>
	<div class="row col-md-12">
	
		<div class="row">
			<label class="col-sm-4">A&ntilde;o *</label>
			<div class="col-sm-3">
				<select name="ano" id="ano"/>
					<?php echo AnoEERR(); ?>
				</select>
			</div>
		</div>
		<div class="row col-md-12">
		<br>
			<label class="col-sm-4"> Mes: *</label>
			<div class="col-sm-3">
			<select name="mesini" id="mesini"/>
				<?php echo  MesesEERR(); ?>
			</select>
			</div>
		</div>
	
		<br>
		
		
		</div>
		<div class="row col-md-12">
		<div class="row">
			<label class="col-sm-4"></label>
			<div class="col-sm-3">
		<input type="submit" id="enviar" class="w130 float_right" value="Buscar" onclick="ajax_post();" tabindex="5" /></div>

			</div>
		</div>
		
	
		<div  class="col-sm-3">
		<label id="resp"></label>
		</div>
	
		</form>
</div>
<div class="content">
<form name="usuarios_ing" method="post" class="col-sm-12" id="usuarios_ing">
	<div class="row col-md-12">
		<div class="row">
			<label class="col-sm-4"></label>
			<div class="col-sm-3">
		<input type="button" id="enviar" class="w130 float_right" value="Clonar" onclick="Clonar();" tabindex="5" /></div>
		
			</div>
		</div>

	
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedores &gt; Agrupaci&oacute;n de Cuentas</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Agrupaci&oacute;n de cuentas Para el &uacute;timo mes cargado</h3>
	
    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="Nueva Agrupaci&oacute;n" class="w130" onClick="NLevel();" />
		<!--
		<input type="button" name="volver"  id="volver"  value="<< Volver" class="w130" onclick="javascript:window.history.back();"/>
		-->
	</div>
        
	<div class="col-sm-12">
	<?php echo agrupacionCuentasListar($mes,$ano); ?>
	</form>
	</div>
	 <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="newuser" id="newuser" value="Volver" class="w130" onClick="Volver();" />
		<!--
		<input type="button" name="volver"  id="volver"  value="<< Volver" class="w130" onclick="javascript:window.history.back();"/>
		-->
	</div>
</div>

<div id="info"></div>

<script>
function ajax_post()
{
	var resultado=document.getElementById("info");
	var xmlhttp;
	if(window.XMLHttpRequest)
	{
		xmlhttp=new XMLHttpRequest();
	}else
	{
		xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");				
	}
	var a =document.getElementById("ano").value;
	var b =document.getElementById("mesini").value;

	var informacionDelUsuario="ano="+a+"&mesini="+b;
	xmlhttp.onreadystatechange=function()
	{
		if(xmlhttp.readyState===4 && xmlhttp.status===200)
		{
			var mensaje=xmlhttp.responseText;
			resultado.innerHTML=mensaje;
			
		}
		
	}

	xmlhttp.open("POST","muestracuentasnuevas.php",true);
	xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	xmlhttp.send(informacionDelUsuario);
	
}


	
	function Clonar()
		{
			window.location.assign("index.php?mod=clonar");
		}
function Volver()
{
	window.location.assign("index.php?mod=estadoresultadonuevo");
}
function NLevel()
{
	window.location.assign("index.php?mod=mantenendor-cuentas-form");
}
function editarReporte(nivel,ano,mes)
{
	window.location.assign("index.php?mod=mantenendor-cuentas-form&nivel="+nivel+"&ano="+ano+"&mes="+mes);
	 $.post('mantenendor-cuentas-form.php', {
              "mes": mes,
              "ano": ano
            },function(data) {
              console.log('procesamiento finalizado', data);
          });
	
}

function eliminarReporte(grupo)
{
	//alert("Eliminar Agrupacion de cuentas");

	var r = confirm("Desea eliminar el grupo ["+ grupo +"] de registros del mantenedor?");

	if (r == true) 
	{
		//x = "You pressed OK!";
		
		var parametros = 
			{
				'accion'  : 'deleteAgrupacionCuentas',
				'nivel'   : grupo
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',					
			success:  function(response) 
				{
					showMessage('div#mini-notification', '', 'ok', 'Grupo eliminado Correctaente');
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-cuentas');}, 2000);
					
				}
			});
		
	} 

}

</script>
