<?php
function formatoMoneda($numero, $moneda)
{
	$bandera = 0;
	$rest = substr($numero, 0, 1);
	$simbolo = "";
	$final = "";
	
	if($rest == '-')
	{
		$bandera = 1;
		$numero = ($numero * -1);
		$simbolo = "-";
	}
	
    $longitud = strlen($numero);
    $punto = substr($numero, -1,1);
    $punto2 = substr($numero, 0,1);
	$separador = ".";
	
	if($punto == ".")
	{
		$numero = substr($numero, 0,$longitud-1);
		$longitud = strlen($numero);
	}
	
	if($punto2 == ".")
	{
		$numero = "0".$numero;
		$longitud = strlen($numero);
	
	}
    $num_entero = strpos ($numero, $separador);
	$centavos = substr ($numero, ($num_entero));
    $l_cent = strlen($centavos);
	
	if($l_cent == 2){$centavos = $centavos."0";}
    elseif($l_cent == 3){$centavos = $centavos;}
    elseif($l_cent > 3){$centavos = substr($centavos, 0,3);}
	
	$entero = substr($numero, -$longitud,$longitud-$l_cent);
	
	if(!$num_entero)
	{
		$num_entero = $longitud;
        $centavos = ".00";
        $entero = substr($numero, -$longitud,$longitud);
    }

    $start = floor($num_entero/3);
    $res = $num_entero-($start*3);
    if($res == 0){$coma = $start-1; $init = 0;}else{$coma = $start; $init = 3-$res;}
    $d= $init; $i = 0; $c = $coma;
        while($i < $num_entero)
		{
            if($d == 3 && $c > 0)
			{
				$d = 0; $sep = "."; $c = $c-1;
			}
			else
			{
				$sep = "";
			}
				
            $final .=  $sep.$entero[$i];
            $i = $i+1; // todos los digitos
            $d = $d+1; // poner las comas
        }
        if($moneda == "pesos")  
		{
			$moneda = "$";
			return $moneda." ".$simbolo.$final;
        }
        elseif($moneda == "dolares"){$moneda = "USD";
        return $moneda." ".$final.$centavos;
        }
        elseif($moneda == "euros")  {$moneda = "EUR";
        return $final.$centavos." ".$moneda;
        }
}

