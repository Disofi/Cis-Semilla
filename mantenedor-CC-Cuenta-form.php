<?php
include('inc/funciones_CC_niveles.php');
$grupo = $_REQUEST['nivel'];
//echo $_SESSION['emp']['id']."<----<br>";
if($grupo == '')
{
    $accion = 'insertNivel';
}
else
{
    $accion = 'updateNivel';
	$datosTitulo = nivelesTituloEERR($grupo);
	//$datosTitulo = agrupacionCuentaTitulo($grupo);
    $datosDescripcion = nivelesDescEERR($grupo);
	//$datosDescripcion = agrupacionCuentaDesc($grupo);
    //$datosIndice = datosReporteIndice($grupo);
    //print_r($datosDescripcion);
}
?>
<form name="mantenedorReporte" method="post" class="col-sm-12" id="mantenedorReporte">
<div class="content">
<fieldset>
	<input name="accion" type="hidden" id="accion" value="<?php echo $accion;?>"/>
    <input name="grupo" type="hidden" id="grupo" value="<?php echo $grupo;?>"/>
    <input name="indice_temp" type="hidden" id="indice_temp" value="<?php echo $datosIndice[0];?>"/>
	<div class="titulo_pagina">
		<h2 class="col-md-10">Mantenedor &gt; Centro de Costo y Niveles EERR</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Nuevo Nivel</h3>
	    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="reporte" id="reporte" value="Confirmar" class="w130 submit" onclick="updatecceerr();"/>
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
	</div>
	<div class="row col-md-12">
		<div class="row">
			<label class="col-sm-4">Titulo Nivel *</label>
			<div class="col-sm-3"><input name="titulo" type="text" id="titulo" value="<?php echo $datosTitulo[0];?>" maxlength="49" placeholder="M&aacute;ximo 40 caracteres" /></div>
		</div>
		
		<div class="row">
			<label class="col-sm-4">Descripci&oacute;n del Nivel *</label>
			<div class="col-sm-3"><input name="descripcion" type="text" id="descripcion" value="<?php echo $datosDescripcion[0];?>" maxlength="49" placeholder="M&aacute;ximo 40 caracteres" /></div>
		</div>
		
		<div class="row">
			<label class="col-sm-4">Centro de Costo *</label>
			<div class="col-sm-3"><?php echo selectCC(); ?> </div>
		</div>

	</div>
	
</fieldset>
</div>	
</form>
<span></span>
<style>
	select { width:180px; margin:0 0 50px 0; border:1px solid #ccc; }
	.clear { clear:both; text-align:center; }
	.izq   { border-radius:10px 0 0 10px; }
	.der   { border-radius:0 10px 10px 0; }
</style>


<?php
function selectCC()
{
	include('inc/conexion.php');
	$salida = "";
	$query = " select CodiCC, DescCC from ".$dbs.".cwtccos where activo = 'S' and DescCC <> '' AND DescCC IS NOT NULL AND nivelCC = 1 ";
	//echo $query."<br>";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="CC" id="CC" class="form-control" onchange="cargarDistribucion(this.value)" maxlength="49" placeholder="M&aacute;ximo 40 caracteres">';
	$salida.='<option value="00">Seleccione Centro de Costo</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' '.$row['DescCC'].'</option>';
		
	}
	$salida.="</select>";
	echo $salida;
}

?>





<script type="text/javascript">

/* Formato de traspaso grid */
$().ready(function() 
	{
		$('.pasar').click(function() { return !$('#origen option:selected').remove().appendTo('#destino'); });  
		$('.quitar').click(function() { return !$('#destino option:selected').remove().appendTo('#origen'); });
		$('.pasartodos').click(function() { $('#origen option').each(function() { $(this).remove().appendTo('#destino'); }); });
		$('.quitartodos').click(function() { $('#destino option').each(function() { $(this).remove().appendTo('#origen'); }); });
		$('.submit').click(function() { $('#destino option').prop('selected', 'selected'); });
	}
);

$(document).ready(function)
{
	$('form').submit(function e)
	e.preventDefault();
	var data = $(this).serializeArray();
}

/*

$(document).on('click', '#reporte', function()
{
	//showMessage('div#mini-notification', '', 'loading', 'Procesando los datos, Por favor espere...');
	$('#destino option').prop('selected', 'selected');
	var cc = $('#cc').val();
	var titulo = $('#titulo').val();
    var descripcion = $('#descripcion').val();
	
    
	if(cc == '00')
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar un Centro de Costo');
		return false;
	}
    if(titulo == '')
	{
		showMessage('div#mini-notification', '#titulo', 'error', 'Debe ingresar Titulo');
		return false;
	}
	if(descripcion == '')
	{
		showMessage('div#mini-notification', '#descripcion', 'error', 'Debe ingresar Descripcion');
		return false;
	}
		
	$.ajax({
		data:parametros,
		url:'Funciones_CC_Niveles.php',
		type:'post',					
		success:  function(response)
			{
				//alert(response);
			var json = eval('(' + response + ')');
			if (json.tipo == 'OK')
				{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-niveles-eerr');}, 1000);	
				}
			else
				{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					//enviarFormHabilitar();
				}
			}
		});

    	
	return false;
});
**/

 	

</script>

<script>
function updatecceerr()
{
	
	var cc = $("#CC").val();
	var nivel = $("#grupo").val();
	console.log(cc +' - '+nivel);
	console.log('inicio');
        var parametros = {
                "cc" : cc,
                "nivel" : nivel,
				"accion": "updateeerr"
        };
		
	if(cc == '00')
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar un Centro de Costo');
		return false;
	}
    if(titulo == '')
	{
		showMessage('div#mini-notification', '#titulo', 'error', 'Debe ingresar Titulo');
		return false;
	}
	if(descripcion == '')
	{
		showMessage('div#mini-notification', '#descripcion', 'error', 'Debe ingresar Descripcion');
		return false;
	}
		
        $.ajax({
                data:  parametros,
                url:   'inc/Funciones_CC_Niveles.php',
                type:  'post',
                beforeSend: function () {
                        $("#updateccnivel").html("Procesando, espere por favor...");
                },
                success:  function (response) {
                        $("#updateccnivel").html(response);
						console.log(response);
						var json = eval('(' + response + ')');
						if (json.tipo == 'OK')
						{
							showMessage('div#mini-notification', '', 'ok', 'Se Guardo Correctamente');
							/*setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-CC-Cuenta');}, 1000);	*/
						}
                }
        });
		
} 
</script>