<?php
session_start();
function MostrarDistribucionCC($centrocosto,$nivel1,$nivel2,$nivel3,$nivel4,$nivel5)
{	
    include('inc/conexion.php');
	
	if($nivel1!="")
	{
		$nivel1=1;
			$valida="select codicc,idnivel from dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel1."'";
		$validares = sqlsrv_query($conn, $valida, array(), array('Scrollable' => 'buffered'));
		echo $valida;
	while($existe = sqlsrv_fetch_array($validares))
	{
		$cc=$existe['codicc'];
		$nivel=$existe['idnivel'];
		
	}
	if($cc!="")
	{
		$nivel1=1;
		$centro=substr($centrocosto,0,2);
		$sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel) values('".$centro."','".$nivel1."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);			
	}else
	{
		$nivel1=1;
		$centro=substr($centrocosto,0,2);
		$sel ="delete  dscis.dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel1."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
		
	}
	}	
	
	if($nivel2!="")
	{
			$nivel2=2;
		$valida="select codicc,idnivel from dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel2."'";
		$validares = sqlsrv_query($conn, $valida, array(), array('Scrollable' => 'buffered'));
		$numero = sqlsrv_fetch_array($validares);
echo $num;
		if($numero=="")
	{
		      echo "aqui";
		$nivel2=2;
		$centro=substr($centrocosto,0,2);
		$sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel) values('".$centro."','".$nivel2."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
	
	}
	else
	{
		
			echo "aquino";
		$nivel2=2;
		$centro=substr($centrocosto,0,2);
		$sel ="delete  dscis.dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel2."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
			
	}
		
			
	}
		
		
	if($nivel3!="")
	{
			$nivel3=3;
		$valida="select codicc,idnivel from dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel3."'";
		$validares = sqlsrv_query($conn, $valida, array(), array('Scrollable' => 'buffered'));
		echo $valida;
	while($existe = sqlsrv_fetch_array($validares))
	{
		$cc=$existe['codicc'];
		$nivel=$existe['idnivel'];
		
	}
	if($cc!="")
	{
		$nivel3=3;
		$centro=substr($centrocosto,0,2);
		$sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel) values('".$centro."','".$nivel3."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);			
	}else
	{
		$nivel3=3;
		$centro=substr($centrocosto,0,2);
		$sel ="delete  dscis.dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel3."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
		
		
	}	
	}
	if($nivel4!="")
	{
			$nivel4=4;
			$valida="select codicc,idnivel from dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel4."'";
		$validares = sqlsrv_query($conn, $valida, array(), array('Scrollable' => 'buffered'));
		echo $valida;
	while($existe = sqlsrv_fetch_array($validares))
	{
		$cc=$existe['codicc'];
		$nivel=$existe['idnivel'];
		
	}
	if($cc!="")
	{
		$nivel4=4;
		$centro=substr($centrocosto,0,2);
		$sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel) values('".$centro."','".$nivel4."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);			
	}else
	{
		$nivel4=4;
		$centro=substr($centrocosto,0,2);
		$sel ="delete  dscis.dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel4."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
		
	
		
	}	
	}
	if($nivel5!="")
	{
			$nivel5=5;
		$valida="select codicc,idnivel from dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel5."'";
		$validares = sqlsrv_query($conn, $valida, array(), array('Scrollable' => 'buffered'));
		echo $valida;
	while($existe = sqlsrv_fetch_array($validares))
	{
		$cc=$existe['codicc'];
		$nivel=$existe['idnivel'];
		
	}
	if($cc!="")
	{
		$nivel5=5;
		$centro=substr($centrocosto,0,2);
		$sel ="insert into  dscis.dbo.ccdistribuible(codicc,idNivel) values('".$centro."','".$nivel5."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);			
	}else
	{
		$nivel5=5;
		$centro=substr($centrocosto,0,2);
		$sel ="delete  dscis.dbo.ccdistribuible where codicc='".$centro."' and idNivel='".$nivel5."') ";
		$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
		$num = sqlsrv_fetch_array($res);
		

	}
	}	
	
	
	
	
	
	$centro =substr($centrocosto,0,2);
	$sel ="select distinct tituloNivel,idNivel from dscis.dbo.DS_nivelesEERR where tituloNivel<>'TITULO_HOLA' order by idNivel asc ";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$num = sqlsrv_fetch_array($res);
	$sel1 ="select distinct tituloNivel from dscis.dbo.DS_nivelesEERR a join dscis.dbo.ccdistribuible b on a.idNivel=b.idnivel where b.codicc='".$centro."'";
	$res1 = sqlsrv_query($conn, $sel1, array(), array('Scrollable' => 'buffered'));
	$j=0;
	if ($num > 0)
		{
		$salida = '
		<table class="registros table table-hover" id="distribucion">
		<thead>
		<tr>
			<th>NIVEL</th>
			<th>Se Distribuye</th>
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
	
		while ($row1=sqlsrv_fetch_array($res1))
		{		
			$filaactual1[$valor2]=$row1['tituloNivel'];
		$valor2++;
		 $nombrefila=$row1['tituloNivel'];

		}
	


		

		for($b=0;$b<count($arrayCiclos);$b++)
		{
		$comparara=0;
		  for($c=0;$c<count($filaactual1);$c++)
		  {
			if($filaactual1.$c==$arrayCiclos.$b)
			{
							$salida .= '<tr ><td >'.$nombrefila.'</td>';
							$salida .='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" checked="checked"></td>';
							break;
			
			}
			else{
					
						// for($b=1;$b<count($arrayCiclos);$b++)
						// {
							// if($filaactual1['tituloNivel'].$c<>$arrayCiclos['tituloNivel'].$b)
							// {
								// echo $filaactual1['tituloNivel'].$c;
							// $salida .= '<tr ><td >ALGO</td>';
								// $salida .='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" ></td>';
							// }
						// }
				}
			
			}
		}
		  
		
			
			
			
			
			
			
			
			
			
			// if($filaactual1.$c<>$arrayCiclos.$b)
			// {
			
			// $sel ="select distinct tituloNivel,idNivel from dscis.dbo.DS_nivelesEERR where tituloNivel<>'TITULO_HOLA' order by idNivel asc ";
			// $res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
			// $num = sqlsrv_fetch_array($res);
			// $comparador=0;
				// while($row=sqlsrv_fetch_array($res))
				// {	
				// $buscavalor[$comparador] = $row["tituloNivel"];
					// echo $row['tituloNivel'];
				// $comparador++;
		
				// }
				
			
			
				


			
		

		
		  // if($filaactual1.$b<>$arrayCiclos.$b)
		  // {
			 // $salida .= '<tr ><td >'.$row['tituloNivel'].'</td>';
					// $salida .='<td ><input type="checkbox" id="cbox2" name="valor_'.$j.'" value="valor_'.$j.'" ></td>';
	
			  
		  // }
		  
		   // if($arrayCiclos["tituloNivel"]==$filaactual1["tituloNivel"])
		   // {
			   // echo $arrayCiclos["tituloNivel"];
			   // echo $filaactual1["tituloNivel"];
			   
		   // }
		   // else{
			   
			   // $aqui="si";
			   // echo $aqui;
		   // }
			}
		
else
    {
        $salida="<h4>No hay registros, ingrese un nuevo Nivel</h4>";	
    }
echo $salida;
}

?>