function EERR($ano,$primerDia,$ultimoDia,$inicioAcumulado,$finAcumulado,$cc,$presupuesto,$mesini)
{
	include('inc/conexion.php');
	require_once('inc/PHPExcel.php');
	$fechaExcel   = date('dmY-His');
		$fname = "informes/EERR-".$fechaExcel.".xls";
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->getProperties()
			->setCreator("Disofi 2017")
			->setLastModifiedBy("Disofi 2017")
			->setTitle("EERR")
			->setSubject("EERR")
			->setDescription("EERR")
			->setKeywords("Office PHPExcel")
			->setCategory("EERR");
	
	$mes = date("m",strtotime($primerDia));
	$arrayIDNivel = "";
	$arrayNombreNivel = "";
	$arrayDescripcionNivel = "";
	$indiceCabecera = 0;
	$finCiclo = 0;
	$contadorCC = count($cc);
	$indiceCiclo = 0;
	$arrayCiclos = "";
	$clase = "";
	
	$querySabana = "";
	$queryNiveles =" SELECT idNivel, tituloNivel, descripcionNivel ";
	$queryNiveles.=" FROM ".$dba.".DS_nivelesEERR  ";
	$queryNiveles.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryNiveles.=" GROUP BY idNivel, tituloNivel, descripcionNivel ";

		$rec_b = sqlsrv_query( $conn, $queryNiveles , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec_b))
	{
		$arrayIDNivel[$indiceCabecera] = $row['idNivel'];
		$arrayNombreNivel[$indiceCabecera] = $row["tituloNivel"];
		$arrayDescripcionNivel[$indiceCabecera] = $row["descripcionNivel"];
		$indiceCabecera++;
	}
	
	$queryPosicion.=" SELECT COUNT(idNivel) as Hasta, idNivel  ";
	$queryPosicion.=" FROM ".$dba.".DS_nivelesEERR ";
	$queryPosicion.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryPosicion.=" GROUP BY idNivel ";
		
	$rec_c = sqlsrv_query( $conn, $queryPosicion , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosPosicion = sqlsrv_num_rows($rec_c);
		while($rowPosicion = sqlsrv_fetch_array($rec_c))
		{
			$finCiclo+=$rowPosicion["Hasta"];
			$arrayBandera[$finCiclo] = $finCiclo;
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
				$resta = substr($cc[$a],0,2);			
				$ppto.= " ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',0)/1000 AS PPTO".$a.", ";
				$real.=" ".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$primerDia."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel)/1000 as REAL".$a."  ,  ";
				$porcentaje.=" Case ";
				$porcentaje.=" when ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',0) = 0 then 0 ";
				$porcentaje.=" Else ROUND((".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$primerDia."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel) ";
				$porcentaje.=" / ".$dba.".returnPPTO('".$ano."','".$presupuesto."','".$cc[$a]."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',0)*100),2) ";
				$porcentaje.=" END as PORCENTAJE".$a.",  ";
				$acumulado.=" ".$dba.".returnRealAcumulado('".$ano."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$inicioAcumulado."','".$finAcumulado."','".$resta."')/1000 as ACUMULADO".$a.", ";
				
			}				
		}	
	}
	
	$acumulado = substr($acumulado, 0, -2);
	for($a=0;$a<count($arrayNiveles);$a++)
	{
		$querySabana.=" select nivel.orden, nivel.idCuenta,nivel.idNivel, ";
		$querySabana.=" ".$ppto;
		$querySabana.=" ".$real;
		$querySabana.=" ".$porcentaje;
		$querySabana.=" ".$acumulado;
		$querySabana.=" from ".$dba.".DS_nivelesEERR  nivel ";
		$querySabana.=" INNER JOIN ".$dba.".[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel ";
		$querySabana.=" WHERE nivel.idNivel = '".$a."' AND nivel.bdsession = '".$_SESSION['emp']['id']."' ";
		$querySabana.=" group by nivel.orden, nivel.idCuenta,nivel.idNivel ";
		if($a == (count($arrayNiveles)-1))
		{
			
		}		
		else
		{
			$querySabana.=" UNION ALL ";
		}
		
	}
	
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
		while($fila = sqlsrv_fetch_array($recSabana))
		{
		
		}
				
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', "")
		->setCellValue('B1', "")
		->setCellValue('C1', "")
		->setCellValue('D1', "ESTADO DE RESULTADOS CONSOLIDADO MENSUAL")
		->setCellValue('E1', "")
		->setCellValue('F1', "")
		->setCellValue('G1', "")
		->setCellValue('H1', "")
		->setCellValue('I1', "")
		->setCellValue('J1', "")
		->setCellValue('K1', "")
		->setCellValue('L1', "")
		->setCellValue('M1', "");
		
		$objPHPExcel->getActiveSheet()->mergeCells("D1:H1");
		
	$keyExcel = 3;
	$Letra = "A";

	$excelCentro = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
        )
    );
	
	$excelRight = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_RIGHT,
        )
    );
	$excelColorCabecera =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => '5ea85e')
        )
    );
	$excelColorTitulo =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        )
    );
	
	$excelPositivo = array(
    'font'  => array(
        'color' => array('rgb' => '000000')
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelPositivoTotal = array(
    'font'  => array(
        'color' => array('rgb' => '000000')
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));
	
	$excelNegativo = array(
    'font'  => array(
        'color' => array('rgb' => 'FF0000')
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelNegativoTotal = array(
    'font'  => array(
        'bold'  => true,
        'color' => array('rgb' => 'FF0000')
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));
	
	$bordeIzqDer = array(
	  'borders' => array(
		'right' => array(
		  'style' => PHPExcel_Style_Border::BORDER_THIN
		),
		'left' => array(
		  'style' => PHPExcel_Style_Border::BORDER_THIN
		)
	  )
	);
	$bordeCompleto = array(
	  'borders' => array(
		'outline' => array(
		  'style' => PHPExcel_Style_Border::BORDER_THIN
		)
	  )
	);
	
	$textoNegritaTitulo = array(
    'font' => array(
        'bold' => true,
		'size' => 12
    )
	);
	
	$objPHPExcel->getActiveSheet()->getStyle("D1:H1")->applyFromArray($excelCentro);
	$objPHPExcel->getActiveSheet()->getStyle("D1:H1")->applyFromArray($textoNegritaTitulo);

	if($contadorCC >0 && $contadorCC <5)
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
	echo '<div id="tablaContenedora" class="tablaContenedora planilla">';
	echo '<table border="1" cellpadding="0" cellspacing="0" width="'.$ancho.'%" class="scrollTable">';
	echo '<thead class="fixedHeader tit">';
	echo '<tr>
		<th class="ta_c">Nombre Cuenta</th>';
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "NOMBRE CUENTA");
			$objPHPExcel->getActiveSheet()
				->getColumnDimension($Letra)
				->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
	
		for ($k=0;$k<$contadorCC;$k++)
	{
		
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, $cc[$k]." ".nombreCC($cc[$k]));
		$inicioLetra = $Letra;
		$Letra++;
		$Letra++;
		
		$objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
		echo '<th class="ta_c" colspan="3">'.$cc[$k].' - '.nombreCC($cc[$k]).'</th>';
	}
	
	$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "TOTALES");
		$inicioLetra = $Letra;
		$Letra++;
		$Letra++;
		$objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
	echo '<th class="ta_c" colspan="3">TOTALES</th></tr></thead>';
	/*FIN CABECERA*/
	
	$Letra = "A";
	$keyExcel++;
	$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "NOMBRE CUENTA");
			$objPHPExcel->getActiveSheet()
				->getColumnDimension($Letra)
				->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
		
	echo '<tbody class="scrollContent">';
	echo '<tr class="stit ta_c">';
	echo '<th class="ta_l">'.nombreNivel(0).'</th>';
	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c">PPTO</th>
			  <th class="ta_c">REAL</th>
			  <th class="ta_c">%</th>
			  ';
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;	  
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;	  
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;	  
	}
	echo '
		<th class="ta_c">PPTO</th>
		<th class="ta_c">REAL</th>
		<th class="ta_c">%</th>
		';
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$Letra++;
	echo '</tr>';
	$banderaWhile = 1;
	$indiceShow = 0;
	$indiceRows = 0;
	$banderaEERRSuma = 0;
	$banderaSumar = 0;
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
	$test = 0;
	$banderaNivel = 0;
	$Letra = "A";
	$keyExcel++;
	$hrefPositivo = '';
	$hrefNegativo = '';
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			echo '<tr class="ta_c">';
			echo '<th class="ta_l">'.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreCuentaAgrupada($fila['idCuenta']));
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			$Letra++;
			for($th=0;$th<$contadorCC;$th++)
			{
					if($fila['PPTO'.$th] >= 0) {$clase = "positivo";}
					else { $clase = "negativo";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($fila['PPTO'.$th],pesos).'</th>';
					$clase = "";
					
					// if($fila['REAL'.$th] >= 0) {$clase = $hrefPositivo;}
					// else { $clase = $hrefNegativo;	}
					// echo '<th class="ta_r "><a href="index.php?mod=saldos_ver&id='.$fila['idCuenta'].'&b='.$mesini.'&c='.$ano.'&cc='.$cc[$th].'" target="_blank" '.$clase.' >'.formatoMoneda($fila['REAL'.$th],pesos).'</a></th>';
					// $clase = "";
					
					// if($fila['PORCENTAJE'.$th] >= 0) {$clase = "positivo";}
					// else { $clase = "negativo";	}
					// echo '<th class="ta_r '.$clase.'">'.$fila['PORCENTAJE'.$th].' %</th>';
					// $clase = "";
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['PPTO'.$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($fila['PPTO'.$th] >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}	
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['REAL'.$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					
					// if($fila['REAL'.$th] >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }

					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					$Letra++;
					
					// if($fila['PORCENTAJE'.$th] >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['PORCENTAJE'.$th]." %");
					
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					$Letra++;
					
					$sumaPPTO[$th] += $fila['PPTO'.$th];
					$sumaREAL[$th] += $fila['REAL'.$th];
					$sumaPORCENTAJE[$th] += $fila['PORCENTAJE'.$th];
					$sumaACUMULADO[$th] += $fila['ACUMULADO'.$th];
	
					$totalPPTO[$th] += $fila['PPTO'.$th]+1;
					$totalREAL[$th] += $fila['REAL'.$th]+2;
					$totalPORCENTAJE[$th] += $fila['PORCENTAJE'.$th]+3;
					$totalACUMULADO[$th] += $fila['ACUMULADO'.$th]+4;
					
					$lineaPPTO += $fila['PPTO'.$th];
					$lineaREAL += $fila['REAL'.$th];
					$lineaPORCENTAJE += $fila['PORCENTAJE'.$th];
					$lineaACUMULADO += $fila['ACUMULADO'.$th];
					
					$lineaTotalPPTO += $fila['PPTO'.$th];
					$lineaTotalREAL += $fila['REAL'.$th];
					$lineaTotalPORCENTAJE += $fila['PORCENTAJE'.$th];
					$lineaTotalACUMULADO += $fila['ACUMULADO'.$th];
					
					$lineaTotalFinalPPTO += $fila['PPTO'.$th];
					$lineaTotalFinalREAL += $fila['REAL'.$th];
					$lineaTotalFinalPORCENTAJE += $fila['PORCENTAJE'.$th];
					$lineaTotalFinalACUMULADO += $fila['ACUMULADO'.$th];
					
					$sumaSegundoPPTO[$th];
					$sumaSegundoReal[$th];
					$sumaSegundoPorcentaje[$th];
					$sumaSegundoAcumulado[$th];	
			}
			
			if($lineaPPTO >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaPPTO,pesos).'</th>';
			$clase = "";
			
			if($lineaREAL >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaREAL,pesos).'</th>';
			$clase = "";
			
			if($lineaPORCENTAJE >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			echo '<th class="ta_r '.$clase.'">'.$lineaPORCENTAJE.' %</th>';
			$clase = "";
			echo '</tr>';
			
			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			
			if($lineaPPTO >= 0) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);				
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;

			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			if($lineaREAL >= 0) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;
			
			
			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaPORCENTAJE." %");
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			if($lineaPORCENTAJE >= 0) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;
			$keyExcel++;
			$Letra = "A";
			$lineaPPTO = 0;
			$lineaREAL = 0;
			$lineaPORCENTAJE = 0;
			$lineaACUMULADO = 0;
			
			if($banderaWhile == $arrayCiclos[$indiceShow])
			{
				$indiceShow++;
				$banderaSumar++;
				$banderaWhile = 0;
				$indiceRows = 0;
				$banderaEERRSuma++;
				echo '<tr class="stit ta_c">';
				echo '<th class="ta_l">'.totalNivel($banderaEERRSuma-1).'</th>';
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, totalNivel($banderaEERRSuma-1));
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$Letra++;
				
				for($th=0;$th<$contadorCC;$th++)
				{
						if($sumaPPTO[$th] >= 0) {$clase = "positivoTotal";}
						else { $clase = "negativoTotal";	}
						echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sumaPPTO[$th],pesos).'</th>';
						$clase = "";
						
						if($sumaREAL[$th] >= 0) {$clase = "positivoTotal";}
						else { $clase = "negativoTotal";	}
						echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sumaREAL[$th],pesos).'</th>';
						$clase = "";
						
						
						if($sumaPORCENTAJE[$th] >= 0) {$clase = "positivoTotal";}
						else { $clase = "negativoTotal";	}
						echo '<th class="ta_r '.$clase.'">'.$sumaPORCENTAJE[$th].' %</th>';
						$clase = "";
						$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaPPTO[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);

						if($sumaPPTO[$th] >= 0) 
						{
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						else 
						{ 
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaREAL[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						if($sumaREAL[$th] >= 0) 
						{
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						else 
						{ 
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						$Letra++;
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaPORCENTAJE[$th]." %");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						if($sumaPORCENTAJE[$th] >= 0) 
						{
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						else 
						{ 
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						$Letra++;
						if($banderaSumar == 1)
						{
							$primerNivelPPTO[$th] += $sumaPPTO[$th];
							$primerNivelREAL[$th] += $sumaREAL[$th];
							$primerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$primerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 2)
						{
							$segundoNivelPPTO[$th] += $sumaPPTO[$th];
							$segundoNivelREAL[$th] += $sumaREAL[$th];
							$segundoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$segundoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 3)
						{
							$tercerNivelPPTO[$th] += $sumaPPTO[$th];
							$tercerNivelREAL[$th] += $sumaREAL[$th];
							$tercerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$tercerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 4)
						{
							$cuartoNivelPPTO[$th] += $sumaPPTO[$th];
							$cuartoNivelREAL[$th] += $sumaREAL[$th];
							$cuartoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$cuartoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 5)
						{
							$quintoNivelPPTO[$th] += $sumaPPTO[$th];
							$quintoNivelREAL[$th] += $sumaREAL[$th];
							$quintoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$quintoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 6)
						{
							$sextoNivelPPTO[$th] += $sumaPPTO[$th];
							$sextoNivelREAL[$th] += $sumaREAL[$th];
							$sextoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							$sextoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
				}
				
				if($lineaTotalPPTO >= 0) {$clase = "positivoTotal";}
				else { $clase = "negativoTotal";	}
				echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaTotalPPTO,pesos).'</th>';
				$clase = "";
				
				if($lineaTotalPPTO >= 0) {$clase = "positivoTotal";}
				else { $clase = "negativoTotal";	}
				echo '<th class="ta_r">'.formatoMoneda($lineaTotalREAL,pesos).'</th>';
				$clase = "";
				
				if($lineaTotalPORCENTAJE >= 0) {$clase = "positivoTotal";}
				else { $clase = "negativoTotal";	}
				echo '<th class="ta_r">'.$lineaTotalPORCENTAJE.' %</th>';
				$clase = "";
				echo '</tr>';
				echo '<tr height="10"></tr>';
				echo '<tr height="10"></tr>';
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				if($lineaTotalPPTO >= 0) 
				{
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				else 
				{ 
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				$Letra++;
				$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				if($lineaTotalREAL >= 0) 
				{
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				else 
				{ 
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				$Letra++;
				$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalPORCENTAJE." %");
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				if($lineaTotalPORCENTAJE >= 0) 
				{
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				else 
				{ 
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				$Letra++;
				$keyExcel++;
				$keyExcelEspacio = $keyExcel;
				$keyExcel++;
				$Letra = "A";
				
				if($banderaSumar == 1)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';								  
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';
						echo '</tr>';
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";	
				}

				if($banderaEERRSuma == 2)
				{
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">RESULTADO POR DEPARTAMENTO </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "RESULTADO POR DEPARTAMENTO");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalSegundoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]));
							//$totalSegundoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]));
							//$totalSegundoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]));
							//$totalSegundoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]));
							
							if($totalSegundoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSegundoPPTO,pesos).'</th>';
							$clase = "";
							
							// if($totalSegundoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSegundoREAL,pesos).'</th>';
							// $clase = "";
							
							// if($totalSegundoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalSegundoPORCENTAJE.' %</th>';
							// $clase = "";
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalSegundoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalSegundoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;

							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoPORCENTAJE." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalSegundoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;

							$segundaLineaPPTO += $totalSegundoPPTO;
							// $segundaLineaREAL += $totalSegundoREAL;
							// $segundaLineaACUMULADO += $totalSegundoACUMULADO;
							// $segundaLineaPORCENTAJE += ($segundaLineaREAL/$segundaLineaPPTO);
					}
					
					if($segundaLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($segundaLineaPPTO,pesos).'</th>';
					$clase = "";
					
					// if($segundaLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($segundaLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// if($segundaLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$segundaLineaPORCENTAJE.' %</th>';
					// $clase = "";
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($segundaLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;

					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($segundaLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;
					
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaPORCENTAJE." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($segundaLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;

					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";	
					
				}
				if($banderaSumar == 2)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$Letra++;						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';
						echo '</tr>';
						
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				if($banderaSumar == 3)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';
						echo '</tr>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				
				if($banderaEERRSuma == 4)
				{
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">EBITDA </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "EBITDA");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalCuartoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]));
							$totalCuartoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]));
							$totalCuartoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]));
							$totalCuartoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]));
							
							if($totalCuartoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.' ">'.formatoMoneda($totalCuartoPPTO,pesos).'</th>';
							$clase = "";
							
							
							if($totalCuartoREAL >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalCuartoREAL,pesos).'</th>';
							$clase = "";
							
							if($totalCuartoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.$totalCuartoPORCENTAJE.' %</th>';
							$clase = "";
							
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalCuartoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalCuartoREAL >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoPORCENTAJE." %");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalCuartoPORCENTAJE >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$cuartoLineaPPTO += $totalCuartoPPTO;
							$cuartoLineaREAL += $totalCuartoREAL;
							$cuartoLineaPORCENTAJE += ($cuartoLineaREAL/$cuartoLineaPPTO);
							$cuartoLineaACUMULADO += $totalCuartoACUMULADO;
					}
					
					if($cuartoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($cuartoLineaPPTO,pesos).'</th>';
					$clase = "";
					
					if($cuartoLineaREAL >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($cuartoLineaREAL,pesos).'</th>';
					$clase = "";
					
					if($cuartoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.$cuartoLineaPORCENTAJE.' %</th>';
					$clase = "";
					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($cuartoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($cuartoLineaREAL >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaPORCENTAJE." %");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($cuartoLineaPORCENTAJE >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
				}
				
				if($banderaSumar == 4)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';
						echo '</tr>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				
				
				if($banderaEERRSuma == 5)
				{
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">RESULTADO OPERACIONAL </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "RESULTADO OPERACIONAL");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalQuintoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]));
							$totalQuintoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]));
							$totalQuintoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]));
							$totalQuintoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]));
							
							if($totalQuintoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalQuintoPPTO,pesos).'</th>';
							$clase = "";
							
							if($totalQuintoREAL >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalQuintoREAL,pesos).'</th>';
							$clase = "";
							
							if($totalQuintoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.$totalQuintoPORCENTAJE.' %</th>';
							$clase = "";
							
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalQuintoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalQuintoREAL >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, $totalQuintoPORCENTAJE." %");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalQuintoPORCENTAJE >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$quintoLineaPPTO += $totalQuintoPPTO;
							$quintoLineaREAL += $totalQuintoREAL;
							$quintoLineaPORCENTAJE += ($quintoLineaREAL/$quintoLineaPPTO);
							$quintoLineaACUMULADO += $totalQuintoACUMULADO;
					}
					if($quintoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($quintoLineaPPTO,pesos).'</th>';
					$clase = "";
					
					if($quintoLineaREAL >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($quintoLineaREAL,pesos).'</th>';
					$clase = "";
					
					if($quintoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.$quintoLineaPORCENTAJE.' %</th>';
					$clase = "";
					//echo '<th class="ta_r">'.formatoMoneda($quintoLineaACUMULADO,pesos).'</th>';
					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($quintoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);						
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);						
						
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($quintoLineaREAL >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaPORCENTAJE." %");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($quintoLineaPORCENTAJE >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
					
				}
				if($banderaSumar == 5)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							
						}
						echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';
						echo '</tr>';
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				
				if($banderaEERRSuma == 6)
				{
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">UTILIDAD ANTES DE IMPTO </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "UTILIDAD ANTES DE IMPTO");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalSextoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]) + abs($sextoNivelPPTO[$th]));
							$totalSextoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]) + abs($sextoNivelREAL[$th]));
							$totalSextoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]) + abs($sextoNivelPORCENTAJE[$th]));
							$totalSextoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]) + abs($sextoNivelACUMULADO[$th]));
							
							if($totalSextoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSextoPPTO,pesos).'</th>';
							$clase = "";
							
							if($totalSextoREAL >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSextoREAL,pesos).'</th>';
							$clase = "";
							
							if($totalSextoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.$totalSextoPORCENTAJE.' %</th>';
							$clase = "";
							
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalSextoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalSextoREAL >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoPORCENTAJE." %");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalSextoPORCENTAJE >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);	
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$sextoLineaPPTO += $totalSextoPPTO;
							$sextoLineaREAL += $totalSextoREAL;
							$sextoLineaPORCENTAJE += ($sextoLineaREAL/$sextoLineaPPTO);
							$sextoLineaACUMULADO += $totalSextoACUMULADO;
							
							
					}
					if($sextoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sextoLineaPPTO,pesos).'</th>';
					$clase = "";
					
					if($sextoLineaREAL >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					$sextoLineaREAL = (array_sum($sextoNivelREAL) + $quintoLineaREAL);
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sextoLineaREAL,pesos).'</th>';
					$clase = "";
					
					if($sextoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.$sextoLineaPORCENTAJE.' %</th>';
					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($sextoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($sextoLineaREAL >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaPORCENTAJE." %");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($sextoLineaPORCENTAJE >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					
					
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
					
					/****************************/
					//UTILIDAD NETA
					/****************************/
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">UTILIDAD NETA </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "UTILIDAD NETA");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalSextoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]) + abs($sextoNivelPPTO[$th]));
							$totalSextoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]) + abs($sextoNivelREAL[$th]));
							$totalSextoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]) + abs($sextoNivelPORCENTAJE[$th]));
							$totalSextoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]) + abs($sextoNivelACUMULADO[$th]));
							
							$totalNetoPPTO = ($totalSextoPPTO*0.24);
							$totalNetoREAL = ($totalSextoREAL*0.24);
							$totalNetoPORCENTAJE = $totalSextoPORCENTAJE;
							$totalNetoACUMULADO = ($totalSextoACUMULADO*0.24);
							
							
							if($totalNetoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalNetoPPTO,pesos).'</th>';
							$clase = "";
							
							if($totalNetoREAL >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalNetoREAL,pesos).'</th>';
							$clase ="";
							
							if($totalNetoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.$totalNetoPORCENTAJE.' %</th>';
							$clase = "";
							
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalNetoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalNetoREAL >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoPORCENTAJE." %");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalNetoPORCENTAJE >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							
							$netoLineaPPTO += $totalNetoPPTO;
							$netoLineaREAL += $totalNetoREAL;
							$netoLineaPORCENTAJE += ($netoLineaREAL/$netoLineaPPTO);
							$netoLineaACUMULADO += $totalNetoACUMULADO;
							
							
					}
					if($netoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($netoLineaPPTO,pesos).'</th>';
					$clase = "";
					
					if($netoLineaREAL >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($netoLineaREAL,pesos).'</th>';
					$clase = "";
					
					if($netoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.$netoLineaPORCENTAJE.' %</th>';
					$clase = "";
					
					echo '</tr>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($netoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($netoLineaREAL >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaPORCENTAJE." %");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($netoLineaPORCENTAJE >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$keyExcel++;
					$keyExcel++;
					$Letra = "A";
				}
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
	echo '</tbody></table>';
	echo '<br><br><br>';
	
	
	
		
		require_once ('inc/PHPExcel/IOFactory.php');
		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
		$objWriter->save($fname);
		
		echo  '<a href="'.$fname.'" class="descarga"><img src="imgs/excel.png" /> &nbsp; DESCARGAR ARCHIVO PARA EXCEL</a>';
		echo '<br>';
}
 
function nombreCC($cc)
{
	include('inc/conexion.php');
	$queryCC = " select CodiCC, DescCC from ".$dbs.".cwtccos where CodiCC = '".$cc."' ";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['DescCC'];
		}
	return $return;
}

function nombreCuentaAgrupada($idCuenta)
{
	include('inc/conexion.php');
	$queryCC = " select descTitulo from ".$dba.".DS_AgrupacionCuentas where idNivel = '".$idCuenta."' AND bdsession = '".$_SESSION['emp']['id']."' group by descTitulo ";
	//echo $queryCC."<br>";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['descTitulo'];
			//echo $return."<----<ksadjaksl<vr>";
		}
	return $return;
}

