<?php

function DistCCosto($tempor,$destin)
	{
	include('inc/conexion.php');
	require_once('inc/PHPExcel.php');

	/* GENERA ARCHIVO */
	$hoy   = date('dmY-His');
	$fname = "informes/DistCCostos-".$hoy.".xls";

	// * INI CABECERA EXCEL * //
	$objPHPExcel = new PHPExcel();
	$objPHPExcel->getProperties()
		->setCreator("Disofi 2015")
		->setLastModifiedBy("Disofi 2015")
		->setTitle("Estado de Resultados")
		->setSubject("Estado de Resultados")
		->setDescription("Estado de Resultados")
		->setKeywords("Disofi")
		->setCategory("Estado de Resultados");

	// * DATOS DE LA EMPRESA * //
	$selb = " SELECT RutE, NomB, Giro, Dire, Ciud, Pais FROM ".$dbs.".[soempre] ";	
	$resb = sqlsrv_query($conn, $selb);
	if ($resb)
		{
		$rowb = sqlsrv_fetch_array($resb);
		$RUTE = trim($rowb['RutE']);
		$RAZO = trim($rowb['NomB']);
		$GIRO = trim($rowb['Giro']);
		$DIRE = trim($rowb['Dire']);
		$CIUD = trim($rowb['Ciud']);
		$PAIS = trim($rowb['Pais']); 
		}
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', $RAZO)
		->setCellValue('A2', $RUTE)
		->setCellValue('D2', 'ESTADO DE RESULTADOS')
		->setCellValue('A3', $DIRE)
		->setCellValue('A2', 'TEMPORADA '.$anoi[1].' - '.$anof[1])
		->setCellValue('A4', $CIUD." - ".$PAIS);
	$tmpa = explode("-",$tempor);
	$anoi = explode(".",$tmpa[0]);
	$anof = explode(".",$tmpa[1]);

	echo '
	<div class="row col-sm-8">
		<div class="col-sm-2">Empresa:</div>
		<div class="col-sm-4">'.$RAZO.'</div>
	</div>
	<div class="row col-sm-8">
		<div class="col-sm-2">RUT:</div>
		<div class="col-sm-4">'.$RUTE.'</div>
	</div>
	<div class="row col-sm-8">
		<div class="col-sm-2">Direcci&oacute;n:</div>
		<div class="col-sm-4">'.$DIRE.'</div>
		<div class="col-sm-4"><b>ESTADO DE RESULTADOS</b></div>
	</div>
	<div class="row col-sm-8">
		<div class="col-sm-2">Temporada</div>
		<div class="col-sm-4">'.$anoi[1].' - '.$anof[1].'</div>
	</div>	
	';

	$salida = "";	
	$sela = " SELECT CodiCC, DescCC FROM ".$dbs.".[cwtccos] ";
	$sela.= " WHERE Activo='S' and NivelCC=(SELECT MAX(NivelCC) FROM AVC2.softland.cwtccos) AND DescCC!=''";
	echo $sela."<br><br>";
	$resa = sqlsrv_query($conn, $sela, array(), array('Scrollable' => 'buffered'));
	if ($resa)
		{
		$j=0;
		while ($rowa=sqlsrv_fetch_array($resa))
			{
			$salida.= "[".$rowa['CodiCC']."],";
			$ccost[$j] = $rowa['CodiCC'];
			$cdesc[$j] = $rowa['DescCC'];
			$j++;
			}
		$salida = substr($salida, 0 ,-1);
		}

	// SELECCIONA LOS TITULOS Y CUENTAS //
	$selc = " SELECT grupo, indice, manejadet, descripcion, '' as pctcod, '0' as corr, tipo, suma ";
	$selc.= " FROM ".$dba.".[DS_PARAMRESULE] WHERE IdbDatos='".$_SESSION['emp']['id']."' AND Nivel='1' ";
	$selc.= " UNION ALL ";
	$selc.= " SELECT a.grupo, a.indice, a.manejadet, a.descripcion, b.pctcod, b.corr, '' as tipo, '' as suma ";
	$selc.= " FROM ".$dba.".[DS_PARAMRESULE] as a ";
	$selc.= " LEFT JOIN ".$dba.".[DS_PARAMRESULD] as b ON a.Indice=b.Indice AND a.Nivel=b.Nivel AND a.IdBDatos=b.IdBDatos "; 
	$selc.= " WHERE a.IdBDatos='".$_SESSION['emp']['id']."' AND a.Nivel='2' ";
	$selc.= " UNION ALL ";
	$selc.= " SELECT grupo, Indice, ManejaDet, Descripcion, '' as pctcod, '9999' as corr, tipo, suma "; 
	$selc.= " FROM ".$dba.".[DS_PARAMRESULE] WHERE IdbDatos='76' AND Nivel='3' ";
	$selc.= " ORDER BY Grupo, Corr ";
	echo $selc."<br><br>";
	$resc = sqlsrv_query($conn, $selc, array(), array('Scrollable' => 'buffered'));
	if ($resc)
		{
		$i=0;
		while ($rowc=sqlsrv_fetch_array($resc))
			{
			$Agrupo[$i]  = trim($rowc['grupo']);
			$Aindice[$i] = trim($rowc['indice']);
			$Amandet[$i] = trim($rowc['manejadet']);
			$Adescri[$i] = trim($rowc['descripcion']);
			$Apctcod[$i] = trim($rowc['pctcod']);
			$Acorrel[$i] = trim($rowc['corr']);
			$Atipo[$i]   = trim($rowc['tipo']);
			$Asuma[$i]   = trim($rowc['suma']);
			$i++;
			}
		}

	$sel = " SELECT PctCod, pcdesc, ".$salida." FROM ( ";
	$sel.= " SELECT cm.PctCod, cwp.pcdesc, cm.cccod, sum(cm.movdebe)-sum(movhaber) as saldo "; 
	$sel.= " FROM ".$dbs.".[cwmovim] cm  ";
	$sel.= " LEFT JOIN ".$dbs.".[cwpctas] cwp  on cm.PctCod = cwp.PCCODI "; 
	$sel.= " LEFT JOIN ".$dbs.".[cwtccos] cwc  on cwc.CodiCC = cm.CcCod  ";
	$sel.= " LEFT JOIN ".$dbs.".[cwcpbte] cwcp on cwcp.CpbNum = cm.CpbNum and cwcp.CpbAno = cm.CpbAno "; 
	$sel.= " WHERE cwcp.cpbest = 'V' AND  ";
	$sel.= " (cm.cpbmes between '06' AND '12' AND cm.cpbano='".$anoi[1]."' AND cwp.pctipo not in ('A','P')) "; 
	$sel.= " OR ";
	$sel.= " (cm.cpbmes between '01' AND '05' AND cm.cpbano='".$anof[1]."' AND cwp.pctipo not in ('A','P')) "; 
	$sel.= " GROUP BY cm.PctCod, cwp.pcdesc, cm.cccod) p ";
	$sel.= " PIVOT ( SUM(saldo) FOR cccod IN (".$salida.")) as pvt ";
	$res = sqlsrv_query($conn, $sel, array(), array('Scrollable' => 'buffered'));
	$largocc = sizeof($ccost);
	if ($res)
		{
		$i=0;
		while ($row=sqlsrv_fetch_array($res))
			{
			$pctcod[$i] = trim($row['PctCod']);
			$pcdesc[$i] = trim($row['pcdesc']);
			for ($k=0;$k<$largocc;$k++)
				{
				$cc=trim($ccost[$k]);
				$cencos[$cc][$i] = (trim($row[$cc])*-1);
				}
			$i++;
			}
		}

	$FILA=6;

	// 1.- RECORRIDO DE LOS TITULOS (OBLIGATORIO) //
	$largo_tit = sizeof($Agrupo);
	$largo_sab = sizeof($pctcod);

	// ARMANDO LA TABLA //
	echo '<div id="tablaContenedora" class="tablaContenedora planilla">';
	echo '<table border="1" cellpadding="0" cellspacing="0" width="100%" class="scrollTable">';

	// CABECERA 1 //
	echo '<thead class="fixedHeader tit">';
	echo '<tr><th class="ta_c">C&oacute;digo</th><th class="ta_c">Descripci&oacute;n</th>';
	for ($k=0;$k<$largocc;$k++)
		{
		echo '<th class="ta_c">'.$ccost[$k].'</th>';
		}
	echo '<th class="ta_c">Total</th></tr></thead>';

	// CABECERA EXCEL //
	$LET=C;
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A'.$FILA, 'Codigo')
		->setCellValue('B'.$FILA, 'Descripcion');
	for ($k=0;$k<$largocc;$k++)
		{
		$objPHPExcel->setActiveSheetIndex(0)
			->setCellValue($LET.$FILA, $ccost[$k]);
		$LET++;
		}
	$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue($LET.$FILA, 'TOTAL');
	$FILA++;
	
	// IMPRIMO LOS TITULOS //
	echo '<tbody class="scrollContent">';

	for ($j=0;$j<$largo_tit;$j++)
		{
		// GASTOS DISTRIBUIDOS //
		if ($Agrupo[$j]==3)
			{
			echo '<tr class="sbt"><td></td><td>Gastos Distribuidos</td>';
			$LET=C;
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue('A'.$FILA, '')
				->setCellValue('B'.$FILA, 'Gastos Distribuidos');
			for ($k=0;$k<$largocc;$k++)
				{
				$cc = $ccost[$k];
				echo '<td class="ta_r"></td>';
				$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue($LET.$FILA, '');
				$LET++;
				}
			echo '<td></td></tr>';
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, 'TOTAL');
			$FILA++;
			
			$largo=sizeof($destin);
			for ($z=0;$z<$largo;$z++)
				{
				$selx = " SELECT DescCC FROM ".$dbs.".cwtccos where CodiCC='".$destin[$z]."' ";
				$resx = sqlsrv_query($conn, $selx, array(), array('Scrollable' => 'buffered'));
				$rowx = sqlsrv_fetch_array($resx);
				$dscx = $rowx['DescCC'];
								
				echo '<tr><td>&nbsp;</td><td style="text-transform:uppercase">'.$dscx.'</td>';
				$LET=C;
				$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue('A'.$FILA, '')
					->setCellValue('B'.$FILA, $dscx);					
				$mcc = $destin[$z];
				for ($k=0;$k<$largocc;$k++)
					{
					$cc = $ccost[$k];
				
					$sely = " SELECT porcen FROM ".$dba.".DistCC where CodiCCAD='".$destin[$z]."' AND CodiCC='".$cc."' ";
					$resy = sqlsrv_query($conn, $sely);
					$rowy = sqlsrv_fetch_array($resy);
					$porc = $rowy['porcen'];
				
					$selp = " SELECT (ROUND(((sum(cm.movdebe)-sum(movhaber))*".$porc.")/100,0))*-1 as porcen ";
					$selp.= " FROM ".$dbs.".[cwmovim] cm ";
					$selp.= " LEFT JOIN ".$dbs.".[cwpctas] cwp on cm.PctCod = cwp.PCCODI "; 
					$selp.= " LEFT JOIN ".$dbs.".[cwtccos] cwc on cwc.CodiCC = cm.CcCod and cwc.codicc='VC-19' ";
					$selp.= " LEFT JOIN ".$dbs.".[cwcpbte] cwcp on cwcp.CpbNum = cm.CpbNum and cwcp.CpbAno = cm.CpbAno ";
					$selp.= " WHERE cwcp.cpbest = 'V' AND cm.cccod='".$destin[$z]."' ";
					$selp.= " AND (cm.cpbmes between '06' AND '12' AND cm.cpbano='".$anoi[1]."' AND cwp.pctipo not in ('A','P') AND cm.cccod='".$destin[$z]."') OR "; 
					$selp.= " (cm.cpbmes between '01' AND '05' AND cm.cpbano='".$anof[1]."' AND cwp.pctipo not in ('A','P') AND cm.cccod='".$destin[$z]."') ";
					$selp.= " GROUP BY cm.cccod ";
					$resp = sqlsrv_query($conn, $selp);
					$rowp = sqlsrv_fetch_array($resp);
					$porp = $rowp['porcen'];
					echo '<td class="ta_r">'.number_format($porp,0,',','.').'</td>';
					$objPHPExcel->setActiveSheetIndex(0)
						->setCellValue($LET.$FILA, $porp);
					$LET++;
					$sumw[$cc]=$sumw[$cc]+$porp;
					}
				echo '<td></td></tr>';
				$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, '');
				$FILA++;
				}

			echo '<tr class="sbt"><td></td><td>Total Gastos Distribuidos</td>';
			$LET=C;
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue('A'.$FILA, '')
				->setCellValue('B'.$FILA, 'Total Gastos Distribuidos');
			for ($k=0;$k<$largocc;$k++)
				{
				$cc = $ccost[$k];
				echo '<td class="ta_r">'.number_format($sumw[$cc],0,',','.').'</td>';
				$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue($LET.$FILA, $sumw[$cc]);
				$LET++;
				}
			echo '<td></td></tr>';
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, '');
			$FILA++;
			
			echo '<tr class="sbt"><td></td><td>Total Gastos Distribuidos + Total Gastos</td>';
			$LET=C;
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue('A'.$FILA, '')
				->setCellValue('B'.$FILA, 'Total Gastos Distribuidos + Total Gastos');
			for ($k=0;$k<$largocc;$k++)
				{
				$cc = $ccost[$k];
				$sumq[$cc] = $suma[$cc]+$sumw[$cc];
				echo '<td class="ta_r">'.number_format($sumq[$cc],0,',','.').'</td>';
				$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue($LET.$FILA, $sumq[$cc]);
				$LET++;
				}
			echo '<td></td></tr>';
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, '');
			$FILA++;
			}
		// TITULOS //
		if ($Acorrel[$j]=='0')
			{
			echo "</tr><tr height='10'></tr>";
			echo '<tr class="stit ta_c">';
			echo '<td>&nbsp;</td>';
			echo '<td>'.$Adescri[$j].'</td>';
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue('A'.$FILA, '')
				->setCellValue('B'.$FILA, '');
			$LET=C;
			if ($Atipo[$j]=='S')
				{
				$gr  = $Agrupo[$j];
				$smx = substr_count($Asuma[$j], ',')+1;
				$smr = explode(',',$Asuma[$j]);
				for ($x=0;$x<$smx;$x++)
					{
					$y = $smr[$x];
					for ($k=0;$k<$largocc;$k++)
						{
						$cc = $ccost[$k];
						$suma[$gr][$cc]=$suma[$gr][$cc]+$suma[$y][$cc];
						}
					}
				for ($k=0;$k<$largocc;$k++)
					{
					$cc = $ccost[$k];
					echo '<td class="ta_r">'.number_format($suma[$gr][$cc],0,',','.').'</td>';
					$objPHPExcel->setActiveSheetIndex(0)
						->setCellValue($LET.$FILA, $suma[$gr][$cc]);
					$LETT++;
					}
				}
			else 
				{
				for ($k=0;$k<$largocc;$k++)
					{
					$cc = $ccost[$k];
					echo '<td class="ta_c">'.$cdesc[$k].'</td>';
					$suma[$cc]='0';
					$objPHPExcel->setActiveSheetIndex(0)
						->setCellValue($LET.$FILA, $cdesc[$k]);
					$LET++;
					}
				}
			echo '<td>&nbsp;</td>';
			echo '</tr>';
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, '');
			$FILA++;
			}
		// CUENTAS //
		if ($Amandet[$j]=='S')
			{
			for ($i=0;$i<$largo_sab;$i++)
				{
				if (trim($Apctcod[$j])==trim($pctcod[$i]))
					{
					echo '<tr>';
					echo '<td>'.$pctcod[$i].'</td>';
					echo '<td>'.$pcdesc[$i].'</td>';
					$objPHPExcel->setActiveSheetIndex(0)
						->setCellValue('A'.$FILA, $pctcod[$i])
						->setCellValue('B'.$FILA, $pcdesc[$i]);
					$LET=C;
					for ($k=0;$k<$largocc;$k++)
						{
						$cc=$ccost[$k];
						echo '<td class="ta_r">'.number_format($cencos[$cc][$i],0,',','.').'</td>';
						$suma[$cc]=$suma[$cc]+$cencos[$cc][$i];
						$objPHPExcel->setActiveSheetIndex(0)
							->setCellValue($LET.$FILA, $cencos[$cc][$i]);
						$LET++;
						}
					echo '<td>&nbsp;</td>';
					echo '</tr>';
					$objPHPExcel->setActiveSheetIndex(0)
						->setCellValue($LET.$FILA, '');
					$FILA++;
					}
				}
			}
		// TOTALES //
		if ($Acorrel[$j]=='9999')
			{
			echo "<tr class='stit ta_c'><td>&nbsp;</td><td>".$Adescri[$j]."</td>";
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue('A'.$FILA, '')
				->setCellValue('B'.$FILA, $Adescri[$j]);
			$LET=C;
			for ($k=0;$k<$largocc;$k++)
				{
				$cc=$ccost[$k];
				echo '<td class="ta_r">'.number_format($suma[$cc],0,',','.').'</td>';
				$gr = $Agrupo[$j];
				$suma[$gr][$cc]=$suma[$cc];
				$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue($LET.$FILA, $suma[$cc]);
				$LET++;
				}
			echo '<td>&nbsp;</td>';			
			echo "</tr><tr height='10'></tr>";
			$objPHPExcel->setActiveSheetIndex(0)
				->setCellValue($LET.$FILA, '');
			$FILA++;
			}
		}
	// FINALIZA LA TABLA
	echo '</tbody></table>';
	require_once ('inc/PHPExcel/IOFactory.php');
    $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
    $objWriter->save($fname);
    $excel =  '<br /><br /><br /><center><a href="'.$fname.'"><img src="imgs/excel.png" />DESCARGAR ARCHIVO PARA EXCEL</a></center>';
    echo $excel;
	}
