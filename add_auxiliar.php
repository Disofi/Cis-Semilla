<?php
require('head.php');
include('inc/funciones.php');

// Agregar nuevo cliente...
if(!isset($_GET['id']))
	{
	$id = null;
	$accion = 'add_auxiliar';
	$row = array(
		'CodAux' => '', 'NomAux' => '', 'RutAux' => '', 'GirAux' => '', 'ComAux' => '', 'CiuAux' => '', 'PaiAux' => 'CL', 'ProvAux' => '', 'DirAux' => '',
		'DirNum' => '', 'FonAux1' => '', 'FonAux2' => '', 'ClaCli' => 'N', 'ClaSoc' => 'N', 'Email' => '', 'Region' => 0, 'ClaDis' => 'N',
		'ClaOtr' => 'N', 'Bloqueado' => 'N', 'esReceptorDTE' => 'N', 'BloqueadoPro' => 'N', 'Usuario' => '', 'Proceso' => 'INGRESO CLIENTE', 'ClaPro' => 'S', 'DirDpto' => '');
	$titulo_form = array('texto' => 'Agregar nuevo cliente', 'css' => 'addForm');
	}

// Editar cliente existente...
if(isset($_GET['id']))
	{
	$id = trim(sanitize($_GET['id']));
	$accion = 'edit_auxiliar';
	$row = mantenedorClientesSeleccionar($id);
	if($row == 'NO_EXISTE')
		{
		echo '<script type="text/javascript">window.location.href=\'index.php?mod=mantenedor-clientes\';</script>';
		}
	$titulo_form = array('texto' => 'Editar cliente existente', 'css' => 'editForm');
	}
?>
<div class="titulo_pagina col-sm-12"><h2>Agregar Auxiliar</h2></div>

<form name="add_auxiliar" method="post" class="col-sm-10" id="add_auxiliar">
<?php 
if(isset($_GET['id']))
	{
	echo '
	<div class="row">
		<label class="col-sm-4">C&oacute;digo Cliente</label>
		<div class="col-sm-3"><input name="cod_cliente" type="text" id="cod_cliente" value="'.$row['CodAux'].'" maxlength="10" readonly="readonly" /></div>
	</div>
	<div class="row">
		<label class="col-sm-4">RUT *</label>
		<div class="col-sm-3"><input name="rut" type="text" id="rut" value="'.$row['RutAux'].'" maxlength="20" readonly="readonly" /></div>
		<label class="col-sm-2">Mandante</label>
		<div class="col-sm-2">';
	echo '</div>
	</div>
	<style type="text/css">
	input#cod_cliente, input#rut { color:#666666 !important; font-weight:bold !important; font-size:13pt !important;}
	input#cod_cliente:focus, input#rut:focus { border-color:#CCCCCC !important; -webkit-box-shadow:none; box-shadow:none; }
	</style>
	';
	}
if(!isset($_GET['id']))
	{
	echo '
	<div class="row">
		<label class="col-sm-4">RUT *</label>
		<div class="col-sm-3"><input name="rut" type="text" id="rut" value="'.$row['RutAux'].'" maxlength="20" placeholder="Sin puntos ni gui&oacute;n" onblur="return buscarRut();"  /></div>
	</div>';
	}
	?>
<div class="row">
	<label class="col-sm-4">Nombre/Raz&oacute;n Social *</label>
	<div class="col-sm-8"><input name="nombre" type="text" id="nombre" value="<?php echo $row['NomAux'];?>" maxlength="60" /></div>
</div>
<div class="row">
	<label class="col-sm-4">C&oacute;digo Giro SII *</label>
	<div class="col-sm-8"><?php echo SelGiroSII($row['GirAux']); ?></div>
</div>
<div class="row">
	<label class="col-sm-4">Direcci&oacute;n *</label>
	<div class="col-sm-6"><input name="direccion_calle" type="text" id="direccion_calle" value="<?php echo $row['DirAux'];?>" maxlength="60" /></div>
	<label class="col-sm-1">N&ordm; *</label>
	<div class="col-sm-1"><input name="direccion_num" type="text" id="direccion_num" value="<?php echo $row['DirNum'];?>" maxlength="10" /></div>
</div>
<div class="row">
	<label class="col-sm-4">Dpto/Oficina</label>
	<div class="col-sm-3"><input name="dir_depto" type="text" id="dir_depto" value="<?php echo $row['DirDpto'];?>" maxlength="60" /></div>
</div>
<div class="row">
	<label class="col-sm-4">Regi&oacute;n *</label>
	<div class="col-sm-8">
		<select name="region" id="region" onchange="cargar_provincias(this.value, '', '', '');"><?php echo SelRPCC('REGIONES', $row['Region'], $row['CiuAux'], $row['ComAux']); ?></select>
	</div>