function nombreNivel($idNivel)
{
	//select tituloNivel from dscis.dbo.DS_nivelesEERR where idNivel = '1' group by tituloNivel
	include('inc/conexion.php');
	$queryCC = " select tituloNivel from ".$dba.".DS_nivelesEERR where idNivel = '".$idNivel."' AND bdsession = '".$_SESSION['emp']['id']."' group by tituloNivel ";
	//echo $queryCC."<br>";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['tituloNivel'];
			//echo $return."<----<ksadjaksl<vr>";
		}
	return $return;
}

function totalNivel($idNivel)
{
	include('inc/conexion.php');
	$queryCC = " select descripcionNivel from ".$dba.".DS_nivelesEERR where idNivel = '".$idNivel."' AND bdsession = '".$_SESSION['emp']['id']."' group by descripcionNivel ";
	//echo $queryCC."<br>";
	$rec = sqlsrv_query( $conn, $queryCC , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
		while($fila = sqlsrv_fetch_array($rec))
		{
			$return = $fila['descripcionNivel'];
		}
	return $return;
}
 
 function EERRACUMULADO($ano,$primerDia,$ultimoDia,$inicioAcumulado,$finAcumulado,$cc,$presupuesto,$mesini,$impuesto)
{
	include('inc/conexion.php');
	require_once('inc/PHPExcel.php');
	$fechaExcel   = date('dmY-His');
		$fname = "informes/EERR-".$fechaExcel.".xls";
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->getProperties()
			->setCreator("Disofi 2017")
			->setLastModifiedBy("Disofi 2017")
			->setTitle("EERR")
			->setSubject("EERR")
			->setDescription("EERR")
			->setKeywords("Office PHPExcel")
			->setCategory("EERR");

	$mes = date("m",strtotime($primerDia));
	$primerNivelPPTO = array(null);
	$segundoNivelPPTO = array(null);	
	$tercerNivelPPTO = array(null);
	$cuartoNivelPPTO = array(null);
	$quintoNivelPPTO = array(null);
	$sextoNivelPPTO = array(null);
	$arrayIDNivel = "";
	$arrayNombreNivel = "";
	$arrayDescripcionNivel = "";
	$indiceCabecera = 0;
	$finCiclo = 0;
	$contadorCC = count($cc);
	$indiceCiclo = 0;
	$arrayCiclos = "";
	$clase = "";
	$queryPosicion = "";

	//=========QUERY PARA AGRUPAR NIVELES===========================

	$queryNiveles =" SELECT idNivel, tituloNivel, descripcionNivel ";
	$queryNiveles.=" FROM ".$dba.".DS_nivelesEERR  ";
	$queryNiveles.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryNiveles.=" GROUP BY idNivel, tituloNivel, descripcionNivel ";
	$rec_b = sqlsrv_query( $conn, $queryNiveles , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($row = sqlsrv_fetch_array($rec_b))
	{
		$arrayIDNivel[$indiceCabecera] = $row['idNivel'];
		$arrayNombreNivel[$indiceCabecera] = $row["tituloNivel"];
		$arrayDescripcionNivel[$indiceCabecera] = $row["descripcionNivel"];
		$indiceCabecera++;
	}
	echo $queryNiveles." <br><br>";
	//=============================================================

	//========QUERY TRAE MES Y FECHA ACTUAL========================
	
	$fechaactual="select month(GETDATE()) as mes, YEAR(GETDATE())  as ano";
	$registros_fecha2=sqlsrv_query($conn,$fechaactual,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($registros_fecha=sqlsrv_fetch_array($registros_fecha2))
	{
		$ano=$registros_fecha['ano'];
		$mes=$registros_fecha['mes'];
	}
	//============================================================

	//========QUERY DE IMPUESTOS (FECHA Y AÑO ACTUAL)=============

	$consultarimpuesto="select impuesto as impuesto from  parametros where mes='".$mes."' and  ano='".$ano."'";
		$consulta_impuesto2=sqlsrv_query($conn,$consultarimpuesto,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	while($consulta_impuesto=sqlsrv_fetch_array($consulta_impuesto2))
	{
		$valorimpuesto=$consulta_impuesto['impuesto'];		
	}
	//===========================================================
	
	//======QUERY PARA TRAER LOS NIVELES Y POSTERIOR ORDENAR=====
	$queryPosicion.=" SELECT COUNT(idNivel) as Hasta, idNivel  ";
	$queryPosicion.=" FROM ".$dba.".DS_nivelesEERR ";
	$queryPosicion.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryPosicion.=" GROUP BY idNivel ";
	$rec_c = sqlsrv_query( $conn, $queryPosicion , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosPosicion = sqlsrv_num_rows($rec_c);
		while($rowPosicion = sqlsrv_fetch_array($rec_c))
		{
			$finCiclo+=$rowPosicion["Hasta"];
			$arrayBandera[$finCiclo] = $finCiclo;
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
		//echo $queryPosicion."<br><br>";
	//==========================================================

	$real = "";
	$acumulado="";
	$porcentaje ="";
	$ppto = "";
	$indice = 0;
	$banderaSTR = 0;	
	$mesAcumulado = "";
	$querySabana = "";
	$resta = "";
	//echo $cc."<br>";
	//echo $cc[0];

	//======TOMA LOS DOS ULTIMOS NUMEROS DEL CENTRO DE COSTO=====

	for($a=0;$a<$contadorCC;$a++)
	{
		for($b=0;$b<count($arrayCiclos);$b++)
		{
			
			if($b == 0)
			{
				
				if($_SESSION['emp']['id'] == 'NUEVAHORNILLAS')
				{
					$resta = $cc[$a]; 
				}
				else
				{
					$resta = substr($cc[$a],0,2); 
				}
	//==========================================================

	//=========PREPARA QUERY CON RESULTADOS PARA CADA COLUMNA POR TANTOS CC TENGA (A)========

				//echo $contadorCC." CONTADORCC-PRIMER FOR <br>";
				//print_r ($arrayCiclos[$b]." ARRAY SEGUNDO FOR <br>");
				//echo $dba. " DBA <br>";
				//echo $_SESSION['emp']['id']." SESSION <br>";
				//echo $ano." AÑO <br>";
				//echo $presupuesto. " PRESUPUESTO <br>";
				//echo $resta." RESTA <br>";
				//echo $mesini." MESINICIAL <br>";
				//echo $a." Contador";
				
				$ppto.= " ROUND(".$dba.".returnPPTO".$_SESSION['emp']['id']."2('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) AS PPTO".$a.", ";
				$real.=" ISNULL(".$dba.".returnREAL".$_SESSION['emp']['id']."('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel),0)/1000 as REAL".$a."  ,  ";
				$porcentaje.=" Case ";
				$porcentaje.=" when ".$dba.".returnPPTO".$_SESSION['emp']['id']."2('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1) = 0 then 0 ";
				$porcentaje.=" ELSE ROUND((ROUND( ";
				$porcentaje.=" (".$dba.".returnREAL".$_SESSION['emp']['id']."('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel) ";
				$porcentaje.=" / ";
				$porcentaje.=" ".$dba.".returnPPTO".$_SESSION['emp']['id']."2('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)";
				$porcentaje.=" ),2)),2) END as PORCENTAJE".$a.", ";
				$acumulado.=" ".$dba.".returnRealAcumulado".$_SESSION['emp']['id']."('".$ano."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$inicioAcumulado."','".$finAcumulado."','".$resta."')/1000 as ACUMULADO".$a.", ";
			}				
		}
	//===================================================================================	
	}

	//echo $ppto." query ppto <br>";
	//echo $real." query real <br>";
	//echo $porcentaje. " query Porcentaje <br>";
	//echo $acumulado. " query Acumulado <br>";
	
	//====ELIMINA COMA DE ULTIMA QUERY(ACUMULADO) Y UTILIZA QUERYS PREVIAMENTE REALIZADAS PARA CADA COLUMNA======
	$acumulado = substr($acumulado, 0, -2);

	//PRUEBA PRESUPUESTO
	$ppto = substr($ppto,0,-2);
	//================
	for($a=0;$a<count($arrayNiveles);$a++)
	{
		//echo $a." Acumulativo For <br>";
		$querySabana.=" select nivel.orden, nivel.idCuenta,nivel.idNivel, ";
		$querySabana.=" ".$ppto;
		//======
		//$querySabana.=" ".$real;
		//$querySabana.=" ".$porcentaje;
		//$querySabana.=" ".$acumulado;
		//======
		$querySabana.=" from ".$dba.".DS_nivelesEERR  nivel ";
		$querySabana.=" INNER JOIN ".$dba.".[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel ";
		$querySabana.=" WHERE nivel.idNivel = '".$a."' AND nivel.bdsession = '".$_SESSION['emp']['id']."' ";
		$querySabana.=" group by nivel.orden, nivel.idCuenta,nivel.idNivel ";
		if($a == (count($arrayNiveles)-1))
		{
			
		}		
		else
		{
			$querySabana.=" UNION ALL ";
		}
	
	}
	echo $querySabana;
	//======================================================================================================
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', "")
		->setCellValue('B1', "")
		->setCellValue('C1', "")
		->setCellValue('D1', "ESTADO DE RESULTADOS CONSOLIDADO ACUMULADO A :".$finAcumulado)
		->setCellValue('E1', "")
		->setCellValue('F1', "")
		->setCellValue('G1', "")
		->setCellValue('H1', "")
		->setCellValue('I1', "")
		->setCellValue('J1', "")
		->setCellValue('K1', "")
		->setCellValue('L1', "")
		->setCellValue('M1', "");
		
		$objPHPExcel->getActiveSheet()->mergeCells("D1:J1");
				
	$keyExcel = 3;
	$Letra = "A";
	$excelCentro = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
        )
    );
	$excelLeft = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_LEFT,
        )
    );	
	$excelRight = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_RIGHT,
        )
    );
	$excelColorCabecera =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => '5ea85e')
        )
    );
	$excelColorTitulo =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        )
    );	
	$excelPositivo = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => '000000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelPositivoTotal = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => '000000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));
	
	$excelNegativo = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => 'FF0000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelNegativoTotal = array(
    'font'  => array(
        'bold'  => true,
        'color' => array('rgb' => 'FF0000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));	  
	$bordeIzqDer = array(
		  'borders' => array(
			'right' => array(
			  'style' => PHPExcel_Style_Border::BORDER_THIN
			),
			'left' => array(
			  'style' => PHPExcel_Style_Border::BORDER_THIN
			)
		  )
		);
	$bordeCompleto = array(
	  'borders' => array(
		'outline' => array(
		  'style' => PHPExcel_Style_Border::BORDER_THIN
		)
	  )
	);
	$fondoBlanco = array(
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$textoNegrita = array(
    'font' => array(
        'bold' => true
    )
	);
	$textoNegritaTitulo = array(
    'font' => array(
        'bold' => true,
		'size' => 12
    )
	);

	
	$objPHPExcel->getActiveSheet()->getStyle("D1:J1")->applyFromArray($excelCentro);
	$objPHPExcel->getActiveSheet()->getStyle("D1:J1")->applyFromArray($textoNegritaTitulo);
	
	
	if($contadorCC >0 && $contadorCC <5)
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
	echo '<div id="tablaContenedora" class="tablaContenedora planilla">';
	echo '<table border="1" cellpadding="0" cellspacing="0" width="'.$ancho.'%" class="scrollTable">';
	echo '<thead class="fixedHeader tit">';
	echo '<tr>
		<th class="ta_c">Nombre Cuenta</th>';
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "");
			$objPHPExcel->getActiveSheet()
				->getColumnDimension($Letra)
				->setAutoSize(true);
				
		$objPHPExcel->getActiveSheet()->getStyle("A1:AR200")->applyFromArray($fondoBlanco);		
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "Concepto");
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$objPHPExcel->getActiveSheet()->getRowDimension('3')->setRowHeight(40);
		
		$Letra++;
		
	for ($k=0;$k<$contadorCC;$k++)
	{
		
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, nombreCC($cc[$k]));
		$inicioLetra = $Letra;
		$Letra++;
		$Letra++;
		//$Letra++;
		$objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$Letra++;
		echo '<th class="ta_c" colspan="3">'.nombreCC($cc[$k]).'</th>';
	}
	
	$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "TOTALES");
		$inicioLetra = $Letra;
		//$Letra++;
		$Letra++;
		$Letra++;
		$objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$Letra++;
	//echo '<th class="ta_c" colspan="3">TOTALES</th></tr></thead>';
	/*FIN CABECERA*/
	
	$Letra = "A";
	$keyExcel++;
	$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "CLP MILES");
			$objPHPExcel->getActiveSheet()
				->getColumnDimension($Letra)
				->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$Letra++;
		
	echo '<tbody class="scrollContent">';
	echo '<tr class="stit ta_c">';
	echo '<th class="ta_l">'.nombreNivel(0).'</th>';
	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c">PPTO</th>';
			  /*echo '<th class="ta_c">PPTO</th>
			  <th class="ta_c">REAL</th>
			  <th class="ta_c">%</th>
			  ';*/
			  //<th class="ta_c">ACUM</th>
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$Letra++;	  

		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
		// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;	  
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
		// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;	  
		/*
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "ACUMULADO");
		$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$Letra++;	  	  
		*/
	}
	echo '<th class="ta_c">PPTO</th>';
		/*echo '
		<th class="ta_c">PPTO</th>
		<th class="ta_c">REAL</th>
		<th class="ta_c">%</th>
		';*/
		//<th class="ta_c">ACUM</th>
		$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "PPTO");
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$Letra++;
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
		// 	$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
		// 	$objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
	echo '</tr>';
	$banderaWhile = 1;
	$indiceShow = 0;
	$indiceRows = 0;
	$banderaEERRSuma = 0;
	$banderaSumar = 0;
	
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
	
	$test = 0;
	$banderaNivel = 0;
	$Letra = "A";
	$keyExcel++;
	$hrefPositivo = '';
	$hrefNegativo = '';
	$sumaPPTO = array(null);
	while($fila = sqlsrv_fetch_array($recSabana))
		{
			echo '<tr class="ta_c">';
			echo '<th class="ta_l">'.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreCuentaAgrupada($fila['idCuenta'])."");
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			$Letra++;
			for($th=0;$th<$contadorCC;$th++)
			{
					if($fila['PPTO'.$th] >= 0) {$clase = "positivo";}
					else { $clase = "negativo";	}
					
					if($fila['idCuenta'] == 21)
					{
						$fila['PPTO'.$th] = ($fila['PPTO'.$th] *-1);
					}
					
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($fila['PPTO'.$th],'pesos').'</th>';
					$clase = "";

					//===================Prueba solo presupuesto===========
					//if($fila['REAL'.$th] >= 0) {$clase = $hrefPositivo;}
					//else { $clase = $hrefNegativo;	}
					//if($fila['idCuenta'] == 24)
					//{
					//	$fila['REAL'.$th] = ($fila['REAL'.$th] *-1);
					//}
					//echo '<th class="ta_r "><a href="index.php?mod=saldos_acumulado_ver&id='.$fila['idCuenta'].'&b='.$mesini.'&c='.$ano.'&cc='.$cc[$th].'" target="_blank" '.$clase.' >'.formatoMoneda($fila['REAL'.$th],pesos).'</a></th>';
					//$clase = "";
					//=====================================================

					//===================Prueba solo presupuesto===========
					//if($fila['PORCENTAJE'.$th] >= 0) {$clase = "positivo";}
					//else { $clase = "negativo";	}
					//echo '<th class="ta_r '.$clase.'">'.$fila['PORCENTAJE'.$th].' %</th>';//columna %
					//$clase = "";
					//======================================================

					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['PPTO'.$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($fila['PPTO'.$th]));
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($fila['PPTO'.$th], 0, ',', '.'));
					number_format(1000.5, 2, '.', '');
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, 1231312321);
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($fila['PPTO'.$th] >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}	
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					$Letra++;
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['REAL'.$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);

					//===============================
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($fila['REAL'.$th], 0, ',', '.'));
					//===============================

					//$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);

					//=================================
					/*
					if($fila['REAL'.$th] >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					*/
					//=================================

					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					//$Letra++;
					
					//================================
					/*
					if($fila['PORCENTAJE'.$th]  >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					}
					*/
					//==============================

					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					
					//============================
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, ROUND($fila['PORCENTAJE'.$th])." %");
					//============================

					//$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					
					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					//$Letra++;
					
					$totalPPTO = array(null);
					$lineaPPTO = 0;
					$lineaTotalPPTO = 0;
					$lineaTotalFinalPPTO = 0;
					$sumaSegundoPPTO = array(null);

					$sumaPPTO[$th] += $fila['PPTO'.$th];
					//$sumaREAL[$th] += $fila['REAL'.$th];
					///////$sumaPORCENTAJE[$th] += $fila['PORCENTAJE'.$th];
					//$sumaPORCENTAJE[$th] = round($sumaREAL[$th]/$sumaPPTO[$th],2);
					//$sumaACUMULADO[$th] += $fila['ACUMULADO'.$th];
	
					$totalPPTO[$th] += $fila['PPTO'.$th];
					//$totalREAL[$th] += $fila['REAL'.$th]+2;
					///////////$totalPORCENTAJE[$th] += $fila['PORCENTAJE'.$th]+3;
					//$totalPORCENTAJE[$th] = round($totalREAL[$th]/$totalPPTO[$th],2);
					//$totalACUMULADO[$th] += $fila['ACUMULADO'.$th]+4;
					
					$lineaPPTO += $fila['PPTO'.$th];
					//$lineaREAL += $fila['REAL'.$th];
					///////////echo $lineaREAL." AAA<br>";
					//////////$lineaPORCENTAJE += $fila['PORCENTAJE'.$th];
					//$lineaPORCENTAJE = round($lineaREAL /$lineaPPTO,2);
					//$lineaACUMULADO += $fila['ACUMULADO'.$th];
					
					$lineaTotalPPTO += $fila['PPTO'.$th];
					//$lineaTotalREAL += $fila['REAL'.$th];
					///////////$lineaTotalPORCENTAJE += $fila['PORCENTAJE'.$th];
					//$lineaTotalPORCENTAJE = round($lineaTotalREAL/$lineaTotalPPTO,2);
					//$lineaTotalACUMULADO += $fila['ACUMULADO'.$th];
					
					$lineaTotalFinalPPTO += $fila['PPTO'.$th];
					//$lineaTotalFinalREAL += $fila['REAL'.$th];
					/////////////$lineaTotalFinalPORCENTAJE += $fila['PORCENTAJE'.$th];
					//$lineaTotalFinalPORCENTAJE = round($lineaTotalFinalREAL/$lineaTotalFinalPPTO,2);
					//$lineaTotalFinalACUMULADO += $fila['ACUMULADO'.$th];
					
					$sumaSegundoPPTO[$th];
					//$sumaSegundoReal[$th];
					//$sumaSegundoPorcentaje[$th];
					//$sumaSegundoAcumulado[$th];	
					
			}
			
			if($lineaPPTO >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaPPTO,'pesos').'</th>';
			$clase = "";
			
			// if($lineaREAL >= 0) {$clase = "positivo";}
			// else { $clase = "negativo";	}
			// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaREAL,pesos).'</th>';
			// $clase = "";
			
			// if($lineaPORCENTAJE >= 0) {$clase = "positivo";}
			// else { $clase = "negativo";	}
			// echo '<th class="ta_r '.$clase.'">'.$lineaPORCENTAJE.' %</th>';
			// $clase = "";
			//echo '<th class="ta_r">'.formatoMoneda($lineaACUMULADO,pesos).'</th>';
			echo '</tr>';
			
			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($lineaPPTO, 0, ',', '.'));
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			 //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelRight);
			
			if($lineaPPTO <> 1234567) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;

			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($lineaREAL, 0, ',', '.'));
			// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			// if($lineaREAL <> 12345678) 
			// {
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			// }
			// else 
			// { 
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			// }
			//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			//$Letra++;
			
			
			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($lineaPORCENTAJE), 0, ',', '.')." %");
			// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			// if($lineaPORCENTAJE <> 12345235) 
			// {
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			// }
			// else 
			// { 
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			// }
			//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			//$Letra++;
			$keyExcel++;
			
			
			
			
			$Letra = "A";
			$lineaPPTO = 0;
			$lineaREAL = 0;
			$lineaPORCENTAJE = 0;
			$lineaACUMULADO = 0;
			
			if($banderaWhile == $arrayCiclos[$indiceShow])
			{
				$indiceShow++;
				$banderaSumar++;
				$banderaWhile = 0;
				$indiceRows = 0;
				$banderaEERRSuma++;
				echo '<tr class="stit ta_c">';
				//echo '<th class="ta_c">TOTAL </th>';
				echo '<th class="ta_l">'.totalNivel($banderaEERRSuma-1).'</th>';
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, totalNivel($banderaEERRSuma-1));
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.'19')->applyFromArray($bordeIzqDer);
				$Letra++;
				
				for($th=0;$th<$contadorCC;$th++)
				{
						if($sumaPPTO[$th] >= 0) {$clase = "positivoTotal";}
						else { $clase = "negativoTotal";	}
						echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sumaPPTO[$th],'pesos').'</th>';
						$clase = "";
						
						// if($sumaREAL[$th] >= 0) {$clase = "positivoTotal";}
						// else { $clase = "negativoTotal";	}
						// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sumaREAL[$th],pesos).'</th>';
						// $clase = "";
						
						
						// if($sumaPORCENTAJE[$th] >= 0) {$clase = "positivoTotal";}
						// else { $clase = "negativoTotal";	}
						// echo '<th class="ta_r '.$clase.'">'.$sumaPORCENTAJE[$th].' %</th>';
						// $clase = "";

						//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaPPTO[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($sumaPPTO[$th], 0, ',', '.'));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						
						if($sumaPPTO[$th] <> 12311123) 
						{
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						else 
						{ 
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						}
						//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						$Letra++;
						//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaREAL[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($sumaREAL[$th], 0, ',', '.'));
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// if($sumaREAL[$th] <> 12311123) 
						// {
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// else 
						// { 
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						///$Letra++;
						
						
						//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaPORCENTAJE[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($sumaPORCENTAJE[$th]), 0, ',', '.')." %");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// if($sumaPORCENTAJE[$th] <> 12311123) 
						// {
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// else 
						// { 
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						//$Letra++;
						
						if($banderaSumar == 1)
						{
							//echo "SUMO EL 1 <br>";
							$primerNivelPPTO[$th] += $sumaPPTO[$th];
							//$primerNivelREAL[$th] += $sumaREAL[$th];
							//$primerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							//$primerNivelPORCENTAJE[$th] = round($primerNivelREAL[$th]/$primerNivelPPTO[$th],2);
							//$primerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							
						}
						if($banderaSumar == 2)
						{
							//echo "SUMO EL 2 <br>";
							$segundoNivelPPTO[$th] += $sumaPPTO[$th];
							//$segundoNivelREAL[$th] += $sumaREAL[$th];
							//////////$segundoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							//$segundoNivelPORCENTAJE[$th] = round($segundoNivelREAL[$th]/$segundoNivelPPTO[$th],2);
							//$segundoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 3)
						{
							//echo "SUMO EL 3 <br>";
							$tercerNivelPPTO[$th] += $sumaPPTO[$th];
							//$tercerNivelREAL[$th] += $sumaREAL[$th];
							/////////$tercerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							//tercerNivelPORCENTAJE[$th] = round($tercerNivelREAL[$th]/$tercerNivelPPTO[$th],2);
							//$tercerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 4)
						{
							//echo "SUMO EL 4 <br>";
							$cuartoNivelPPTO[$th] += $sumaPPTO[$th];
							//$cuartoNivelREAL[$th] += $sumaREAL[$th];
							//////////$cuartoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $cuartoNivelPORCENTAJE[$th] = round($cuartoNivelREAL[$th]/$cuartoNivelPPTO[$th],2);
							// $cuartoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							//print_r($cuartoNivelREAL);
						}
						if($banderaSumar == 5)
						{
							//echo "SUMO EL 5 <br>";
							$quintoNivelPPTO[$th] += $sumaPPTO[$th];
							// $quintoNivelREAL[$th] += $sumaREAL[$th];
							/////////$quintoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $quintoNivelPORCENTAJE[$th] = round($quintoNivelREAL[$th]/$quintoNivelPPTO[$th],2);
							// $quintoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						}
						if($banderaSumar == 6)
						{
							//echo "SUMO EL 6 <br>";
							$sextoNivelPPTO[$th] += $sumaPPTO[$th];
							// $sextoNivelREAL[$th] += $sumaREAL[$th];
							////////$sextoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $sextoNivelPORCENTAJE[$th] = round($sextoNivelREAL[$th]/$sextoNivelPPTO[$th],2);
							// $sextoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							//echo array_sum($sextoNivelREAL);
							//echo "<br>";
						}
				}
				
				if($lineaTotalPPTO >= 0) {$clase = "positivoTotal";}
				else { $clase = "negativoTotal";	}
				echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaTotalPPTO,'pesos').'</th>';
				$clase = "";
				
				// if($lineaTotalREAL >= 0) {$clase = "positivoTotal";}
				// else { $clase = "negativoTotal";	}
				// echo '<th class="ta_r">'.formatoMoneda($lineaTotalREAL,pesos).'</th>';
				// $clase = "";
				
				// if($lineaTotalPORCENTAJE >= 0) {$clase = "positivoTotal";}
				// else { $clase = "negativoTotal";	}
				// echo '<th class="ta_r">'.$lineaTotalPORCENTAJE.' %</th>';
				// $clase = "";

				//////echo '<th class="ta_r">'.formatoMoneda($lineaTotalACUMULADO,pesos).'</th>';
				
				echo '</tr>';
				echo '<tr height="10"></tr>';
				echo '<tr height="10"></tr>';
				
				//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($lineaTotalPPTO, 0, ',', '.'));
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				if($lineaTotalPPTO <> 12311123) 
				{
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				else 
				{ 
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				}
				//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				$Letra++;
				//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($lineaTotalREAL, 0, ',', '.'));
				// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				// if($lineaTotalREAL <> 12311123) 
				// {
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				// }
				// else 
				// { 
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				// }
				/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				//$Letra++;
				/////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaTotalPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
				// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($lineaTotalPORCENTAJE), 0, ',', '.')." %");
				// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				// if($lineaTotalPORCENTAJE <> 12311123) 
				// {
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				// }
				// else 
				// { 
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				// }
				//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
				//$Letra++;
				$keyExcel++;
				$keyExcelEspacio = $keyExcel;
				$keyExcel++;
				$Letra = "A";
				
				
				//echo $banderaSumar."<--- bandera SUMAR <br>";
				if($banderaSumar == 1)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>';
								  /*echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';*/								  
							//<th class="ta_c">ACUM</th>
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
							$Letra++;
							
						}
						
						echo '<th class="ta_c">PPTO</th>';
							/*echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';*/
							//<th class="ta_c">ACUM</th>
						echo '</tr>';
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						//echo " AAA ".$Letra.$keyExcelEspacio."<br>";
						$Letra++;
						$keyExcel++;
						$Letra = "A";	
				}

				if($banderaEERRSuma == 2)
				{
					//echo " BBB ".$Letra.$keyExcelEspacio."<br>";
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">RESULTADO POR DEPARTAMENTO </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "RESULTADO POR DEPARTAMENTO");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							
							$totalSegundoPPTO = ($primerNivelPPTO[$th] - $segundoNivelPPTO[$th]);
							//$totalSegundoREAL = ($primerNivelREAL[$th] - $segundoNivelREAL[$th]);
							//$totalSegundoPORCENTAJE = ($primerNivelPORCENTAJE[$th] - $segundoNivelPORCENTAJE[$th]);
							//$totalSegundoACUMULADO = ($primerNivelACUMULADO[$th] - $segundoNivelACUMULADO[$th]);
							
							
							
							if($totalSegundoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSegundoPPTO,'pesos').'</th>';
							$clase = "";
							
							// if($totalSegundoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSegundoREAL,pesos).'</th>';
							// $clase = "";
							
							// if($totalSegundoPORCENTAJE >= -10524654) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							
							///////$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO*100)),2)-100;
							///////$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO*100)),2);
							//if($totalSegundoPPTO > $totalSegundoREAL)
							//{
								///////$totalSegundoPORCENTAJE = ($totalSegundoPORCENTAJE - 100);
								///////$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO*100)),2)-100;
								//$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO)),2);
							//}
							// else
							// {
								/////$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO*100)),2)-100;
								//$totalSegundoPORCENTAJE = round((($totalSegundoREAL / $totalSegundoPPTO)),2);
							//}
							//echo '<th class="ta_r '.$clase.'">'.$totalSegundoPORCENTAJE.' %</th>';
							//$clase = "";
							//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalSegundoPPTO, 0, ',', '.'));
							//$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);

							if($totalSegundoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							$segundaLineaPPTO = 0;
							//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							/////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalSegundoREAL, 0, ',', '.'));
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							
							// if($totalSegundoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSegundoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($totalSegundoPORCENTAJE), 0, ',', '.')." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							
							// if($totalSegundoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;							
							$segundaLineaPPTO += $totalSegundoPPTO;
							//$segundaLineaREAL += $totalSegundoREAL;
							/////////$segundaLineaPORCENTAJE += $totalSegundoPORCENTAJE;
							//$segundaLineaPORCENTAJE = round($segundaLineaREAL/$segundaLineaPPTO,2);
							//$segundaLineaACUMULADO += $totalSegundoACUMULADO;
					}
					
					if($segundaLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($segundaLineaPPTO,'pesos').'</th>';
					$clase = "";
					
					// if($segundaLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($segundaLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// if($segundaLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$segundaLineaPORCENTAJE.' %</th>';
					// $clase = "";
				
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($segundaLineaPPTO, 0, ',', '.'));
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($segundaLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					/////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($segundaLineaREAL, 0, ',', '.'));
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($segundaLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					/////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					/////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $segundaLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($segundaLineaPORCENTAJE), 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($segundaLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";	
					
				}
				if($banderaSumar == 2)
				{
					//echo " CCC ".$Letra.$keyExcelEspacio."<br>";
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>';
								  /*
								  echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';
								  */
							//<th class="ta_c">ACUM</th>
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '<th class="ta_c">PPTO</th>';
							/*echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';*/
						echo '</tr>';
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				if($banderaSumar == 3)
				{
					//echo " banderaSumar3 ".$Letra.$keyExcelEspacio."<br>";
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						//echo '<th class="ta_c">Nombre Cuenta'.$banderaNivel.'</th>';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>';
								  /*echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';*/
								  //<th class="ta_c">ACUM</th>
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '<th class="ta_c">PPTO</th>';
							/*echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';*/
							//<th class="ta_c">ACUM</th>
						echo '</tr>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
						
						
				}
				
				if($banderaEERRSuma == 4)
				{
					//echo " banderaEERRSuma4 ".$Letra.$keyExcelEspacio."<br>";
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">EBITDA </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "EBITDA");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
						
						
							$totalCuartoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]));
							//$totalCuartoREAL = ($primerNivelREAL[$th] - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]));
							////////$totalCuartoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]));
							//$totalCuartoPORCENTAJE = ROUND(($totalCuartoREAL/$totalCuartoPPTO),2);
							//$totalCuartoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]));
							
							if($totalCuartoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.' ">'.formatoMoneda($totalCuartoPPTO,'pesos').'</th>';
							$clase = "";
							
							
							// if($totalCuartoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalCuartoREAL,pesos).'</th>';
							// $clase = "";
							
							// if($totalCuartoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalCuartoPORCENTAJE.' %</th>';
							// $clase = "";
							
							////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalCuartoPPTO, 0, ',', '.'));
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalCuartoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$cuartoLineaPPTO = 0;
							//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalCuartoREAL, 0, ',', '.'));
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalCuartoREAL, 0, ',', '.')." ");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalCuartoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
								//////formatoMoneda
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							/////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, ROUND($totalCuartoPORCENTAJE)."%");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalCuartoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							$cuartoLineaPPTO += $totalCuartoPPTO;
							//$cuartoLineaREAL += $totalCuartoREAL;
							//////////$cuartoLineaPORCENTAJE += $totalCuartoPORCENTAJE;
							//$cuartoLineaPORCENTAJE = round($cuartoLineaREAL/$cuartoLineaPPTO,2);
							//$cuartoLineaACUMULADO += $totalCuartoACUMULADO;
					}
					
					if($cuartoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($cuartoLineaPPTO,'pesos').'</th>';
					$clase = "";
					
					// if($cuartoLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($cuartoLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// if($cuartoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$cuartoLineaPORCENTAJE.' %</th>';
					// $clase = "";
					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($cuartoLineaPPTO, 0, ',', '.'));
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($cuartoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($cuartoLineaREAL, 0, ',', '.'));
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($cuartoLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($cuartoLineaPORCENTAJE), 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($cuartoLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
				}
				
				if($banderaSumar == 4)
				{
						//echo " banderaSumar ".$Letra.$keyExcelEspacio."<br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>';
								  /*echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';*/
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
						}
						echo '<th class="ta_c">PPTO</th>';
							/*echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';*/
						echo '</tr>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
				}
				
				
				if($banderaEERRSuma == 5)
				{
					//echo " banderaEERRSuma5 ".$Letra.$keyExcelEspacio."<br>";
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">RESULTADO OPERACIONAL </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "RESULTADO OPERACIONAL");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalQuintoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]));
							//$totalQuintoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]));
							/////////$totalQuintoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]));
							//$totalQuintoPORCENTAJE = ROUND(($totalQuintoREAL/totalQuintoPPTO),2);
							//$totalQuintoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]));
							
							if($totalQuintoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalQuintoPPTO,'pesos').'</th>';
							$clase = "";
							
							// if($totalQuintoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalQuintoREAL,pesos).'</th>';
							// $clase = "";
							
							// if($totalQuintoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalQuintoPORCENTAJE.' %</th>';
							// $clase = "";
							
							//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalQuintoPPTO, 0, ',', '.'));
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalQuintoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$quintoLineaPPTO = 0;
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalQuintoREAL, 0, ',', '.'));
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalQuintoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, number_format(ROUND($totalQuintoPORCENTAJE), 0, ',', '.')." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalQuintoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							//////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							$quintoLineaPPTO += $totalQuintoPPTO;
							//$quintoLineaREAL += $totalQuintoREAL;
							////////$quintoLineaPORCENTAJE += $totalQuintoPORCENTAJE;
							//$quintoLineaPORCENTAJE = round($quintoLineaREAL/$quintoLineaPPTO,2);
							//$quintoLineaACUMULADO += $totalQuintoACUMULADO;
					}
					if($quintoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($quintoLineaPPTO,'pesos').'</th>';
					$clase = "";
					
					// if($quintoLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($quintoLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// if($quintoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$quintoLineaPORCENTAJE.' %</th>';
					// $clase = "";
					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($quintoLineaPPTO, 0, ',', '.'));
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($quintoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($quintoLineaREAL, 0, ',', '.'));
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($quintoLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($quintoLineaPORCENTAJE), 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($quintoLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					$keyExcel++;
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
					
				}
				if($banderaSumar == 5)
				{
						//echo " banderaSumar5 ".$Letra.$keyExcelEspacio."<br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$Letra++;
						
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>';
								  /*echo '<th class="ta_c">PPTO</th>
								  <th class="ta_c">REAL</th>
								  <th class="ta_c">%</th>
								  ';*/
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							$Letra++;
							
						}
						echo '<th class="ta_c">PPTO</th>';
							/*echo '
							<th class="ta_c">PPTO</th>
							<th class="ta_c">REAL</th>
							<th class="ta_c">%</th>
							';*/
							//<th class="ta_c">ACUM</th>
						echo '</tr>';
						
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						$Letra++;
						$keyExcel++;
						$Letra = "A";
						
				}
				
				if($banderaEERRSuma == 6)
				{
					//echo " banderaEERRSuma6 ".$Letra.$keyExcelEspacio."<br>";
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">UTILIDAD ANTES DE IMPTO </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "UTILIDAD ANTES DE IMPTO");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					for($th=0;$th<$contadorCC;$th++)
					{
						//quintoLineaREAL
							$totalSextoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]) + abs($sextoNivelPPTO[$th]));
							//$totalSextoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]) + abs($sextoNivelREAL[$th]));
							///////$totalSextoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]) + abs($sextoNivelPORCENTAJE[$th]));
							//$totalSextoPORCENTAJE = round(($totalSextoREAL/$totalSextoPPTO),2);
							//$totalSextoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]) + abs($sextoNivelACUMULADO[$th]));
							
							if($totalSextoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSextoPPTO,'pesos').'</th>';
							$clase = "";
							
							// if($totalSextoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalSextoREAL,pesos).'</th>';
							// $clase = "";
							
							// if($totalSextoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalSextoPORCENTAJE.' %</th>';
							// $clase = "";
														
							///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalSextoPPTO, 0, ',', '.'));
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalSextoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$sextoLineaPPTO = 0;
							//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalSextoREAL, 0, ',', '.'));
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalSextoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalSextoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($totalSextoPORCENTAJE), 0, ',', '.')." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalSextoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							$sextoLineaPPTO += $totalSextoPPTO;
							//$sextoLineaREAL += $totalSextoREAL;
							///////$sextoLineaPORCENTAJE += $totalSextoPORCENTAJE;
							//$sextoLineaPORCENTAJE = round($sextoLineaREAL/$sextoLineaPPTO,2);
							//$sextoLineaACUMULADO += $totalSextoACUMULADO;
					}
					if($sextoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sextoLineaPPTO,'pesos').'</th>';
					$clase = "";
					
					// if($sextoLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// $sextoLineaREAL = (array_sum($sextoNivelREAL) + $quintoLineaREAL);
					////////echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sextoLineaREAL,pesos).' - '.array_sum($sextoNivelREAL).'</th>';
					//echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sextoLineaREAL,pesos).'</th>';
					///////quintoLineaREAL
					//$clase = "";
					
					// if($sextoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$sextoLineaPORCENTAJE.' %</th>';					
					echo '</tr>';
					echo '<tr height="10"></tr>';
					echo '<tr height="10"></tr>';	
					
					///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($sextoLineaPPTO, 0, ',', '.'));
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($sextoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($sextoLineaREAL, 0, ',', '.'));
					//$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelRight);
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					// if($sextoLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sextoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($sextoLineaPORCENTAJE), 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($sextoLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					/////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					$keyExcel++;		
					$keyExcelEspacio = $keyExcel;
					$keyExcel++;
					$Letra = "A";
					
					
					/****************************/
					//UTILIDAD NETA
					/****************************/
					echo '<tr class="stit ta_c">';
					echo '<th class="ta_c">UTILIDAD NETA </th>';
					$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "UTILIDAD NETA");
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					$Letra++;
					
					$impuestoactual="select impuesto  as impuesto from  dscis.dbo.Parametros";
					$valoractual=sqlsrv_query($conn,$impuestoactual,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
						while($impuestos=sqlsrv_fetch_array($valoractual))
					{
					$impuestovaloractual=$impuestos['impuesto'];
				
				
					}
					$fechaactual="select month(GETDATE()) as mes, YEAR(GETDATE())  as ano";
					$registros_fecha2=sqlsrv_query($conn,$fechaactual,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
					while($registros_fecha=sqlsrv_fetch_array($registros_fecha2))
					{
					$mes=$registros_fecha['mes'];
					$ano=$registros_fecha['ano'];
				
					}
					$consultarimpuesto="select impuesto as impuesto from  parametros where mes='".$mes."' and  ano='".$ano."'";
					$consulta_impuesto2=sqlsrv_query($conn,$consultarimpuesto,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
					while($consulta_impuesto=sqlsrv_fetch_array($consulta_impuesto2))
					{
						$valorimpuesto=$consulta_impuesto['impuesto'];		
					}
						
					if($impuesto==$valorimpuesto)
					{
						$valorimpuesto=$valorimpuesto;
					}
					else
					{
						$modificaimpuesto="update parametros  set impuesto ='".$impuesto."' where impuesto='".$valorimpuesto."'";
					
						$impuestomod=sqlsrv_query($conn,$modificaimpuesto,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
						$impuestonuevo="select impuesto as impuesto from  parametros where mes='".$mes."' and  ano='".$ano."'";
						$impuesto_modificado=sqlsrv_query($conn,$impuestonuevo,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
						while($impuesto_modificado1=sqlsrv_fetch_array($impuesto_modificado))
						{
							$valorimpuesto=$impuesto_modificado1['impuesto'];		
						}
						$insertarimpuesto="insert into registrarimpuesto(impuesto,mes,ano) values('".$impuesto."','".$mes."','".$ano."')";
						$insertandoimpuesto=sqlsrv_query($conn,$insertarimpuesto,array(),array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
						}

                   
						$valorimpuestoacalcular=100-$valorimpuesto;
						$valorimpuestoacalcular=$valorimpuestoacalcular/100;
			
					if($ano == '2017')
					{
						$porcentajeUtilidadNeta = $valorimpuestoacalcular; //27
					}
					else
					{
						$porcentajeUtilidadNeta = $valorimpuestoacalcular; //27 
					}
					
					for($th=0;$th<$contadorCC;$th++)
					{
							$totalSextoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]) + abs($sextoNivelPPTO[$th]));
							// $totalSextoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]) + abs($sextoNivelREAL[$th]));
							//////$totalSextoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]) + abs($sextoNivelPORCENTAJE[$th]));
							// $totalSextoPORCENTAJE = round(($totalSextoREAL/$totalSextoPPTO),2);
							
							// $totalSextoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]) + abs($sextoNivelACUMULADO[$th]));
							
							$totalNetoPPTO = ($totalSextoPPTO*$valorimpuestoacalcular);
							// $totalNetoREAL = ($totalSextoREAL*$valorimpuestoacalcular);
							// $totalNetoPORCENTAJE = $totalSextoPORCENTAJE;
							// $totalNetoACUMULADO = ($totalSextoACUMULADO*$valorimpuestoacalcular);
							
							
							if($totalNetoPPTO >= 0) {$clase = "positivoTotal";}
							else { $clase = "negativoTotal";	}
							echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalNetoPPTO,'pesos').'</th>';
							$clase = "";
							
							// if($totalNetoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalNetoREAL,pesos).'</th>';
							// $clase ="";
							
							// if($totalNetoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalNetoPORCENTAJE.' %</th>';
							// $clase = "";
							
							///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalNetoPPTO, 0, ',', '.'));
							$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							if($totalNetoPPTO >= 0) 
							{
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							else 
							{ 
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							}
							///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							$Letra++;
							$netoLineaPPTO = 0;
							////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalNetoREAL, 0, ',', '.'));
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalNetoREAL >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							/////////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($totalNetoPORCENTAJE), 0, ',', '.')." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalNetoPORCENTAJE >= 0) 
							// {
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
							// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							////////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							//$Letra++;
							
							$netoLineaPPTO += $totalNetoPPTO;
							//$netoLineaREAL += $totalNetoREAL;
							////////$netoLineaPORCENTAJE += $totalNetoPORCENTAJE;
							//$netoLineaPORCENTAJE = round($netoLineaREAL/$netoLineaPPTO,2);
							//$netoLineaACUMULADO += $totalNetoACUMULADO;
					}
					//$netoLineaR = (($sextoLineaREAL * $valorimpuesto)/100);
					if($netoLineaPPTO >= 0) {$clase = "positivoTotal";}
					else { $clase = "negativoTotal";	}
					echo '<th class="ta_r '.$clase.'">'.formatoMoneda($netoLineaPPTO,'pesos').'</th>';
					$clase = "";
					
					// if($netoLineaR >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($netoLineaR,pesos).'</th>';
					// $clase = "";
					
					// if($netoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$netoLineaPORCENTAJE.' %</th>';
					// $clase = "";					
					echo '</tr>';
					//////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaPPTO, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($netoLineaPPTO, 0, ',', '.'));
					$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					if($netoLineaPPTO >= 0) 
					{
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					else 
					{ 
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					}
					//////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					$Letra++;
					///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($netoLineaR, 0, ',', '.'));
					//$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelRight);
					/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					// if($netoLineaREAL >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					/////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					///////$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $netoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($netoLineaPORCENTAJE), 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($netoLineaPORCENTAJE >= 0) 
					// {
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// 	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					
					//////FORMATO NUMERO===>$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					///////$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					//$Letra++;
					$keyExcel++;
					$keyExcel++;
					$Letra = "A";
				}
				//var_dump($sumaPPTO);
				//echo "<br><br>";
				
				$sumaREAL = "";
				$sumaPORCENTAJE = "";
				$sumaACUMULADO = "";	
				
				$lineaTotalPPTO = 0;
				$lineaTotalREAL = 0;
				$lineaTotalPORCENTAJE = 0;
				$lineaTotalACUMULADO = 0;
				$sumaPPTO = array(null);

			
				
			}
			else
			{
				$indiceRows =1;
			}
			$banderaWhile++;
			$banderaNivel++;
			
			/*
			$border_style= array('borders' => array('right' => array('style' => 
			PHPExcel_Style_Border::BORDER_THICK,'color' => array('argb' => '000000'),)));
			
			
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($border_style);
			*/
			
			
		}
	echo '</tbody></table>';
	echo '<br><br><br>';
	
	
	
		
		require_once ('inc/PHPExcel/IOFactory.php');
		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
		$objWriter->save($fname);
		
		echo  '<a href="'.$fname.'" class="descarga"><img src="imgs/excel.png" /> &nbsp; DESCARGAR ARCHIVO PARA EXCEL</a>';
		echo '<br>';
	
	
}


