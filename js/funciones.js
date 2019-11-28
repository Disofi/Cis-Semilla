/* Imprimir mensajes del formulario según su tipo... */
function showMessage(element, inputFocus, msgClass, msgText)
	{
	$(element).removeClass('ok');
	$(element).removeClass('alert');
	$(element).removeClass('error');
	$(element).removeClass('loading');
	$(element + ' p').html('');
	$(element + ' p').removeClass('ok');
	$(element + ' p').removeClass('alert');
	$(element + ' p').removeClass('error');
	$(element + ' p').removeClass('loading');
	$(element + ' p').addClass(msgClass);
	$(element).addClass(msgClass);
	var parametros = '';
	if($.trim(inputFocus) != '')
		{
		var primeraLetra = inputFocus.toString();
		primeraLetra = primeraLetra.substring(0, 1);
		if(primeraLetra == '#')
			{
			$(inputFocus).focus();
			$(inputFocus).select();
			}
		if(primeraLetra == '{')
			{
			parametros = inputFocus;
			}
		}
	$(element + ' p').html(msgText);
	$(element).miniNotification(parametros);
	}

/* Close thePopUp */
function CloseTPU()
	{
	document.getElementById('thepopup').style.display=none;
	}

/* Ocultar mensaje del formulario... */
function hide_message_div() { setTimeout(function(){$('div.message-div').fadeOut(2000);},6000); }

/* Efecto ancla animada hacia un elemento X... */
function ir_elemento(elemento)
	{
	$('html,body').stop().animate({ scrollTop: jQuery(elemento).offset().top }, 500);
	}

/* Bloquear y desbloquear botón de envío del formulario... */
function enviarFormDeshabilitar() { 
	$('input#enviar').addClass('enviando');
	$('input#cancelar').addClass('cancelar_blocked');
	$('input#enviar, input#cancelar').attr('disabled', 'disabled');
	$('input#enviar').attr('value', 'Enviando datos...');
	}
function enviarFormHabilitar() {
	$('input#enviar').removeClass('enviando');
	$('input#cancelar').removeClass('cancelar_blocked');
	$('input#enviar, input#cancelar').removeAttr('disabled');	
	$('input#enviar').attr('value', 'Guardar Datos');
	}
function EnviarHabilita() 
	{
	$('input#enviar').removeClass('enviando');
	$('input#cancelar').removeClass('cancelar_blocked');
	$('input#enviar, input#cancelar').removeAttr('disabled');	
	$('input#enviar').attr('value', 'Seleccione');
	}
function volver(url) 
	{
	window.location.href = url; 
	}
function atras() 
	{ 
	window.history.back(); 
	}

function DelDoc(codaux,ttdcod,numdoc,movnum,tipo) 
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 el elemento seleccionado.\u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var accion = 'deldoc';
		if (tipo=='C') 		{ var url = 'compras_sel'; }
		else if (tipo=='V') { var url = 'ventas_sel';  }
		else 				{ var url = 'honoras_sel'; }

		var parametros = 
			{
			'codaux'  : codaux,
			'ttdcod'  : ttdcod,
			'numdoc'  : numdoc,
			'movnum'  : movnum,
			'accion'  : accion,
			'seccion' : 'seccion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod='+url);}, 2000);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}

/* ELIMINA FILA MANTENEDOR HONORARIOS */
function DelHon(emp,tdoc,ctapas,ctaret) 
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 el elemento seleccionado.\u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var url = 'honoras_ctas';
		var parametros = 
			{
			'emp'     : emp,
			'tdoc'    : tdoc,
			'ctapas'  : ctapas,
			'ctaret'  : ctaret,
			'accion'  : 'delhon',
			'seccion' : 'seccion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod='+url);}, 2000);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}


function EdiDoc(codaux,ttdcod,numdoc,movnum,tipo)
	{
	var mensaje = 'Estimado Usuario: \n procedera a modificar los datos del presente documento, Desea continuar?';
	if (confirm(mensaje))
		{
		if (tipo=='C')
			{
			setTimeout(function(){ $(location).attr('href', 'index.php?mod=compras_ing&a='+codaux+'&b='+ttdcod+'&c='+numdoc+'&d='+movnum);}, 1000);
			}
		else if (tipo=='V')
			{
			setTimeout(function(){ $(location).attr('href', 'index.php?mod=ventas_ing&a='+codaux+'&b='+ttdcod+'&c='+numdoc+'&d='+movnum);}, 1000);
			}
		else
			{
			setTimeout(function(){ $(location).attr('href', 'index.php?mod=honoras_ing&a='+codaux+'&b='+ttdcod+'&c='+numdoc+'&d='+movnum);}, 1000);
			}
		}
	}






/* Permitir solamente caracteres numericos (EJ: <input type="text" name="numeros" onkeypress="return allowOnlyNumbers(event);">) */
function allowOnlyNumbers(e, obj)
	{
	var charCode = (e.which) ? e.which : e.keyCode;
	if(charCode > 31 && (charCode < 48 || charCode > 57))
		{
		$(obj).val('0');
		$(obj).focus();
		$(obj).select();
		return false;
		}
	if(charCode == 8)
		{
		if($(obj).val().length == 0)
			{
			$(obj).val('0');
			$(obj).focus();
			$(obj).select();
			return false;
			}
		}
	return true;
	}

function isAlphaNumeric(val)
	{
	if (val.match(/^[a-zA-Z0-9]+$/))
		{
		return true;
		}
	else
		{
		return false;
		}
	} 

/* GENERALES */
$(document).ready(function(){
	$('#dataTable').DataTable({
		language: { 'url': 'js/jquery-datatables/languages/es.json' },
		aoColumnDefs: [{ 'bSortable': false, 'aTargets': ['no-sortable'] }],
		"pageLength": 50
		});
	});
	
	// $(document).ready(function(){
	// $('#distribucion').DataTable({
		// language: { 'url': 'js/jquery-datatables/languages/es.json' },
		// aoColumnDefs: [{ 'bSortable': false, 'aTargets': ['no-sortable'] }],
		// pageLength: 50
		// });
	// });

