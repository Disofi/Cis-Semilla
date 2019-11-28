<?php 
include('inc/funciones_distribucion.php');
$cc=$_POST['CodiCC'];
echo $cc;
?>

 <html>
<head>
<meta charset="utf-8">

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
<script src="//code.jquery.com/jquery-1.12.0.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>  
<script>
function getval(sel)
{
	$("#mostrarmodal").modal('show');
	$("#CC").val(sel.value);
	document.getElementById('#CC').value = '1000';

	
}
function Borrar(sel)
{
	$("#modalborrar").modal('show');
	$("#centro_1").val(sel.value);
	document.getElementById('#CC').value = '1000';

}
   function MandarSi(val,sel)
   {
	   var si="si";
    var value=$("#CC").val();
	 	   	window.location.assign("index.php?mod=seleccionniveles&respuesta="+si+"&cc="+value);
   }
   
   function MandarNo(val)
   {
		var value=$("#CC").val();
		var no=document.getElementById("no");
	   window.location.assign("index.php?mod=distribucion-eerr-form2&centrocosto="+value);
   }
 function BorrarSi(val,sel)
   {
	   var si="si";
    var value=$("#CC").val();
	 	   	window.location.assign("index.php?mod=seleccionniveles&respuesta="+si+"&cc="+value);
   }
   
   function BorrarNo(val)
   {
		var value=$("#CC").val();
		var no=document.getElementById("no");
	   window.location.assign("index.php?mod=distribucion-eerr-form2&centrocosto="+value);
   }

    </script>
</head>
<body>
   <div class="modal fade" id="mostrarmodal" tabindex="-1" role="dialog" aria-labelledby="basicModal" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
           <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
              <h3>Atencion!</h3>
           </div>
           <div class="modal-body">
              <h4>El Centro De Costo     <input type="text"  id="CC" style="border:0;background-color:white;whidth:150px;font:bold 20px;text-align:center;" value="CC"> Es Distribuible?</h4>
              
       </div>

           <div class="modal-footer">
          <!-- <a href="#" data-dismiss="modal" class="btn btn-danger">Cerrar</a>-->
		  <input type="button" value="SI" class="btn btn-primary" name="si" id="si" onclick="MandarSi();" style="widht:5000px;"></a>
		 <input type="button"  value="NO" class="btn btn-primary" name="no" id="no" onclick="MandarNo();" style="widht:5000px;"></a>
		  
           </div>

		
      </div>
   </div>
</div>



 <div class="modal fade" id="modalborrar" tabindex="-1" role="dialog" aria-labelledby="basicModal" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
           <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
              <h3>Atencion!</h3>
           </div>
           <div class="modal-body">
              <h4>Esta segur@ que desea borrar la distribucion?  <input type="text"  id="centro_1" style="border:0;background-color:white;whidth:150px;font:bold 20px;text-align:center;" value="CC"></h4>
              
       </div>

           <div class="modal-footer">
          <!-- <a href="#" data-dismiss="modal" class="btn btn-danger">Cerrar</a>-->
		  <input type="button" value="SI" class="btn btn-primary" name="si" id="si" onclick="BorrarSi();" style="widht:5000px;"></a>
		 <input type="button"  value="NO" class="btn btn-primary" name="no" id="no" onclick="BorrarNo();" style="widht:5000px;"></a>
		  
           </div>

		
      </div>
   </div>
</div>








<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-12">Mantenedor CC</h2>
		<div class="col-md-12">&nbsp;</div>
	</div>
		<form method="post" action="#">
	<div class="row">
	<div class="col-sm-6">

	<div class="col-sm-8">
	<?php echo selectCC();  ?>
	<br/>
	<!--<div id="ccdistribuibles">
	<div class="form-group">
		<label class="control-label col-sm-2" for="email"></label>
		<div class="col-sm-10" id="Distribuibles" style="display:none">
			<?php echo MostrarDistribucionCC($valor); ?>
		</div>
	</div>-->
	</div>

	</div>
	


	
	
	</div>
	
	<div class="row">
	<div class="col-sm-6" style="float:right;">
	<div class="col-sm-8" style="float:right;">
	<?php echo MostrarDistribucionActual(); ?>
	<br/>
	<!--<div id="ccdistribuibles">
	<div class="form-group">
		<label class="control-label col-sm-2" for="email"></label>
		<div class="col-sm-10" id="Distribuibles" style="display:none">
		
		</div>
	</div>
	</div>-->
	

	</div>
	


	
	
	</div>
	
	
	

</div>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
<BR/>
	<div class="titulo_pagina">
		<h2 class="col-md-12">CLONAR DISTRIBUCION POR A&ntilde;O</h2>
		<div class="col-md-12">&nbsp;</div>
		<input type="button" value="Clonar Distribucion" onclick="ClonarDistribucion();" style="float:right;">
	</div>

	</form>
</body>
</html>






<!--<div class="content">
	
	<div class="titulo_pagina">
		<h2 class="col-md-12">Mantenedor CC</h2>
		<div class="col-md-12">&nbsp;</div>
	</div>
	<div class="row">
	<div class="col-sm-6">
	
	<div class="col-sm-8">
	<?php echo selectCC();  ?>
	<br/>
	<div id="ccdistribuibles">
	<div class="form-group">
		<label class="control-label col-sm-2" for="email"></label>
		<div class="col-sm-10" id="Distribuibles" style="display:none">
			<?php echo MostrarDistribucionCC($valor); ?>
		</div>
	</div>
	</div>
	</div>
	


	
	
	</div>
</div>
<!-- if (document.getElementById('dos').style.display=='block') {  
// document.getElementById('dos').style.display='none';  
// }else{  
// document.getElementById('uno').style.display='none';  
// document.getElementById('dos').style.display='block';  
// document.getElementById('tres').style.display='none'; 
<div id="mensaje"></div>
	</div> -->
	<script>
	function ClonarDistribucion()
	{
	window.location.assign("index.php?mod=clonardistribucion");
	}
	</script>