function mantenedorDistribucion()
{
	include('inc/conexion.php');
		
	$mes = date("m",strtotime($primerDia));
	//echo $mesini."MES ACTUAL<---<br>";
	//echo $ano."  A&ntilde;o <br>";
	//echo $primerDia."  primerDia <br>";
	//echo $ultimoDia."  ultimoDia <br>";
	//echo $inicioAcumulado." inicioAcumulado <br>";
	//echo $finAcumulado."  finAcumulados <br>";
	//echo $presupuesto." PPTO<br>";
	//echo $mes." MES<--<br>";
	//print_r($cc);	
	//echo "<br>";
	$arrayIDNivel = "";
	$arrayNombreNivel = "";
	$arrayDescripcionNivel = "";
	$indiceCabecera = 0;
	$finCiclo = 0;
	//$contadorCC = count($cc);
	$contadorCC = 1;
	$indiceCiclo = 0;
	$arrayCiclos = "";
	$clase = "";
	//echo $contadorCC."<--<br>";
	$querySabana = "";
	$queryNiveles =" SELECT idNivel, tituloNivel, descripcionNivel ";
	$queryNiveles.=" FROM ".$dba.".DS_nivelesEERR  ";
	$queryNiveles.=" WHERE bdsession = 'CIS' ";
	$queryNiveles.=" GROUP BY idNivel, tituloNivel, descripcionNivel ";
		//echo $queryNiveles."<br>";
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
		//echo $queryPosicion."<br>";
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
		$querySabana.=" select nivel.orden, nivel.idCuenta, ";
		$querySabana.=" ".$ppto;
		$querySabana.=" ".$real;
		$querySabana.=" ".$porcentaje;
		$querySabana.=" ".$acumulado;
		$querySabana.=" from ".$dba.".DS_nivelesEERR  nivel ";
		$querySabana.=" INNER JOIN ".$dba.".[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel ";
		$querySabana.=" WHERE nivel.idNivel = '".$a."' AND nivel.bdsession = '".$_SESSION['emp']['id']."' ";
		$querySabana.=" group by nivel.orden, nivel.idCuenta ";
		if($a == (count($arrayNiveles)-1))
		{
			
		}		
		else
		{
			$querySabana.=" UNION ALL ";
		}
		
	}

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
	echo '<div id="tablaContenedora" >';
	echo '<table border="1" cellpadding="0" cellspacing="0" class="scrollTable">';
	echo '<thead class="fixedHeader tit">';
	echo '<tr>
		<th class="ta_c">Nombre Cuenta</th>';
		
		
		
