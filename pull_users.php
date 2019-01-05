<?php

	$conn=mysqli_connect('72.52.82.6','evix','***REMOVED***','evix');

	if(!$conn)
		die("Failed to connect to database". mysqli_error());

	//peer status'
	//0 = new signup
	//1 = approved, mnot added
	//2 = added, not connected
	//3 = added, connected
	//4 = added, not connected
	//5 = deleted
	$query="SELECT * FROM peers WHERE status in (1,2,3)";
	$row=mysqli_query($conn,$query);

	if(!$row)
		die("Error executing query: ". mysqli_error($conn));

	$peers=array();
	$i=0;
	while($peer=mysqli_fetch_array($row))
	{
		if($peer['asn']!='' AND $peer['description']!='' AND $peer['asset']!='')
		{
			$asn='AS'. $peer['asn'];
			$peers['asns'][$asn]['as_sets'][0]=$peer['asset'];
			$peers['clients'][$i]['asn']=$peer['asn'];
			$peers['clients'][$i]['cfg']['filtering']['irrdb']['as_sets'][0]=$peer['asset'];
			$peers['clients'][$i]['cfg']['filtering']['max_prefix']['action']="shutdown";
			$peers['clients'][$i]['cfg']['filtering']['max_prefix']['peering_db']['enabled']=false;
			$peers['clients'][$i]['cfg']['filtering']['max_prefix']['limit_ipv4']=100;
			$peers['clients'][$i]['cfg']['filtering']['max_prefix']['limit_ipv6']=100;
			$peers['clients'][$i]['description']=$peer['description'];
			$j=0;
			if($peer['address']!='')
			{
				$ip=long2ip($peer['address']);
				$peers['clients'][$i]['ip'][$j]=$ip;
				$j++;
			}
			if($peer['address6']!='')
			{
                                $peers['clients'][$i]['ip'][$j]=$peer['address6'];
			}
			$i++;
		}

	}
	echo str_replace('---','', str_replace('...', '', yaml_emit($peers)));
?>
