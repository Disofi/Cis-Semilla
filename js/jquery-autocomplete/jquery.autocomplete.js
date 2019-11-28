$(function(){
	$('#codigo_0').autocomplete({
		source: 'ajax.process.despachos.php',
		minLength: 2,
		select: function(event, ui){
			var id = ui.item.id;
			var str = ui.item.value;
			
			
			alert(str);
        },
		
		html: true, // optional (jquery.ui.autocomplete.html.js required)
		
		// optional (if other layers overlap autocomplete list)
        open: function(event, ui){
            $('.ui-autocomplete').css('z-index', 1000);
		}
    });
 
});