$(document).ready(function()
	{
	$('a.tooltip_a').tooltip({
		position:{
			my: 'center bottom-20',
			at: 'center top',
			using: function(position, feedback){
				$( this ).css(position);
				$('<div>')
				.addClass('arrow')
				.addClass(feedback.vertical)
				.addClass(feedback.horizontal)
				.appendTo(this);
				}
			}
		});
	});

$(document).ready(function()
	{
	$('a.fancyboxBasic').fancybox({
		type: 'iframe',
		autoSize : false,
		beforeLoad : function(){         
			this.width  = parseInt(this.element.data('fancybox-width'));
			this.height = parseInt(this.element.data('fancybox-height'));
			this.modal = this.element.data('fancybox-modal');
			},
		transitionIn	: 'elastic',
		transitionOut	: 'elastic',
		speedIn			: 600, 
		speedOut		: 400, 
		overlayShow		: false,
		helpers			: {
			'title' : null
			}
		});
	$('a.fancyboxModal').fancybox({
		modal: true,
		type: 'iframe',
		autoSize : false,
		beforeLoad : function(){         
			this.width  = parseInt(this.element.data('fancybox-width'));
			this.height = parseInt(this.element.data('fancybox-height'));
			this.modal = this.element.data('fancybox-modal');
			},
		transitionIn	: 'elastic',
		transitionOut	: 'elastic',
		speedIn			: 600, 
		speedOut		: 400, 
		overlayShow		: false,
		helpers			: {
			'title' : null
			}
		});
	});
	
function numeros(donde,caracter)
	{
	pat = /[\*,\+,\(,\),\?,\,$,\[,\],\^]/;
	valor = donde.value;
	largo = valor.length;
	crtr = true;
	if(isNaN(caracter) || pat.test(caracter) == true)
		{
		if (pat.test(caracter)==true)
			{ 
			caracter = " \ "  + caracter;
			}
		carcter = new RegExp(caracter,"g");
		valor = valor.replace(carcter,"");
		donde.value = valor;
		crtr = false;
		}
	else
		{
		var nums = new Array();
		cont = 0;
		for(m=0;m<largo;m++)
			{
			if(valor.charAt(m) == "." || valor.charAt(m) == " ")
				{continue;}
			else
				{
				nums[cont] = valor.charAt(m);
				cont++;
				}
			}
		}
	var cad1="",cad2="",tres=0;
	if(largo > 3 && crtr == true)
		{
		for (k=nums.length-1;k>=0;k--)
			{
			cad1 = nums[k];
			cad2 = cad1 + cad2;
			tres++;
			if((tres%3) == 0)
				{
				if(k!=0)
					{
					cad2 = "." + cad2;
					}
				}
			}
		donde.value = cad2;
		}
	}

/* MANTENEDORES */
function buscarRut()
	{
	var rut = $.trim($('#rut').val());
	rut = rut.replace(/[^kK0-9]+/g, '');
	rut = rut.substr(0, rut.length-1);
	$.getJSON('inc/rut.php?ruta=' + rut,
	function(lea){ if(lea == 1) {
		var msg = confirm('El Rut ya se encuentra en el sistema...');
		if(msg) { parent.jQuery.fancybox.close(); }
		else	{ parent.jQuery.fancybox.close(); }
		}});
	$('#codigo').val(rut);
	}

/* MANTEENDOR DE AUXILIAR */
function cargar_provincias(region, provincia, ciudad, comuna)
	{
	var parametros = 
		{
		'tipo' : 'PROVINCIAS',
		'region' : region,
		'provincia' : provincia,
		'ciudad' : ciudad,
		'comuna' : comuna,
		'seccion' : 'add-auxiliar'
		};
	$('select#provincia, select#ciudad, select#comuna').html('<option value=""></option>');
	$.post('ajax.process.php', parametros, function(data)
		{
		$('select#provincia').html(data);
		$('select#provincia').attr('onchange', 'cargar_ciudades($(\'select#region\').val(), \'\', \'\', \'\');');
		});
	}
/* MANTEENDOR DE AUXILIAR */
function cargar_ciudades(region, provincia, ciudad, comuna)
	{
	var parametros = 
		{
		'tipo' : 'CIUDADES',
		'region' : region,
		'provincia' : provincia,
		'ciudad' : ciudad,
		'comuna' : comuna,
		'seccion' : 'add-auxiliar'
		};
	$('select#ciudad, select#comuna').html('<option value=""></option>');
	$.post('ajax.process.php', parametros, function(data)
		{
		$('select#ciudad').html(data);
		$('select#ciudad').attr('onchange', 'cargar_comunas($(\'select#region\').val(), \'\', \'\', \'\');');
		});
	}
/* MANTEENDOR DE AUXILIAR */
function cargar_comunas(region, provincia, ciudad, comuna)
	{
	var parametros = 
		{
		'tipo' : 'COMUNAS',
		'region' : region,
		'provincia' : provincia,
		'ciudad' : ciudad,
		'comuna' : comuna,
		'seccion' : 'add-auxiliar'
		};
	$('select#comuna').html('<option value=""></option>');
	$.post('ajax.process.php', parametros, function(data) { $('select#comuna').html(data); });
	}
/* FIN MANTENEDORES */

/* IFRAMES */
$(document).ready(function() {
	$(".popup").fancybox({
		maxWidth	: 800,
		maxHeight	: 600,
		fitToView	: false,
		width		: '70%',
		height		: '70%',
		autoSize	: false,
		closeClick	: false,
		openEffect	: 'none',
		closeEffect	: 'none'
	});
});

/* Para Calendario */
$(document).ready(function()
	{
	$('input.datePicker').datepicker(
		{
		changeMonth: true,
		changeYear: true,
		firstDay: 1,
		});
	});

