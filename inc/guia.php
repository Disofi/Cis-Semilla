<?php
$objPHPExcel->setActiveSheetIndex(0)->setCellValueExplicit($Letra.$keyExcel, $totalNetoPORCENTAJE, PHPExcel_Cell_DataType::TYPE_NUMERIC);
$objPHPExcel->getActiveSheet()->getColumnDimension($Letra);
if($totalNetoPORCENTAJE >= 0) 
{
	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelPositivoTotal);
	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
}
else 
{ 
	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelNegativoTotal);
	$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->applyFromArray($excelCentro);
}
$objPHPExcel->getActiveSheet()->getStyle($Letra.$keyExcel)->getNumberFormat()->setFormatCode(PHPExcel_Style_NumberFormat::FORMAT_NUMBER_COMMA_SEPARATED1);
$Letra++;

?>