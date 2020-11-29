<?php

$conn = mysqli_connect('127.0.0.1', 'evix', '***REMOVED***', 'evix');

if (!$conn) {
    die("Failed to connect to database" . mysqli_error());
}

$query = "SELECT * FROM asns WHERE EXISTS (SELECT 1 FROM ips WHERE ips.asn=asns.asn AND (ips.provisioned=true OR ips.monitor=false))";
$row = mysqli_query($conn, $query);

if (!$row) {
    die("Error executing query: " . mysqli_error($conn));
}

$peers = array();
$i = 0;
while ($peer = mysqli_fetch_array($row)) {
    $nquery = "SELECT * FROM clients WHERE id=" . $peer['client_id'];
    $nrow = mysqli_query($conn, $nquery);
    $client = mysqli_fetch_array($nrow);
    $asn = 'AS' . $peer['asn'];
    $peers['clients'][$i]['asn'] = $peer['asn'];
    $peers['clients'][$i]['cfg']['filtering']['max_prefix']['action'] = "shutdown";
    $peers['clients'][$i]['cfg']['filtering']['max_prefix']['peering_db']['enabled'] = false;
    $peers['clients'][$i]['cfg']['filtering']['max_prefix']['limit_ipv4'] = 200;
    $peers['clients'][$i]['cfg']['filtering']['max_prefix']['limit_ipv6'] = 100;
    $peers['clients'][$i]['description'] = $client['name'];

    $j = 0;
    $query = "SELECT * FROM ips WHERE asn=" . $peer['asn'];
    $res = mysqli_query($conn, $query);
    while ($additional = mysqli_fetch_array($res)) {
        if ($additional['ip'] != '') {
            $peers['clients'][$i]['ip'][$j] = $additional['ip'];
            $j++;
        }
    }
    $i++;

}
echo str_replace('---', '', str_replace('...', '', yaml_emit($peers)));
