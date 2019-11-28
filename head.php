<?php
include('inc/conexion.php');
error_reporting(0);
?>
<!doctype html>
<html>
<head>
<meta charset="utf-8" />
<title>.: CIS SEMILLAS :.</title>
<link rel="shortcut icon" href="imgs/favicon.ico" />
<?php
if (empty($_SESSION['user']['id'])) 
	{
	$style = '<link rel="stylesheet" href="css/singin.css" type="text/css" />';
	$style.= '<script src="js/assets/js/ie10-viewport-bug-workaround.js"></script>';
	}
else 
	{
	$style = '<link rel="stylesheet" href="css/styles.css" type="text/css" />'; 
	}
echo $style; 
?>
<link rel="stylesheet" href="css/mediaQueries.css" type="text/css" />
<link rel="stylesheet" href="css/tooltip.css" type="text/css" />
<link rel="stylesheet" href="css/autocomplete.css" type="text/css" />
<link rel="stylesheet" href="js/jquery-ui/jquery-ui.css" type="text/css" />
<link rel="stylesheet" href="js/jquery-ui/jquery-ui.structure.css" type="text/css" />
<link rel="stylesheet" href="js/jquery-miniNotification/jquery.miniNotification.css" type="text/css" />
<link rel="stylesheet" href="js/jquery-datatables/media/css/jquery.dataTables.css" type="text/css" />
<link rel="stylesheet" href="js/bootstrap/css/bootstrap.css" type="text/css">
<link rel="stylesheet" href="js/fancybox/source/jquery.fancybox.css" type="text/css" />
<script type="text/javascript" src="js/jquery-1.11.1.js"></script>
<script type="text/javascript" src="js/jquery.menu.js"></script>
<script type="text/javascript" src="js/jquery.rut.js"></script>
<script type="text/javascript" src="js/jquery.tooltip.js"></script>
<script type="text/javascript" src="js/jquery-ui/jquery-ui.js"></script>
<script type="text/javascript" src="js/jquery-miniNotification/jquery.miniNotification.js"></script>
<script type="text/javascript" src="js/jquery-datatables/media/js/jquery.dataTables.js"></script>
<script type="text/javascript" src="js/bootstrap/js/bootstrap.js"></script>
<script type="text/javascript" src="js/fancybox/source/jquery.fancybox.js"></script>
<script type="text/javascript" src="js/funciones.js"></script>
<script type="text/javascript" src="js/jquery.bpopup.min.js"></script>
<script type="text/javascript">
;(function($) 
	{
	$(function() 
		{
		$('#botonPopUp').bind('click', function(e){
			e.preventDefault();
			$('#thepopup').bPopup({follow: [false, false],position: [300, 0],appendTo: 'form',zIndex: 2,modalClose: false});
			});
		});
	})
(jQuery);
</script>

<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" />
</head>
<body>
<div id="mini-notification"><p></p></div>
<div id="page-loader"><div>&nbsp;</div></div>
