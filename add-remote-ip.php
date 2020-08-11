<?php
	$conn=mysqli_connect('127.0.0.1','evix','***REMOVED***','evix');
	if(!$conn)
                die("Something has gone wrong with the database: ". mysqli_error($conn));

	$asn=$argv[1];
	$endpoint=$argv[2];
	$type=$argv[3];
	$query="UPDATE tunnels SET remoteip=". $endpoint. " WHERE asn=". $asn. " AND type=". $type. ";";
	$res=mysqli_query($conn,$query);
	if(mysqli_affected_rows($conn)==1)
	{
		echo "Tunnels table updated!\n";
	}
	else
	{
		//echo "Something went wrong updating the tunnels table. ". mysqli_affected_rows($conn). " rows were modified which seems weird. It's not important for now but may be in the future!\n";
	}
?>
