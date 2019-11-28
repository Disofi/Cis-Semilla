<?php
include('inc/funciones_rodrigo.php');
$accion = $_REQUEST['accion'];
$seccion = $_REQUEST['seccion'];

if($accion == 'delete' && $seccion == 'reporte')
{
    $grupo = $_REQUEST['grupo'];
    borrarGrupoReporte($grupo);
}

?>