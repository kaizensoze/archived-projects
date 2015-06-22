<?php 
//require("Mail.php");

class SMTPClient
{
	function SMTPClient ($name, $from, $to, $subject, $body)
	{
        $SmtpServer="mail.legalspeedlozenges.com";
        $SmtpPort="26"; //default
        $SmtpUser="orders@legalspeedlozenges.com";
        $SmtpPass="Speedy1501!";

		$this->SmtpServer = $SmtpServer;
		$this->SmtpUserOriginal = $SmtpUser;
		$this->SmtpUser = base64_encode ($SmtpUser);
		$this->SmtpPass = base64_encode ($SmtpPass);
		$this->from = $from; //the user
		$this->name = $name;
		$this->to = $to; //vitacare email
		$this->subject = $subject;
		$this->body = $body;
		
		if ($SmtpPort == "") 
		{
			$this->PortSMTP = 25;
		}
		else
		{
			$this->PortSMTP = $SmtpPort;
		}
	}
		
	function SendMail ()
	{
		$talk;
	
		if ($SMTPIN = fsockopen ($this->SmtpServer, $this->PortSMTP)) 
		{
		//fputs ($SMTPIN, "EHLO ".$HTTP_HOST."\r\n"); 
		$talk["hello"] = fgets ( $SMTPIN, 1024 ); 
		fputs($SMTPIN, "auth login\r\n");
		$talk["res"]=fgets($SMTPIN,1024);
		fputs($SMTPIN, $this->SmtpUser."\r\n");
		$talk["user"]=fgets($SMTPIN,1024);
		fputs($SMTPIN, $this->SmtpPass."\r\n");
		$talk["pass"]=fgets($SMTPIN,256);
		fputs ($SMTPIN, "MAIL FROM: <".$this->SmtpUserOriginal.">\r\n"); 
		$talk["From"] = fgets ( $SMTPIN, 1024 ); 
		fputs ($SMTPIN, "RCPT TO: <".$this->to.">\r\n"); 
		$talk["To"] = fgets ($SMTPIN, 1024); 
		fputs($SMTPIN, "DATA\r\n");
		$talk["data"]=fgets( $SMTPIN,1024 );
		
		$headers = "To: <".$this->to.">\r\nFrom: ".$this->name." <".$this->SmtpUserOriginal.">\r\nReply-To: <".$this->from.">\r\nSubject:".$this->subject."\r\n\r\n\r\n".$this->body."\r\n.\r\n";
		fputs($SMTPIN, $headers);
		//echo $headers;
		$talk["send"]=fgets($SMTPIN,256);
		//CLOSE CONNECTION AND EXIT ... 
		fputs ($SMTPIN, "QUIT\r\n"); 
		fclose($SMTPIN);
        
		// 
		} 
		return $talk;
	} 
}

?>