function CargaPCCMON()
	{
	var tipdoc = $('#tipdoc').val();
	if ($.trim(tipdoc) == 00) 
		{ 
		$('#pccmon').val('');
		}
	else 
		{
		var x = tipdoc.split('[SEP]');
		var cm = x[2];
		$('#pccmon').val(cm);
		}
	}

function CargaTdoc()
	{
	var tipdoc = $('#tipdoc').val();
	var ax = tipdoc.split('[||]');
	tdoc   = ax[0];
	retn   = ax[1];
	ctapas = ax[2];
	ctaret = ax[3];
	pccmon = ax[4];
	if ($.trim(tipdoc) == 00) 
		{ 
		$('#pccmon').val('');
		}
	else 
		{
		$('#pccmon').val(pccmon);
		$('#retenc').val(retn);
		//$('#codcta3').val(ctapas);
		//if (retn=='S')
		//	{
		//	$('#codcta2').val(ctaret);	
		//	}
		}
	}

function AsigIVA(i)
	{
	Suma(i);
	var ctaiva = $('#ctaiva').val();
	var neto   = $('#vtot1').val();
	neto = neto.split('.').join('');
	var iva    = Math.round((parseFloat(neto)*19)/100);
	var ctacc = '00';
	var ctadg = '00';
	var n = 0; 
	$('input.montox'+i).each(function(){
		$(this).html(n);
		n++;
		});
	while ( n >= 0)
		{
		deleteDR(i,'#fila'+i+'_'+n);
		n--;
		}
	alf(':last',ctaiva,iva,ctacc,ctadg,i);
	Suma(i);
	SumaAll();
	}

function CargaEQUIV()
	{
	var a = $('#pccmon').val();
	var b = $('#fecemi').val();
	$.getJSON("inc/equiv.php?a="+a+"&b="+b,
	function(lea)
		{
		if (($.trim(lea) == 0) || ($.trim(lea) == ''))
			{
			lea = 1;
			}
		$('#equiva').val(lea);
		});
	}

/* ACTIVA/DESACTIVA CAMPOS Y CALCULOS */
function Retencion()
	{
	var ret = $('#retenc').val();
	if (ret=='N')
		{
		document.getElementById('retoc').style.display='none';
		}
	else 
		{
		document.getElementById('retoc').style.display='block';
		}
	}

/* VALIDA DOCUMENTO ACTUAL */	
function ValidaDocumento()
	{
	var numdoc = $('#numdoc').val();
	var codaux = $('#codaux').val();
	var tipdoc = $('#tipdoc').val();
	var x = tipdoc.split('[SEP]');
	var tp = x[0];
	var ct = x[1];
	var cm = x[2];
	var cc = x[3];

	$.getJSON("inc/disp.php?a="+numdoc+"&b="+codaux+"&c="+tp+"",
	function(lea)
		{
		if(lea==1) 
			{ 
			showMessage('div#mini-notification', '#numdoc', 'error', 'El N&uacute;mero de Documento ya fue ingresado al sistema para este Auxiliar.'); 
            $('#numdoc').val('');
			}
		});	
	var cdn = tp + '-' + numdoc + '-' + codaux;
	cdn = cdn.substring(0,20);
	if (cc=='N') { document.getElementById('cencos').disabled=true; }

	$('#descri').val(cdn);
	$('#ctatdoc').val(ct);
	document.getElementById('botonPopUp').disabled=true; 
	}

/* VALIDA DOCUMENTO HONORRIOS */
function ValDoc()
	{
	var numdoc = $('#numdoc').val();
	var codaux = $('#codaux').val();
	var tipdoc = $('#tipdoc').val();
	var x = tipdoc.split('[||]').join('');
	var tp = x[0];
	var ct = x[1];
	var cm = x[2];
	var cc = x[3];

	$.getJSON("inc/disp.php?a="+numdoc+"&b="+codaux+"&c="+tp+"",
	function(lea)
		{
		if(lea==1) 
			{ 
			showMessage('div#mini-notification', '#numdoc', 'error', 'El N&uacute;mero de Documento ya fue ingresado al sistema para este Auxiliar.'); 
            $('#numdoc').val('');
			}
		});	
	var cdn = tp + '-' + numdoc + '-' + codaux;
	cdn = cdn.substring(0,20);
	if (cc=='N') { document.getElementById('cencos').disabled=true; }

	$('#descri').val(cdn);
	$('#ctatdoc').val(ct);
	document.getElementById('botonPopUp').disabled=true; 
	}



/* Consulta si es Proveedor */
function ConsultaPro()
	{
	var CPro = $('#clapro').val();
	if (CPro == 'N') 
		{ 
		var resp = confirm("Estimado Usuario, usted ha seleccionado un auxiliar que no es proveedor, ¿Desea clasificarlo también como proveedor?"); 
		if (resp) 
			{ 
			$('#clapro').val('S'); 
			} 
		else 
			{
			$('#auxili').val('');
			$('#codaux').val('');
			$('#clapro').val('');
			$('#auxili').focus();
			}
		} 
	}

/* Activa/Desactiva Boton Detalle Libro */
function ActivaDL() 
	{ 
	var valor = $('#montot').val(); 
	if ((valor == '') || (valor == 0 )) 
		{ 
		document.getElementById('botonPopUp').disabled=true; 
		} 
	else 
		{ 
		document.getElementById('botonPopUp').disabled=false; 
		} 
	}
	
function IVA(y,z)
	{
	var campo = 'campo'+y;
	var newcampo = 'campo'+z;
	var valor = $('#'+campo+'').val();
	valor = valor.split('.').join('');
	var iva = parseFloat(valor)*19/100;
	iva = Math.round(iva);
	iva = numeropts(iva,'0',',','.');
	$('#monto'+z).val(iva);
	Suma(z);
	SumaAll();
	}

