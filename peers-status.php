<?php
	//peers who have been exempted from peering with the route servers
	$exceptions=array(209833,58057,204438,47422);
 //dependancies
        use PHPMailer\PHPMailer\PHPMailer;
        use PHPMailer\PHPMailer\Exception;

        require '/evix/PHPMailer/src/Exception.php';
        require '/evix/PHPMailer/src/PHPMailer.php';
        require '/evix/PHPMailer/src/SMTP.php';

	$ipver=$argv[1];
	if($ipver==6)
		$birdcmd="birdc6";
	else
		$birdcmd="birdc";

        //connect to the database
        $conn=mysqli_connect('127.0.0.1','evix','***REMOVED***','evix');
        if(!$conn)
                die("Failed to connect to database". mysqli_error());

	//start by de-provisioning any delinquant peers
	$deprovisionedres=mysqli_query($conn,"SELECT * FROM notificationsv". $ipver. " WHERE status=3");
	while($deprovision=mysqli_fetch_array($deprovisionedres))
	{
		$query="UPDATE peers SET status=5,address". $ipver. "=NULL WHERE asn=". $deprovision['asn'];
		mysqli_query($conn,$query);
		$query="DELETE FROM notificationsv". $ipver. " WHERE ID=". $deprovision['ID'];
		mysqli_query($conn,$query);
	}

        //grab a list of all active peers
        $query="SELECT * FROM peers WHERE status in (1,2,3)";
        $result=mysqli_query($conn,$query);
        while($row=mysqli_fetch_array($result))
        {
		$connection = ssh2_connect('72.52.82.6', 22, array('hostkey'=>'ssh-rsa'));

		if (ssh2_auth_pubkey_file($connection, 'evix','/home/evix/.ssh/id_rsa.pub','/home/evix/.ssh/id_rsa'))
		{
	                $birdquery=$birdcmd. " show protocols | grep AS". $row['asn'];
			$stream = ssh2_exec($connection, $birdquery);
			stream_set_blocking($stream, true);
			$stream_out = ssh2_fetch_stream($stream, SSH2_STREAM_STDIO);
			$output=stream_get_contents($stream_out);

				//if peer is currently down
	                        if(strstr($output,"start"))
        	                {
					if(in_array($row['asn'],$exceptions))
					{
						 mysqli_query($conn,"UPDATE notificationsv". $ipver. " SET status=0 WHERE asn=". $row['asn']);
					}

                	                echo "ASN ". $row['asn']. " has a DOWN session\n";
	                       	        //see if they have already been logged
                                	$res=mysqli_query($conn,"SELECT * FROM notificationsv". $ipver. " WHERE asn=". $row['asn']. " AND status=1 ORDER BY date DESC");
	                                if(mysqli_num_rows($res)>0)
        	                        {
                	                        $notification=mysqli_fetch_array($res);

        	                                //see if date is longer the 3 days (259200)
                	                        if((time()-$notification['date'])>259200)
                        	                {
                                	                $query="UPDATE notificationsv". $ipver. " SET date=". time(). ",status=2 WHERE ID=". $notification['ID'];
							mysqli_query($conn,$query);
	                                                //send email notification
							echo "\nASN ". $row['asn']. " has been down for over 3 days.... sending notification\n";
							$subject='EVIX Peering Session Offline';
							$messageHtml='Hello AS'. $row['asn']. ' operator,<br/>
		You are receiving this message because you have a BGP session configured with EVIX that has currently been offline for more then 3 days.  Please investigate the reported issue at your earliest convienience. <br/><br/> Generally, we require members to maintain a session with our primary route server, members with don sessions for more then 14 days will be de-provisioned.  If you require assistance, or specifically do not wish to peer with the route server, please reach out to us at: peering@evix.org';
							$message='Hello AS'. $row['asn']. ' operator,
		You are receiving this message because you have a BGP session configured with EVIX that has currently been offline for more then 3 days.  Please investigate the reported issue at your earliest convienience. 

		Generally, we require members to maintain a session with our primary route server, members with don sessions for more then 14 days will be de-provisioned.  If you require assistance, or specifically do not wish to peer with the route server, please reach out to us at: peering@evix.org';
							$to=$row['contact'];
							if(!in_array($row['asn'],$exceptions))
                                        		{
								sendEmail($to,$subject,$message,$messageHtml);
							}
                                        	}
	                                }
					else
					{
	        	                        //see if they have already been notified
        	        	                $res=mysqli_query($conn,"SELECT * FROM notificationsv". $ipver. " WHERE asn=". $row['asn']. " AND status=2 ORDER BY date DESC");
                	        	        if(mysqli_num_rows($res)>0)
                        	        	{
                                	        	$notification=mysqli_fetch_array($res);

		                                        //see if the date is longer then 2 weeks (1037000)
        		                                if((time()-$notification['date'])>1037000)
                		                        {
								echo "\nASN ". $row['asn']. " has been down for over 14 days.... de-provisioning\n";
                        		                        $query="UPDATE notificationsv". $ipver. " SET date=". time(). ",status=3 WHERE ID=". $notification['ID'];
								mysqli_query($conn,$query);
                                		                //send email notification
								$subject='EVIX Peering Session De-provisioned';
								$messageHtml='Hello AS'. $row['asn']. ' operator,
<br/><br/>
You are receiving this message because your session with the EVIX route server has been down for more then 14 days. 
<br/><br/>
Generally, we require members to maintain a session with our primary route server, and, as you have not been able to maintain this requirement your ASN has been marked for de-provisioning in our database and will be deleted within 24 hours.
<br/><br/>
If you have any questions, please reach out to us at: peering@evix.org';
								$message='
Hello AS'. $row['asn']. ' operator,

You are receiving this message because your session with the EVIX route server has been down for more then 14 days. 

Generally, we require members to maintain a session with our primary route server, and, as you have not been able to maintain this requirement your ASN has been marked for de-provisioning in our database and will be deleted within 24 hours.

If you have any questions, please reach out to us at: peering@evix.org';
								$to=$row['contact'];
								sendEmail($to,$subject,$message,$messageHtml);
                                        		}

						}
						else
						{
							mysqli_query($conn,"INSERT INTO notificationsv". $ipver. " (asn,date,status) VALUES(". $row['asn']. ",". time(). ",1)");
						}
	                                }
        	                }
				else if(strstr($output,"up"))
				{
					mysqli_query($conn,"UPDATE notificationsv". $ipver. " SET status=0 WHERE asn=". $row['asn']);
				}
                }
		else
			die("SSH Authentication failed");
        }



function sendEmail($to,$subject,$message,$messageHtml)
{

	$mail = new PHPMailer(true);
	try {
		//Server settings
		//$mail->SMTPDebug = 2;
		$mail->isSMTP();
		$mail->Host = 'mx02.ipaddr.is';
		$mail->SMTPAuth = true;
		$mail->Username = 'support@evix.org';
		$mail->Password = 'yhsYVM_igFWg7';
		//$mail->SMTPSecure = 'tls';
		$mail->Port = 25;

		$mail->SMTPOptions = array(
   			'ssl' => array(
			'verify_peer' => false,
		   	'verify_peer_name' => false,
		 	'allow_self_signed' => true
    			)
		);

		//Recipients
		$mail->setFrom('peering@evix.org', 'EVIX Technical Support');
		$mail->addAddress($to);
		$mail->addReplyTo('peering@evix.org', 'EVIX Technical Support');
		$mail->addBCC('peering@evix.org');

		//Content
		$mail->isHTML(true);
		$mail->Subject = $subject;
		$mail->Body    = $messageHtml;
		$mail->AltBody = $message;

		$mail->send();
	} catch (Exception $e) {
		echo 'Message could not be sent. Mailer Error: ', $mail->ErrorInfo;
	}
}
