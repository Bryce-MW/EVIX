<?php
	$ip6_prefix='2602:fed2:fff:ffff::';
	$asn=$argv[1];
	$conn=mysqli_connect('127.0.0.1','evix','***REMOVED***','evix');

        if(!$conn)
                die("Failed to connect to database". mysqli_error());


	if($asn=='pending')
	{
		$query="SELECT * FROM peers WHERE status=0";
		$res=mysqli_query($conn,$query);
		if(mysqli_num_rows($res) > 0)
		{
			echo "Current number of pending peers:\n";
			while($row=mysqli_fetch_array($res))
			{
				echo "ASN: ". $row['asn']. "\n";
				echo "Description: ". $row['description']. "\n";
				echo "AS-SET: ". $row['asset']. "\n";
				echo "Contact Email: ". $row['contact']. "\n";
				echo "Tunnel Location: ". $row['location']. "\n";
				echo "-----------------\n";
			}
		}
		exit(3);
	}

	$asn=preg_replace('/[^0-9.]+/', '', $asn);

	//check if asn is currerntly in a pending status
	$query="SELECT * FROM peers WHERE asn=". $asn. " AND status=0";
	$res=mysqli_query($conn,$query);
	if(mysqli_num_rows($res)==1)
	{
		$row=mysqli_fetch_array($res);
		if($row['description']!='' AND $row['contact']!='')
		{
			echo "ASN ". $asn. " is in database and data looks good";
		}
	}
	else
	{
		echo "ERROR: There is an incorrect number of rows in the database, perhaps the peer submitted twice?\nPlase correct the data source before continuing.\nCurrent number of rows (matching ASN) is: ". mysqli_num_rows($res);
		exit(1);
	}

	//find next available IP address
	for($i=3461441656; $i< 3461441776; $i++)
	{
		$query="SELECT * FROM peers WHERE address=". $i;
		$rows=mysqli_num_rows(mysqli_query($conn,$query));
//		echo $rows;
		if($rows==0)
		{
			$ip=long2ip($i);
			$octets=explode('.',$ip);

			//ensure the corresponding ipv6 address is not taken
			$ip6=$ip6_prefix. $octets[3];
			$query="SELECT * FROM peers WHERE address6='". $ip6. "'";
			$rows=mysqli_num_rows(mysqli_query($conn,$query));
			if($rows== 0)
	                {
				//ensure the address is not in the additionalips table
				$query="SELECT * FROM additionalips WHERE address=". $i;
				$rows=mysqli_num_rows(mysqli_query($conn,$query));
				if($rows==0)
				{
					$query="SELECT * FROM additionalips WHERE address6=". $ip6;
	                                $rows=mysqli_num_rows(mysqli_query($conn,$query));
					if($rows==0)
                                	{
						echo "new user IPv6 is ". $ip6. "\n";
		                                echo "new user IP is ". $ip. "\n";

						$query="UPDATE peers SET address=". $i. ",address6='". $ip6. "',status=2 WHERE asn=". $asn;
						$res=mysqli_query($conn,$query);
						if(!$res)
						{
							echo "An error occured updating peer's status in the database... please correct.  User will NOT be added to bird. ". mysqli_error($conn);
							exit(1);
						}
						else
						{
							echo "Database updated sucessfully!\n";
							$ch = curl_init();
							curl_setopt($ch, CURLOPT_URL,"http://netbox.as60927.net/api/ipam/ip-addresses/");
							curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");
							curl_setopt($ch, CURLOPT_POSTFIELDS, '{"address": "'. $ip. '/24","description":"AS'. $asn. '"}');
							curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
							curl_setopt($ch, CURLOPT_HTTPHEADER, array(
							'Content-Type: application/json','Authorization: Token 4395619eed6fe9f1092cecd57e52f754bba916f3'
							));
							$result = curl_exec($ch);
							curl_setopt($ch, CURLOPT_POSTFIELDS, '{"address": "'. $ip6. '/64","description":"AS'. $asn. '"}');
							$result = curl_exec($ch);
							exit(0);
						}
					}
					//exit(1);
				}
			}
		}
	}
	exit(2);

?>