echo '<th class="ta_c">Descripci&oacute;n</th>';	
	
	  
	

	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c" colspan="3">'.$cc[$k].' - '.nombreCC($cc[$k]).'</th>';
	}
	
	echo '</tr></thead>';
	/*FIN CABECERA*/		
	echo '<tbody class="scrollContent">';
	echo '<tr class="stit ta_c">';
	echo '<th class="ta_l">'.nombreNivel(0).' nombreNivel</th>';
	for ($k=0;$k<$contadorCC;$k++)
	{
		echo '<th class="ta_c">% DISTRIBUCI&Oacute;N</th>
			  ';
		
	}

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
			//echo $banderaWhile."<<--<br>";
			//echo '<tr class="stit ta_c">'; COLOR
			echo '<tr class="ta_c">';
		echo '<th class="ta_c">'.$fila['idCuenta'].' - '.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			echo '<th class="ta_l">'.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			
			
			
			echo '<th class="ta_r"><input type="number" name="agrupacionCta'.$fila['idCuenta'].'" id="agrupacionCta'.$fila['idCuenta'].'" class="form-control" value="0"> </th>';
			$clase = "";
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
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  ';								  
							
						}
						
						echo '</tr>';
				}
				if($banderaSumar == 2)
				{
					//print_r($arrayNiveles);
					//echo $banderaSumar."<-- banderaSUMAR<br>br>";
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';					
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  ';
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
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  ';
								  //<th class="ta_c">ACUM</th>
							
						}
						
							//<th class="ta_c">ACUM</th>
						echo '</tr>';
						
						
						
				}
				
				if($banderaSumar == 4)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  ';
						}
						
						echo '</tr>';
						
				}

				if($banderaSumar == 5)
				{
						echo '<tr class="stit ta_c">';
						echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						for ($k=0;$k<$contadorCC;$k++)
						{
							echo '<th class="ta_c">PPTO</th>
								  ';
						}
						
						echo '</tr>';
				}
				
				
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
		echo "<td>&nbsp;</td><td><input type='button' id='enviarCC' name='enviarCC' value='Enviar' class='form-control'></td>";
		echo '</tr>';
	echo '</tbody></table>';

}

