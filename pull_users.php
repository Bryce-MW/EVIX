<?php

	$conn=mysqli_connect('127.0.0.1','evix','***REMOVED***','evix');

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
			if(strstr($peer['location'],"FMT"))
			{
				$peers['clients'][$i]['cfg']['attach_custom_communities'][0]="source_fremont";
			}
			else if(strstr($peer['location'],"NL"))
			{
				$peers['clients'][$i]['cfg']['attach_custom_communities'][0]="source_amsterdam";
			}
			else if(strstr($peer['location'],"NZ"))
			{
				$peers['clients'][$i]['cfg']['attach_custom_communities'][0]='source_auckland';
			}
			else if(strstr($peer['location'],"VAN"))
                        {
                                $peers['clients'][$i]['cfg']['attach_custom_communities'][0]='source_vancouver';
                        }

			$j=0;
			if($peer['address']!='')
			{
				$ip=long2ip($peer['address']);
				$peers['clients'][$i]['ip'][$j]=$ip;
				$j++;

				//get additional IPs (if any)
				$query="SELECT * FROM additionalips WHERE asn=". $peer['asn'];
				$res=mysqli_query($conn,$query);
				while($additional=mysqli_fetch_array($res))
				{
					$peers['clients'][$i]['ip'][$j]=long2ip($additional['address']);
					$j++;
				}
			}
			if($peer['address6']!='')
			{
                                $peers['clients'][$i]['ip'][$j]=$peer['address6'];
				$j++;

				//get additional IPs (if any)
                                $query="SELECT * FROM additionalips WHERE asn=". $peer['asn'];
                                $res=mysqli_query($conn,$query);
                                while($additional=mysqli_fetch_array($res))
                                {
                                        $peers['clients'][$i]['ip'][$j]=$additional['address6'];
                                        $j++;
                                }
			}
			$i++;
		}

	}
	echo str_replace('---','', str_replace('...', '', yaml_emit($peers)));
?>
