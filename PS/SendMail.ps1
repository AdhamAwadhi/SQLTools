#SSRS Report Sender.
#Author: Evgeny Khabarov ekhabarov@dev.ms
#Date: 09.02.2015

function sendMail ([string]$rcpt, $body, $att, $subject){
    #Creating a Mail object
    $msg = new-object Net.Mail.MailMessage
    #Email structure 
    $msg.From = "Reporting Server <noreply@domain.tld>"
    $msg.ReplyTo = "Reporting Server <noreply@domain.tld>"
   
    if ($rcpt.IndexOf(";") -lt 1) {
        $msg.To.Add($rcpt)
    } else {
        foreach ($e in $rcpt.Split(';')) {
            $r = $e.Trim()
            $msg.To.Add($r)
        }
    }
    
    $msg.subject = $subject
    $msg.body = $body
    
    #Attachment add
    if ($att -and (Test-Path $att)) {
        $msg.Attachments.Add($att)
    }
    $Username = "user"
    $Password = "password"

    $smtp = new-object Net.Mail.SmtpClient("smtp.domain.tld", 25)
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password)
    $smtp.Send($msg)
}

#Attachment path
$attachment = "path_to_attachment"
$sbj = "Subj"
$rcpts = "mail1@domain.tld; mail2@domain.tld"
$b = "Body"
$err_rcpt = "error@domain.tld"
$err_msg =  "Report <path_to_attachment> not found"


if (Test-Path $attachment) {
    sendMail -rcpt $rcpts -body $b -att $attachment
} else {
    sendMail  -rcpt $err_rcpt -body $err_msg
}