/* Calcula el valor de la retencion, solo si este lleva */
function CalRet()
	{
	var ret = $('#retenc').val();
	var mtot = $('#montot').val();
	mtot = mtot.split('.').join('');

	var tipdoc = $('#tipdoc').val();
	var ax = tipdoc.split('[||]');
	var ctapas = ax[2];
	var ctaret = ax[3];

	if (ret=='S')
		{
		var retn = Math.round(parseFloat((mtot*10)/100));
		var mliq = Math.round(parseFloat(mtot-retn));
		
		$('#honos').val(mtot);
		$('#reten').val(retn);
		$('#gasto').val(mliq);

		$('#codcta2').val('');
		alf(':last',ctaret,retn,'','',2);
		Suma(2);

		$('#codcta3').val('');
		alf(':last',ctapas,mliq,'','',3);
		Suma(3);
		SumaAll();
 		}
 	else
 		{
		$('#monhonos').val(mtot);
		$('#mongasto').val(mtot);

		$('#codcta3').val('');
		alf(':last',ctapas,mtot,'','',3);
		Suma(3);
		SumaAll();
 		}
	}
	
function verificar(i)
	{
	if (i==1)
		{
		var vtot  = $('#vtot1').val();
		var honos = $('#honos').val();
		
		if (vtot!=honos) 
			{
			showMessage('div#mini-notification', '#vtot1', 'error', 'Se encontraron diferencias entre el detalle de documentos y el monto de honorarios');  
			return false;
			} 	
		else { return true; }
		}
	if (i==2)
		{
		var vtot  = $('#vtot2').val();
		var reten = $('#reten').val();
		
		if (vtot!=reten) 
			{
			showMessage('div#mini-notification', '#vtot2', 'error', 'Se encontraron diferencias entre el detalle de documentos y el monto de retencion');
			return false;  
			}
		else { return true; }
		}
	if (i==3)
		{
		var vtot  = $('#vtot3').val();
		var gasto = $('#gasto').val();
		
		if (vtot!=gasto) 
			{
			showMessage('div#mini-notification', '#vtot1', 'error', 'Se encontraron diferencias entre el detalle de documentos y el monto liquido');  
			return false;
			}
		else { return true; }
		}
	}

function SelCC(valor, id)
	{
	var sel = $('#cencos'+id).val();
	if (sel == 00) { showMessage('div#mini-notification', '', 'error', 'Estimado Usuario, Debe seleccionar un CENTRO DE COSTO para la cuenta'); }
	}

