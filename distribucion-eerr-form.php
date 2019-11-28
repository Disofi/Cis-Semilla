<?php
include ('inc/funciones_EERR.php');
$centrocosto=$_REQUEST['centrocosto'];
 //echo $centrocosto;

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
		<label class="control-label col-sm-2" for="ano">A&ntilde;o</label>
		<div class="col-sm-10">
			<!--<input type="email" class="form-control" id="email" placeholder="Enter email">-->
			<?php echo selectAno(); ?>
		</div>
	</div>
	

	
	<div class="form-group">
		<label class="control-label col-sm-2" for="email">Centro de Costo:</label>
		<div class="col-sm-10">
			<!--<input type="email" class="form-control" id="email" placeholder="Enter email">-->
			<?php echo selectCC(); ?>
		</div>
	</div>
	<div class="form-group">
		<!-- <label class="control-label col-sm-2" for="email">&nbsp;</label>
		 <div class="col-sm-10">
			// <input type="email" class="form-control" id="email" placeholder="Enter email">
			 &nbsp;
		// </div>-->
	</div>
	<div id="formDistribucionCC" class="containter">
		<?php //echo mantenedorDistribucion(); ?>
	</div>
<input type="hidden" name="accion" id="accion" value="guardarDistcc" >
</form>


</div>
<script>
// function pasarHoja()
// {
	// var =document.getElementById("resultado");
	// var xmlhttp;
	// if(window.XMLHttpRequest)	
	// {
		// xmlhttp= new XMLHttpRequest();
		
	// }else
	// {
		// xmlhttp= new ActiveXObject("Microsoft.XMLHTTP");
		
	// }
	// var pasarinfo= document.getElementById("pasar").value;
	// xmlhttp.onreadystatechange=function()
	// {
			// if(xmlhttp.readyState===4 && xmlhttp.status===200)
		// {
			// var mensaje=xmlhttp.responseText;
			// resultado.innerHTML=mensaje;
			
		// }
		
	// }
	// xmlhttp.open("POST","modificardistribucion.php",true);
	// xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	// xmlhttp.send(informacionDelUsuario);
	
// }

function Modificar()
{
	window.location.assign("index.php?mod=modificardistribucion");	
}

// function Enviar_Valor()
// {
	// var resultado=document.getElementById("resultado");
	// var xmlhttp;
	// if(window.XMLHttpRequest)
	// {
		// xmlhttp=new XMLHttpRequest();
	// }else
	// {
		// xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");				
	// }
	// var anodistribucion =document.getElementById("anodis").value;
	// var informacionDelUsuario="ano="+anodistribucion;
	// xmlhttp.onreadystatechange=function()
	// {
		// if(xmlhttp.readyState===4 && xmlhttp.status===200)
		// {
			// var mensaje=xmlhttp.responseText;
			// resultado.innerHTML=mensaje;
			
		// }
		
	// }
		// xmlhttp.open("POST","modificardistribucion.php",true);
	// xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	// xmlhttp.send(informacionDelUsuario);
	
// }


$( document ).ready(function() {
    //console.log( "ready!" );
	$("#formDistribucionCC").show();
});
function cargarDistribucion()
{
	var anoSelect = $("#ano").val();
	var CCosto = $("#CC").val();
	
	
	if(anoSelect == "" || anoSelect == 0)
	{
		showMessage('div#mini-notification', '' , 'error', 'Debe Seleccionar un A&ntilde;o para realizar la Distribución por Centro de Costo');
		return false;
	}
	
	if(CCosto == "" || CCosto == 0)
	{
		showMessage('div#mini-notification', '' , 'error', 'Debe Seleccionar un Centro de Costo para realizar la Distribución por Centro de Costo');
		return false;
	}
	

	//console.log(CodiCC);
	$("#formDistribucionCC").hide();
	//$("#formDistribucionCC").show();
	//$("#formDistribucionCC").show();
	var parametros = 
	{

		'accion'	: 'mostrarFormDist',
		'CodiCC'	: CCosto,
		'anoSelect'	: anoSelect
		
		
	};
	
	
	$.ajax({
		data:  parametros,
		url:   'procesos/procesos.distribucion.php',
		type:  'post',					
		success:  function(response) 
			{
	
				$("#formDistribucionCC").show();
				$("#formDistribucionCC").html(response);
			
			}
		});
	return false;
	
	
}

function cambiarCheck(id, valor)
{
	//console.log(valor +' -- '+id);
	//alert(id +' -- '+valor);
	
	if($("#"+id).is(":checked")) 
	{
		//alert("CHECK");
		$("#sumaCuenta"+id).val(1);
    }	
	else
	{
		//alert("UNCHECKED");
		$("#sumaCuenta"+id).val(0);
	}
	
}

function validarValor(valor,id)
{
	//console.log(valor +' // '+id);
	//showMessage('div#mini-notification', '#tipo', 'error', 'Seleccione tipo de usuario');
	if(valor > 100)
	{
		showMessage('div#mini-notification', '#'+id, 'error', 'El valor a distribuir debe ser entre 0 y 100%');
		$("#"+id).val(0);
	}
	
	
}

function enviarFormulario()
{
	var parametros = $('form#distCC').serialize();
	console.log(parametros);
	var CCFcorm = $("#CC").val();	
	$.ajax({
	
		data:  parametros,
		url:   'procesos/procesos.distribucion.php',
		type:  'post',					
		success:  function(response) 
			{
				$("#formDistribucionCC").html(response);
				showMessage('div#mini-notification', '#CC', 'ok', 'Distribuci&oacute;n para el Centro de Costo '+CCFcorm+' ingresado');
				$('#CC option:eq(0)').prop('selected', true);
				$("#formDistribucionCC").show();
				
			}
		});
	
	return false;
}

	





</script>