function selectCC($centrocosto)
{
	include('inc/conexion.php');
	$salida = "";
	$query = " select CodiCC, DescCC from ".$dbs.".cwtccos where activo = 'S' and DescCC <> '' AND DescCC IS NOT NULL AND nivelCC = 1 ";
	
	//echo $query."<br>";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="CC" id="CC" class="form-control" onchange="cargarDistribucion();">';
	$salida.='<option value="0">Seleccione Centro de Costo</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' '.$row['DescCC'].'</option>';
		
	}
	$salida.="</select>";
	echo $salida;
}



function selectCC2($centrocosto)
{
	include('inc/conexion.php');
	$salida = "";
	$query = " select CodiCC, DescCC from ".$dbs.".cwtccos where activo = 'S' and DescCC <> '' AND DescCC IS NOT NULL AND nivelCC = 1 and codicc='".$centrocosto."'";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="CC" id="CC" class="form-control" onchange="cargarDistribucion()">';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['CodiCC'].'">'.$row['CodiCC'].' '.$row['DescCC'].'</option>';
		
	}
	$salida.="</select>";
	echo $salida;
}


function selectAno()
{
		
		include('inc/conexion.php');
	$salida = "";
	$query = " select distinct ano from DS_DistribucionCC where ano<>'' order by ano asc";
	$rec = sqlsrv_query( $conn, $query , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registros = sqlsrv_num_rows($rec);
	$salida.='<select name="ano" id="ano" class="form-control" onchange="cargarDistribucion()">';
	$salida.='<option value="0">Seleccione A&ntilde;o</option>';
	while($row = sqlsrv_fetch_array($rec))
	{
		$salida.='<option value="'.$row['ano'].'">'.$row['ano'].'</option>';
		
	}
	$salida.="</select>";
	echo $salida;
	
}


function seleccionaAno()
{
	
	$ingreso.='<input type="text" id="anoingresado" style="background-color:white;">';
	echo $ingreso;
}

 function Forecast($ano,$primerDia,$ultimoDia,$inicioAcumulado,$finAcumulado,$cc,$presupuesto,$mesini)
{
	include('inc/conexion.php');
	require_once('inc/PHPExcel.php');
	$fechaExcel   = date('dmY-His');
		$fname = "informes/Forecast-".$fechaExcel.".xls";
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->getProperties()
			->setCreator("Disofi 2017")
			->setLastModifiedBy("Disofi 2017")
			->setTitle("Forecast")
			->setSubject("Forecast")
			->setDescription("Forecast")
			->setKeywords("Office PHPExcel")
			->setCategory("Forecast");
	
	$mes = date("m",strtotime($primerDia));
	//echo $mesini."MES ACTUAL<---<br>";
	//$mesini = '12';
	
	
	if($mesini <= '09')
	{
		$mesini = $mesini +1;
		$mesini = "0".$mesini;
	}
	//echo $mesini."MES NUEVO<---<br>";
	//echo $ano."  A&ntilde;o <br>";
	//echo $primerDia."  primerDia <br>";
	//echo $ultimoDia."  ultimoDia <br>";
	//echo $inicioAcumulado." inicioAcumulado <br>";
	//echo $finAcumulado."  finAcumulados <br>";
	//echo $presupuesto." PPTO<br>";
	//echo $mes." MES<--<br>";
	//print_r($cc);	
	//echo "<br>";
	$arrayIDNivel = "";
	$arrayNombreNivel = "";
	$arrayDescripcionNivel = "";
	$indiceCabecera = 0;
	$finCiclo = 0;
	$contadorCC = count($cc);
	$indiceCiclo = 0;
	$arrayCiclos = "";
	$clase = "";
	//echo $contadorCC."<--<br>";
	$querySabana = "";
	$queryNiveles =" SELECT idNivel, tituloNivel, descripcionNivel ";
	$queryNiveles.=" FROM ".$dba.".DS_nivelesEERR  ";
	$queryNiveles.=" WHERE bdsession = '".$_SESSION['emp']['id']."' ";
	$queryNiveles.=" GROUP BY idNivel, tituloNivel, descripcionNivel ";
		//echo $queryNiveles."<br>";
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
		//echo $queryPosicion."<br>";
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
	$mesAcumulado = "";

	//echo $mesini."<br>";
	for($a=0;$a<$contadorCC;$a++)
	{
		for($b=0;$b<count($arrayCiclos);$b++)
		{
			
			if($b == 0)
			{
				//echo $cc[$a]."<br>";
				$resta = substr($cc[$a],0,2); 

				$real.=" 
				(ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel),0)/1000 ) as REAL".$a."  ,";
				
				$realTT.=
				" 
				(ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',0,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',0,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',0),0)/1000 ) as REALTT".$a."  ,
				";
				
				
				$porcentajeeee.=
				"
				ROUND(((ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel),0)/1000 )
				/
				(ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',0,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',0,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',0),0)/1000 ))*100,2)
				AS PORCENTAJE".$a." ,";
				
				$porcentaje.= "
				CASE 
				WHEN ROUND((ROUND([DSCIS].[dbo].returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0)
				 + 
				ISNULL([DSCIS].[dbo].returnREAL('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel),0)/1000 ),0) = 0
				THEN '0'
				WHEN 
				(ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',0,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',0,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',0),0)/1000 ) = 0
				THEN '02'
				
				
				ELSE
				ROUND(((ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',nivel.idCuenta,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',nivel.idCuenta,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',nivel.idNivel),0)/1000 )
				/
				(ROUND(".$dba.".returnPPTOForecast('".$ano."','".$presupuesto."','".$resta."',0,'".$_SESSION['emp']['id']."','".$mesini."',1)/1000,0) + 
				ISNULL(".$dba.".returnREAL('".$ano."',0,'".$inicioAcumulado."','".$ultimoDia."','".$resta."','".$_SESSION['emp']['id']."',0),0)/1000 ))*100,2)
				END AS PORCENTAJE".$a." ,";
				
				
				
				/*
				CASE WHEN ROUND((ROUND([DSCIS].[dbo].returnPPTOForecast('2017','CIS2017-2','07',0,'CIS','10',1)/1000,0)
				 + 
				ISNULL([DSCIS].[dbo].returnREAL('2017',0,'01/01/2017','31/10/2017','07','CIS',0),1)/1000 ),0) = 0 THEN 'NO DIVIDO'
				ELSE '11111'
				END AS fin
				*/
				/*
				THEN 'aaa'

			END
			as asdsadsadsa
				*/
			}				
		}
		
	}
	
	$porcentaje = substr($porcentaje, 0, -2);
	for($a=0;$a<count($arrayNiveles);$a++)
	//for($a=0;$a<1;$a++)
	{
		$querySabana.=" select nivel.orden, nivel.idCuenta,nivel.idNivel, ";
		$querySabana.=" ".$ppto;
		$querySabana.=" ".$real;
		$querySabana.=" ".$realTT;
		$querySabana.=" ".$porcentaje;
		$querySabana.=" from ".$dba.".DS_nivelesEERR  nivel ";
		$querySabana.=" INNER JOIN ".$dba.".[DS_AgrupacionCuentas] agrupacion ON nivel.idCuenta = agrupacion.idNivel ";
		$querySabana.=" WHERE nivel.idNivel = '".$a."' AND nivel.bdsession = '".$_SESSION['emp']['id']."' ";
		$querySabana.=" group by nivel.orden, nivel.idCuenta,nivel.idNivel ";
		if($a == (count($arrayNiveles)-1))
		{
			
		}		
		else
		{
			$querySabana.=" UNION ALL ";
		}
		
	}
		
		
		//echo $querySabana."<br><br>";
		//break;
	$recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	$registrosSabana = sqlsrv_num_rows($recSabana);
	//echo  $registrosSabana."<--- registros <br>";
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			//echo $fila[0]."<br>";
		}
				
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', "")
		->setCellValue('B1', "")
		->setCellValue('C1', "")
		->setCellValue('D1', "FORECAST :".$finAcumulado)
		->setCellValue('E1', "")
		->setCellValue('F1', "")
		->setCellValue('G1', "")
		->setCellValue('H1', "")
		->setCellValue('I1', "")
		->setCellValue('J1', "")
		->setCellValue('K1', "")
		->setCellValue('L1', "")
		->setCellValue('M1', "");
		
		$objPHPExcel->getActiveSheet()->mergeCells("D1:J1");
				
	$keyExcel = 3;
	$Letra = "A";
	$excelCentro = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
        )
    );
	//'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
	$excelLeft = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_LEFT,
        )
    );
	
	$excelRight = array(
        'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_RIGHT,
        )
    );
	$excelColorCabecera =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => '5ea85e')
        )
    );
	$excelColorTitulo =  array(
        'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        )
    );
	
	$excelPositivo = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => '000000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelPositivoTotal = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => '000000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));
	
	$excelNegativo = array(
    'font'  => array(
        //'bold'  => true,
        'color' => array('rgb' => 'FF0000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$excelNegativoTotal = array(
    'font'  => array(
        'bold'  => true,
        'color' => array('rgb' => 'FF0000')
        //'size'  => 15,
        //'name'  => 'Verdana'
    ),
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'e5e5e5')
        ));	  
	$bordeIzqDer = array(
		  'borders' => array(
			'right' => array(
			  'style' => PHPExcel_Style_Border::BORDER_THIN
			),
			'left' => array(
			  'style' => PHPExcel_Style_Border::BORDER_THIN
			)
		  )
		);
	$bordeCompleto = array(
	  'borders' => array(
		'outline' => array(
		  'style' => PHPExcel_Style_Border::BORDER_THIN
		)
	  )
	);

	$fondoBlanco = array(
	'fill' => array(
            'type' => PHPExcel_Style_Fill::FILL_SOLID,
            'color' => array('rgb' => 'FFFFFF')
        ));
		
	$textoNegrita = array(
    'font' => array(
        'bold' => true
    )
	);
	$textoNegritaTitulo = array(
    'font' => array(
        'bold' => true,
		'size' => 12
    )
	);

	
	$objPHPExcel->getActiveSheet()->getStyle("D1:J1")->applyFromArray($excelCentro);
	$objPHPExcel->getActiveSheet()->getStyle("D1:J1")->applyFromArray($textoNegritaTitulo);
	
	
	if($contadorCC >0 && $contadorCC <5)
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
	echo '<div id="tablaContenedora" class="tablaContenedora planilla">';
	echo '<table border="1" cellpadding="0" cellspacing="0" width="'.$ancho.'%" class="scrollTable">';
	echo '<thead class="fixedHeader tit">';
	echo '<tr>
		<th class="ta_c">Nombre Cuenta</th>';
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "");
			$objPHPExcel->getActiveSheet()
				->getColumnDimension($Letra)
				->setAutoSize(true);
				
		$objPHPExcel->getActiveSheet()->getStyle("A1:AR200")->applyFromArray($fondoBlanco);		
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($Letra.$keyExcel, "Concepto");
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		$objPHPExcel->getActiveSheet()->getRowDimension('2')->setRowHeight(40);
		
		$Letra++;
		
	//echo '<th class="ta_c">Descripci&oacute;n</th>';	
	
	  
	

	// for ($k=0;$k<$contadorCC;$k++)
	// {
		
		// $objPHPExcel->setActiveSheetIndex(0)
			// ->setCellValue($Letra.$keyExcel, nombreCC($cc[$k]));
		// $inicioLetra = $Letra;
		// $Letra++;
		// //$Letra++;
		// //$Letra++;
		// $objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
		// echo '<th class="ta_c" colspan="2">'.nombreCC($cc[$k]).'</th>';
	// }
	
	// $objPHPExcel->setActiveSheetIndex(0)
			// ->setCellValue($Letra.$keyExcel, "TOTALES");
		// $inicioLetra = $Letra;
		// //$Letra++;
		// //$Letra++;
		// $Letra++;
		// $objPHPExcel->getActiveSheet()->mergeCells($inicioLetra.$keyExcel.":".$Letra.$keyExcel);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($excelColorCabecera);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($inicioLetra.$keyExcel.":".$Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
	// echo '<th class="ta_c" colspan="2">TOTALES</th></tr></thead>';
	// /*FIN CABECERA*/
	
	// $Letra = "A";
	// $keyExcel++;
	// $objPHPExcel->setActiveSheetIndex(0)
			// ->setCellValue($Letra.$keyExcel, "CLP MILES");
			// $objPHPExcel->getActiveSheet()
				// ->getColumnDimension($Letra)
				// ->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
		
	// echo '<tbody class="scrollContent">';
	// echo '<tr class="stit ta_c">';
	// echo '<th class="ta_l">'.nombreNivel(0).'</th>';
	// for ($k=0;$k<$contadorCC;$k++)
	// {
		// echo '
			  // <th class="ta_c">REAL</th>
			  // <th class="ta_c">%</th>
			  // ';	  
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
		// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;	  
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
		// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;	  
	// }
	// echo '
		
		// <th class="ta_c">REAL</th>
		// <th class="ta_c">%</th>
		// ';
		// //<th class="ta_c">ACUM</th>
		
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "REAL");
			// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
		// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "%");
			// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra)->setAutoSize(true);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($textoNegrita);
		// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
		// $Letra++;
	// echo '</tr>';
	// $banderaWhile = 1;
	// $indiceShow = 0;
	// $indiceRows = 0;
	// $banderaEERRSuma = 0;
	// $banderaSumar = 0;
	// //print_r($arrayCiclos);
	// $recSabana = sqlsrv_query( $conn, $querySabana , array(), array( "Scrollable" => SQLSRV_CURSOR_KEYSET ));
	// $registrosSabana = sqlsrv_num_rows($recSabana);
	// //echo  $registrosSabana."<--- registros <br>";
	// //echo $querySabana."<br><br><br>";
	// $test = 0;
	// $banderaNivel = 0;
	// $Letra = "A";
	// $keyExcel++;
	// $hrefPositivo = '';
	// $hrefNegativo = '';
	// //$hrefPositivo = 'style="color:#000000"';
	// //$hrefNegativo = 'style="color:#FF0000"';
	// $banderaFlag = 0;
		while($fila = sqlsrv_fetch_array($recSabana))
		{
			//echo $banderaWhile."<<--<br>";
			//echo '<tr class="stit ta_c">'; COLOR
			echo '<tr class="ta_c">';
			echo '<th class="ta_l">'.nombreCuentaAgrupada($fila['idCuenta']).'</th>';
			$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreCuentaAgrupada($fila['idCuenta'])."");
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
			$Letra++;
			// for($th=0;$th<$contadorCC;$th++)
			// {
				
					// //echo $Letra.$keyExcelEspacio."<br>";
					// if($fila['REAL'.$th] >= 0) {$clase = $hrefPositivo;}
					// else { $clase = $hrefNegativo;	}
					// echo '<th class="ta_r "><a href="index.php?mod=saldos_acumulado_ver&id='.$fila['idCuenta'].'&b='.$mesini.'&c='.$ano.'&cc='.$cc[$th].'" target="_blank" '.$clase.' >'.formatoMoneda($fila['REAL'.$th],pesos).'</a></th>';
					// $clase = "";
					
					// if($fila['PORCENTAJE'.$th] >= 0) {$clase = "positivo";}
					// else { $clase = "negativo";	}
					// //echo '<th class="ta_r '.$clase.'">'.$fila['PORCENTAJE'.$th].' %</th>';
					// echo '<th class="ta_r '.$clase.'">'.ROUND($fila['PORCENTAJE'.$th]).' %</th>';
					// $clase = "";
					
					
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($fila['REAL'.$th], 0, ',', '.'));
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $fila['REAL'.$th]);
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($fila['REAL'.$th] >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					// $Letra++;
					
					// if($fila['PORCENTAJE'.$th]  >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, ROUND($fila['PORCENTAJE'.$th])." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);									
					// $Letra++;
					
					// $sumaPPTO[$th] += $fila['PPTO'.$th];
					// $sumaREAL[$th] += $fila['REAL'.$th];
					// $sumaPORCENTAJE[$th] += $fila['PORCENTAJE'.$th];
					// $sumaACUMULADO[$th] += $fila['ACUMULADO'.$th];
	
					// $totalPPTO[$th] += $fila['PPTO'.$th]+1;
					// $totalREAL[$th] += $fila['REAL'.$th]+2;
					// $totalPORCENTAJE[$th] += $fila['PORCENTAJE'.$th]+3;
					// $totalACUMULADO[$th] += $fila['ACUMULADO'.$th]+4;
					
					// $lineaPPTO += $fila['PPTO'.$th];
					// $lineaREAL += $fila['REAL'.$th];
					
					// if($banderaFlag == 0)
					// {
						// if($th == ($contadorCC -1))
						// {
							// //echo "CABECERA = ".$lineaREAL;
							// $banderaFlag = 1;
							// $nuevoTotalForecast = $lineaREAL;
						// }
						// //echo $lineaREAL." - ".$th." - ".$contadorCC."<br>";
					// }
					
					
					// //echo $nuevoTotalForecast." AAA<br>";
					// $lineaPORCENTAJE += $fila['PORCENTAJE'.$th];
					// $lineaACUMULADO += $fila['ACUMULADO'.$th];
					
					// $lineaTotalPPTO += $fila['PPTO'.$th];
					// $lineaTotalREAL += $fila['REAL'.$th];
					// $lineaTotalPORCENTAJE += $fila['PORCENTAJE'.$th];
					// $lineaTotalACUMULADO += $fila['ACUMULADO'.$th];
					
					// $lineaTotalFinalPPTO += $fila['PPTO'.$th];
					// $lineaTotalFinalREAL += $fila['REAL'.$th];
					// $lineaTotalFinalPORCENTAJE += $fila['PORCENTAJE'.$th];
					// $lineaTotalFinalACUMULADO += $fila['ACUMULADO'.$th];
					
					// $sumaSegundoPPTO[$th];
					// $sumaSegundoReal[$th];
					// $sumaSegundoPorcentaje[$th];
					// $sumaSegundoAcumulado[$th];	
					
					
			// }
			
			
			
			if($lineaREAL >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			echo '<th class="ta_r '.$clase.'">'.formatoMoneda($lineaREAL,pesos).'</th>';
			
			$clase = "";
			
			if($lineaPORCENTAJE >= 0) {$clase = "positivo";}
			else { $clase = "negativo";	}
			$lineaPORCENTAJE = round(($lineaREAL / $nuevoTotalForecast)*100,2);
			echo '<th class="ta_r '.$clase.'">'.ROUND($lineaPORCENTAJE).' %</th>';
			$clase = "";
			//echo '<th class="ta_r">'.formatoMoneda($lineaACUMULADO,pesos).'</th>';
			echo '</tr>';
			

			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($lineaREAL, 0, ',', '.'));
			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaREAL);
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			if($lineaREAL <> 12345678) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;
			
			
			//$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $lineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
			$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($lineaPORCENTAJE), 0, ',', '.')." %");
			$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
			if($lineaPORCENTAJE <> 12345235) 
			{
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			else 
			{ 
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
			}
			//$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
			$Letra++;
			$keyExcel++;
			
			
			
			
			$Letra = "A";
			$lineaPPTO = 0;
			$lineaREAL = 0;
			$lineaPORCENTAJE = 0;
			$lineaACUMULADO = 0;
			
			if($banderaWhile == $arrayCiclos[$indiceShow])
			{
				$indiceShow++;
				$banderaSumar++;
				$banderaWhile = 0;
				$indiceRows = 0;
				$banderaEERRSuma++;
				echo '<tr class="stit ta_c">';
				//echo '<th class="ta_c">TOTAL </th>';
				echo '<th class="ta_l">'.totalNivel($banderaEERRSuma-1).'</th>';
				
				$objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, totalNivel($banderaEERRSuma-1));
				$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
				$objPHPExcel->getActiveSheet()->getStyle($Letra.'19')->applyFromArray($bordeIzqDer);
				$Letra++;
				
				// for($th=0;$th<$contadorCC;$th++)
				// {

						// if($sumaREAL[$th] >= 0) {$clase = "positivoTotal";}
						// else { $clase = "negativoTotal";	}
						// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($sumaREAL[$th],pesos).'</th>';
						// $clase = "";
						
						
						// //$sumaPORCENTAJE[$th] = ($sumaPORCENTAJE[$th] / $nuevoTotalForecast)*100);
						// if($sumaPORCENTAJE[$th] >= 0) {$clase = "positivoTotal";}
						// else { $clase = "negativoTotal";	}
						// echo '<th class="ta_r '.$clase.'">'.ROUND($sumaPORCENTAJE[$th]).' %</th>';
						// $clase = "";

						
						// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($sumaREAL[$th], 0, ',', '.'));
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaREAL[$th]);
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// if($sumaREAL[$th] <> 12311123) 
						// {
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// else 
						// { 
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						// $Letra++;
						
						
						// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $sumaPORCENTAJE[$th], PHPExcel_Cell_DataType::TYPE_NUMERIC);
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format(ROUND($sumaPORCENTAJE[$th]), 0, ',', '.')." %");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// if($sumaPORCENTAJE[$th] <> 12311123) 
						// {
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// else 
						// { 
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// }
						// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
						// $Letra++;
						// if($banderaSumar == 1)
						// {
							// //echo "SUMO EL 1 <br>";
							// $primerNivelPPTO[$th] += $sumaPPTO[$th];
							// $primerNivelREAL[$th] += $sumaREAL[$th];
							// $primerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $primerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							
						// }
						// if($banderaSumar == 2)
						// {
							// //echo "SUMO EL 2 <br>";
							// $segundoNivelPPTO[$th] += $sumaPPTO[$th];
							// $segundoNivelREAL[$th] += $sumaREAL[$th];
							// $segundoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $segundoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						// }
						// if($banderaSumar == 3)
						// {
							// //echo "SUMO EL 3 <br>";
							// $tercerNivelPPTO[$th] += $sumaPPTO[$th];
							// $tercerNivelREAL[$th] += $sumaREAL[$th];
							// $tercerNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $tercerNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						// }
						// if($banderaSumar == 4)
						// {
							// //echo "SUMO EL 4 <br>";
							// $cuartoNivelPPTO[$th] += $sumaPPTO[$th];
							// $cuartoNivelREAL[$th] += $sumaREAL[$th];
							// $cuartoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $cuartoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							// //print_r($cuartoNivelREAL);
							
							
						// }
						// if($banderaSumar == 5)
						// {
							// //echo "SUMO EL 5 <br>";
							// $quintoNivelPPTO[$th] += $sumaPPTO[$th];
							// $quintoNivelREAL[$th] += $sumaREAL[$th];
							// $quintoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $quintoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
						// }
						// if($banderaSumar == 6)
						// {
							// //echo "SUMO EL 6 <br>";
							// $sextoNivelPPTO[$th] += $sumaPPTO[$th];
							// $sextoNivelREAL[$th] += $sumaREAL[$th];
							// $sextoNivelPORCENTAJE[$th] += $sumaPORCENTAJE[$th];
							// $sextoNivelACUMULADO[$th] += $sumaACUMULADO[$th];
							// //echo array_sum($sextoNivelREAL);
							// //echo "<br>";
						// }
				// }
				
				
		
				// if($banderaEERRSuma == 4)
				// {
					// //echo " banderaEERRSuma4 ".$Letra.$keyExcelEspacio."<br>";
					// echo '<tr class="stit ta_c">';
					// echo '<th class="ta_c">EBITDA </th>';
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "EBITDA");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// $Letra++;
					// for($th=0;$th<$contadorCC;$th++)
					// {
							// $totalCuartoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]));
							// $totalCuartoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]));
							// //$totalCuartoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]));
							// $totalCuartoPORCENTAJE = ROUND(($totalCuartoREAL/$totalCuartoPPTO ),2);
							// $totalCuartoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]));

							
							// if($totalCuartoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalCuartoREAL,pesos).'</th>';
							// $clase = "";
							
							// //$fila['REALTT'.$th]
							
							// //$totalCuartoPORCENTAJE = ROUND(($totalCuartoREAL / $fila['REALTT'.$th])*100);
							// $totalCuartoPORCENTAJE = ROUND(($totalCuartoREAL / $totalCuartoPPTO),2);
							// if($totalCuartoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalCuartoPORCENTAJE.' %</th>';
							// $clase = "";
							
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalCuartoREAL, 0, ',', '.'));
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalCuartoREAL, 0, ',', '.')." ");
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalCuartoREAL);
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalCuartoREAL >= 0) 
							// {
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
						// //formatoMoneda
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, $totalCuartoPORCENTAJE."%");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalCuartoPORCENTAJE >= 0) 
							// {
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;
							// $cuartoLineaPPTO += $totalCuartoPPTO;
							// $cuartoLineaREAL += $totalCuartoREAL;
							// //$cuartoLineaPORCENTAJE += $totalCuartoPORCENTAJE;
							// $cuartoLineaPORCENTAJE = ROUND(($cuartoLineaREAL/$cuartoLineaPPTO ),2);
							// $cuartoLineaACUMULADO += $totalCuartoACUMULADO;
					// }
					
					// if($cuartoLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($cuartoLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// //$cuartoLineaPORCENTAJE = ROUND(($cuartoLineaREAL / $nuevoTotalForecast)*100);
					// //$cuartoLineaPORCENTAJE = ROUND(($cuartoLineaREAL / $cuartoLineaPPTO ),2);
					// if($cuartoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$cuartoLineaPORCENTAJE.' %</th>';
					// $clase = "";
					
					// echo '</tr>';
					// echo '<tr height="10"></tr>';
					// echo '<tr height="10"></tr>';	
					
					
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($cuartoLineaREAL, 0, ',', '.'));
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaREAL);
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($cuartoLineaREAL >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $cuartoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($cuartoLineaPORCENTAJE, 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($cuartoLineaPORCENTAJE >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;
					// $keyExcel++;
					// $keyExcelEspacio = $keyExcel;
					// $keyExcel++;
					// $Letra = "A";
				// }
				
				// if($banderaSumar == 4)
				// {
						// //echo " banderaSumar ".$Letra.$keyExcelEspacio."<br>";
						// echo '<tr class="stit ta_c">';
						// echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $Letra++;
						// for ($k=0;$k<$contadorCC;$k++)
						// {
							// echo '
								  // <th class="ta_c">REAL</th>
								  // <th class="ta_c">%</th>
								  // ';
							
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// $Letra++;
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// $Letra++;
						// }
						// echo '
						
							// <th class="ta_c">REAL</th>
							// <th class="ta_c">%</th>
							// ';
						// echo '</tr>';
						
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						// $Letra++;
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						// $Letra++;
						// $keyExcel++;
						// $Letra = "A";
				// }
				
				
				// if($banderaEERRSuma == 5)
				// {
					// //echo " banderaEERRSuma5 ".$Letra.$keyExcelEspacio."<br>";
					// echo '<tr class="stit ta_c">';
					// echo '<th class="ta_c">RESULTADO OPERACIONAL </th>';
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "RESULTADO OPERACIONAL");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
					// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
					// $Letra++;
				// }
					// // for($th=0;$th<$contadorCC;$th++)
					// {
							// $totalQuintoPPTO = (abs($primerNivelPPTO[$th]) - abs($segundoNivelPPTO[$th]) - abs($tercerNivelPPTO[$th]) - abs($cuartoNivelPPTO[$th]) - abs($quintoNivelPPTO[$th]));
							// $totalQuintoREAL = (abs($primerNivelREAL[$th]) - abs($segundoNivelREAL[$th]) - abs($tercerNivelREAL[$th]) - abs($cuartoNivelREAL[$th]) - abs($quintoNivelREAL[$th]));
							// //$totalQuintoPORCENTAJE = (abs($primerNivelPORCENTAJE[$th]) - abs($segundoNivelPORCENTAJE[$th]) - abs($tercerNivelPORCENTAJE[$th]) - abs($cuartoNivelPORCENTAJE[$th]) - abs($quintoNivelPORCENTAJE[$th]));
							// $totalQuintoPORCENTAJE = ROUND(($totalQuintoREAL/$totalQuintoPPTO),2);
							// $totalQuintoACUMULADO = (abs($primerNivelACUMULADO[$th]) - abs($segundoNivelACUMULADO[$th]) - abs($tercerNivelACUMULADO[$th]) - abs($cuartoNivelACUMULADO[$th]) - abs($quintoNivelACUMULADO[$th]));
							
							// if($totalQuintoREAL >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($totalQuintoREAL,pesos).'</th>';
							// $clase = "";
							
							
							// //$totalQuintoPORCENTAJE = ROUND(($totalQuintoREAL / $fila['REALTT'.$th])*100);
							// $totalQuintoPORCENTAJE = ROUND(($totalQuintoREAL/$totalQuintoPPTO),2);
							// if($totalQuintoPORCENTAJE >= 0) {$clase = "positivoTotal";}
							// else { $clase = "negativoTotal";	}
							// echo '<th class="ta_r '.$clase.'">'.$totalQuintoPORCENTAJE.' %</th>';
							// $clase = "";
							
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($totalQuintoREAL, 0, ',', '.'));
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoREAL);
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalQuintoREAL >= 0) 
							// {
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;
							// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalQuintoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, number_format($totalQuintoPORCENTAJE, 0, ',', '.')." %");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// if($totalQuintoPORCENTAJE >= 0) 
							// {
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// else 
							// { 
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
								// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// }
							// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
							// $Letra++;
							// $quintoLineaPPTO += $totalQuintoPPTO;
							// $quintoLineaREAL += $totalQuintoREAL;
							// //$quintoLineaPORCENTAJE += $totalQuintoPORCENTAJE;
							// $quintoLineaPORCENTAJE = ROUND(($quintoLineaREAL/$quintoLineaPPTO),2);
							// $quintoLineaACUMULADO += $totalQuintoACUMULADO;
					// }
					
					// if($quintoLineaREAL >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.formatoMoneda($quintoLineaREAL,pesos).'</th>';
					// $clase = "";
					
					// //$quintoLineaPORCENTAJE = ROUND(($quintoLineaREAL / $nuevoTotalForecast)*100);
					// $quintoLineaPORCENTAJE = ROUND(($quintoLineaREAL / $quintoLineaPPTO ),2);
					// if($quintoLineaPORCENTAJE >= 0) {$clase = "positivoTotal";}
					// else { $clase = "negativoTotal";	}
					// echo '<th class="ta_r '.$clase.'">'.$quintoLineaPORCENTAJE.' %</th>';
					// $clase = "";
					
					// echo '</tr>';
					// echo '<tr height="10"></tr>';
					// echo '<tr height="10"></tr>';	
					
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaREAL, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($quintoLineaREAL, 0, ',', '.'));
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaREAL);
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($quintoLineaREAL >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;
					// //$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $quintoLineaPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
					// $objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, number_format($quintoLineaPORCENTAJE, 0, ',', '.')." %");
					// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
					// if($quintoLineaPORCENTAJE >= 0) 
					// {
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// else 
					// { 
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeCompleto);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
					// }
					// //$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
					// $Letra++;
					// $keyExcel++;
					// $keyExcelEspacio = $keyExcel;
					// $keyExcel++;
					// $Letra = "A";
					
				// }
				// if($banderaSumar == 5)
				// {
						// //echo " banderaSumar5 ".$Letra.$keyExcelEspacio."<br>";
						// echo '<tr class="stit ta_c">';
						// echo '<th class="ta_l">'.nombreNivel($banderaEERRSuma).'</th>';
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, nombreNivel($banderaEERRSuma));
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelLeft);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $Letra++;
						
						
						// for ($k=0;$k<$contadorCC;$k++)
						// {
							// echo '
								  // <th class="ta_c">REAL</th>
								  // <th class="ta_c">%</th>
								  // ';
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// $Letra++;
							// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
							// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
							// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
							// $Letra++;
							
						// }
						// echo '
							// <th class="ta_c">REAL</th>
							// <th class="ta_c">%</th>
							// ';
							// //<th class="ta_c">ACUM</th>
						// echo '</tr>';
						
						
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						// $Letra++;
						// $objPHPExcel->setActiveSheetIndex(0)->setCellValue($Letra.$keyExcel, "");
						// $objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelColorTitulo);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($bordeIzqDer);
						// $objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcelEspacio)->applyFromArray($excelColorTitulo);
						// $Letra++;
						// $keyExcel++;
						// $Letra = "A";
						
				// }
				
				if($banderaEERRSuma == 6)
				{
					
					$Letra++;
					$keyExcel++;
					$keyExcel++;
					$Letra = "A";
				}
				
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
		echo '</tbody></table>';
		echo '<br><br><br>';
		
		require_once ('inc/PHPExcel/IOFactory.php');
		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
		$objWriter->save($fname);
		
		echo  '<a href="'.$fname.'" class="descarga"><img src="imgs/excel.png" /> &nbsp; DESCARGAR ARCHIVO PARA EXCEL</a>';
		echo '<br>';
	
}
?>