<?php


$_GET=array();
$_GET['from']= time()-172800;
$_GET['to']= time();
$_GET['id']=$argv[1];
$_GET['type']='port_bits';
$_GET['legend']='yes';
$_GET['height']='100';
$_GET['width']='350';
$config['webui']['graph_type']= 'svg';

$start = microtime(true);

$init_modules = array('web', 'graphs');
require '/opt/librenms/includes/init.php';

set_debug(isset($_GET['debug']));

rrdtool_initialize(false);
require '/evix/scripts/graph.inc.php';
rrdtool_close();
file_put_contents("/evix/IX-Website/templates/page/". $argv[2]. "_graph.html",$imagedata);
