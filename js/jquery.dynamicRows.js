

function addDynamicRow(){

/* Clonar ultima exactamente fila tal cual... */
var tableBody = $('#DynamicRowsTable').find('tbody');
var trLast = tableBody.find('tr:last');
var trNew = trLast.clone();
trLast.after(trNew);

/* Renombrar id de la fila nueva... */
var trNewId = 'fila_' + $('#numRows').val();
trLast = tableBody.find('tr:last');
trLast.attr('id', trNewId);

/* Añadir boton para eliminar fila... */
$('#' + trNewId + ' td div.acciones').html('<a href="javascript:deleteDynamicRow(\'#' + trNewId + '\');" class="delete icon">Eliminar</a>');


/* Resetear campos de formulario... */
$('#' + trNewId + ' td input[type="text"], #' + trNewId + ' td input[type="email"]').val('');				
$('#' + trNewId + ' td input[type="text"], #' + trNewId + ' td input[type="email"]').removeAttr('value');
$('#' + trNewId + ' td input[type="text"], #' + trNewId + ' td input[type="email"]').attr('value', '');

/* Actualizar contador de filas... */
var num_filas = parseInt($('#numRows').val());
$('#numRows').val(num_filas + 1);
countDynamicRows();	
}







function deleteDynamicRow(RowId){
$('table#DynamicRowsTable tbody tr' + RowId).remove();
countDynamicRows();
}






function countDynamicRows(){
var n = 1;
	$('table#DynamicRowsTable tbody tr td.numItem').each(function(){
		$(this).html(n);
		n++;
	})
}