/* FUNCIONES PARA OCULTAR/MOSTAR SUBDETALLE DE LIBRO */
function opu1() { document.getElementById('tbpu1').style.display='block'; cpu2();cpu3();cpu4();cpu5();cpu6();cpu7();cpu8();cpu9(); } 
	function cpu1()	{ document.getElementById('tbpu1').style.display='none'; document.getElementById('bpu1').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu2() { document.getElementById('tbpu2').style.display='block'; cpu1();cpu3();cpu4();cpu5();cpu6();cpu7();cpu8();cpu9(); } 
	function cpu2()	{ document.getElementById('tbpu2').style.display='none'; document.getElementById('bpu2').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu3() { document.getElementById('tbpu3').style.display='block'; cpu2();cpu1();cpu4();cpu5();cpu6();cpu7();cpu8();cpu9(); } 
	function cpu3()	{ document.getElementById('tbpu3').style.display='none'; document.getElementById('bpu3').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu4() { document.getElementById('tbpu4').style.display='block'; cpu2();cpu3();cpu1();cpu5();cpu6();cpu7();cpu8();cpu9(); } 
	function cpu4()	{ document.getElementById('tbpu4').style.display='none'; document.getElementById('bpu4').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu5() { document.getElementById('tbpu5').style.display='block'; cpu2();cpu3();cpu4();cpu1();cpu6();cpu7();cpu8();cpu9(); } 
	function cpu5()	{ document.getElementById('tbpu5').style.display='none'; document.getElementById('bpu5').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu6() { document.getElementById('tbpu6').style.display='block'; cpu2();cpu3();cpu4();cpu5();cpu1();cpu7();cpu8();cpu9(); } 
	function cpu6()	{ document.getElementById('tbpu6').style.display='none'; document.getElementById('bpu6').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu7() { document.getElementById('tbpu7').style.display='block'; cpu2();cpu3();cpu4();cpu5();cpu6();cpu1();cpu8();cpu9(); } 
	function cpu7()	{ document.getElementById('tbpu7').style.display='none'; document.getElementById('bpu7').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu8() { document.getElementById('tbpu8').style.display='block'; cpu2();cpu3();cpu4();cpu5();cpu6();cpu7();cpu1();cpu9(); } 
	function cpu8()	{ document.getElementById('tbpu8').style.display='none'; document.getElementById('bpu8').style.display='none'; document.getElementById('BVol').style.display='none'; }
function opu9() { document.getElementById('tbpu9').style.display='block'; cpu2();cpu3();cpu4();cpu5();cpu6();cpu7();cpu8();cpu1(); } 
	function cpu9()	{ document.getElementById('tbpu9').style.display='none'; document.getElementById('bpu9').style.display='none'; document.getElementById('BVol').style.display='none'; }

function ocultar() 
	{
	document.getElementById('bpu1').style.display='none';
	document.getElementById('bpu2').style.display='none';
	document.getElementById('bpu3').style.display='none';
	document.getElementById('bpu4').style.display='none';
	document.getElementById('bpu5').style.display='none';
	document.getElementById('bpu6').style.display='none';
	document.getElementById('bpu7').style.display='none';
	document.getElementById('bpu8').style.display='none';
	document.getElementById('bpu9').style.display='none';
	document.getElementById('BVol').style.display='none';
	}
function mostrar() 
	{
	document.getElementById('BVol').style.display='block';
	document.getElementById('bpu1').style.display='block';
	document.getElementById('bpu2').style.display='block';
	document.getElementById('bpu3').style.display='block';
	document.getElementById('bpu4').style.display='block';
	document.getElementById('bpu5').style.display='block';
	document.getElementById('bpu6').style.display='block';
	document.getElementById('bpu7').style.display='block';
	document.getElementById('bpu8').style.display='block';
	document.getElementById('bpu9').style.display='block';
	}

/* FUNCIONES DE AGREGAR FILAS (variable) */
function addfl(i)
	{ 
	var codigo		= $('#codcta'+i).val(); 
	var monto		= $('#monto'+i).val(); 
	var UsaCC		= $('#cta_cc'+i).val();
	var strcencos	= $('#cencos'+i).val();
	var UsaDetG		= $('#cta_dg'+i).val();
	var strDetG		= $('#detgas'+i).val();

	var ctacc = $('#cencos'+i).val();
	var ctadg = $('#detgas'+i).val();

	var mensaje ='Debe Ingresar : ';

	if ($.trim(codigo)=='')				{ mensaje = mensaje + '- Cuenta '; }
	if ($.trim(monto)=='')				{ mensaje = mensaje + '- Monto '; }
	if ($.trim(UsaCC)=='S')				{ if ($.trim(strcencos)=='00') { mensaje = mensaje + '- Centro de Costo '; } }
	if ($.trim(UsaDetG)=='S')			{ if ($.trim(strDetG)=='00')   { mensaje = mensaje + '- Detalle de Gasto ';} }
	if ($.trim(mensaje).length > 16) 	{ showMessage('div#mini-notification','','error',mensaje); } 
	else 
		{
		alf(':last',codigo,monto,ctacc,ctadg,i);
		$('#codcta'+i).val(''); 
		$('#monto'+i).val(''); 
		$('#cta_cc'+i).val(''); 
		$('#cta_dg'+i).val(''); 
		$('#cencos'+i).val('00'); 
		$('#detgas'+i).val('00');
		document.getElementById('cencos'+i).disabled=true; 
		document.getElementById('detgas'+i).disabled=true; 
		//if($.trim(codigo)!='')
		//	{
			addfila(i);
			Suma(i);
			SumaAll();
		//	} 
		} 
	}

function alf(fila,codigo,monto,ctacc,ctadg,i)
	{
	var ctable = $('table#DRT'+i+' tr' + fila + ' td input.ctable'+i).val();
	if ($.trim(ctable)!='')
		{
		addfila(i);
		}
	$('table#DRT'+i+' tr' + fila + ' td input.ctable'+i).val(codigo);
	$('table#DRT'+i+' tr' + fila + ' td input.montox'+i).val(monto);
	$('table#DRT'+i+' tr' + fila + ' td input.ctaccx'+i).val(ctacc);
	$('table#DRT'+i+' tr' + fila + ' td input.ctadgx'+i).val(ctadg);
	}

/* Busca Cuentas */
$(document).ready(function()
	{
	$('input#cuenta').autocomplete(
		{
		source: 'ajax.cuentas.php',
		minLength: 2,
		select: function(event, ui)
			{
			var codigo = ui.item.codigo;
			var nombre = ui.item.nombre;
			var codnom = ui.item.value; 
			$('#cuenta').val(codigo); 
			this.value = codigo; 
			return false; 
			},
		html: false, 
		open: function(event, ui)
			{
			$('.ui-autocomplete').css('z-index', 1000);
			}
		});
	});	


/* Buscar Auxiliar */
$(document).ready(function(){$('input#auxili').autocomplete({	source: 'ajax.process.php',	minLength: 2, select: function(event, ui){
	var codigo = ui.item.codigo; var nombre = ui.item.nombre; var clapro = ui.item.clapro; $('input#codaux').val(codigo); $('input#clapro').val(clapro); this.value = nombre; return false; },
	html: false, open: function(event, ui){$('.ui-autocomplete').css('z-index', 1000);}});});	

function autoCompleteAreaNegocio(){	
var parametroRadio = $("input[name='areaDeNegocios']:checked").val();
$(document).ready(
function(){
	//var radioValue = $("input[name='areaDeNegocios']:checked").val();
$('input#dataAreaNegocio').autocomplete(
{	
source: 'ajax.process.php?mod=areaNegocio&condicionProveedor='+parametroRadio,	minLength: 2, select: function(event, ui){
	var codigo = ui.item.codigo;
	var nombre = ui.item.nombre; 
	var clapro = ui.item.clapro; 
	$('input#codauxAreaNegocio').val(codigo); 
	$('input#claproAreaNegocio').val(clapro); 
	this.value = nombre; return false; },
	html: false, 
	open: function(event, ui){$('.ui-autocomplete').css('z-index', 1000);}});});		

}

$(document).ready(function(){$('input#dataProveedor').autocomplete({	
source: 'ajax.process.php?mod=proveedor',	minLength: 2, select: function(event, ui){
	var codigo = ui.item.codigo; 
	var nombre = ui.item.nombre; 
	var clapro = ui.item.clapro; 

	$('input#codProveedor').val(codigo); 
	$('input#claproProveedor').val(clapro); 
	this.value = nombre; 
	return false; 
	},
	html: false, open: function(event, ui){$('.ui-autocomplete').css('z-index', 1000);}});});	

/* Copia Valor de Monto Total a Visual Monto Total en PopUp */
function CopiaMTOT(valor) { $('#vmtot').val(valor); }

function Compara()
	{ 
	var vmtot = $('#vmtot').val();
	if (vmtot > 999) { vmtot = vmtot.split('.').join(''); }
	var svmtot = $('#svmtot').val(); 
	if (svmtot > 999) { svmtot = svmtot.split('.').join(''); }	
	if (svmtot != vmtot)
		{
		showMessage('div#mini-notification', '', 'error','La suma del "DETALLE LIBRO" debe ser igual al valor del campo "MONTO TOTAL", Por favor, revise la información ');
		}
	}

/* Verifica check y actualiza los otros del mismo tipo */
function CheckIdem(valor)
	{
	document.getElementById('check'+valor).checked = true;
	}

/* verifica y consulta segun el mes seleccionado */
function CargaListado()
	{
	var mes = $('#mes').val();
	var ano = $('#ano').val();
	
	if ($.trim(mes) == 00) 
		{ 
		showMessage('div#mini-notification', '#mes', 'error', 'Por favor, debe seleccionar un Mes'); 
		}
	else 
		{
		if ($.trim(ano) == 00) 
			{ 
			showMessage('div#mini-notification', '#ano', 'error', 'Por favor, debe seleccionar un Año');
			}
		else
			{
			document.write("<?=$_SESSION['mes']=?>" + mes);
			document.getElementById('VerListado').style.display='block';
			}
		}
	}

/* Activa / Desactiva Centro Costo y Detalle Gastos */	
function ACCDG(i)
	{ 
	var cta_cc=$('#cta_cc'+i).val(); 
	var cta_dg=$('#cta_dg'+i).val(); 
	if(cta_cc=='S')
		{ document.getElementById('cencos'+i).disabled=false; }
	else
		{ document.getElementById('cencos'+i).disabled=true; } 
	if(cta_dg=='S')
		{ document.getElementById('detgas'+i).disabled=false; }
	else
		{ document.getElementById('detgas'+i).disabled=true; }
	}

/* CARGA Campo cc [CentroCosto] en Pagos_ing2.php */
function ActCC()
	{
	var x   = document.getElementById('forpagos').value;
	var y   = x.split('[||]');
	var cd  = y[0]; // Código de Documento
	var ds  = y[1]; // Descripción
	var cta = y[2]; // Cuenta Contable
	var dp  = y[3]; // Tipo de Pago
	var cc  = y[4]; // Centro de Costo
	var td  = y[5]; // Conciliacion
	
	/* Activa Centro de costo */
	if (cc=='S') { document.getElementById('ccosto').disabled=false; }
	else { document.getElementById('ccosto').disabled=true; }

	/* Si el pago es con Cheque a Fecha, Muestro zona oculta */
	if (cd=='CH') { document.getElementById('oculto').style.display='block'; }
	else { document.getElementById('oculto').style.display='none'; }

	/* Activa Conciliacion si TipoDocumentoConciliacion es Diferente a 00 */
	if (td!='00')
		{
		document.getElementById('tipdoccon').disabled=false;
		if ($.trim(td)!='')
			{
			document.getElementById('areanumdoccb').style.display='block';
			}
		else 
			{
			document.getElementById('areanumdoccb').style.display='none';
			}
		}
	else
		{
		document.getElementById('tipdoccon').disabled=true;
		document.getElementById('areanumdoccb').style.display='none';
		}
	$('#cc').val(cc);
	$('#ctable').val(cta);
	}

/* Cuenta Filas */
function countDR(i)
	{
	var n = 1; 
	$('#DRT'+i+' tbody tr td.NItem'+i).each(function()
		{
		$(this).html(n);
		n++;
		}
	);}	

/* Elimina Filas */
function deleteDR(i,RowId)
	{
	if(RowId=='#fila'+i+'_0')
		{
		var filas=$('#DRT'+i+' >tbody >tr').length; 
		if(filas==1)
			{
			$('table#DRT'+i+' tbody tr input.ctable'+i).val('');
			$('table#DRT'+i+' tbody tr input.montox'+i).val('');
			$('#vtot'+i).val('');
			}
		else
			{
			$('table#DRT'+i+' tbody tr ' + RowId).remove();
			$('#vtot'+i).val('');
			}
		}
	else
		{
		$('table#DRT'+i+' tbody tr' + RowId).remove();
		$('#vtot'+i).val('');
		}
	Suma(i);
	countDR(i);
	}

function addfila(i)
    {
    var tableBody = $('#DRT'+i).find('tbody');
    var trLast = tableBody.find('tr:last');
    var trNew = trLast.clone();
    trLast.after(trNew);
    var trNewId = 'fila'+i+'_' + $('#NRows'+i).val();
    trLast = tableBody.find('tr:last');
    trLast.attr('id', trNewId);
    $('#' + trNewId + ' td.acciones').html('<a href="javascript:deleteDR('+i+',\'#' + trNewId + '\');" class="delete icon">Eliminar</a>');
    $('#' + trNewId + ' td input[type="text"]').val('');
    $('#' + trNewId + ' td input[type="text"]').removeAttr('value');
    $('#' + trNewId + ' td input[type="text"]').attr('value', '');
    var num_filas = parseInt($('#NRows'+i).val());
    $('#NRows'+i).val(num_filas + 1);
    countDR(i);    
    }

/* SUMA EL SUBDETALLE POR ITEM PRINCIPAL */
function Suma(i)
	{ 
	var valor; 
	var total = 0; 
	$('table#DRT'+i+' input.montox'+i).each(function()
		{ 
		valor = $(this).val();
		if(valor!='') 
			{ 
			valor = valor.split('.').join(''); 
			} 
		else 
			{ 
			valor=0; 
			} 
		total = parseFloat(total) + parseFloat(valor); 
		}); 
	total = parseFloat(total);
	total = numeropts(total,'0',',','.');
	$('input#vtot'+i).val(total); 
	$('#campo'+i).val(total); 
	SumaAll();
	}

/* Suma Global */
function SumaAll(){
	if (document.getElementById('campo1')) { var campo1 = $('#campo1').val(); campo1 = campo1.split('.').join(''); } else { var campo1 = 0; }
	if (document.getElementById('campo2')) { var campo2 = $('#campo2').val(); campo2 = campo2.split('.').join(''); } else { var campo2 = 0; }
	if (document.getElementById('campo3')) { var campo3 = $('#campo3').val(); campo3 = campo3.split('.').join(''); } else { var campo3 = 0; }
	if (document.getElementById('campo4')) { var campo4 = $('#campo4').val(); campo4 = campo4.split('.').join(''); } else { var campo4 = 0; }
	if (document.getElementById('campo5')) { var campo5 = $('#campo5').val(); campo5 = campo5.split('.').join(''); } else { var campo5 = 0; }
	if (document.getElementById('campo6')) { var campo6 = $('#campo6').val(); campo6 = campo6.split('.').join(''); } else { var campo6 = 0; }
	if (document.getElementById('campo7')) { var campo7 = $('#campo7').val(); campo7 = campo7.split('.').join(''); } else { var campo7 = 0; }
	if (document.getElementById('campo8')) { var campo8 = $('#campo8').val(); campo8 = campo8.split('.').join(''); } else { var campo8 = 0; }
	if (document.getElementById('campo9')) { var campo9 = $('#campo9').val(); campo9 = campo9.split('.').join(''); } else { var campo9 = 0; }
	total = parseFloat(campo1) + parseFloat(campo2) + parseFloat(campo3) + parseFloat(campo4) + parseFloat(campo5) + 
			parseFloat(campo6) + parseFloat(campo7) + parseFloat(campo8) + parseFloat(campo9);
	total = numeropts(total,'0',',','.');
	$('#svmtot').val(total);
	}

function contara(tipo) 
	{
	if (tipo=='C') { url = 'compras'; }
	else if (tipo=='H') { url = 'honoras'; } 
	else { url = 'ventas'; }

	var checkboxes = document.getElementById(url+"_app").checkbox;

	var apro = "";
	for (var x=0; x < checkboxes.length; x++)
		{
		if (checkboxes[x].checked)
			{
			if ($.trim(apro) == "")
				{
				apro = document.getElementsByName("checkbox")[x].value;
				}
			else
				{
				apro = apro + "," + document.getElementsByName("checkbox")[x].value;
				}
			}
		}
	if (apro == '')
		{
		var chq = document.getElementsByName('checkbox')[0].value;
		apro = chq;
		if (document.getElementById(chq).checked == true)
			{ 
			if (confirm("Estimado Usuario, Desea exportar los siguientes documentos para su contabilización : " + apro))
				{
				$(location).attr('href', 'index.php?mod='+ url +'_csv&np=' + apro);
				}
			}
		else 
			{ 
			alert('No hay datos seleccionados'); 
			}
		}
	else
		{
		if (confirm("Sr. Usuario, Desea exportar los siguientes documentos para su contabilización : " + apro))
			{
			$(location).attr('href', 'index.php?mod='+ url +'_csv&np=' + apro);
			}
		}
	}
/* Consulta si es Auxiliar Existe MAZ 26/06/2015*/
function ConsultaExisteAux()
	{
	var codaux = $('#codaux').val();
	$.getJSON("inc/ExisteAux.php?a="+codaux+"",
	function(lea)
		{
		if(lea==0) 
			{ 
			alert("Sr. Usuario: \n El Auxiliar no existe. Debe agregarlo para poder continuar !");
			$('#codaux').val('');
			$('#auxili').val('');
			$('#auxili').focus();
			}
		});    
	}

function numeropts(numero, decimales, separador_decimal, separador_miles)
	{
	numero=parseFloat(numero);
	if(isNaN(numero))
		{
		return "";
		}
	if(decimales!==undefined)
		{
		numero=numero.toFixed(decimales);
		}
	numero=numero.toString().replace(".", separador_decimal!==undefined ? separador_decimal : ",");
	if(separador_miles)
		{
		var miles=new RegExp("(-?[0-9]+)([0-9]{3})");
		while(miles.test(numero))
			{
			numero=numero.replace(miles, "$1" + separador_miles + "$2");
			}
		}
	return numero;
	}	

function TraeDetalle()
	{
	var x = $('#tipdoc').val();
	var y = x.split('[SEP]');
	var a = y[0];
	var b = $('#codaux').val();
	
	$.getJSON("inc/detalle.php?a="+a+"&b="+b,
	function(data)
		{
		var dat = data.valor;
		if (dat==1)
			{
			var msj = 'Estimado Usuario: \n Desea cargar el detalle de libro guardado para este Auxiliar?';
			if (confirm(msj))
				{
				$.each(data.lineas, function(i, res)
					{
					var cta = data.pctcod[i];
					var dga = data.dgacod[i];
					var ccd = data.cccod[i];
					var ndt = data.lineas[i];
					alf(':last',cta,'0',ccd,dga,ndt);
					});
				}
			}
		});
	}
	
function TraeDetalleMod()
	{
	var x = $('#glovar').val();
	var y = x.split('[||]');
	var a = y[0];
	var b = y[1];
	var c = y[2];
	var d = y[3];
		
	$.getJSON("inc/detalle.php?a="+a+"&b="+b+"&c="+c+"&d="+d,
	function(data)
		{
		var dat = data.valor;
		if (dat==1)
			{
			$.each(data.lineas, function(i, res) 
				{
				var cta = data.pctcod[i];
				var dga = data.dgacod[i];
				var ccd = data.cccod[i];
				var ndt = data.lineas[i];
				var mnt = data.monto[i];
				alf(':last',cta,mnt,ccd,dga,ndt);
				});
			}
		});
	}

function CambiaFecha()
	{
	var fecemi = $('#fecemi').val();
	var fecven = $('#fecven').val();
	var conven = $('#conven').val();
	var z = conven.split('[||]');
	var dias   = z[1];
	var cuotas = z[2];

	var hoy = new Date();
	var dd = hoy.getDate();
	var mm = hoy.getMonth()+1; //hoy es 0!
	var yyyy = hoy.getFullYear();

	if(dd<10) { dd='0'+dd; } 
	if(mm<10) { mm='0'+mm; } 

	hoy = dd+'/'+mm+'/'+yyyy;
	
	var days = mostrarFecha(dias);

	if (fecven!=days)
		{
		var msj = 'Estimado Usuario: \n La fecha de primer vencimiento ingresada es '+fecven+' y la fecha propuesta por el sistema de acuerdo a la condición de venta indicada corresponde a: '+days+' \n ¿Desea reemplazar la fecha del primer vencimiento por la propuesta en el sistema?';
		if (confirm(msj))
			{
			$('#fecven').val(days);
			}
		}
	}

function mostrarFecha(days)
	{
	//ml = parseInt(35*24*60*60*1000);
	fc = new Date();
	dd = fc.getDate();
	mm = fc.getMonth()+1;
	yy = fc.getFullYear();
	
	tp = fc.getTime();
	ml = parseInt(days*24*60*60*1000);
	tt = fc.setTime(tp+ml);
	dd = fc.getDate();
	mm = fc.getMonth()+1;
	yy = fc.getFullYear();

	if(dd<10) { dd = '0'+dd; } 
	if(mm<10) { mm = '0'+mm; } 

	ff = dd+'/'+mm+'/'+yy; 
	return ff;
	}

/* funciones para Pago Clientes */

function DisabledMonto(check,i) 
	{ 
	if (check.checked==true)
		{
		document.getElementById('monto'+i).disabled = false;
		}
	else
		{
		document.getElementById('monto'+i).disabled = true;
		document.getElementById('monto'+i).value = '0';
		}

	}

function SumaPagos()
	{ 
	var a = document.pagos_ing.elements['monto[]'];
	var total = 0;
	var largo = a.length;

	if ($.trim(largo)=='') 
		{
		//alert ('Vacio es el Largo'); 
		var valor = $('#monto0').val();
		total = valor.split('.').join('');		
		}
	else 
		{
		for (x=0;x<largo;x++)
			{
			var monto = a[x].value;
			if (monto=='') { monto = '0'; }
			monto = monto + '.';
			var monto = monto.split('.').join('');
			total = parseInt(total) + parseInt(monto);
			//alert (total);
			}
		}
	total = numeropts(total,'0',',','.');
	$('input#total').val(total); 
	}

function NoMayor(i)
	{
	var saldo = $('#saldo'+i).val();
	var monto = $('#monto'+i).val();
	saldo = saldo.split('.').join('');
	monto = monto.split('.').join('');
	saldo = parseInt(saldo);
	monto = parseInt(monto);
		
	if (monto > saldo) { showMessage('div#mini-notification', '', 'error', 'El Monto a pagar no puede ser mayor al saldo  || ' + monto + ' > ' + saldo ); }
	if (monto <= 0) { showMessage('div#mini-notification', '', 'error', 'El Monto a pagar no puede igual o menor a 0  || ' + monto + ' != ' + saldo ); }
	}

/* ************************************************************************ */
/* 							FUNCIONES DE USUARIOS							*/
/* ************************************************************************ */

function EdiUser(id)
	{
	var mensaje = 'Estimado Usuario: \n procedera a modificar los datos del usuario, Desea continuar?';
	if (confirm(mensaje))
		{
		setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-usuarios-form&id='+id);}, 500);
		}
	}
	
function DelUser(id) 
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 el usuario seleccionado.\u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var accion = 'delete';
		var url = 'mantenedor-usuarios';

		var parametros = 
			{
			'id'      : id,
			'accion'  : accion,
			'seccion' : 'mantenedor_usuarios'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.mantenedores.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod='+url);}, 500);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}

/* ************************************************************************ */
/*				   FUNCIONES DE FORMATO ESTADO RESULTADO					*/
/* ************************************************************************ */

function EdiForm(id)
	{
	var mensaje = 'Estimado Usuario: \n procedera a modificar los datos del nivel ' + id + ', Desea continuar?';
	if (confirm(mensaje))
		{
		setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-formatos-form&id='+id);}, 500);
		}
	}
	
function DelForm(id) 
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 el nivel seleccionado. (' + id + ') \u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var accion = 'delete';
		var url = 'mantenedor-formatos';

		var parametros = 
			{
			'id'      : id,
			'accion'  : accion,
			'seccion' : 'mantenedor_formatos'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.mantenedores.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-formatos');}, 1000);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}

/* ************************************************************************ */
/*				   FUNCIONES CUENTAS CON DISTRIBUCION CC					*/
/* ************************************************************************ */

function EdiDist(id)
	{
	var mensaje = 'Estimado Usuario: \n procedera a modificar los datos la cuenta ' + id + ', Desea continuar?';
	if (confirm(mensaje))
		{
		setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-distribucion-form&id='+id);}, 500);
		}
	}
	
function DelDist(id)
	{
	var mensaje = 'ATENCI\u00D3N: Esta acci\u00F3n dejar\u00E1 en valor "0" todas las distribuciones del centro de costo '+ id +'. Desea continuar...?';
	if (confirm(mensaje))
		{
		var accion = 'delete';
		var url = 'mantenedor-distribucion';
		var parametros = 
			{
			'id'      : id,
			'accion'  : accion,
			'seccion' : 'mantenedor_distribucion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.mantenedores.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-distribucion');}, 2000);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}

/* ************************************************************************ */
/*				   FUNCIONES UBICACION DE CENTROS DE COSTOS					*/
/* ************************************************************************ */

function EdiUbi(id)
	{
	var mensaje = 'Estimado Usuario: \n procedera a modificar los datos la ubicacion ' + id + ', Desea continuar?';
	if (confirm(mensaje))
		{
		setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-ubicacion-form&id='+id);}, 500);
		}
	}	
function DelUbi(id) 
	{
	var mensaje = 'ATENCI\u00D3N: Se eliminar\u00E1 la ubicacion de los Centros de Costos. (' + id + ') \u000A\u000AEsta operaci\u00F3n es irreversible. Desea continuar...?';
	if (confirm(mensaje))
		{
		var accion = 'delete';
		var url = 'mantenedor-ubicacion';

		var parametros = 
			{
			'id'      : id,
			'accion'  : accion,
			'seccion' : 'mantenedor_ubicacion'
			};
		$.ajax({
			data:  parametros,
			url:   'ajax.process.mantenedores.php',
			type:  'post',					
			success:  function(response)
				{
				var json = eval('(' + response + ')');
				if (json.tipo == 'OK')
					{
					showMessage('div#mini-notification', '', 'ok', json.mensaje);
					$('div#mini-notification').css('display', 'block');
					setTimeout(function(){ $(location).attr('href', 'index.php?mod=mantenedor-ubicacion');}, 1000);
					}
				else
					{
					showMessage('div#mini-notification', '', 'error', json.mensaje);
					}
				}
			});
		}
	}

/* MENUS */
