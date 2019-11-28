<?php
function formatoMoneda($numero, $moneda)
{
    $longitud = strlen($numero);
    $punto = substr($numero, -1,1);
    $punto2 = substr($numero, 0,1);
    $separador = ".";
    if($punto == "."){
    $numero = substr($numero, 0,$longitud-1);
    $longitud = strlen($numero);
    }
    if($punto2 == "."){
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
    if(!$num_entero){
        $num_entero = $longitud;
        $centavos = ".00";
        $entero = substr($numero, -$longitud,$longitud);
    }

    $start = floor($num_entero/3);
    $res = $num_entero-($start*3);
    if($res == 0){$coma = $start-1; $init = 0;}else{$coma = $start; $init = 3-$res;}
    $d= $init; $i = 0; $c = $coma;
        while($i <= $num_entero){
            if($d == 3 && $c > 0){$d = 0; $sep = "."; $c = $c-1;}else{$sep = "";}
            $final .=  $sep.$entero[$i];
            $i = $i+1; // todos los digitos
            $d = $d+1; // poner las comas
        }
        if($moneda == "pesos")  {$moneda = "$";
        return $moneda." ".$final;
        }
        elseif($moneda == "dolares"){$moneda = "USD";
        return $moneda." ".$final.$centavos;
        }
        elseif($moneda == "euros")  {$moneda = "EUR";
        return $final.$centavos." ".$moneda;
        }
}


function sumarTotales($valor1, $valor2)
{
    $total = ($valor1 + $valor2);
    return $total;
}
function nombreMes($mes)
{
	if($mes == '1' || $mes == '01'){ $salida = 'ENE';}
	if($mes == '2' || $mes == '02'){ $salida = 'FEB';}
	if($mes == '3' || $mes == '03'){ $salida = 'MAR';}
	if($mes == '4' || $mes == '04'){ $salida = 'ABR';}
	if($mes == '5' || $mes == '05'){ $salida = 'MAY';}
	if($mes == '6' || $mes == '06'){ $salida = 'JUN';}
	if($mes == '7' || $mes == '07'){ $salida = 'JUL';}
	if($mes == '8' || $mes == '08'){ $salida = 'AGO';}
	if($mes == '9' || $mes == '09'){ $salida = 'SEP';}
	if($mes == '10' || $mes == '010'){ $salida = 'OCT';}
	if($mes == '11' || $mes == '011'){ $salida = 'NOV';}
	if($mes == '12' || $mes == '012'){ $salida = 'DIC';}
	return $salida;
}
function estadoResultado($mes,$ano)
{
	include('inc/conexion.php');
	require_once('inc/PHPExcel.php');
	$registro_acumulado = 0;
		$fechaExcel   = date('dmY-His');
		$datoFecha = date('d/m/Y');
		$fname = "informes/EERR-".$fechaExcel.".xls";
		$objPHPExcel = new PHPExcel();
		$objPHPExcel->getProperties()
			->setCreator("Disofi 2016")
			->setLastModifiedBy("Disofi 2016")
			->setTitle("EERR")
			->setSubject("EERR")
			->setDescription("EERR")
			->setKeywords("Office PHPExcel Buinzoo")
			->setCategory("EERR");
	$keyCuenta = 0;
	$anoAnterior = ($ano - 1);
	$campoQuery = substr($mes,1);
	$spaceA = 0;
	$spaceB = 0;
	$spaceC = 0;
	$bandera = 0;
	$bandera2=0;
	$bandera3=0;
	$bandera4=0;
	$n = 7;
	$totalRealAnterior = 0;
	$presupuestoActual = 0;
	$totalRealVariacionAnteriorConActual = 0;
	$totalRealActual = 0;
	$totalRealVariacionRealPptoActual = 0;
	$acumuladoTotalPresupuestoActual = 0;
	$acumuladoTotalPresupuestoActualArray = 0;
	$realAnterior = 0;
	$realActual = 0;
	//echo "Parametros Entrada : ".$mes." -- ".$ano." -- ".$anoAnterior." -- ".$campoQuery."<br><br>";
	echo 'Mes:'.$mes."<br>";
	$data = $mes;
	echo 'A&ntilde;o:'.$ano."<br>";
	$arregloCondicionQuery = array('0'=>'buinzoo','1' => 'comercializadora','2' => 'hospital', '3' => 'inmobiliaria');
	$arregloBd = array('0'=>'buinzoo','1' => 'comercializ','2' => 'hospital', '3' => 'inmobiliaria');


	$queryMax =" select max(nivel) as hasta from dsbuinzoo.dbo.ds_cuentas ";
	//echo $queryMax." --QUERY MAX <br>";
	$resMax = sqlsrv_query($conn, $queryMax, array(), array('Scrollable' => 'buffered'));
	while ($rowMax=sqlsrv_fetch_array($resMax))
	{
		$hasta = $rowMax['hasta'];
		//echo $hasta."-- HASTA <br>";
	}
	

	//for($tt=1; $tt<=$hasta; $tt++)
	for($tt=1; $tt<=$hasta; $tt++)
	{
		$query =" select cuentas.nombreCuenta, cuentas.id, cuentas.nivel ";
		$query.=" from dsbuinzoo.dbo.ds_cuentas cuentas ";
		$query.=" LEFT JOIN dsbuinzoo.dbo.DS_Presupuesto ppto ON cuentas.id = ppto.idCuenta ";
		$query.=" WHERE ppto.ano = '".$ano."' AND cuentas.nivel = '".$tt."' ";
		$query.=" group by cuentas.nombreCuenta,cuentas.id,cuentas.nivel order by cuentas.id  ";
		//echo $query."-- query <br>";
		$resQuery = sqlsrv_query($conn, $query, array(), array('Scrollable' => 'buffered'));
		while ($row=sqlsrv_fetch_array($resQuery))
		{
			//$contadorCuentas = $row['nombreCuenta'];
			$arrayCuentas[$keyCuenta] = $row['nombreCuenta'];
			$arrayIdCuentas[$keyCuenta] = $row['id'];
			$keyCuenta++;
		}
		
		
		//echo "<br><br>";
		//var_dump($arrayContadorCuentas);

		/* TOTAL Mensual*/
		//print_r($arrayCuentas);
		//for($a=0;$a<count($arrayCuentas);$a++)
		for($a=0;$a<count($arrayCuentas);$a++)
		{
			//echo $arrayCuentas[$a]."<br>";
			for($b=0;$b<4;$b++)
			{
				// query trae todos los datos segun el nombre de cuenta, bd y nivel
				$queryPCCODI =" SELECT TOP 1 * FROM dsbuinzoo.dbo.ds_cuentas WHERE nombreCuenta = '".$arrayCuentas[$a]."'
				AND BD = '".$arregloCondicionQuery[$b]."' ";
				$queryPCCODI.=" AND nivel = '".$tt."'";
					//echo $queryPCCODI."<br>";
				$res = sqlsrv_query($conn, $queryPCCODI, array(), array('Scrollable' => 'buffered'));
				while ($row=sqlsrv_fetch_array($res))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
				}

				$pccodi = substr($pccodi,0, strlen($pccodi)-1);
				$pccodi = str_replace("''","','" , $pccodi);

				//obtiene datos de año anterior segun mes especificado
				$queryMovim =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo as tipo";
				$queryMovim .= " from ".$arregloBd[$b].".softland.cwmovim movim";
				$queryMovim .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovim.=" where cpbano = '".$anoAnterior."' AND pctCod IN (".$pccodi.")  ";
				$queryMovim.=" and MovFe BETWEEN convert(datetime,'01/".$mes."/".$anoAnterior."',103) ";
				if($mes == 02)
        {
					$queryMovim.=" AND convert(datetime,'28/".$mes."/".$anoAnterior."',103) ";
				}
        else if($mes == 01 || $mes == 03 || $mes == 05 || $mes == 07 || $mes == 08 || $mes == 10 || $mes == 12)
				{
					$queryMovim.=" AND convert(datetime,'31/".$mes."/".$anoAnterior."',103) ";
				}
        else if($mes == 02 || $mes == 04 || $mes == 06 || $mes == 09 || $mes == 11)
				{
					$queryMovim.=" AND convert(datetime,'30/".$mes."/".$anoAnterior."',103) ";
				}

        $queryMovim .= "group by movim.pctcod, ctas.pctipo";

				//sumatoria de los debe y haber del año anterior y mes especificado
				$resMovim = sqlsrv_query($conn, $queryMovim, array(), array('Scrollable' => 'buffered'));
				while ($rowMovim=sqlsrv_fetch_array($resMovim))
				{
            if ($rowMovim['pctipo'] == 'I' OR $rowMovim['pctipo'] == 'P')
            {
                $resSuma = $rowMovim['resultadoSuma'] * -1;
                $totalRealAnterior =  sumarTotales($totalRealAnterior, $resSuma);
            }
            else
            {
                $totalRealAnterior =  sumarTotales($totalRealAnterior, $rowMovim['resultadoSuma']);
            }
				}
				//obtiene datos del año actual segun mes especificado
				$queryMovimActual =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo";
        $queryMovimActual .= " from ".$arregloBd[$b].".softland.cwmovim movim";
        $queryMovimActual .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovimActual.=" where cpbano = '".$ano."' AND pctCod IN (".$pccodi.")";
				$queryMovimActual.=" and MovFe BETWEEN convert(datetime,'01/".$mes."/".$ano."',103) ";
				if($mes == 02)
        {
					$queryMovimActual.=" AND convert(datetime,'28/".$mes."/".$ano."',103) ";
				}
				else if($mes == 01 || $mes == 03 || $mes == 05 || $mes == 07 || $mes == 08 || $mes == 10 || $mes == 12)
				{
					$queryMovimActual.=" AND convert(datetime,'31/".$mes."/".$ano."',103) ";
				}
				else if($mes == 02 || $mes == 04 || $mes == 06 || $mes == 09 || $mes == 11)
				{
					$queryMovimActual.=" AND convert(datetime,'30/".$mes."/".$ano."',103) ";
				}
        $queryMovimActual .= "group by movim.pctcod, ctas.pctipo";
        //echo $queryMovimActual;
        //realiza sumatoria de los debe y haber del año actual y mes especificado
				$resMovimActual = sqlsrv_query($conn, $queryMovimActual, array(), array('Scrollable' => 'buffered'));
				while ($rowMovimActual=sqlsrv_fetch_array($resMovimActual))
				{
          if ($rowMovimActual['pctipo'] == 'I' OR $rowMovimActual['pctipo'] == 'P')
          {
              $resSuma = $rowMovimActual['resultadoSuma'] * -1;
              $totalRealActual = sumarTotales($resSuma, $totalRealActual);
          }
          else
          {
              $totalRealActual = sumarTotales($rowMovimActual['resultadoSuma'], $totalRealActual);
          }

				}
				//echo $totalRealActual."-> total RAc<br><br>";

				if($b==3)
				{
					//Obtiene todos los datos de la tabla presupuesto segun idcuenta y año
					//ademas realiza suma
					if($bandera2 == $arrayIdCuentas[$a])
          {

					}
          else
          {
						$queryObtengoPresupuesto =" SELECT * FROM dsbuinzoo.dbo.ds_presupuesto ";
						$queryObtengoPresupuesto.=" WHERE idCuenta = '".$arrayIdCuentas[$a]."' AND ano = '".$ano."' ";
						$resPre = sqlsrv_query($conn, $queryObtengoPresupuesto, array(), array('Scrollable' => 'buffered'));
						while ($rowPre=sqlsrv_fetch_array($resPre))
						{
							$totalPresupuestoActual = sumarTotales($rowPre[$campoQuery],$totalPresupuestoActual);
						}
						$bandera2 = $arrayIdCuentas[$a];
					}

				}
					$pccodi = "";
			}


		}
		//echo "<br>TOTALES ----- TOTALES<br>";
		//obtiene totales a base de resultados anteriores
		//echo $totalPresupuestoActual." -> total Presupuesto <br><br>";

		$totalRealVariacionAnteriorConActual = ($totalRealActual / $totalRealAnterior);
		$totalRealVariacionRealPptoActual = ($totalRealActual / $totalPresupuestoActual );

		/*echo $totalRealAnterior." : Total Real Anterior<br>";
		echo $totalPresupuestoActual." : Total Presupuesto Actual <br>";
		echo $totalRealActual." : Total REal Actual<br>";
		echo $totalRealVariacionAnteriorConActual." : Total Real Variacion <br>";
		echo $totalRealVariacionRealPptoActual." : Total Real Variacion Entre Real y PPto Del a&ntilde;o<br><br>";
		*/

		/*Fin Total Mensual*/

		/* TOTAL ACUMULADO*/
		//Es l asumatoria de los montos totales de los meses anteriores con respecto al mes especificado
		//for($a=0;$a<count($arrayCuentas);$a++)
		for($a=0;$a<count($arrayCuentas);$a++)
		{
			//echo $arrayCuentas[$a]."<br>";
			for($b=0;$b<4;$b++)
			{
				//obtiene datos de cuentas segun el nombre de cuenta, el
				//nombre de la base de datos asociada y nivel
				$queryPCCODI =" SELECT * FROM dsbuinzoo.dbo.ds_cuentas WHERE nombreCuenta = '".$arrayCuentas[$a]."' AND BD = '".$arregloCondicionQuery[$b]."' ";
				$queryPCCODI.=" AND nivel='".$tt."'";
					//echo $queryPCCODI."<br>";
				$res = sqlsrv_query($conn, $queryPCCODI, array(), array('Scrollable' => 'buffered'));
				while ($row=sqlsrv_fetch_array($res))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
				}

				$pccodi = substr($pccodi,0, strlen($pccodi)-1);
				$pccodi = str_replace("''","','" , $pccodi);
				//echo $pccodi."<===<br>";
				//la siguiente consulta obtiene la suma de los debe-haber segun el año anterior y el codigo de la cuenta
				$queryMovim  ="select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo";
        $queryMovim .= " from ".$arregloBd[$b].".softland.cwmovim movim";
        $queryMovim .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovim .=" where cpbano = '".$anoAnterior."' AND pctCod IN (".$pccodi.")";
				$queryMovim .=" and MovFe BETWEEN convert(datetime,'01/01/".$anoAnterior."',103)";
				if($mes == 02)
				{
					$queryMovim.=" AND convert(datetime,'28/".$mes."/".$anoAnterior."',103)";
				}
				else if($mes == 01 || $mes == 03 || $mes == 05 || $mes == 07 || $mes == 08 || $mes == 10 || $mes == 12)
				{
					$queryMovim.=" AND convert(datetime,'31/".$mes."/".$anoAnterior."',103)";
				}
				else if($mes == 02 || $mes == 04 || $mes == 06 || $mes == 09 || $mes == 11)
				{
					$queryMovim.=" AND convert(datetime,'30/".$mes."/".$anoAnterior."',103)";
				}
        $queryMovim .= " group by movim.pctcod, ctas.pctipo";
				//Se acumulan lso resultados de la suma de la consulta, ademas se agregan a un arreglo
				$resMovim = sqlsrv_query($conn, $queryMovim, array(), array('Scrollable' => 'buffered'));
				while ($rowMovim=sqlsrv_fetch_array($resMovim))
				{
          if ($rowMovim['pctipo'] == 'I' OR $rowMovim['pctipo'] == 'P')
          {
              $resSuma = $rowMovim['resultadoSuma'] * -1;
              $acumuladoTotalRealAnterior = sumarTotales($acumuladoTotalRealAnterior, $resSuma);
              $acumuladoTotalRealAnteriorArray = sumarTotales($acumuladoTotalRealAnteriorArray, $resSuma);
          }
          else
          {
            $acumuladoTotalRealAnterior = sumarTotales($acumuladoTotalRealAnterior,$rowMovim['resultadoSuma']);
            $acumuladoTotalRealAnteriorArray = sumarTotales($acumuladoTotalRealAnteriorArray,$rowMovim['resultadoSuma']);
          }
				}

				//echo $acumuladoTotalRealAnterior."->total real anterior <br><br>";
        //echo $acumuladoTotalRealAnteriorArray." acumulado total real anterior aRRAY <br><br>";
				//La consulta obtiene la suma de los debe-haber segun el año y codigo de cuenta
				$queryMovimActual =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo";
        $queryMovimActual .= " from ".$arregloBd[$b].".softland.cwmovim movim";
        $queryMovimActual .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovimActual.=" where cpbano = '".$ano."' AND pctCod IN (".$pccodi.")  ";
				$queryMovimActual.=" and MovFe BETWEEN convert(datetime,'01/01/".$ano."',103) ";
				if($mes == 2)
				{
					$queryMovimActual.=" AND convert(datetime,'28/".$mes."/".$ano."',103) ";
				}
				else if($mes == 1 || $mes == 3 || $mes == 5 || $mes == 7 || $mes == 8 || $mes == 10 || $mes == 12)
				{
					$queryMovimActual.=" AND convert(datetime,'31/".$mes."/".$ano."',103) ";
				}
				else if($mes == 2 || $mes == 4 || $mes == 6 || $mes == 9 || $mes == 11)
				{
					$queryMovimActual.=" AND convert(datetime,'30/".$mes."/".$ano."',103) ";
				}
					//echo $queryMovimActual."<br><br>";
        $queryMovimActual .= " group by movim.pctcod, ctas.pctipo";
				//Se obtiene el dato de la consulta se acumula y se aguarda en un arreglo
				$resMovimActual = sqlsrv_query($conn, $queryMovimActual, array(), array('Scrollable' => 'buffered'));
				while ($rowMovimActual=sqlsrv_fetch_array($resMovimActual))
				{
          if ($rowMovimActual['pctipo'] == 'I' OR $rowMovimActual['pctipo'] == 'P') {
              $resSuma = $rowMovimActual['resultadoSuma'] * -1;
              $acumuladototalRealActual = sumarTotales($acumuladototalRealActual,$resSuma);
    					$acumuladoTotalRealActualArray = sumarTotales($acumuladoTotalRealActualArray,$resSuma);
          }
          else
          {
            $acumuladototalRealActual = sumarTotales($acumuladototalRealActual,$rowMovimActual['resultadoSuma']);
  					$acumuladoTotalRealActualArray = sumarTotales($acumuladoTotalRealActualArray,$rowMovimActual['resultadoSuma']);
          }
				}
				//echo $acumuladototalRealActual."->Total Real Actual <br><br>";
        //echo "acumuladoTotalRealActualArray ".$acumuladoTotalRealActualArray."<br><br>";
				//Para obtener los totales o valores de los presupuestos actuales
				if($b==3)
				{
					if($bandera3==$arrayIdCuentas[$a]){

					}
					else
					{
						for($sum=1;$sum<=$campoQuery;$sum++)
						{
							$variableSumar = $variableSumar."[".$sum."]+";
						}

						$variableSumar = substr($variableSumar, 0, -1);
            //echo $variableSumar;
						$queryObtengoPresupuesto =" SELECT isnull(sum(".$variableSumar."),0) AS acumulado FROM dsbuinzoo.dbo.ds_presupuesto ";
						$queryObtengoPresupuesto.=" WHERE idCuenta = '".$arrayIdCuentas[$a]."' AND ano = '".$ano."' ";
            //echo $queryObtengoPresupuesto;
						$resPre = sqlsrv_query($conn, $queryObtengoPresupuesto, array(), array('Scrollable' => 'buffered'));
						while ($rowPre=sqlsrv_fetch_array($resPre))
						{
							$acumuladoTotalPresupuestoActual = sumarTotales($acumuladoTotalPresupuestoActual, $rowPre['acumulado']);
							$acumuladoTotalPresupuestoActualArray = sumarTotales($acumuladoTotalPresupuestoActualArray,$rowPre['acumulado']);
						}
						$bandera3 = $arrayIdCuentas[$a];
					}

					$arrayAcumuladoTotalRealAnterior[$a] = $acumuladoTotalRealAnteriorArray;
					$arrayAcumuladoTotalPresupuestoActual[$a] = $acumuladoTotalPresupuestoActualArray;
					$arrayAcumuladoTotalRealActualArray[$a] = $acumuladoTotalRealActualArray;
					$arrayAcumuladoTotalRealVariacionAnteriorConActual[$a] = round(($acumuladoTotalRealActualArray / $acumuladoTotalRealAnteriorArray ),2);
					$arrayAcumuladoTotalRealVariacionRealPptoActual[$a] = ($acumuladoTotalRealActualArray / $acumuladoTotalPresupuestoActualArray);

					$variableSumar = "";
					$acumuladoTotalRealAnteriorArray = 0;
					$acumuladoTotalRealActualArray = 0;
					$acumuladoTotalPresupuestoActualArray = 0;

				}
					$pccodi = "";
			}
			//echo $acumuladoTotalPresupuestoActual."->Acumulado Presupuesto Actual <br><br>";

		}

		/*Fin Total Acumulado*/

		  $alignCenter = array(
			'alignment' => array(
            'horizontal' => PHPExcel_Style_Alignment::HORIZONTAL_CENTER,
				),
			'font'  => array(
			'bold'  => true
			)
			);

			$styleArray = array(
			'font'  => array(
			'bold'  => true
			));

		//Rellenar excel con datos
		$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A1', "")
		->setCellValue('B1', "")
		->setCellValue('C1', "")
		->setCellValue('D1', "ESTADO DE RESULTADOS CONSOLIDADO ".nombreMes($mes)."-".$ano)
		->setCellValue('E1', "")
		->setCellValue('F1', "")
		->setCellValue('G1', "")
		->setCellValue('H1', "")
		->setCellValue('I1', "")
		->setCellValue('J1', "")
		->setCellValue('K1', "")
		->setCellValue('L1', "")
		->setCellValue('M1', $datoFecha);
		$objPHPExcel->getActiveSheet()->getStyle('G1')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('G1')->setAutoSize(true);

		$objPHPExcel->getActiveSheet()->mergeCells('A4:F4');
		$objPHPExcel->getActiveSheet()->mergeCells('H4:M4');
		$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A4', "MES")
		->setCellValue('B4', "")
		->setCellValue('C4', "")
		->setCellValue('D4', "")
		->setCellValue('E4', "")
		->setCellValue('F4', "")
		->setCellValue('G4', "")
		->setCellValue('H4', "ACUMULADO")
		->setCellValue('I4', "")
		->setCellValue('J4', "")
		->setCellValue('K4', "")
		->setCellValue('L4', "")
		->setCellValue('M4', "");
		$objPHPExcel->getActiveSheet()->getStyle('A4')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('A4')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle('H4')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('H4')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle('G4')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('G4')->setAutoSize(true);

		$objPHPExcel->getActiveSheet()->mergeCells('D5:E5');
		$objPHPExcel->getActiveSheet()->mergeCells('K5:L5');
		$objPHPExcel->setActiveSheetIndex(0)
		->setCellValue('A5', "REAL")
		->setCellValue('B5', "PPTO")
		->setCellValue('C5', "REAL")
		->setCellValue('D5', "VARIACION")
		->setCellValue('E5', "")
		->setCellValue('F5', "PROPORC")
		->setCellValue('G5', "CUENTAS")
		->setCellValue('H5', "REAL")
		->setCellValue('I5', "PPTO")
		->setCellValue('J5', "REAL")
		->setCellValue('K5', "VARIACION")
		->setCellValue('L5', "")
		->setCellValue('M5', "PROPORC REAL");

		$objPHPExcel->getActiveSheet()->getStyle('D5')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('D5')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle('K5')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('K5')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getStyle('G5')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('G5')->setAutoSize(true);



		if($tt == 1)
		{
			//Generación de vista de tabla de Estado de resultados
			echo '<div id="tablaContenedora" class="tablaContenedora planilla">';
			echo '<table border="0" cellpadding="0" cellspacing="0" width="100%" class="scrollTable">';
			echo '<thead class="fixedHeader">';
			echo '<tr>';
			echo '<th colspan="6" class="eerrTitulo">Mes</th>';
			echo '<th>&nbsp;</th>';
			echo '<th colspan="6" class="eerrTitulo">Acumulado</th>';
			echo '</tr>';
			echo '</thead>';

			echo '<tbody class="scrollContent">';
			echo '<tr>';
			echo '<td class="eerrSubtitulo">Real</td>';
			echo '<td class="eerrSubtitulo">Ppto</td>';
			echo '<td class="eerrSubtitulo">Real</td>';
			echo '<td class="eerrSubtitulo" colspan="2">Variaci&oacute;n</td>';
			echo '<td class="eerrSubtitulo">Propor</td>';
			echo '<td>&nbsp;</td>';
			echo '<td class="eerrSubtitulo">Real</td>';
			echo '<td class="eerrSubtitulo">Ppto</td>';
			echo '<td class="eerrSubtitulo">Real</td>';
			echo '<td class="eerrSubtitulo" colspan="2">Variaci&oacute;n</td>';
			echo '<td class="eerrSubtitulo">Propor</td>';
			echo '</tr>';

			echo '<tr>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$anoAnterior.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">Real '.nombreMes($mes).'-'.$anoAnterior.'/Real '.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">Real '.nombreMes($mes).'-'.$ano.'/Ppto '.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td>&nbsp;</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$anoAnterior.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">Real '.nombreMes($mes).'-'.$anoAnterior.'/Real '.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">Real '.nombreMes($mes).'-'.$ano.'/Ppto '.nombreMes($mes).'-'.$ano.'</td>';
			echo '<td class="eerrSubtitulo">'.nombreMes($mes).'-'.$ano.'</td>';
			echo '</tr>';

		$objPHPExcel->setActiveSheetIndex(0)
  		->setCellValue('A6', nombreMes($mes).'-'.$anoAnterior)
  		->setCellValue('B6', nombreMes($mes).'-'.$ano)
  		->setCellValue('C6', nombreMes($mes).'-'.$ano)
  		->setCellValue('D6', nombreMes($mes).'-'.$anoAnterior.'/Real '.nombreMes($mes).'-'.$ano)
  		->setCellValue('E6', nombreMes($mes).'-'.$ano.'/Ppto '.nombreMes($mes).'-'.$ano)
  		->setCellValue('F6', nombreMes($mes).'-'.$ano)
  		->setCellValue('G6', "")
  		->setCellValue('H6', nombreMes($mes).'-'.$anoAnterior)
  		->setCellValue('I6', nombreMes($mes).'-'.$ano)
  		->setCellValue('J6', nombreMes($mes).'-'.$ano)
  		->setCellValue('K6', nombreMes($mes).'-'.$anoAnterior.'/Real '.nombreMes($mes).'-'.$ano)
  		->setCellValue('L6', nombreMes($mes).'-'.$ano.'/Ppto '.nombreMes($mes).'-'.$ano)
  		->setCellValue('M6', nombreMes($mes).'-'.$ano);

		$objPHPExcel->getActiveSheet()->getStyle('G6')->applyFromArray($alignCenter);
		$objPHPExcel->getActiveSheet()->getColumnDimension('G4')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('A6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('B6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('C6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('D6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('E6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('F6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('G6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('H6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('I6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('J6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('K6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('L6')->setAutoSize(true);
		$objPHPExcel->getActiveSheet()->getColumnDimension('M6')->setAutoSize(true);

		}
		else
		{
  			echo '<tr>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo" colspan="2">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo" colspan="2">&nbsp;</td>';
  			echo '<td class="eerrSubtitulo">&nbsp;</td>';
  			echo '</tr>';

			$objPHPExcel->setActiveSheetIndex(0)
  			->setCellValue('A'.$n.'', "")
  			->setCellValue('B'.$n.'', "")
  			->setCellValue('C'.$n.'', "")
  			->setCellValue('D'.$n.'', "")
  			->setCellValue('E'.$n.'', "")
  			->setCellValue('F'.$n.'', "")
  			->setCellValue('G'.$n.'', "")
  			->setCellValue('H'.$n.'', "")
  			->setCellValue('I'.$n.'', "")
  			->setCellValue('J'.$n.'', "")
  			->setCellValue('K'.$n.'', "")
  			->setCellValue('L'.$n.'', "")
  			->setCellValue('M'.$n.'', "");

			$objPHPExcel->getActiveSheet()->getStyle('G6')->applyFromArray($alignCenter);
			$objPHPExcel->getActiveSheet()->getColumnDimension('G'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('A'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('B'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('C'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('D'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('E'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('F'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('G'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('H'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('I'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('J'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('K'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('L'.$n.'')->setAutoSize(true);
			$objPHPExcel->getActiveSheet()->getColumnDimension('M'.$n.'')->setAutoSize(true);

			$n++;

		}


		//for($a=0;$a<count($arrayCuentas);$a++)
		for($a=0;$a<count($arrayCuentas);$a++)
		{
			//echo $arrayCuentas[$a]."<br>";
			for($b=0;$b<4;$b++)
			{
				$queryPCCODI =" SELECT * FROM dsbuinzoo.dbo.ds_cuentas WHERE nombreCuenta = '".$arrayCuentas[$a]."' AND BD = '".$arregloCondicionQuery[$b]."' ";
				$queryPCCODI.=" AND nivel ='".$tt."' ";
				//echo $queryPCCODI."<br>";
				$res = sqlsrv_query($conn, $queryPCCODI, array(), array('Scrollable' => 'buffered'));
				while ($row=sqlsrv_fetch_array($res))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
					$hrefId = $row['id'];
				}

				$pccodi = substr($pccodi, 0, strlen($pccodi)-1);
				$pccodi = str_replace("''","','" , $pccodi);
				//echo $pccodi."<===<br>";

				//$queryMovim =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma from buinzoo.softland.cwmovim ";
				$queryMovim =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo";
        $queryMovim .= " from ".$arregloBd[$b].".softland.cwmovim movim";
        $queryMovim .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovim.=" where cpbano = '".$anoAnterior."' AND pctCod IN (".$pccodi.")";
				$queryMovim.=" and MovFe BETWEEN convert(datetime,'01/".$mes."/".$anoAnterior."',103)";
				if($mes == 2)
				{
					$queryMovim.=" AND convert(datetime,'28/".$mes."/".$anoAnterior."',103)";
				}
				else if($mes == 1 || $mes == 3 || $mes == 5 || $mes == 7 || $mes == 8 || $mes == 10 || $mes == 12)
				{
					$queryMovim.=" AND convert(datetime,'31/".$mes."/".$anoAnterior."',103)";
				}
				else if($mes == 2 || $mes == 4 || $mes == 6 || $mes == 9 || $mes == 11)
				{
					$queryMovim.=" AND convert(datetime,'30/".$mes."/".$anoAnterior."',103)";
				}
        $queryMovim .= " group by movim.pctcod, ctas.pctipo";
				$resMovim = sqlsrv_query($conn, $queryMovim, array(), array('Scrollable' => 'buffered'));
				while ($rowMovim=sqlsrv_fetch_array($resMovim))
				{
          if ($rowMovim['pctipo'] == 'I' OR $rowMovim['pctipo'] == 'P')
          {
              $resSuma = $rowMovim['resultadoSuma'] * -1;
              $realAnterior = sumarTotales($realAnterior, $resSuma);
          }
          else
          {
            $realAnterior = sumarTotales($realAnterior, $rowMovim['resultadoSuma']);
          }
				}
				$queryMovimActual =" select isnull(sum(MovDebe-MovHaber),0) as resultadoSuma, movim.pctcod, ctas.pctipo";
				$queryMovimActual .= " from ".$arregloBd[$b].".softland.cwmovim movim";
				$queryMovimActual .= " INNER JOIN buinzoo.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi";
				$queryMovimActual.=" where cpbano = '".$ano."' AND pctCod IN (".$pccodi.") ";
				$queryMovimActual.=" and MovFe BETWEEN convert(datetime,'01/".$mes."/".$ano."',103)";
				if($mes == 2)
				{
					$queryMovimActual.=" AND convert(datetime,'28/".$mes."/".$ano."',103)";
				}
				else if($mes == 1 || $mes == 3 || $mes == 5 || $mes == 7 || $mes == 8 || $mes == 10 || $mes == 12)
				{
					$queryMovimActual.=" AND convert(datetime,'31/".$mes."/".$ano."',103)";
				}
				else if($mes == 2 || $mes == 4 || $mes == 6 || $mes == 9 || $mes == 11)
				{
					$queryMovimActual.=" AND convert(datetime,'30/".$mes."/".$ano."',103)";
				}
				$queryMovimActual .= " group by movim.pctcod, ctas.pctipo";

				//echo $queryMovimActual."<br><br>";
				$resMovimActual = sqlsrv_query($conn, $queryMovimActual, array(), array('Scrollable' => 'buffered'));
				while ($rowMovimActual=sqlsrv_fetch_array($resMovimActual))
				{
          if ($rowMovimActual['pctipo'] == 'I' OR $rowMovimActual['pctipo'] == 'P') {
              $resSuma = $rowMovimActual['resultadoSuma'] * -1;
              $realActual = sumarTotales($realActual,$resSuma);
          }
          else
          {
            $realActual = sumarTotales($realActual,$rowMovimActual['resultadoSuma']);
          }
				}
				if($b==3)
				{
					if($bandera == $arrayIdCuentas[$a]){

					}else
					{
						$queryObtengoPresupuesto =" SELECT * FROM dsbuinzoo.dbo.ds_presupuesto ";
						$queryObtengoPresupuesto.="WHERE idCuenta = '".$arrayIdCuentas[$a]."' AND ano = '".$ano."' ";
						$resPre = sqlsrv_query($conn, $queryObtengoPresupuesto, array(), array('Scrollable' => 'buffered'));
						while ($rowPre=sqlsrv_fetch_array($resPre))
						{
								$presupuestoActual = $rowPre[$campoQuery];
						}

						$variacionRealAnualEntreAnos = round(($realActual / $realAnterior),2);
						$variacionRealPptoAnoActual = round(($realActual / $presupuestoActual),2);
						//$Proporc = $realActual/$totalRealActual;
            //echo "Real Actual -->".$realActual;
          //  echo "totalRealActual --> ".$totalRealActual;
          //  echo "proporcion --> ".$Proporc;
            $Proporc = round(($realActual/$totalRealActual),4);

						echo '<tr>';
						echo '<td class="eerrCuerpo"><a href="index.php?mod=saldos_ver&id='.$hrefId.'&b='.$mes.'&c='.$ano.'">'.formatoMoneda($realAnterior,pesos).'</a></td>'; $totalA +=$realAnterior;
						echo '<td class="eerrCuerpo">'.formatoMoneda($presupuestoActual,pesos).'</td>'; $totalB += $presupuestoActual;
						echo '<td class="eerrCuerpo">'.formatoMoneda($realActual,pesos).'</td>'; $totalC +=$realActual;
						echo '<td class="eerrCuerpo">'.round($variacionRealAnualEntreAnos,2).' %</td>'; $totalD +=$variacionRealAnualEntreAnos;
						echo '<td class="eerrCuerpo">'.round($variacionRealPptoAnoActual,2).' %</td>';$totalE += $variacionRealPptoAnoActual;
						echo '<td class="eerrCuerpo">'.$Proporc.' %</td>'; $totalF += $Proporc;
						echo '<td class="eerrSubtitulo">'.$arrayCuentas[$a].'</td>';
						echo '<td class="eerrCuerpo">'.formatoMoneda($arrayAcumuladoTotalRealAnterior[$a],pesos).'</td>';$totalG += $arrayAcumuladoTotalRealAnterior[$a];
						echo '<td class="eerrCuerpo">'.formatoMoneda($arrayAcumuladoTotalPresupuestoActual[$a],pesos).'</td>'; $totalH += $arrayAcumuladoTotalPresupuestoActual[$a];
						echo '<td class="eerrCuerpo">'.formatoMoneda($arrayAcumuladoTotalRealActualArray[$a],pesos).'</td>'; $totalI += $arrayAcumuladoTotalRealActualArray[$a];
						echo '<td class="eerrCuerpo">'.round($arrayAcumuladoTotalRealVariacionAnteriorConActual[$a],2).' %</td>'; $totalJ += $arrayAcumuladoTotalRealVariacionAnteriorConActual[$a];
						echo '<td class="eerrCuerpo">'.round($arrayAcumuladoTotalRealVariacionRealPptoActual[$a],2).' %</td>';$totalK += $arrayAcumuladoTotalRealVariacionRealPptoActual[$a];
						echo '<td class="eerrCuerpo">'.$Proporc.' %</td>'; $totalL += $Proporc;
						echo '</tr>';

						$objPHPExcel->setActiveSheetIndex(0)
							->setCellValue('A'.$n.'',$realAnterior)
							->setCellValue('B'.$n.'',$presupuestoActual)
							->setCellValue('C'.$n.'',$realActual)
							->setCellValue('D'.$n.'',$variacionRealAnualEntreAnos)
							->setCellValue('E'.$n.'',$variacionRealPptoAnoActual)
							->setCellValue('F'.$n.'',$Proporc)
							->setCellValue('G'.$n.'',strtoupper($arrayCuentas[$a]))
							->setCellValue('H'.$n.'',$arrayAcumuladoTotalRealAnterior[$a])
							->setCellValue('I'.$n.'',$arrayAcumuladoTotalPresupuestoActual[$a])
							->setCellValue('J'.$n.'',$arrayAcumuladoTotalRealActualArray[$a])
							->setCellValue('K'.$n.'',$arrayAcumuladoTotalRealVariacionAnteriorConActual[$a])
							->setCellValue('L'.$n.'',$arrayAcumuladoTotalRealVariacionRealPptoActual[$a])
							->setCellValue('M'.$n.'',$Proporc);
						$objPHPExcel->getActiveSheet()->getStyle('G'.$n.'')->applyFromArray($alignCenter);
						$objPHPExcel->getActiveSheet()->getColumnDimension('G'.$n.'')->setAutoSize(true);
						$n++;

					}
					$pccodi = "";
					$realAnterior = 0;
					$presupuestoActual = 0;
					$realActual = 0;
					$bandera = $arrayIdCuentas[$a];
				}
			}
		}
					echo '<tr>';
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalA,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalB,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalC,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.round($totalD,2).' %</td>';
					echo '<td class="eerrCuerpoTotal">'.round($totalE,2).' %</td>';
					echo '<td class="eerrCuerpoTotal">'.$totalF.' %</td>';
					echo '<td class="eerrSubtituloTotal">TOTAL '.$tt.' Nivel</td>';//7
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalG,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalH,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalI,pesos).'</td>';
					echo '<td class="eerrCuerpoTotal">'.round($totalJ,2).'%</td>';
					echo '<td class="eerrCuerpoTotal">'.round($totalK,2).'%</td>';
					echo '<td class="eerrCuerpoTotal">'.$totalL.' %</td>';
					echo '</tr>';


					$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue('A'.$n.'',$totalA)
					->setCellValue('B'.$n.'',$totalB)
					->setCellValue('C'.$n.'',$totalC)
					->setCellValue('D'.$n.'',$totalD)
					->setCellValue('E'.$n.'',$totalE)
					->setCellValue('F'.$n.'',$totalF)
					->setCellValue('G'.$n.'','TOTAL')
					->setCellValue('H'.$n.'',$totalG)
					->setCellValue('I'.$n.'',$totalH)
					->setCellValue('J'.$n.'',$totalI)
					->setCellValue('K'.$n.'',$totalJ)
					->setCellValue('L'.$n.'',$totalK)
					->setCellValue('M'.$n.'',$totalL);
					$objPHPExcel->getActiveSheet()->getStyle('G'.$n.'')->applyFromArray($alignCenter);
					$objPHPExcel->getActiveSheet()->getColumnDimension('G'.$n.'')->setAutoSize(true);
					$n++;

				$acumj = $totalJ;
				$acumk = $totalK;

				$keyCuenta = 0;
				$arrayCuentas = "";
				$totalA =0;
				$totalB =0;
				$totalC =0;
				$totalD =0;
				$totalE =0;
				$totalF =0;
				$totalG =0;
				$totalH =0;
				$totalI =0;
				$totalJ =0;
				$totalK =0;
				$totalL =0;

	}

			echo '<tr>';
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalRealAnterior,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalPresupuestoActual,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($totalRealActual,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.round($totalRealVariacionAnteriorConActual,2).'%</td>';
			echo '<td class="eerrCuerpoTotal">'.round($totalRealVariacionRealPptoActual,2).'%</td>';
			echo '<td class="eerrCuerpoTotal">'.$Proporc.'%</td>';
			echo '<td class="eerrSubtituloTotal">TOTALES NIVELES</td>';//7
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($acumuladoTotalRealAnterior,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($acumuladoTotalPresupuestoActual,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.formatoMoneda($acumuladototalRealActual,pesos).'</td>';
			echo '<td class="eerrCuerpoTotal">'.round($acumj,2).'%</td>';
			echo '<td class="eerrCuerpoTotal">'.round($acumk,2).'%</td>';
			echo '<td class="eerrCuerpoTotal">'.$Proporc.'%</td>';
			echo '</tr>';

		echo '</tbody>';
		echo '</table>';

		$objPHPExcel->setActiveSheetIndex(0)
					->setCellValue('A'.$n.'',formatoMoneda($acumuladoTotalRealAnterior,pesos))
					->setCellValue('B'.$n.'',formatoMoneda($totalPresupuestoActual,pesos))
					->setCellValue('C'.$n.'',formatoMoneda($totalRealActual,pesos))
					->setCellValue('D'.$n.'',round($totalRealVariacionAnteriorConActual,2))
					->setCellValue('E'.$n.'',round($totalRealVariacionRealPptoActual,2))
					->setCellValue('F'.$n.'',$Proporc)
					->setCellValue('G'.$n.'','TOTALES NIVELES')
					->setCellValue('H'.$n.'',formatoMoneda($acumuladoTotalRealAnterior,pesos))
					->setCellValue('I'.$n.'',formatoMoneda($acumuladoTotalPresupuestoActual,pesos))
					->setCellValue('J'.$n.'',formatoMoneda($acumuladototalRealActual,pesos))
					->setCellValue('K'.$n.'',round($acumj,2))
					->setCellValue('L'.$n.'',round($acumk,2))
					->setCellValue('M'.$n.'',$Proporc);
					$objPHPExcel->getActiveSheet()->getStyle('G'.$n.'')->applyFromArray($alignCenter);
					$objPHPExcel->getActiveSheet()->getColumnDimension('G'.$n.'')->setAutoSize(true);
					$n++;

		require_once ('inc/PHPExcel/IOFactory.php');
		$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel2007');
		$objWriter->save($fname);
		//print $salida;
		echo '<br>';
		echo  '<a href="'.$fname.'" class="descarga"><img src="imgs/excel.png" /> &nbsp; DESCARGAR ARCHIVO PARA EXCEL</a>';
		echo '</div>';

}

//function DetalleCuentasSaldos($cta,$mes,$ano,$ccs)
function DetalleCuentasSaldos($id,$mes,$ano,$cc)
{
	
	include('inc/conexion.php');
	//echo $id." -- ".$mes." -- ".$ano."--".$cc."<br>";
	$a = $ano-1;
	$salida = '
			<center>
			<table border="1" width="1000" class="boxedb">
				<tr class="tit">
					<th width="80" align="center">Cod. Cuenta</th>
					<th width="80" align="center">Dia</th>
					<th width="80" align="center">Comprobante</th>
					<th width="80" align="center">Linea</th>
					<th width="80" align="center">Debe </th>
					<th width="80" align="center">Haber</th>
					<th width="150" align="center">Descripción</th>
					<th width="150" align="center">CC</th>
				</tr>
			<tbody>';
	$totalDebe = 0;
	$totalHaber = 0;
	
		//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
		$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
			//echo $queryCuentas."<br>";

		$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
		while($row = sqlsrv_fetch_array($rec))
		{
			$pccodi = $pccodi."'".$row['PCCODI']."',";
		}
		$pccodi = substr($pccodi, 0, -1);
		//$arrayPCCODI[0] = $pccodi;
		//$pccodi = "";
		$resta = substr($cc,0,2);
		$sql = " SELECT PctCod, day(Cpbfec) as dia, CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa,cccod ";
		$sql.= " FROM ".$dbs.".cwmovim WHERE PctCod IN (".$pccodi.") and cpbmes='".$mes."' ";
		$sql.=" AND cpbano='".$ano."' ";
		//$sql.=" AND CCCod = '".$cc."' ";
		$sql.=" AND CCCod LIKE '".$resta."%' ";
			//echo $sql."<br>";
		$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
		
		while($row = sqlsrv_fetch_array($rec))
		{
			$salida .= '
				<tr class="">
					<td align="center">'.$row['PctCod'].'</td>
					<td align="center">'.$row['dia'].'</td>
					<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
					<td align="center">'.$row['movnum'].'</td>
					<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
					<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
					<td align="center">'.$row['MovGlosa'].'</td>
					<td align="center">'.$row['cccod'].'</td>
				</tr>';
				
				$totalDebe +=$row['MovDebe'];
				$totalHaber +=$row['Movhaber'];		
		}		
	
			$salida.='
				<tr class="">
					<td align="center">TOTAL</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="right">'.number_format($totalDebe,2,",",".").'</td>
					<td align="right">'.number_format($totalHaber,2,",",".").'</td>
					<td align="center">&nbsp;</td>
					<td align="center">TOTAL</td>
				</tr>';
		$salida .= '</tbody>
		</table>
		</center>';
	/*
	if ($ccs=='')
		{
		$sql = " SELECT PctCod, day(Cpbfec) as dia, CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa ";
		$sql.= " FROM ".$dbs.".cwmovim WHERE PctCod='".$cta."' and cpbmes='".$mes."' AND cpbano='".$ano."'";
		}
	else
		{
		$sql = " SELECT PctCod, day(Cpbfec) as dia, CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa ";
		$sql.= " FROM ".$dbs.".cwmovim WHERE PctCod='".$cta."' and cpbmes='".$mes."' AND cpbano='".$ano."' AND CcCod='".$ccs."'";
		}
	*/

	//echo $sql;
	/*
	$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
	$num_rows = sqlsrv_num_rows($rec);
	if($num_rows > 0)
		{
		$salida = '
		<center>
		<table border="1" width="1000" class="boxedb">
			<tr class="tit">
				<th width="80" align="center">Cod. Cuenta</th>
				<th width="80" align="center">Dia</th>
				<th width="80" align="center">Comprobante</th>
				<th width="80" align="center">Linea</th>
				<th width="80" align="center">Debe </th>
				<th width="80" align="center">Haber</th>
				<th width="150" align="center">Descripción</th>
			</tr>
		<tbody>';
		while($row = sqlsrv_fetch_array($rec))
			{
			$salida .= '
			<tr class="">
				<td align="center">'.$row['PctCod'].'</td>
				<td align="center">'.$row['dia'].'</td>
				<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'">'.$row['CpbNum'].'</td>
				<td align="center">'.$row['movnum'].'</td>
				<td align="right">'.number_format($row['MovDebe'],2,",",".").'</td>
				<td align="right">'.number_format($row['Movhaber'],2,",",".").'</td>
				<td align="left">'.$row['MovGlosa'].'</td>
			</tr>';
			}
		$salida .= '</tbody>
		</table>
		</center>';
		}
	if($num_rows == 0)
		{
		$salida = '<div class="message_info"><p>No se han encontrado elementos en esta secci&oacute;n</p></div>';
		}
		*/
	return $salida;
	}
	

function DetalleCuentasSaldosAcumulado($id,$mes,$ano,$cc)
{
	
	include('inc/conexion.php');
	//echo $id." -id- ".$mes." -mes- ".$ano."-ano-".$cc."--cc<br>";

	$a = $ano-1;
	$valor=$id;
		$querycc="select valor, suma from dscis.dbo.DS_DistribucionCC where ano='".$ano."'  and CodiCC='".$cc."' and idCuenta='".$id."' ";

		$sumas = sqlsrv_query($conn, $querycc, array(), array('Scrollable' => 'buffered'));
		while ($row1 = sqlsrv_fetch_array($sumas))
		{
			$tienesumas=$row1['suma'];
			$valordistribucion=$row1['valor'];
		
			if($valor==1 ||$valor==2 || $valor==3 || $valor==4 ||$valor==5 || $valor==6 ||$valor==7 ||$valor==8|| $valor==9 )
			{	
		
			
		
										if($valordistribucion==100)
										{
																		$salida = '
																	<center>
														<table border="1" width="1000" class="boxedb">
														<tr class="tit">
															<th width="80" align="center">Cod. Cuenta</th>
															<th width="80" align="center">Dia</th>
															<th width="80" align="center">Comprobante</th>
															<th width="80" align="center">Linea</th>
															<th width="80" align="center">Debe </th>
															<th width="80" align="center">Haber</th>
															<th width="150" align="center">Descripción</th>
															<th width="150" align="center">CC</th>
																<th width="150" align="center">Distribucion100 '.$cc.' y Nivel '.$id.'</th>
															
														</tr>
													<tbody>';
											$totalDebe = 0;
											$totalHaber = 0;
											$totalcc=0;
												$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
												$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
												while ($row1 = sqlsrv_fetch_array($centroccosto))
												{
													$centro=$centroccosto."'".$row1['CcCod']."',";
												}
												//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
												$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
													//echo $queryCuentas."<br>";

												$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
												while($row = sqlsrv_fetch_array($rec))
												{
													$pccodi = $pccodi."'".$row['PCCODI']."',";
												}
												$pccodi = substr($pccodi, 0, -1);
												//$arrayPCCODI[0] = $pccodi;
												//$pccodi = "";
												$resta = substr($cc,0,2);
												$ccosto= substr($cc,0,5);
												
												
												
												
								
												
												
												
												
												
												
												
												
										$centro=substr($cc, 0, -1);
			
												
												
												$sql = "  
													SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
							FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
							and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
							IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '".$centro."1'  ";


											
												$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

												while($row = sqlsrv_fetch_array($rec))
												{
													$salida .= '
														<tr class="">
															<td align="center">'.$row['PctCod'].'</td>
															<td align="center">'.$row['dia'].'</td>
															<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
															<td align="center">'.$row['movnum'].'</td>
															<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
															<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
															<td align="center">'.$row['MovGlosa'].'</td>
															<td align="center">'.$row['CcCod'].'</td>
															<td align="center">'.$row['valor'].'</td>
														</tr>';
														
														
													
														
														$totalcc=$row['valor'];
														$totalDebe +=$row['MovDebe'];
														$totalHaber +=$row['Movhaber'];		
												}		
												
											
												 $suma=$totalDebe-$totalHaber;
												 
												 $valortotal=$suma*$totalcc;
												 echo $valortotal;
                                                 $resultado=$valortotal/100000;
												 
													$salida.='
														<tr class="">
															<td align="center">TOTAL</td>
															<td align="center">&nbsp;</td>
															<td align="center">&nbsp;</td>
															<td align="center">&nbsp;</td>
															<td align="right">'.number_format($totalDebe,2,",",".").'</td>
															<td align="right">'.number_format($totalHaber,2,",",".").'</td>
															<td align="center">&nbsp;</td>
															<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
															<td align="right">Centro Costo * Distribucion '.number_format($resultado,2,",",".").'</td>
														
														</tr>';
												$salida .= '</tbody>
												</table>
												</center>';
												
												

												
												return $salida;
										}
			
			
								
				if($valordistribucion==0)
				{
										$salida = '
											<center>
											<table border="1" width="1000" class="boxedb">
											<tr class="tit">
												<th width="80" align="center">Cod. Cuenta</th>
												<th width="80" align="center">Dia</th>
												<th width="80" align="center">Comprobante</th>
												<th width="80" align="center">Linea</th>
												<th width="80" align="center">Debe </th>
												<th width="80" align="center">Haber</th>
												<th width="150" align="center">Descripción</th>
												<th width="150" align="center">CC</th>
													<th width="150" align="center">Distribucion0</th>
												
											</tr>
										<tbody>';
								$totalDebe = 0;
								$totalHaber = 0;
								$totalcc=0;
									$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
									$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
									while ($row1 = sqlsrv_fetch_array($centroccosto))
									{
										$centro=$centroccosto."'".$row1['CcCod']."',";
									}
									//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
									$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
										//echo $queryCuentas."<br>";

									$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
									while($row = sqlsrv_fetch_array($rec))
									{
										$pccodi = $pccodi."'".$row['PCCODI']."',";
									}
									$pccodi = substr($pccodi, 0, -1);
									//$arrayPCCODI[0] = $pccodi;
									//$pccodi = "";
									$resta = substr($cc,0,2);
									$ccosto= substr($cc,0,5);
									
									
									
									
									$sql = "  
							SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
							FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
							and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
							IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '".$cc."' ";


								
									$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

									while($row = sqlsrv_fetch_array($rec))
									{
										$salida .= '
											<tr class="">
												<td align="center">'.$row['PctCod'].'</td>
												<td align="center">'.$row['dia'].'</td>
												<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
												<td align="center">'.$row['movnum'].'</td>
												<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
												<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
												<td align="center">'.$row['MovGlosa'].'</td>
												<td align="center">'.$row['CcCod'].'</td>
												<td align="center">'.$row['valor'].'</td>
											</tr>';
											
											
										
											
											$totalcc=$row['valor'];
											$totalDebe +=$row['MovDebe'];
											$totalHaber +=$row['Movhaber'];		
									}		
									
								
									 $suma=$totalDebe-$totalHaber;
									 
									 $valortotal=$suma*$totalcc;
									 echo $valortotal;
                                     $resultado=$valortotal/100000;
									 
										$salida.='
											<tr class="">
												<td align="center">TOTAL</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="right">'.number_format($totalDebe,2,",",".").'</td>
												<td align="right">'.number_format($totalHaber,2,",",".").'</td>
												<td align="center">&nbsp;</td>
												<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
												<td align="right">Centro Costo * Distribucion '.number_format($resultado,2,",",".").'</td>
											
											</tr>';
									$salida .= '</tbody>
									</table>
									</center>';
									
									

									
									return $salida;
				}
	
			if($tienesuma>0 )
			{
			
								$salida = '
									<center>
									<table border="1" width="1000" class="boxedb">
									<tr class="tit">
										<th width="80" align="center">Cod. Cuenta</th>
										<th width="80" align="center">Dia</th>
										<th width="80" align="center">Comprobante</th>
										<th width="80" align="center">Linea</th>
										<th width="80" align="center">Debe </th>
										<th width="80" align="center">Haber</th>
										<th width="150" align="center">Descripción</th>
										<th width="150" align="center">CC</th>
											<th width="150" align="center">Tiene Suma</th>
										
										</tr>
									<tbody>';
									$totalDebe = 0;
										$totalHaber = 0;
								$totalcc=0;
							$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
							$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
							while ($row1 = sqlsrv_fetch_array($centroccosto))
							{
								$centro=$centroccosto."'".$row1['CcCod']."',";
							}
							//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
							$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
								//echo $queryCuentas."<br>";

							$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
							while($row = sqlsrv_fetch_array($rec))
							{
								$pccodi = $pccodi."'".$row['PCCODI']."',";
							}
							$pccodi = substr($pccodi, 0, -1);
							//$arrayPCCODI[0] = $pccodi;
							//$pccodi = "";
							$resta = substr($cc,0,2);
							$ccosto= substr($cc,0,5);
							
							
							
							
							$sql = "  
					SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
					FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
					INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
					and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
					IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
					and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '12-%' ";


						
							$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

							while($row = sqlsrv_fetch_array($rec))
							{
										$salida .= '
									<tr class="">
										<td align="center">'.$row['PctCod'].'</td>
										<td align="center">'.$row['dia'].'</td>
										<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
										<td align="center">'.$row['movnum'].'</td>
										<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
										<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
										<td align="center">'.$row['MovGlosa'].'</td>
										<td align="center">'.$row['CcCod'].'</td>
										<td align="center">'.$row['valor'].'</td>
									</tr>';
									
									
								
									
										$totalcc=$row['valor'];
										$totalDebe +=$row['MovDebe'];
										$totalHaber +=$row['Movhaber'];		
								}		
							
						
							 $suma=$totalDebe-$totalHaber;
							 
							 $valortotal=$suma*$totalcc;
							 $resultado=$valortotal/100000;

							 
								$salida.='
									<tr class="">
										<td align="center">TOTAL</td>
										<td align="center">&nbsp;</td>
										<td align="center">&nbsp;</td>
										<td align="center">&nbsp;</td>
										<td align="right">'.number_format($totalDebe,2,",",".").'</td>
										<td align="right">'.number_format($totalHaber,2,",",".").'</td>
										<td align="center">&nbsp;</td>
										<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
										<td align="right">Centro Costo * Distribucion '.number_format($resultado,2,",",".").'</td>
									
									</tr>';
							$salida .= '</tbody>
							</table>
							</center>';
							
							

							
								return $salida;
		
			}
			else{	


 
			 $salida = '
				<center>
					<table border="1" width="1000" class="boxedb">
				<tr class="tit">
					<th width="80" align="center">Cod. Cuenta</th>
					<th width="80" align="center">Dia</th>
					<th width="80" align="center">Comprobante</th>
					<th width="80" align="center">Linea</th>
					<th width="80" align="center">Debe </th>
					<th width="80" align="center">Haber</th>
					<th width="150" align="center">Descripción</th>
					<th width="150" align="center">CC</th>
					<th width="150" align="center">DISTRIBUCION</th>
				</tr>
				<tbody>';
				$totalDebe = 0;
				$totalHaber = 0;
				$totalcc=0;
				$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
				$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
				while ($row1 = sqlsrv_fetch_array($centroccosto))
				{
					$centro=$centroccosto."'".$row1['CcCod']."',";
				}
				//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
				$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
					//echo $queryCuentas."<br>";

				$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
				while($row = sqlsrv_fetch_array($rec))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
				}
				$pccodi = substr($pccodi, 0, -1);
				//$arrayPCCODI[0] = $pccodi;
				//$pccodi = "";
				$resta = substr($cc,0,2);
				$ccosto= substr($cc,0,5);
		
		
		
		
				$sql = "SELECT PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,
				(select valor from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%' ) as valor,
				(select suma from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%') as suma ,
				(select sum(movdebe-movhaber)FROM CIS.softland.cwmovim p 
				INNER JOIN CIS.softland.cwpctas c  on p.pctcod = c.pccodi 
				INNER JOIN CIS.softland.cwcpbte  cp ON p.cpbnum = cp.cpbnum 
				WHERE  p.cpbano ='".$ano."'  and cp.CpbAno = '".$ano."'  
				AND p.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and p.cpbmes BETWEEN 00 AND '".$mes."' AND cp.CpbEst = 'V' and p.cccod like '".$ccosto."%') as centro
				FROM CIS.softland.cwmovim movim 
				INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
				INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
				WHERE movim.cpbano ='".$ano."'  and cpbte.CpbAno = '".$ano."' 
				AND movim.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '12-%'";

 

			$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

				while($row = sqlsrv_fetch_array($rec))
				{
					
					$salida .= '
						<tr class="">
							<td align="center">'.$row['PctCod'].'</td>
							<td align="center">'.$row['dia'].'</td>
							<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'&cc1='.$row['CcCod'].'" target="_blank">'.$row['CpbNum'].'</td>
							<td align="center">'.$row['movnum'].'</td>
							<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
							<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
							<td align="center">'.$row['MovGlosa'].'</td>
							<td align="center">'.$row['CcCod'].'</td>
							<td align="center">'.$row['valor'].'</td>
				
						</tr>';
						
				
			
					    $distribucion=$row['valor'];
											
						$totalcc=$row['valor'];
						$totalDebe +=$row['MovDebe'];
						$totalHaber +=$row['Movhaber'];		
				}		
		
	
					$suma=$totalDebe-$totalHaber;
		 
						if($distribucion==0 || $distribucion==100)
						{
			
						$total=0; 
						}
		 else{
			$total=$suma*$totalcc;
			$resultado=$total/100000;
		 }

		 
			$salida.='
				<tr class="">
					<td align="center">TOTAL</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="right">'.number_format($totalDebe,2,",",".").'</td>
					<td align="right">'.number_format($totalHaber,2,",",".").'</td>
					<td align="center">&nbsp;</td>
					<td align="center">TOTAL</td>
					<td align="right">DEBE-HABER * CC '.number_format($suma,2,",",".").'</td>
			    <td align="right"> TOTAL DISTRIBUIDO '.number_format($resultado,2,",",".").'</td>
				
				</tr>';
			$salida .= '</tbody>
			</table>
			</center>';
		
		

		
			return $salida;
			 
			 


		 
			
			}
	
	
	
	

	
	}
	

	
			if($valor==10 ||$valor==11 || $valor==12 || $valor==13 ||$valor==14 || $valor==15 ||$valor==16 )
			{	
			
				
			
		
										if($valordistribucion==100)
										{
																		$salida = '
																	<center>
														<table border="1" width="1000" class="boxedb">
														<tr class="tit">
															<th width="80" align="center">Cod. Cuenta</th>
															<th width="80" align="center">Dia</th>
															<th width="80" align="center">Comprobante</th>
															<th width="80" align="center">Linea</th>
															<th width="80" align="center">Debe </th>
															<th width="80" align="center">Haber</th>
															<th width="150" align="center">Descripción</th>
															<th width="150" align="center">CC</th>
																<th width="150" align="center">Distribucion100 '.$cc.' y Nivel '.$id.'</th>
															
														</tr>
													<tbody>';
											$totalDebe = 0;
											$totalHaber = 0;
											$totalcc=0;
												$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
												$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
												while ($row1 = sqlsrv_fetch_array($centroccosto))
												{
													$centro=$centroccosto."'".$row1['CcCod']."',";
												}
												//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
												$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
													//echo $queryCuentas."<br>";

												$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
												while($row = sqlsrv_fetch_array($rec))
												{
													$pccodi = $pccodi."'".$row['PCCODI']."',";
												}
												$pccodi = substr($pccodi, 0, -1);
												//$arrayPCCODI[0] = $pccodi;
												//$pccodi = "";
												$resta = substr($cc,0,2);
												$ccosto= substr($cc,0,5);
												
												
												
												
								
												
												
												
												
												
												
												
												
										$centro=substr($cc, 0, -1);
			
												
												
												$sql = "  
													SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
							FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
							and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
							IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '".$centro."1'  ";


											
												$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

												while($row = sqlsrv_fetch_array($rec))
												{
													$salida .= '
														<tr class="">
															<td align="center">'.$row['PctCod'].'</td>
															<td align="center">'.$row['dia'].'</td>
															<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
															<td align="center">'.$row['movnum'].'</td>
															<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
															<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
															<td align="center">'.$row['MovGlosa'].'</td>
															<td align="center">'.$row['CcCod'].'</td>
															<td align="center">'.$row['valor'].'</td>
														</tr>';
														
														
													
														
														$totalcc=$row['valor'];
														$totalDebe +=$row['MovDebe'];
														$totalHaber +=$row['Movhaber'];		
												}		
												
											
												 $suma=$totalDebe-$totalHaber;
												 
												 $valortotal=$suma*$totalcc;
												 $resultado=$valortotal/100000;

												 
													$salida.='
														<tr class="">
															<td align="center">TOTAL</td>
															<td align="center">&nbsp;</td>
															<td align="center">&nbsp;</td>
															<td align="center">&nbsp;</td>
															<td align="right">'.number_format($totalDebe,2,",",".").'</td>
															<td align="right">'.number_format($totalHaber,2,",",".").'</td>
															<td align="center">&nbsp;</td>
															<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
															<td align="right">Centro Costo * Distribucion '.number_format($resultado,2,",",".").'</td>
														
														</tr>';
												$salida .= '</tbody>
												</table>
												</center>';
												
												

												
												return $salida;
										}
			
			
								
				if($valordistribucion==0)
				{
										$salida = '
											<center>
											<table border="1" width="1000" class="boxedb">
											<tr class="tit">
												<th width="80" align="center">Cod. Cuenta</th>
												<th width="80" align="center">Dia</th>
												<th width="80" align="center">Comprobante</th>
												<th width="80" align="center">Linea</th>
												<th width="80" align="center">Debe </th>
												<th width="80" align="center">Haber</th>
												<th width="150" align="center">Descripción</th>
												<th width="150" align="center">CC</th>
													<th width="150" align="center">Distribucion0</th>
												
											</tr>
										<tbody>';
								$totalDebe = 0;
								$totalHaber = 0;
								$totalcc=0;
									$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
									$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
									while ($row1 = sqlsrv_fetch_array($centroccosto))
									{
										$centro=$centroccosto."'".$row1['CcCod']."',";
									}
									//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
									$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
										//echo $queryCuentas."<br>";

									$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
									while($row = sqlsrv_fetch_array($rec))
									{
										$pccodi = $pccodi."'".$row['PCCODI']."',";
									}
									$pccodi = substr($pccodi, 0, -1);
									//$arrayPCCODI[0] = $pccodi;
									//$pccodi = "";
									$resta = substr($cc,0,2);
									$ccosto= substr($cc,0,5);
									
									
									
									
									$sql = "  
							SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
							FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
							and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
							IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '".$cc."' ";


								
									$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

									while($row = sqlsrv_fetch_array($rec))
									{
										$salida .= '
											<tr class="">
												<td align="center">'.$row['PctCod'].'</td>
												<td align="center">'.$row['dia'].'</td>
												<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
												<td align="center">'.$row['movnum'].'</td>
												<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
												<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
												<td align="center">'.$row['MovGlosa'].'</td>
												<td align="center">'.$row['CcCod'].'</td>
												<td align="center">'.$row['valor'].'</td>
											</tr>';
											
											
										
											
											$totalcc=$row['valor'];
											$totalDebe +=$row['MovDebe'];
											$totalHaber +=$row['Movhaber'];		
									}		
									
								
									 $suma=$totalDebe-$totalHaber;
									 
									 $valortotal=$suma*$totalcc;

									 
										$salida.='
											<tr class="">
												<td align="center">TOTAL</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="right">'.number_format($totalDebe,2,",",".").'</td>
												<td align="right">'.number_format($totalHaber,2,",",".").'</td>
												<td align="center">&nbsp;</td>
												<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
												<td align="right">Centro Costo * Distribucion '.number_format($valortotal,2,",",".").'</td>
											
											</tr>';
									$salida .= '</tbody>
									</table>
									</center>';
									
									

									
									return $salida;
				}
	
			if($tienesuma>0 )
			{
			
								$salida = '
									<center>
									<table border="1" width="1000" class="boxedb">
									<tr class="tit">
										<th width="80" align="center">Cod. Cuenta</th>
										<th width="80" align="center">Dia</th>
										<th width="80" align="center">Comprobante</th>
										<th width="80" align="center">Linea</th>
										<th width="80" align="center">Debe </th>
										<th width="80" align="center">Haber</th>
										<th width="150" align="center">Descripción</th>
										<th width="150" align="center">CC</th>
											<th width="150" align="center">Tiene Suma</th>
										
										</tr>
									<tbody>';
									$totalDebe = 0;
										$totalHaber = 0;
								$totalcc=0;
							$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
							$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
							while ($row1 = sqlsrv_fetch_array($centroccosto))
							{
								$centro=$centroccosto."'".$row1['CcCod']."',";
							}
							//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
							$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
								//echo $queryCuentas."<br>";

							$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
							while($row = sqlsrv_fetch_array($rec))
							{
								$pccodi = $pccodi."'".$row['PCCODI']."',";
							}
							$pccodi = substr($pccodi, 0, -1);
							//$arrayPCCODI[0] = $pccodi;
							//$pccodi = "";
							$resta = substr($cc,0,2);
							$ccosto= substr($cc,0,5);
							
							
							
							
							$sql = "  
					SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
					FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
					INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
					and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
					IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
					and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '01-%' ";


						
							$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

							while($row = sqlsrv_fetch_array($rec))
							{
										$salida .= '
									<tr class="">
										<td align="center">'.$row['PctCod'].'</td>
										<td align="center">'.$row['dia'].'</td>
										<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
										<td align="center">'.$row['movnum'].'</td>
										<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
										<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
										<td align="center">'.$row['MovGlosa'].'</td>
										<td align="center">'.$row['CcCod'].'</td>
										<td align="center">'.$row['valor'].'</td>
									</tr>';
									
									
								
									
										$totalcc=$row['valor'];
										$totalDebe +=$row['MovDebe'];
										$totalHaber +=$row['Movhaber'];		
								}		
							
						
							 $suma=$totalDebe-$totalHaber;
							 
							 $valortotal=$suma*$totalcc;
							 $resultado=$valortotal/100000;

							 
								$salida.='
									<tr class="">
										<td align="center">TOTAL</td>
										<td align="center">&nbsp;</td>
										<td align="center">&nbsp;</td>
										<td align="center">&nbsp;</td>
										<td align="right">'.number_format($totalDebe,2,",",".").'</td>
										<td align="right">'.number_format($totalHaber,2,",",".").'</td>
										<td align="center">&nbsp;</td>
										<td align="center">Valor por Centro Costo '.number_format($suma,2,",",".").'</td>
										<td align="right">Centro Costo * Distribucion '.number_format($resultado,2,",",".").'</td>
									
									</tr>';
							$salida .= '</tbody>
							</table>
							</center>';
							
							

							
								return $salida;
		
			}
			else{	


 
			 $salida = '
				<center>
					<table border="1" width="1000" class="boxedb">
				<tr class="tit">
					<th width="80" align="center">Cod. Cuenta</th>
					<th width="80" align="center">Dia</th>
					<th width="80" align="center">Comprobante</th>
					<th width="80" align="center">Linea</th>
					<th width="80" align="center">Debe </th>
					<th width="80" align="center">Haber</th>
					<th width="150" align="center">Descripción</th>
					<th width="150" align="center">CC</th>
					<th width="150" align="center">DISTRIBUCION</th>
				</tr>
				<tbody>';
				$totalDebe = 0;
				$totalHaber = 0;
				$totalcc=0;
				$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
				$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
				while ($row1 = sqlsrv_fetch_array($centroccosto))
				{
					$centro=$centroccosto."'".$row1['CcCod']."',";
				}
				//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
				$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
					//echo $queryCuentas."<br>";

				$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
				while($row = sqlsrv_fetch_array($rec))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
				}
				$pccodi = substr($pccodi, 0, -1);
				//$arrayPCCODI[0] = $pccodi;
				//$pccodi = "";
				$resta = substr($cc,0,2);
				$ccosto= substr($cc,0,5);
		
		
		
		
				$sql = "SELECT PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,
				(select valor from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%' ) as valor,
				(select suma from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%') as suma ,
				(select sum(movdebe-movhaber)FROM CIS.softland.cwmovim p 
				INNER JOIN CIS.softland.cwpctas c  on p.pctcod = c.pccodi 
				INNER JOIN CIS.softland.cwcpbte  cp ON p.cpbnum = cp.cpbnum 
				WHERE  p.cpbano ='".$ano."'  and cp.CpbAno = '".$ano."'  
				AND p.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and p.cpbmes BETWEEN 00 AND '".$mes."' AND cp.CpbEst = 'V' and p.cccod like '".$ccosto."%') as centro
				FROM CIS.softland.cwmovim movim 
				INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
				INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
				WHERE movim.cpbano ='".$ano."'  and cpbte.CpbAno = '".$ano."' 
				AND movim.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '11-%'";

 

			$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

				while($row = sqlsrv_fetch_array($rec))
				{
					
					$salida .= '
						<tr class="">
							<td align="center">'.$row['PctCod'].'</td>
							<td align="center">'.$row['dia'].'</td>
							<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'&cc1='.$row['CcCod'].'" target="_blank">'.$row['CpbNum'].'</td>
							<td align="center">'.$row['movnum'].'</td>
							<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
							<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
							<td align="center">'.$row['MovGlosa'].'</td>
							<td align="center">'.$row['CcCod'].'</td>
							<td align="center">'.$row['valor'].'</td>
				
						</tr>';
						
				
			
					    $distribucion=$row['valor'];
											
						$totalcc=$row['valor'];
						$totalDebe +=$row['MovDebe'];
						$totalHaber +=$row['Movhaber'];		
				}		
		
	
					$suma=$totalDebe-$totalHaber;
		 
						if($distribucion==0 || $distribucion==100)
						{
			
						$total=0; 
						}
		 else{
			$total=$suma*$totalcc;
			$resultado=$total/100000;
		 }

		 
			$salida.='
				<tr class="">
					<td align="center">TOTAL</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="right">'.number_format($totalDebe,2,",",".").'</td>
					<td align="right">'.number_format($totalHaber,2,",",".").'</td>
					<td align="center">&nbsp;</td>
					<td align="center">TOTAL</td>
					<td align="right">DEBE-HABER * CC '.number_format($suma,2,",",".").'</td>
			    <td align="right"> TOTAL DISTRIBUIDO '.number_format($resultado,2,",",".").'</td>
				
				</tr>';
			$salida .= '</tbody>
			</table>
			</center>';
		
		

		
			return $salida;
			 
			 


		 
			
			}
	
	
	
	

	
	}
		
	

	







		
		

				if($valor==17 ||$valor==18 || $valor==26)
				{	
		
		
		$querycc="select valor, suma from dscis.dbo.DS_DistribucionCC where ano='".$ano."'  and CodiCC='".$cc."' and idCuenta='".$id."' ";

		$sumas = sqlsrv_query($conn, $querycc, array(), array('Scrollable' => 'buffered'));
		while ($row1 = sqlsrv_fetch_array($sumas))
		{
											$tienesumas=$row1['suma'];
											$valordistribucion=$row1['valor'];
											echo $valordistribucion;
												if($valordistribucion==100  )
												{
														$salida = '
															<center>
													<table border="1" width="1000" class="boxedb">
													<tr class="tit">
														<th width="80" align="center">Cod. Cuenta</th>
														<th width="80" align="center">Dia</th>
														<th width="80" align="center">Comprobante</th>
														<th width="80" align="center">Linea</th>
														<th width="80" align="center">Debe </th>
														<th width="80" align="center">Haber</th>
														<th width="150" align="center">Descripción</th>
														<th width="150" align="center">CC</th>
													</tr>
												<tbody>';
												$totalDebe = 0;
										$totalHaber = 0;
											$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
											$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
											while ($row1 = sqlsrv_fetch_array($centroccosto))
											{
												$centro=$centroccosto."'".$row1['CcCod']."',";
											}
											//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
											$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
												//echo $queryCuentas."<br>";

											$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
											while($row = sqlsrv_fetch_array($rec))
											{
												$pccodi = $pccodi."'".$row['PCCODI']."',";
											}
											$pccodi = substr($pccodi, 0, -1);
											//$arrayPCCODI[0] = $pccodi;
											//$pccodi = "";
											$resta = substr($cc,0,2);
											$ccosto= substr($cc,0,5);
											
											
											
											$sql = " SELECT 		PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,(select valor from  dscis.dbo.ds_distribucioncc c where idcuenta='".$id."' and codicc like '".$ccosto."0' and ano='".$ano."') as valor
							FROM CIS.softland.cwmovim movim INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum WHERE movim.cpbano = '".$ano."'  
							and cpbte.CpbAno = '".$ano."'  AND movim.pctcod collate Modern_Spanish_CI_AS 
							IN ( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS'   ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '".$cc."1'  ";
											
											
											echo $sql;
											
											echo $sql;
											$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
											
											while($row = sqlsrv_fetch_array($rec))
											{
												$salida .= '
													<tr class="">
														<td align="center">'.$row['PctCod'].'</td>
														<td align="center">'.$row['dia'].'</td>
														<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'" target="_blank">'.$row['CpbNum'].'</td>
														<td align="center">'.$row['movnum'].'</td>
														<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
														<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
														<td align="center">'.$row['MovGlosa'].'</td>
														<td align="center">'.$row['cccod'].'</td>
													</tr>';
													
													$totalDebe +=$row['MovDebe'];
													$totalHaber +=$row['Movhaber'];		
											}		
											$suma=$totalDebe-$totalHaber;
										   $resultado=$suma/100000;
												$salida.='
													<tr class="">
														<td align="center">TOTAL</td>
														<td align="center">&nbsp;</td>
														<td align="center">&nbsp;</td>
														<td align="center">&nbsp;</td>
														<td align="right">'.number_format($totalDebe,2,",",".").'</td>
														<td align="right">'.number_format($totalHaber,2,",",".").'</td>
														<td align="center">&nbsp;</td>
														<td align="center">'.number_format($resultado,2,",",".").'</td>
													</tr>';
												$salida .= '</tbody>
											</table>
											</center>';
											return $salida;
			}
			  if($tienesumas>0)
				{
								$salida = '
										<center>
										<table border="1" width="1000" class="boxedb">
											<tr class="tit">
												<th width="80" align="center">Cod. Cuenta</th>
												<th width="80" align="center">Dia</th>
												<th width="80" align="center">Comprobante</th>
												<th width="80" align="center">Linea</th>
												<th width="80" align="center">Debe </th>
												<th width="80" align="center">Haber</th>
												<th width="150" align="center">Descripción</th>
												<th width="150" align="center">CC</th>
													<th width="150" align="center">Distribucion Por CENTRO COSTO</th>
											<th width="150" align="center">Tiene Suma</th>
												<th width="150" align="center">VALOR CC PROPIO</th>
									</tr>
										<tbody>';
										$totalDebe = 0;
										$totalHaber = 0;
										$totalcc=0;
									$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
									$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
									while ($row1 = sqlsrv_fetch_array($centroccosto))
									{
										$centro=$centroccosto."'".$row1['CcCod']."',";
									}
									//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
									$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
										//echo $queryCuentas."<br>";

									$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
									while($row = sqlsrv_fetch_array($rec))
									{
										$pccodi = $pccodi."'".$row['PCCODI']."',";
									}
									$pccodi = substr($pccodi, 0, -1);
									//$arrayPCCODI[0] = $pccodi;
									//$pccodi = "";
									$resta = substr($cc,0,2);
									$ccosto= substr($cc,0,5);
									
									
									
									
									$sql = "  
							SELECT PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,
							(select valor from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%' ) as valor,
							(select suma from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%') as suma ,
							(select sum(movdebe-movhaber)FROM CIS.softland.cwmovim p 
							INNER JOIN CIS.softland.cwpctas c  on p.pctcod = c.pccodi 
							INNER JOIN CIS.softland.cwcpbte  cp ON p.cpbnum = cp.cpbnum 
							WHERE  p.cpbano ='".$ano."'  and cp.CpbAno = '".$ano."'  
							AND p.pctcod collate Modern_Spanish_CI_AS IN 
							( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='".$_SESSION['emp']['id']."' ) 
							and p.cpbmes BETWEEN 00 AND '".$mes."' AND cp.CpbEst = 'V' and p.cccod like '".$ccosto."%') as centro
							FROM CIS.softland.cwmovim movim 
							INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
							INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
							WHERE movim.cpbano ='".$ano."'  and cpbte.CpbAno = '".$ano."' 
							AND movim.pctcod collate Modern_Spanish_CI_AS IN 
							( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '11' AND BDSession ='".$_SESSION['emp']['id']."' ) 
							and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '01-%'";
									
						
								
									$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));
									while($row = sqlsrv_fetch_array($rec))
									{
									
										$salida .= '
											<tr class="">
												<td align="center">'.$row['PctCod'].'</td>
												<td align="center">'.$row['dia'].'</td>
												<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'&cc1='.$row['CcCod'].'" target="_blank">'.$row['CpbNum'].'</td>
												<td align="center">'.$row['movnum'].'</td>
												<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
												<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
												<td align="center">'.$row['MovGlosa'].'</td>
												<td align="center">'.$row['CcCod'].'</td>
												<td align="center">'.$row['valor'].'</td>
												  <td align="center">'.$row['suma'].'</td>
												 <td align="center">'.$row['centro'].'</td>
											</tr>';
												$propiocentro=$row['centro'];
										
											$totalcc=$row['valor'];
											$totalDebe +=$row['MovDebe'];
											$totalHaber +=$row['Movhaber'];		
											
										}
											
											$suma=$totalDebe-$totalHaber;
									 
											$valortotal=$suma*$totalcc;
									 
											$divide= $valortotal/100;
										$distribucion= intval($divide); 
										$valortotaltotal=$distribucion+$propiocentro;
										$resultado=$valortotal/100000;
										$salida.='
											<tr class="">
												<td align="center">TOTAL</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="center">&nbsp;</td>
												<td align="right">'.number_format($totalDebe,2,",",".").'</td>
												<td align="right">'.number_format($totalHaber,2,",",".").'</td>
												<td align="center">&nbsp;</td>
												<td align="center">TOTAL (PARA EL ESTADO RESULTADO SE DIVIDE POR 100)</td>
												<td align="right">VALOR CC * DISTRIBUCION  '.number_format($divide,0,",",".").' </td>
											<td align="right">VALOR CC 11*DISTRIBUCION + SUMA PROPIO CENTRO   TOTAL: '.number_format($resultado,2,",",".").'</td>
											</tr>';
									$salida .= '</tbody>
									</table>
									</center>';
									
									

									
									return $salida;
				}
				if($valordistribucion==0){
				
																	$salida = '
																<center>
																<table border="1" width="1000" class="boxedb">
																<tr class="tit">
																<th width="80" align="center">Cod. Cuenta</th>
																<th width="80" align="center">Dia</th>
																<th width="80" align="center">Comprobante</th>
																<th width="80" align="center">Linea</th>
																<th width="80" align="center">Debe </th>
																<th width="80" align="center">Haber</th>
																<th width="150" align="center">Descripción</th>
																<th width="150" align="center">CC</th>
																<th width="150" align="center">DISTRIBUCION</th>
															</tr>
															<tbody>';
															$totalDebe = 0;
															$totalHaber = 0;
															$totalcc=0;
															$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
															$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
															while ($row1 = sqlsrv_fetch_array($centroccosto))
															{
																$centro=$centroccosto."'".$row1['CcCod']."',";
															}
															//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
															$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
																//echo $queryCuentas."<br>";

															$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
															while($row = sqlsrv_fetch_array($rec))
															{
																$pccodi = $pccodi."'".$row['PCCODI']."',";
															}
															$pccodi = substr($pccodi, 0, -1);
															//$arrayPCCODI[0] = $pccodi;
															//$pccodi = "";
															$resta = substr($cc,0,2);
															$ccosto= substr($cc,0,5);
													
													
													
													
															$sql = "SELECT 
																isnull(sum(MovDebe-MovHaber),0) as resultadoSuma
																FROM CIS.softland.cwmovim movim 
																INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi
																INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
																INNER JOIN [DSCIS].[dbo].[DS_AgrupacionCCNivel] ccnivel ON SUBSTRING(movim.ccCod,1,3) collate Modern_Spanish_CI_AS = SUBSTRING(ccnivel.codiCC,1,3)
																WHERE movim.cpbano ='".$ano."'  and cpbte.CpbAno = '".$ano."' 
																AND movim.pctcod collate Modern_Spanish_CI_AS IN   
																(
																	select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='".$_SESSION['emp']['id']."'
																) 
																and movim.CpbMes  BETWEEN 00 AND convert(datetime,'".$mes."' ,103) 
																AND cpbte.CpbEst = 'V' and ccnivel.idnivel='2' AND ccnivel.BDSession ='".$_SESSION['emp']['id']."'
																and movim.CcCod like '01-%'";

											 

														$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

															while($row = sqlsrv_fetch_array($rec))
															{
																
																$salida .= '
																	<tr class="">
																		<td align="center">'.$row['PctCod'].'</td>
																		<td align="center">'.$row['dia'].'</td>
																		<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'&cc1='.$row['CcCod'].'" target="_blank">'.$row['CpbNum'].'</td>
																		<td align="center">'.$row['movnum'].'</td>
																		<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
																		<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
																		<td align="center">'.$row['MovGlosa'].'</td>
																		<td align="center">'.$row['CcCod'].'</td>
																		<td align="center">'.$row['valor'].'</td>
															
																	</tr>';
																	
															
														
																	$distribucion=$row['valor'];
																						
																	$totalcc=$row['valor'];
																	$totalDebe +=$row['MovDebe'];
																	$totalHaber +=$row['Movhaber'];		
															}		
													
												
																		$suma=$totalDebe-$totalHaber;
																		if($distribucion==0 || $distribucion==100)
																		{
																			$total=0; 
																		}
																else{
																		$total=$suma*$totalcc;
																		$resultado=$total/100000;
																		}

													 
														$salida.='
															<tr class="">
																<td align="center">TOTAL</td>
																<td align="center">&nbsp;</td>
																<td align="center">&nbsp;</td>
																<td align="center">&nbsp;</td>
																<td align="right">'.number_format($totalDebe,2,",",".").'</td>
																<td align="right">'.number_format($totalHaber,2,",",".").'</td>
																<td align="center">&nbsp;</td>
																<td align="center">TOTAL</td>
																<td align="right">DEBE-HABER * CC '.number_format($suma,2,",",".").'</td>
															<td align="right"> TOTAL DISTRIBUIDO '.number_format($resultado,2,",",".").'</td>
															
															</tr>';
														$salida .= '</tbody>
														</table>
														</center>';
													
													

													
														return $salida;
														 
														 


													 
														
														
												

			}else{	


 
			 $salida = '
				<center>
					<table border="1" width="1000" class="boxedb">
				<tr class="tit">
					<th width="80" align="center">Cod. Cuenta</th>
					<th width="80" align="center">Dia</th>
					<th width="80" align="center">Comprobante</th>
					<th width="80" align="center">Linea</th>
					<th width="80" align="center">Debe </th>
					<th width="80" align="center">Haber</th>
					<th width="150" align="center">Descripción</th>
					<th width="150" align="center">CC</th>
					<th width="150" align="center">DISTRIBUCION</th>
				</tr>
				<tbody>';
				$totalDebe = 0;
				$totalHaber = 0;
				$totalcc=0;
				$querycc="select distinct(CcCod) FROM CIS.softland.cwmovim where CcCod like '%1' order by CcCod asc";
				$centroccosto = sqlsrv_query($conn, $$querycc, array(), array('Scrollable' => 'buffered'));
				while ($row1 = sqlsrv_fetch_array($centroccosto))
				{
					$centro=$centroccosto."'".$row1['CcCod']."',";
				}
				//$queryCuentas = " SELECT * FROM ".$dba.".ds_cuentas WHERE id = '".$id."' and bd = '".$arrayCuentas[$q]."' ";
				$queryCuentas =" SELECT * FROM ".$dba.".DS_AgrupacionCuentas WHERE idNivel = '".$id."' and BDSession = '".$_SESSION['emp']['id']."' ";
					//echo $queryCuentas."<br>";

				$rec = sqlsrv_query($conn, $queryCuentas, array(), array('Scrollable' => 'buffered'));
				while($row = sqlsrv_fetch_array($rec))
				{
					$pccodi = $pccodi."'".$row['PCCODI']."',";
				}
				$pccodi = substr($pccodi, 0, -1);
				//$arrayPCCODI[0] = $pccodi;
				//$pccodi = "";
				$resta = substr($cc,0,2);
				$ccosto= substr($cc,0,5);
		
		
		
		
				$sql = "SELECT PctCod, day(movim.Cpbfec) as dia, movim.CpbNum, movnum, MovDebe, MovDebeMa, Movhaber, MovhaberMA, MovGlosa, movim.CcCod ,
				(select valor from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%' ) as valor,
				(select suma from dscis.dbo.ds_distribucioncc c where idcuenta='".$valor."' and codicc like '".$ccosto."%') as suma ,
				(select sum(movdebe-movhaber)FROM CIS.softland.cwmovim p 
				INNER JOIN CIS.softland.cwpctas c  on p.pctcod = c.pccodi 
				INNER JOIN CIS.softland.cwcpbte  cp ON p.cpbnum = cp.cpbnum 
				WHERE  p.cpbano ='".$ano."'  and cp.CpbAno = '".$ano."'  
				AND p.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and p.cpbmes BETWEEN 00 AND '".$mes."' AND cp.CpbEst = 'V' and p.cccod like '".$ccosto."%') as centro
				FROM CIS.softland.cwmovim movim 
				INNER JOIN CIS.softland.cwpctas ctas ON movim.pctcod = ctas.pccodi 
				INNER JOIN CIS.softland.cwcpbte cpbte ON movim.cpbnum = cpbte.cpbnum 
				WHERE movim.cpbano ='".$ano."'  and cpbte.CpbAno = '".$ano."' 
				AND movim.pctcod collate Modern_Spanish_CI_AS IN 
				( select PCCODI from [DSCIS].[dbo].[DS_AgrupacionCuentas] where idNivel = '".$id."' AND BDSession ='CIS' ) 
				and movim.cpbmes BETWEEN 00 AND '".$mes."' AND cpbte.CpbEst = 'V' and movim.cccod like '01-%'";

 

			$rec = sqlsrv_query($conn, $sql, array(), array('Scrollable' => 'buffered'));

				while($row = sqlsrv_fetch_array($rec))
				{
					
					$salida .= '
						<tr class="">
							<td align="center">'.$row['PctCod'].'</td>
							<td align="center">'.$row['dia'].'</td>
							<td align="center"><a href="index.php?mod=comprobante&a='.$row['CpbNum'].'&b='.$mes.'&c='.$ano.'&item='.$arrayBD[$q].'&cc='.$cc.'&cc1='.$row['CcCod'].'" target="_blank">'.$row['CpbNum'].'</td>
							<td align="center">'.$row['movnum'].'</td>
							<td align="right">$ '.number_format($row['MovDebe'],2,",",".").'</td>
							<td align="right">$ '.number_format($row['Movhaber'],2,",",".").'</td>
							<td align="center">'.$row['MovGlosa'].'</td>
							<td align="center">'.$row['CcCod'].'</td>
							<td align="center">'.$row['valor'].'</td>
				
						</tr>';
						
				
			
					    $distribucion=$row['valor'];
											
						$totalcc=$row['valor'];
						$totalDebe +=$row['MovDebe'];
						$totalHaber +=$row['Movhaber'];		
				}		
		
	
					$suma=$totalDebe-$totalHaber;
		 
						if($distribucion==0 || $distribucion==100)
						{
			
						$total=0; 
						}
		 else{
			$total=$suma*$totalcc;
			$resultado=$total/1000;
		 }

		 
			$salida.='
				<tr class="">
					<td align="center">TOTAL</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="center">&nbsp;</td>
					<td align="right">'.number_format($totalDebe,2,",",".").'</td>
					<td align="right">'.number_format($totalHaber,2,",",".").'</td>
					<td align="center">&nbsp;</td>
					<td align="center">TOTAL</td>
					<td align="right">DEBE-HABER * CC '.number_format($suma,2,",",".").'</td>
			    <td align="right"> TOTAL DISTRIBUIDO '.number_format($resultado,2,",",".").'</td>
				
				</tr>';
			$salida .= '</tbody>
			</table>
			</center>';
		
		

		
			return $salida;
			 
			 


		 
			
			}
	
	}
			
		
								

		 
			
				}
		
			}
		
	
}

	

?>