</div>
<div class="row">
	<label class="col-sm-4">Provincia *</label>
	<div class="col-sm-8">
		<?php
		if(isset($_GET['id']))
			{
			echo '<select name="provincia" id="provincia" onchange="cargar_ciudades(\''.$row['Region'].'\', \'\', \'\', \'\')">';
			echo SelRPCC('PROVINCIAS', $row['Region'], $row['ProvAux'], $row['CiuAux'], $row['ComAux']);
			echo '</select>';
			}
		if(!isset($_GET['id']))
			{
			echo '<select name="provincia" id="provincia">';
			echo '<option value=""></option>';
			echo '</select>';
			}
		?>                                                                                                   
	</div>
</div>
<div class="row">
	<label class="col-sm-4">Ciudad *</label>
	<div class="col-sm-8">
		<?php
		if(isset($_GET['id']))
			{
			echo '<select name="ciudad" id="ciudad" onchange="cargar_comunas(\''.$row['Region'].'\', \'\', \'\', \'\')">';
			echo SelRPCC('CIUDADES', $row['Region'], $row['ProvAux'], $row['CiuAux'], $row['ComAux']);
			echo '</select>';
			}
		if(!isset($_GET['id']))
			{
			echo '<select name="ciudad" id="ciudad">';
			echo '<option value=""></option>';
			echo '</select>';
			}
		?>                                                                                                   
	</div>
</div>
<div class="row">
	<label class="col-sm-4">Comuna *</label>
	<div class="col-sm-8">
		<select name="comuna" id="comuna">
		<?php
		if(isset($_GET['id']))  { echo SelRPCC('COMUNAS', $row['Region'], $row['ProvAux'], $row['CiuAux'], $row['ComAux']); }
		if(!isset($_GET['id'])) { echo '<option value=""></option>'; }
		?>
		</select>
	</div>
</div>
<div class="row">
	<label class="col-sm-4">Tel&eacute;fono 1 *</label>
	<div class="col-sm-3"><input name="telefono_01" type="text" id="telefono_01" value="<?php echo $row['FonAux1'];?>" maxlength="15" /></div>
</div>
<div class="row">
	<label class="col-sm-4">Tel&eacute;fono 2</label>
	<div class="col-sm-3"><input name="telefono_02" type="text" id="telefono_02" value="<?php echo $row['FonAux2'];?>" maxlength="15" /></div>
</div>
<div class="row">
	<label class="col-sm-4">Correo electr&oacute;nico *</label>
	<div class="col-sm-8"><input name="correo" type="text" id="correo" value="<?php echo $row['Email'];?>" maxlength="100" placeholder="ejemplo@ejemplo.cl" /></div>
</div>

<div class="row">
	<div class="col-sm-12">
		<input type="hidden" name="id"  id="id" value="<?php echo $id;?>" />
		<input type="hidden" name="pais" id="pais" value="<?php echo $row['PaiAux'];?>" />
		<input type="hidden" name="ClaCli" id="ClaCli" value="<?php echo $row['ClaCli'];?>" />
		<input type="hidden" name="ClaSoc" id="ClaSoc" value="<?php echo $row['ClaSoc'];?>" />
		<input type="hidden" name="ClaDis" id="ClaDis" value="<?php echo $row['ClaDis'];?>" />
		<input type="hidden" name="ClaOtr" id="ClaOtr" value="<?php echo $row['ClaOtr'];?>" />
		<input type="hidden" name="Bloqueado" id="Bloqueado" value="<?php echo $row['Bloqueado'];?>" />
		<input type="hidden" name="esReceptorDTE" id="esReceptorDTE" value="<?php echo $row['esReceptorDTE'];?>" />
		<input type="hidden" name="BloqueadoPro" id="BloqueadoPro" value="<?php echo $row['BloqueadoPro'];?>" />
		<input type="hidden" name="Usuario" id="Usuario" value="<?php echo $row['Usuario'];?>" />
		<input type="hidden" name="Proceso" id="Proceso" value="<?php echo $row['Proceso'];?>" />
		<input type="hidden" name="ClaPro" id="ClaPro" value="<?php echo $row['ClaPro'];?>" />
		<input type="hidden" name="accion" id="accion" value="<?php echo $accion;?>" />
		<input type="hidden" name="seccion" id="seccion" value="add_auxiliar" />
        <input type="hidden" name="codigo" id="codigo" value="" />
		<input type="button" id="enviar" class="float_right margin_top_10" value="Guardar Datos" />
		<input type="button" id="cancelar" class="float_right margin_top_10 margin_right_5" value="Cancelar" />
	</div>
</div>
</form>

