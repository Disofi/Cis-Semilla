<?php
include('includes/funciones.php');
include('includes/funciones_clientes.php');
?>

<div class="titulo_pagina">
	<h2 class="col-md-10">Clientes &gt; Ver Listado</h2>
	<div class="col-md-2">&nbsp;</div>
</div>

<div class="table-responsive">
	<?php echo clientesListar();?>
</div>

<script type="text/javascript">
function ir_listado(obj)
	{
	var valor = $(obj).val();
	var url = 'index.php?mod=clientes';
	if(valor == 'user' || valor == 'all')
		{
		url += '&list=' + valor;
		}
	$(location).attr('href', url);
	}

function verificarCredito(cod_cliente, id_fila)
	{
	var hrefAttr = $('table.registros tr#' + id_fila + ' td div.acciones a.btnVerificarNota').attr('href');
	$('table.registros tr#' + id_fila + ' td div.acciones a.btnVerificarNota').attr('href', '#');
	$('table.registros tr#' + id_fila + ' td div.acciones a.btnVerificarNota').removeClass('guia').addClass('loading');
	$.post('ajax.process.clientes.php',
		{
		'cod_cliente'	: cod_cliente,
		'seccion'	: 'clientes',
		'accion'	: 'clientes_verificar_credito'
		},
	function(credito)
		{
		credito = parseInt(credito);
		if(credito > 0) { $(location).attr('href', 'index.php?mod=clientes-notapedido&cliente=' + cod_cliente); }
		else
			{
			$.post('ajax.process.clientes.php', 
				{
				'cod_cliente' : cod_cliente,
				'seccion'	: 'clientes',
				'accion'	: 'clientes_seleccionar'}, function(dataCliente)
					{
					var json = eval('(' + dataCliente + ')');
					if ($.trim(json.NomCliente) != '')
						{
						$('table.registros tr#' + id_fila + ' td div.acciones a.btnVerificarNota').attr('href', hrefAttr);
						$('table.registros tr#' + id_fila + ' td div.acciones a.btnVerificarNota').removeClass('loading').addClass('guia');
						$('input[type="search"]').focus();
						alert('AVISO DEL SISTEMA:\n\nEl cliente ' + json.NomCliente + ' no dispone de cr\u00E9dito para poder generar una nueva nota de pedido.');
						}
					}
				);
			return false;
			}
		});
	}
</script>