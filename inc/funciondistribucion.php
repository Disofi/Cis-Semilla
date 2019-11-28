<?php
session_start();
function MostrarDistribucionCC($centrocosto,$nivel1,$nivel2,$nivel3,$nivel4,$nivel5)
{	
    include('inc/conexion.php');
	
		
	
	$centro=substr($centrocosto,0,2);
	   $centrocostoevaluado=strlen($centrocosto);
	   echo $centrocostoevaluado."centrocostoevaluado";
	

if($nivel1=="")
{

	 $sel ="delete  from dscis.dbo.ccdistribuible where codicc='".$centrocosto."' ";
		 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
	
}

		if($centrocostoevaluado=='6' && $nivel1<>"")
	  {
		  	   $nivelinsertar=1;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel1<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=1;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}
	

		if($centrocostoevaluado=='6' && $nivel2<>"")
	  {
		  	   $nivelinsertar=2;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel2<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=2;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}

	
	
	
		if($centrocostoevaluado=='6' && $nivel3<>"")
	  {
		  	   $nivelinsertar=3;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel3<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=3;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}
	

		
	
		if($centrocostoevaluado=='6' && $nivel4<>"")
	  {
		  	   $nivelinsertar=4;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel4<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=4;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}
	
	
		
	 

		if($centrocostoevaluado=='6' && $nivel5<>"")
	  {
		  	   $nivelinsertar=5;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel1<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=5;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}
	
	
		if($centrocostoevaluado=='6' && $nivel6<>"")
	  {
		  	   $nivelinsertar=6;
	  $centro=substr($centrocosto,0,2);
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centro."','".$nivelinsertar."','CIS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
		}
		else if($centrocostoevaluado=='3' && $nivel6<>"")
		{
			echo $centrocostoevaluado."centroeval";
			   $nivelinsertar=6;
	 $sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel,BdSession) values('".$centrocosto."','".$nivelinsertar."','NUEVAHORNILLAS') ";
	 echo $sel;
		  $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		 $num = sqlsrv_fetch_array($res);
	
		
			
		}
	
	

	
		

   $largocccinsertar=strlen($centrocosto);
   $centro=substr($centrocosto,0,2);

    if($largocccinsertar=="3")
	{

			$sel34 ="select distinct tituloNivel from dscis.dbo.DS_nivelesEERR a join dscis.dbo.ccdistribuible b on a.idNivel=b.idnivel where b.codicc='".$centrocosto."'";
			$res34 = sqlsrv_query($conn, $sel34, array(), array('Scrollable' => 'buffered'));
			$existe =sqlsrv_fetch_array($res34);
			if($existe=="")
			{
			
				$salida.='
						<table class="registros table table-hover" id="distribucion">
							<thead>
							<tr>
						<th>NIVEL</th>
						<th>Se Distribuye 1</th>
						</tr>
					</thead>
					<tbody>';
				 $salida.= '<tr ><td >Gastos de Producci&oacute;n</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_1" value="valor_1" ></td>';
									 $salida.= '<tr ><td >Gastos de Venta</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_2" value="valor_2" ></td>';
									 $salida.= '<tr ><td >Gastos de Administraci&oacute;n</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_3" value="valor_3" ></td>';
									 $salida.= '<tr ><td >Otros</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_4" value="valor_4" ></td>';
									 $salida.= '<tr ><td >Otros Ingresos y Gastos</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_5" value="valor_5" ></td>';

			
				$salida.='</tbody></table>'; 
				$salida.='<table>';
				$salida.='<td>';
				$salida.='<input type="submit" id="cbox1" value="Enviar Seleccion">';	
				$salida.='</td>';
				$salida.='<td>';
				$salida.='<input type="button" id="cbox2" value="Volver" onclick="Volver();">';	
				$salida.='</td>';
			echo $salida;
				
			}else
			{
		$salida.='
		<table class="registros table table-hover" id="distribucion">
		<thead>
		<tr>
			<th>NIVEL</th>
			<th>Se Distribuye 2</th>
		</tr>
		</thead>
		<tbody>';
		$valor=0;
		$nombrefila1=array();
		while($row=sqlsrv_fetch_array($res))
		{		
		$arrayCiclos[$valor] = $row["tituloNivel"];
		$valor++;
      
		} 
		$valor2=0;
		$sel22 ="select distinct tituloNivel,idNivel from dscis.dbo.DS_nivelesEERR where tituloNivel<>'TITULO_HOLA' order by idNivel asc ";
		$res22 = sqlsrv_query($conn, $sel22, array(), array('Scrollable' => 'buffered'));
		$num22 = sqlsrv_fetch_array($res22);
		$valor22=0;
		$valor34=0;
		$j=0;
		$centros=substr($centrocosto,0,2);
		while ($row2=sqlsrv_fetch_array($res22))
		{
			
			$sel34 ="select distinct tituloNivel from dscis.dbo.DS_nivelesEERR a join dscis.dbo.ccdistribuible b on a.idNivel=b.idnivel where b.codicc='".$centrocostocis."'";
			echo $sel34;
			$res34 = sqlsrv_query($conn, $sel34, array(), array('Scrollable' => 'buffered'));
			while($row34=sqlsrv_fetch_array($res34))
			{
			if($row34['tituloNivel']==$row2['tituloNivel'])
			{
					 $salida.= '<tr ><td >'.$row34['tituloNivel'].'</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" checked="checked"></td>';
				  break;
				
			}else{
					 $salida.= '<tr ><td >'.$row2['tituloNivel'].'</td>';
						 $salida.='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" ></td>';
				}
			}
			
			
			$valor22++;
			$j++;
		}

			$salida.='</tbody></table>'; 
		 $salida.='<input type="submit" id="cbox2" value="Enviar Selección"  style="display:none;">';	
		 	 $salida.='<input type="button" id="cbox2" value="Salir" onclick="Salir()">';	
			echo $salida;
			// $salida.="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	  
}

}else if($largocccinsertar=="6")
{
			
			$sel34 ="select distinct tituloNivel from dscis.dbo.DS_nivelesEERR a join dscis.dbo.ccdistribuible b on a.idNivel=b.idnivel where b.codicc='".$centro."'";
			echo $sel34."consulta";
			$res34 = sqlsrv_query($conn, $sel34, array(), array('Scrollable' => 'buffered'));
			$existe =sqlsrv_fetch_array($res34);
			if($existe=="")
			{
			
				$salida.='
						<table class="registros table table-hover" id="distribucion">
							<thead>
							<tr>
						<th>NIVEL</th>
						<th>Se Distribuye 1</th>
						</tr>
					</thead>
					<tbody>';
				 $salida.= '<tr ><td >Gastos de Producci&oacute;n</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_1" value="valor_1" ></td>';
									 $salida.= '<tr ><td >Gastos de Venta</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_2" value="valor_2" ></td>';
									 $salida.= '<tr ><td >Gastos de Administraci&oacute;n</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_3" value="valor_3" ></td>';
									 $salida.= '<tr ><td >Otros</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_4" value="valor_4" ></td>';
									 $salida.= '<tr ><td >Otros Ingresos y Gastos</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_5" value="valor_5" ></td>';

			
				$salida.='</tbody></table>'; 
				$salida.='<table>';
				$salida.='<td>';
				$salida.='<input type="submit" id="cbox1" value="Enviar Seleccion">';	
				$salida.='</td>';
				$salida.='<td>';
				$salida.='<input type="button" id="cbox2" value="Volver" onclick="Volver();">';	
				$salida.='</td>';
			echo $salida;
				
			}else
			{
		$salida.='
		<table class="registros table table-hover" id="distribucion">
		<thead>
		<tr>
			<th>NIVEL</th>
			<th>Se Distribuye 2</th>
		</tr>
		</thead>
		<tbody>';
		$valor=0;
		$nombrefila1=array();
		while($row=sqlsrv_fetch_array($res))
		{		
		$arrayCiclos[$valor] = $row["tituloNivel"];
		$valor++;
      
		} 
		$valor2=0;
		$sel22 ="select distinct tituloNivel,idNivel from dscis.dbo.DS_nivelesEERR where tituloNivel<>'TITULO_HOLA' order by idNivel asc ";
		$res22 = sqlsrv_query($conn, $sel22, array(), array('Scrollable' => 'buffered'));
		$num22 = sqlsrv_fetch_array($res22);
		$valor22=0;
		$valor34=0;
		$j=0;
		$centros=substr($centrocosto,0,2);
		while ($row2=sqlsrv_fetch_array($res22))
		{
			
			$sel34 ="select distinct tituloNivel from dscis.dbo.DS_nivelesEERR a join dscis.dbo.ccdistribuible b on a.idNivel=b.idnivel where b.codicc='".$centro."'";
		
			$res34 = sqlsrv_query($conn, $sel34, array(), array('Scrollable' => 'buffered'));
			while($row34=sqlsrv_fetch_array($res34))
			{
			if($row34['tituloNivel']==$row2['tituloNivel'])
			{
					 $salida.= '<tr ><td >'.$row34['tituloNivel'].'</td>';
					$salida.='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" checked="checked"></td>';
				  break;
				
			}else{
					 $salida.= '<tr ><td >'.$row2['tituloNivel'].'</td>';
						 $salida.='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" ></td>';
				}
			}
			
			
			$valor22++;
			$j++;
		}

			$salida.='</tbody></table>'; 
		 $salida.='<input type="submit" id="cbox2" value="Enviar Selección"  style="display:none;">';	
		 	 $salida.='<input type="submit" id="cbox2" value="Enviar Valor" >';	
			  $salida.='<input type="button" id="cbox2" value="Salir" onclick="Salir()">';	
			echo $salida;
			// $salida.="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	  
	
}
}
}


?>

<script>
function Salir()
{
	window.location.assign("index.php?mod=mantenedorCC");	
}

	
</script>