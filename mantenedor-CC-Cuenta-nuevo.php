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
		<h2 class="col-md-10">Nuevo &gt; Centro de Costo por Niveles EERR</h2>
		<div class="col-md-2">&nbsp;</div>
	</div>
	
	<h3 class="userForm col-sm-12 borde_gris2">Nuevo Nivel</h3>
	    <div class="col-sm-12 ta_r mb10 mt10">
		<input type="button" name="reporte" id="reporte" value="Confirmar" class="w130 submit" onclick="agregar();"/>
		<input type="button" name="volver"  id="volver"  value="<< VOLVER" class="w130" onclick="javascript:window.history.back();"/>
	</div>
	<div class="row col-md-12">
		<div class="row">
			<label class="col-sm-4">Nivel EERR *</label>
			<div class="col-sm-3"><?php echo selectNivel(); ?> </div>
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
	$salida.='<select name="CC" id="CC" class="form-control"  maxlength="49" placeholder="M&aacute;ximo 40 caracteres">';
	$salida.='<option value="00">Seleccione Centro de Costo</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' '.$row['DescCC'].'</option>';
		
	}
	$salida.="</select>";
	echo $salida;
}

function selectNivel()
{
	include('inc/conexion.php');
	$salida = "";
	$query = " SELECT idNivel, tituloNivel FROM ".$dba.".[DS_nivelesEERR] where [bdsession]='".$_SESSION['emp']['id']."' group by idNivel, tituloNivel";
	//echo $query."<br>";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="Nivel" id="Nivel" class="form-control"  maxlength="49" placeholder="M&aacute;ximo 40 caracteres">';
	$salida.='<option value="00">Seleccione NIvel EERR</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['idNivel'].'">'.$row['tituloNivel'].' '.$row['DescCC'].'</option>';
		
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

</script>

<script>
function agregar()
{
	
	var cc = $("#CC").val();
	var nivel = $("#Nivel").val();
	console.log(cc +' - '+nivel);
	console.log('inicio');
        var parametros = {
                "cc" : cc,
                "nivel" : nivel,
				"accion": "agregarccnivel"
        };
		
	if(cc == '00')
	{
		showMessage('div#mini-notification', '', 'error', 'Debe seleccionar un Centro de Costo');
		return false;
	}
    if(nivel == '00')
	{
		showMessage('div#mini-notification', '#titulo', 'error', 'Debe seleccionar un un Nivel EERR');
		return false;
	}
	
		
        $.ajax({
                data:  parametros,
                url:   'inc/Funciones_CC_Niveles.php',
                type:  'post',
                beforeSend: function () {
                        $("#agregarccnivel").html("Procesando, espere por favor...");
                },
                success:  function (response) {
                        $("#agregarccnivel").html(response);
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