<script type="text/javascript">
<?php
if(isset($_GET['id']))
	{
	echo '$(document).ready(function() {
	cargar_provincias(\''.$row['Region'].'\',\''.$row['ProvAux'].'\',\''.$row['CiuAux'].'\',\''.$row['ComAux'].'\');
	cargar_ciudades(\''.$row['Region'].'\',\''.$row['ProvAux'].'\',\''.$row['CiuAux'].'\',\''.$row['ComAux'].'\');
	cargar_comunas(\''.$row['Region'].'\',\''.$row['ProvAux'].'\',\''.$row['CiuAux'].'\',\''.$row['ComAux'].'\');
	});';
	}
?>
$(document).on('click', 'form#add_auxiliar input#enviar', function()
	{
	var rut				= $('#rut').val();
	var nombre 			= $('#nombre').val();
	var cod_giro_sii 	= $('#cod_giro_sii').val();
	var direccion_calle = $('#direccion_calle').val();
	var direccion_num 	= $('#direccion_num').val();
	var dir_depto 		= $('#dir_depto').val();
	var region 			= $('#region').val();
	var provincia 		= $('#provincia').val();
	var ciudad 			= $('#ciudad').val();
	var comuna 			= $('#comuna').val();
	var telefono_01 	= $('#telefono_01').val();	
	var telefono_02 	= $('#telefono_02').val();
	var correo 			= $('#correo').val();
	var accion 			= $('#accion').val();

	if(accion == 'add_auxiliar')
		{
		if($.trim(rut) == '')
			{
			showMessage('div#mini-notification', '#rut', 'error', 'Ingrese el RUT del cliente');
			ir_elemento('header');
			return false;
			}
		if($.trim(rut) != '')
			{
			if(!$.validateRut(rut)) 
				{
				showMessage('div#mini-notification', '#rut', 'error', 'El RUT ingresado no es v&aacute;lido');
				ir_elemento('header');
				return false;
				}
			}
		$('#rut').val($.formatRut(rut));
		rut = $('#rut').val();
		}
	if($.trim(nombre) == '')
		{
		showMessage('div#mini-notification', '#nombre', 'error', 'Ingrese el nombre / raz&oacute;n social del cliente');
		ir_elemento('header');
		return false;
		}
	if($.trim(cod_giro_sii) == '')
		{
		showMessage('div#mini-notification', '#cod_giro_sii', 'error', 'Seleccione el c&oacute;digo de giro SII');
		ir_elemento('header');
		return false;
		}
	if($.trim(direccion_calle) == '')
		{
		showMessage('div#mini-notification', '#direccion_calle', 'error', 'Ingrese la direcci&oacute;n del cliente (Nombre calle)');
		ir_elemento('header');
		return false;
		}
	if($.trim(direccion_num) == '')
		{
		showMessage('div#mini-notification', '#direccion_num', 'error', 'Ingrese la direcci&oacute;n del cliente (N&uacute;mero)');
		ir_elemento('header');
		return false;
		}
	if($.trim(region) == '')
		{
		showMessage('div#mini-notification', '#region', 'error', 'Debe Seleccionar una regi&oacute;n');
		ir_elemento('header');
		return false;
		}
	if($.trim(provincia) == '')
		{
		showMessage('div#mini-notification', '#provincia', 'error', 'Debe seleccionar una provincia');
		ir_elemento('header');
		return false;
		}
	if($.trim(ciudad) == '')
		{
		showMessage('div#mini-notification', '#ciudad', 'error', 'Debe Seleccionar una ciudad');
		ir_elemento('header');
		return false;
		}
	if($.trim(comuna) == '')
		{
		showMessage('div#mini-notification', '#comuna', 'error', 'Debe Seleccionar una comuna');
		ir_elemento('header');
		return false;
		}
	if($.trim(telefono_01) == '')
		{
		showMessage('div#mini-notification', '#telefono_01', 'error', 'Ingrese al menos un n&uacute;mero telef&oacute;nico del cliente');
		ir_elemento('header');
		return false;
		}
	if($.trim(correo) == '')
		{
		showMessage('div#mini-notification', '#correo', 'error', 'Ingrese correo electr&oacute;nico del cliente');
		ir_elemento('header');
		return false;
		}
	if($.trim(correo) != '')
		{
		if(!correo.match(/^[a-zA-Z0-9\._-]+@[a-zA-Z0-9-]{2,}[.][a-zA-Z]{2,4}$/)) 
			{
			showMessage('div#mini-notification', '#correo', 'error', 'El correo electr&oacute;nico no es v&aacute;lido');
			ir_elemento('header');
			return false;
			}	
		}

	showMessage('div#mini-notification', '', 'loading', 'Guardando datos, Espere...');
	$('#preloader').fadeIn('slow');
	enviarFormDeshabilitar();

	var parametros = $('form#add_auxiliar').serialize();
	$.ajax({
		data:  parametros,
		url:   'ajax.process.php',
		type:  'post',					
		success:  function(response)
			{
			var json = eval('(' + response + ')');
			if(json.tipo == 'OK')
				{
				showMessage('div#mini-notification', '', 'ok', json.mensaje);
				$('div#mini-notification').css('display', 'block');
				setTimeout(function(){ parent.jQuery.fancybox.close(); }, 4000);
				}
			else
				{
				showMessage('div#mini-notification', json.campo, 'error', json.mensaje);
				$('#preloader').fadeOut('slow', function() { enviarFormHabilitar(); });
				}
			}
		});
	return false;
	});

/* Boton Cancelar... */
$(document).on('click', 'form#add_auxiliar input#cancelar', function()
	{
	if(confirm('Usted est\u00e1 a punto de cancelar esta acci\u00f3n (La informaci\u00f3n del formulario podr\u00eda perderse)\n\nDesea continuar y salir de esta p\u00e1gina...?') == true)
		{
		parent.jQuery.fancybox.close();
		}
	});
</script>
<?php
require('footer.php');
?>
