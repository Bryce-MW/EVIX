<?php

	$conn=mysqli_connect('206.81.104.1','evix','***REMOVED***','evix');

	if(!$conn)
		die("Failed to connect to database". mysqli_error());

	//peer status'
	//0 = new signup
	//1 = approved, mnot added
	//2 = added, not connected
	//3 = added, connected
	//4 = added, not connected
	//5 = deleted
	$query="SELECT * FROM peers WHERE status in (2,3,4)";
	$row=mysqli_query($conn,$query);

	if(!$row)
		die("Error executing query: ". mysqli_error($conn));

	$table='<table class="sortable" border="0" cellpadding="2" cellspacing="1" width="100%">
          <thead><tr class="peers">
              <th align=left>User</th>
              <th align=left>AS</th>
              <th align=left class="wide">IPv4 /24</th>
              <th align=left class="wide">IPv6 /64</th>
              <th align=left>Location</th>
              <th align=left>Status</th>
          </tr></thead>
          <tbody><tr>
          </tr>';
	$i=0;
	while($peer=mysqli_fetch_array($row))
	{
		if($peer['asn']!='' AND $peer['description']!='' AND $peer['asset']!='')
		{

			$table .='<tr>
                  <td class="peer-table-company"><a href="'.  $peer['website']. '">'. $peer['description']. '</a></td>
                  <td class="peer-table-as">'. $peer['asn']. '</td>';
			if($peer['address']!='')
			{
				$ip=long2ip($peer['address']);
				$table .='<td class="peer-table-ipv4">'. $ip. '</td>';
			}
			else
				$table .='<td class="peer-table-ipv4">-----</td>';
			if($peer['address6']!='')
			{
                                $table .='<td class="peer-table-ipv6">'. $peer['address6']. '</td>';
			}
			else
				$table .='<td class="peer-table-ipv6">-----</td>';

			$table .='<td class="peer-table-loc">'. $peer['location']. '</td>';
		if($peer['status']==1)
                  $table .='<td class="peer-table-policy"><font color="grey">Installing...</font></td>';
		else
		  $table .='<td class="peer-table-policy"><font color="#00aa00">Connected</font></td>';
        $table .='</tr>';
		}

	}
	$source=file_get_contents("/evix/IX-website/templates/page/ix_peers.html");
	$start="<!--auto generated peers-->";
	$end="<!--end auto generated peers-->";

	$output=explode($start,$source);
	$replace=explode($end,$source);
	$output=$output[0]. $start. $table. $end. $replace[1];

	echo $output;
?>
