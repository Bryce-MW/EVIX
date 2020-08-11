<?php

	$peers=array(
		"version" => "0.7",
    		"timestamp" => date("Y-m-d"). "T". date("H:i:s"),
		"ixp_list" => array (
			0 => array (
				"shortname" => "EVIX",
				"name" => "Experimental Virtual Internet Exchange",
				"ixp_id" => 756,
			        "ixf_id"=> 756,
			        "peeringdb_id"=> 2274,
			        "country"=> "US",
		        	"url"=> "https://evix.org/",
		                "switch"=> array(
	                                0 => array(
        	                        "id" => 0,
                	                "name" => "Fremont POP",
                        	        "pdb_facility_id" => 547,
                                	"city" => "Fremont",
	                                "country" => "US"
        	                        ),
                	                1 => array (
                        	        "id" => 1,
                                	"name" => "Dronten POP",
	                                "pdb_facility_id" => 857,
        	                        "city" => "Dronten",
                	                "country" => "NL"
                        	        ),
                                	2 => array (
	                                "id" => 2,
        	                        "name" => "NZ POP",
                	                "city" => "Auckland",
                        	        "country" => "NZ"
                                	)
				),
				"vlan" => array (
                                0 => array(
                                "id"=>0,
                                "name" => "peering VLAN",
                                "number" => 40,
                                "ipv4" => array (
                                        "prefix" => "206.81.104.0",
                                        "mask_length" => 24
                                ),
                                "ipv6" => array (
                                        "prefix" => "2602:fed2:fff:ffff::",
                                        "mask_length" => 64
                                )
                        )
                )
	)
	),
	"member_list"=> array (),
	);

	$conn=mysqli_connect('127.0.0.1','evix','***REMOVED***','evix');
	$query="SELECT * FROM peers WHERE status in (1,2,3) ORDER BY address, address6, asn";
	$res=mysqli_query($conn,$query);
	if($res)
	{
		$i=0;
		while($row=mysqli_fetch_array($res))
		{
			$peers["member_list"][$i]["asnum"]=intval($row['asn']);
			$peers["member_list"][$i]["member_type"]="peering";
			$peers["member_list"][$i]["name"]=$row['description'];
			$peers["member_list"][$i]["url"]=$row['website'];

			//get additional IPs (if any)
                        $additionalquery="SELECT * FROM additionalips WHERE asn=". $row['asn'];
                        $additionalres=mysqli_query($conn,$additionalquery);
			$additionalrows=mysqli_num_rows($additionalres);
			$additionalips=array();
			$additionalips4=array();
			while($additional=mysqli_fetch_array($additionalres))
                        {
	                        //$peers['clients'][$i]['ip'][$j]=long2ip($additional['address']);
				$additionalips[]=array (
						"vlan_id" => 0,
						"ipv4" => array (
                                                "address" => long2ip($additional['address']),
                                                "routeserver" => true,
                                                "as_macro" => $row['asset'] ),
						"ipv6" => array (
                                                "address" => $additional['address6'],
                                                "routeserver" => true,
                                                "as_macro" => $row['asset'] )
					);
                        }

			$peers["member_list"][$i]["connection_list"]=array (
				0=> array (
				"ixp_id" => 756,
				"state" => "active",
				"if_list" => array (
					0=>array (
					"switch_id" => 0,
					"if_speed" => 100
					)
				),
				"vlan_list" => array (
					array (
					"vlan_id" => 0,
					"ipv4" => array (
						"address" => long2ip($row['address']),
						"routeserver" => true,
						"as_macro" => $row['asset']
					),
					"ipv6" => array (
						"address" => $row['address6'],
						"routeserver" => true,
                                                "as_macro" => $row['asset']
					) 					)
				),$additionalips
				)
			);
			$i++;
		}
		//backup Route Server
		$peers["member_list"][$i]["asnum"]=209762;
                        $peers["member_list"][$i]["member_type"]="peering";
                        $peers["member_list"][$i]["name"]="Backup Route Server";
                        $peers["member_list"][$i]["url"]="https://evix.org";
                        $peers["member_list"][$i]["connection_list"]=array (
                                0=> array (
                                "ixp_id" => 756,
                                "state" => "active",
                                "if_list" => array (
                                        0=>array (
                                        "switch_id" => 0,
                                        "if_speed" => 1000
                                        )
                                ),
                                "vlan_list" => array (
                                        0=>array (
                                        "vlan_id" => 0,
                                        "ipv4" => array (
                                                "address" => "206.81.104.253",
                                                "routeserver" => true,
                                                "as_macro" => "AS209762"
                                        ),
                                        "ipv6" => array (
                                                "address" => "2602:fed2:fff:ffff::253",
                                                "routeserver" => true,
                                                "as_macro" => "AS209762"
                                        )
                                )
                        )
                ));
		$peers["member_list"][$i]["asnum"]=137933;
                        $peers["member_list"][$i]["member_type"]="peering";
                        $peers["member_list"][$i]["name"]="Route Server";
                        $peers["member_list"][$i]["url"]="https://evix.org";
                        $peers["member_list"][$i]["connection_list"]=array (
                                0=> array (
                                "ixp_id" => 756,
                                "state" => "active",
                                "if_list" => array (
                                        0=>array (
                                        "switch_id" => 0,
                                        "if_speed" => 1000
                                        )
                                ),
                                "vlan_list" => array (
                                        0=>array (
                                        "vlan_id" => 0,
                                        "ipv4" => array (
                                                "address" => "206.81.104.1",
                                                "routeserver" => true,
                                                "as_macro" => "AS137933"
                                        ),
                                        "ipv6" => array (
                                                "address" => "2602:fed2:fff:ffff::1",
                                                "routeserver" => true,
                                                "as_macro" => "AS137933"
					)
				)
			)
		)
	);

	}
	echo json_encode($peers);
?>
