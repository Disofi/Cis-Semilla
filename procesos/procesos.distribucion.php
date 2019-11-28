<?php
session_start();
include('../inc/conexion.php');
include('../inc/funciones_EERR.php');

function nombreCuentaAgrupadaDist($idCuenta)
{
	include('../inc/conexion.php');
	$queryCC = " select descTitulo from ".$dba.".DS_AgrupacionCuentas where idNivel = '".$idCuenta."'and  bdsession = '".$_SESSION['emp']['id']."'  group by descTitulo ";
		//echo $queryCC."<---<br>";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['descTitulo'];
			//echo $return."<----<ksadjaksl<vr>";
		}
	return $return;
}

function nombreNivelDist($idNivel)
{
	include('../inc/conexion.php');
	$queryCC = " select tituloNivel from ".$dba.".DS_nivelesEERR where idNivel = '".$idNivel."' and  bdsession = '".$_SESSION['emp']['id']."' group by tituloNivel ";
	//echo $queryCC."<br>";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['tituloNivel'];
		}
	return $return;
}
	$accion = $_REQUEST['accion'];


if($accion == 'mostrarFormDist')
{	
	$mes = date("m",strtotime($primerDia));
	$CodiCCDist = $_REQUEST['CodiCC'];
	$anoSelect = $_REQUEST['anoSelect'];

	$arrayIDNivel = "";
	$arrayNombreNivel = "";
	$arrayDescripcionNivel = "";
	$indiceCabecera = 0;
	$finCiclo = 0;
    $anonuevo= $_REQUEST['anoSelect'];

	//$contadorCC = count($cc);
	$contadorCC = 1;
	$indiceCiclo = 0;
	$arrayCiclos = "";
	$clase = "";
	//echo $contadorCC."<--<br>";
	$querySabana = "";
	$queryNiveles =" SELECT idNivel, tituloNivel, descripcionNivel ";
	$queryNiveles.=" FROM ".$dba.".DS_nivelesEERR  ";
	$queryNiveles.=" WHERE  bdsession = '".$_SESSION['emp']['id']."' ";
	$queryNiveles.=" GROUP BY idNivel, tituloNivel, descripcionNivel ";
		//echo $queryNiveles."<br><br>";
	$rec_b = sqlsrv_query( $conn, $queryNiveles , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec_b))
	{
		//echo $row['idNivel']." //".$row['tituloNivel']." //".$row['descripcionNivel']."<br>";
		$arrayIDNivel[$indiceCabecera] = $row['idNivel'];
		$arrayNombreNivel[$indiceCabecera] = $row["tituloNivel"];
		$arrayDescripcionNivel[$indiceCabecera] = $row["descripcionNivel"];
		$indiceCabecera++;
	}
	
	$queryPosicion.=" SELECT COUNT(idNivel) as Hasta, idNivel  ";
	$queryPosicion.=" FROM ".$dba.".DS_nivelesEERR ";
	$queryPosicion.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryPosicion.=" GROUP BY idNivel ";
		//echo $queryPosicion."<br><br>";
	$rec_c = sqlsrv_query( $conn, $queryPosicion , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosPosicion = sqlsrv_num_rows($rec_c);
		while($rowPosicion = sqlsrv_fetch_array($rec_c))
		{
			//echo $rowPosicion["Hasta"]." -- ".$rowPosicion["idNivel"]."<br>";
			$finCiclo+=$rowPosicion["Hasta"];
			$arrayBandera[$finCiclo] = $finCiclo;
			//$arrayNiveles[$indiceCiclo] = $rowPosicion["idNivel"];
			$arrayCiclos[$indiceCiclo] = $rowPosicion["Hasta"];
			
			if($indiceCiclo == 0)
			{
				$arrayNiveles[0] = $rowPosicion["idNivel"];
				$banderaResta = $finCiclo;
			}
			else
			{
				$arrayNiveles[$finCiclo-$banderaResta] = $rowPosicion["idNivel"];
			}
			
			
			$indiceCiclo++;
		}
		
	//echo $registrosPosicion."<br>";
	//print_r($arrayCiclos);
	//echo "<br>";
	//print_r($arrayBandera);
	//print_r($arrayNiveles);
	//echo "<br><br>";
	//echo $arrayCiclos[0];
	$real = "";
	$acumulado="";
	$porcentaje ="";
	$ppto = "";
	$indice = 0;
	$banderaSTR = 0;	
	for($a=0;$a<$contadorCC;$a++)
	{
		for($b=0;$b<count($arrayCiclos);$b++)
		{
			if($b == 0)
			{
				$ppto.= " ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mes."',0)/1000 AS PPTO".$a.", ";
				$real.=" ".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$primerDia."','".$ultimoDia."','".$cc[$a]."','".$_SESSION['emp']['id']."')/1000 as REAL".$a."  ,  ";
				//$porcentaje.=" '%' as '%', ";
				$porcentaje.=" Case ";
				$porcentaje.=" when ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mes."',0) = 0 then 0 ";
				$porcentaje.=" Else ROUND((".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$primerDia."','".$ultimoDia."','".$cc[$a]."','".$_SESSION['emp']['id']."') ";
				$porcentaje.=" / ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mes."',0)*100),2) ";
				$porcentaje.=" END as PORCENTAJE".$a.",  ";
				$acumulado.=" ".$dba.".returnRealAcumulado('".$ano."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$inicioAcumulado."','".$finAcumulado."','".$cc[$a]."')/1000 as ACUMULADO".$a.", ";
			}				
		}	
	}


	$acumulado = substr($acumulado, 0, -2);
	for($a=0;$a<count($arrayNiveles);$a++)
	{
		$querySabana.=" select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma ";
		//$querySabana.=" ".$ppto;
		//$querySabana.=" ".$real;
		//$querySabana.=" ".$porcentaje;
		//$querySabana.=" ".$acumulado;
		$querySabana.=" from ".$dba.".DS_nivelesEERR  nivel ";
		$querySabana.=" INNER JOIN ".$dba.".[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel ";
		$querySabana.=" LEFT JOIN ".$dba.".DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel  AND dist.CodiCC = '".$CodiCCDist."'";
		$querySabana.=" WHERE nivel.idNivel = '".$a."' AND nivel.bdsession = '".$_SESSION['emp']['id']."' and dist.ano = '".$anoSelect."' ";
		$querySabana.=" group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma ";

		if($a == (count($arrayNiveles)-1))
		{
			
		}		
		else
		{
			$querySabana.=" UNION ALL ";
		}
	}
	
	//echo $querySabana."<br><br>";
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
	//echo  $registrosSabana."<--- registros <br>";
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			//echo $fila[0]."<br>";
		}

	if($contadorCC >=0 && $contadorCC <5)
	{ 
		$ancho = 35; 
	}
	else if($contadorCC >5 && $contadorCC <10)
	{ 
		$ancho = 50; 
	}
	else if($contadorCC >10 && $contadorCC <15)
	{
		$ancho = 70;
	}
	else
	{
		$ancho = 100;
	}
		echo '<br/>';
		echo '<br/>';
	echo '<div id="tablaContenedora" >';
	echo '<table border="1" cellpadding="0" cellspacing="0" class="scrollTable" style="margin-top:50px;">';

	echo '<thead class="fixedHeader tit">';
	echo '<tr>
		<th class="ta_c">Nombre Cuenta</th>
		';		
	//echo '<th class="ta_c">Descripci&oacute;n</th>';	
	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c" colspan="3">'.$cc[$k].' - '.nombreCC($cc[$k]).'</th>';
	}
	//echo '<th class="ta_c">Suma Directa</th>';
	echo '</tr></thead>';
	
	/*FIN CABECERA*/		
	echo '<tbody class="scrollContent">';
	echo '<tr class="stit ta_c">';

	echo '<th class="ta_l">'.nombreNivelDist(0).'</th>';
	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>';
		
	}
	echo '<th class="ta_c">Suma</th>';
	echo '</tr>';
	$banderaWhile = 1;
	$indiceShow = 0;
	$indiceRows = 0;
	$banderaEERRSuma = 0;
	$banderaSumar = 0;
	//print_r($arrayCiclos);
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
	//echo  $registrosSabana."<--- registros <br>";
	//echo $querySabana."<br><br><br>";
	$test = 0;
	$banderaNivel = 0;
	$hrefPositivo = '';
	$hrefNegativo = '';
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			$checked = "";
			if($fila['suma'] == 1)
			{
				$checked = " checked ";
			}
			//echo $banderaWhile."<<--<br>";
			//echo '<tr class="stit ta_c">'; COLOR
			echo '<tr class="ta_c">';
			//echo '<th class="ta_c">'.$fila['idCuenta'].' - '.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			echo '<th class="ta_l">'.nombreCuentaAgrupadaDist($fila['idCuenta']).'</th>';
			
			
			
			echo '<th class="ta_r"><input type="number" name="agrupacionCta[]" id="agrupacionCta'.$fila['idCuenta'].'" class="form-control" value="'.$fila['valor'].'" min="0" max="100" onBlur="validarValor(this.value, this.id);">
								<input type="hidden" name="idCuenta[]" id="idCuenta" class="form-control" value="'.$fila['idNivel'].'">			</th>';
			$clase = "";
			echo '<th class="ta_c">
			<input type="checkbox" name="check[]" id="'.$fila['idCuenta'].'" value="0" onchange="cambiarCheck(this.id, this.value);" '.$checked.'>
			<input type="hidden" name="sumaCuenta[]" id="sumaCuenta'.$fila['idCuenta'].'" value="'.$fila['suma'].'">
			</th>';
			echo '</tr>';
			
			
			$lineaPPTO = 0;
			$lineaREAL = 0;
			$lineaPORCENTAJE = 0;
			$lineaACUMULADO = 0;
			
			if($banderaWhile == $arrayCiclos[$indiceShow])
			{
				//echo " *** ".$banderaWhile." -- ".$arrayCiclos[$indiceShow]."<br>";
				//echo $banderaNivel." <-- bandera NIVEL<br>";
				$indiceShow++;
				$banderaSumar++;
				$banderaWhile = 0;
				$indiceRows = 0;
				$banderaEERRSuma++;
				echo '<tr class="stit ta_c">';
				//echo '<th class="ta_c">TOTAL </th>';
				//echo '<th class="ta_l">'.totalNivel($banderaEERRSuma-1).'</th>';
				
				
				
				
				
				echo '</tr>';
				echo '<tr height="10"></tr>';
				echo '<tr height="10"></tr>';
				
				
				//echo $banderaSumar."<--- bandera SUMAR <br>";
				if($banderaSumar == 1)
				{
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';
						
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  ';								  
							echo '<th class="ta_c">SUMA</th>
								  ';			
						}
						
						echo '</tr>';
				}
				if($banderaSumar == 2)
				{
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';					
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  ';
								  echo '<th class="ta_c">SUMA</th>';
							//<th class="ta_c">ACUM</th>
							
						}
						echo '</tr>';

				}
				if($banderaSumar == 3)
				{
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						//echo '<th class="ta_c">Nombre Cuenta'.$banderaNivel.'</th>';
						echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  ';
								    echo '<th class="ta_c">SUMA</th>';
								  //<th class="ta_c">ACUM</th>
							
						}
						
							//<th class="ta_c">ACUM</th>
						echo '</tr>';
						
						
						
				}
				
				if($banderaSumar == 4)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  ';
								  	echo '<th class="ta_c">SUMA</th>
								  ';
						}
						
						echo '</tr>';
						
				}

				if($banderaSumar == 5)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  ';
								  	echo '<th class="ta_c">SUMA</th>';
						}
						
						echo '</tr>';
				}
				
				
				// if($banderaSumar == 6)
				// {
						// echo '<tr class="stit ta_c">';
						// echo '<th class="ta_l">'.nombreNivelDist($banderaEERRSuma).'</th>';
						// for ($k=0;$k<$contadorCC;$k++)
						// {
							// echo '<th class="ta_c">% DISTRIBUCI&Oacute;N [0.00]</th>
								  // ';
								  	// echo '<th class="ta_c">SUMA</th>';
						// }
						
						// echo '</tr>';
				// }
				
				
				//var_dump($sumaPPTO);
				//echo "<br><br>";
				$sumaPPTO = "";
				$sumaREAL = "";
				$sumaPORCENTAJE = "";
				$sumaACUMULADO = "";	
				
				$lineaTotalPPTO = 0;
				$lineaTotalREAL = 0;
				$lineaTotalPORCENTAJE = 0;
				$lineaTotalACUMULADO = 0;
			}
			else
			{
				$indiceRows =1;
			}
			$banderaWhile++;
			$banderaNivel++;
			
		}
		echo '<tr class="sinBorde">';
		echo "<td>&nbsp;</td><td><input type='button' id='enviarCC' name='enviarCC' value='Enviar' class='form-control' onclick='enviarFormulario();'></td>";
		echo '</tr>';
	echo '</tbody></table>';
}
else if($accion == 'guardarDistcc')
{
	$valor = $_REQUEST['agrupacionCta'];
	$CodiCC = $_REQUEST['CC'];
	
	$idCuenta = $_REQUEST['idCuenta'];
	$sumaCuenta = $_REQUEST['sumaCuenta'];
	
	$anoSelect = $_REQUEST['ano'];
	
	print_r($valor);
	$i = 0;
	$QueryByPass = "
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."' AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '0' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL 
	
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '1' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL 
	
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '2' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL 
	
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '3' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL
	
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '4' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL 
	
	select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC ='".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '5' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano
	
	UNION ALL
	
		select nivel.orden, nivel.idCuenta, ISNULL(dist.valor,0) as valor, nivel.idNivel, ISNULL(dist.suma,0) as suma , dist.ano
	from [DSCIS].[dbo].DS_nivelesEERR nivel INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel 
	LEFT JOIN [DSCIS].[dbo].DS_DistribucionCC dist ON dist.idCuenta = agrupacion.idNivel AND dist.CodiCC = '".$CodiCCDist."'  AND dist.ano = '".$anoSelect."'
	WHERE nivel.idNivel = '6' AND nivel.bdsession = 'CIS' group by nivel.orden, nivel.idCuenta, dist.valor, nivel.idNivel, dist.suma , dist.ano"
	
	;
//	echo $QueryByPass."<br>";
	$recSabana = sqlsrv_query( $conn, $QueryByPass , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			echo $fila['idCuenta']."\n";
			$arrayCuentas[$i] = $fila['idCuenta'];
			$i++;
		}

	$queryDelete = "DELETE FROM ".$dba.".DS_DistribucionCC WHERE CodiCC = '".$CodiCC."' AND bdsession = '".$_SESSION['emp']['id']."' and ano = '".$anoSelect."' ";
//echo $queryDelete."<br>";
	$recDelete = sqlsrv_query( $conn, $queryDelete , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	for($a=0;$a<count($valor);$a++)
	{
		echo $valor[$a]."<br>";
		$queryInsert =" INSERT INTO ".$dba.".DS_DistribucionCC ";
		$queryInsert.=" (idCuenta, valor, CodiCC,idNivel,suma, BDsession,ano) ";
		$queryInsert.=" VALUES ";
		$queryInsert.=" ('".$arrayCuentas[$a]."','".$valor[$a]."','".$CodiCC."','".$idCuenta[$a]."','".$sumaCuenta[$a]."','".$_SESSION['emp']['id']."','".$anoSelect."') ";
		$recInsert = sqlsrv_query( $conn, $queryInsert , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	echo $queryInsert."\n";
	}
	
	echo "FIN";
}
else
{
	echo "nada";
}
?>