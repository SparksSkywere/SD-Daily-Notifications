#Powershell script to auto notifiy a servicedesk
#PS Console Hide
function Show-Console
{
    param ([Switch]$Show,[Switch]$Hide)
    if (-not ("Console.Window" -as [type])) { 

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }
    if ($Show)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        $null = [Console.Window]::ShowWindow($consolePtr, 5)
    }
    if ($Hide)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        #0 hide
        $null = [Console.Window]::ShowWindow($consolePtr, 0)
    }
}
#To show the console change "-hide" to "-show"
show-console -Hide

#Set time value for when you want emails sent no need for 00
$scheduledTime = Get-Date -Hour 8 -Minute 0 -Second 0
#Debug varient, meant to be changed
#$scheduledTime = Get-Date -Hour 00 -Minute 00 -Second 0
#Set notification email to send to who
$notificationEmail = "CHANGEME"
#Send email function
function send-email {
    #Forced parameters, if not filled out the email will not send
	param (
		[Parameter(Mandatory=$true)]
		[string]$subject,
		[Parameter(Mandatory=$true)]
		[string]$body,
		[Parameter(Mandatory=$true)]
		[string]$to
	)
	#Set up the email message
	$mailMessage = New-Object System.Net.Mail.MailMessage
	$mailMessage.From = "CHANGEME"
	$mailMessage.To.Add($to)
	$mailMessage.Subject = $subject
	$mailMessage.Body = $body

	#Set up the SMTP client
	$smtpClient = New-Object System.Net.Mail.SmtpClient
	$smtpClient.Host = "smtp.CHANGEME.com"
	#Enable below if you need SSL or TLS
	#$smtpClient.Port = 465(SSL)/587(TLS)
    #$smtpClient.EnableSsl = $true
	$smtpClient.Credentials = New-Object System.Net.NetworkCredential("CHANGEME", "CHANGEME")

	#Send the email
	$smtpClient.Send($mailMessage)
}

#Check Time
function Currenttime
{
    $currentTime = Get-Date
    Return $currentTime
}

#Constant loop of the code, this means once set off, never need to touch it again
while ($true) 
{
    #Loop check time call
    $currentTime = Currenttime
    #Time debug
    #Write-Host "TIME CHECKING DEBUG, the time is $currentTime"
    if ($currentTime.ToString("HH:mm:ss") -eq $scheduledTime.ToString("HH:mm:ss")) {
        #Email debug
        #Write-Host "Sending email Debug"
        #Default email: send-email -subject "SUBJECT" -body "BODY" -to $notificationEmail
        send-email -subject "Daily Server-room check" -body "Please investigate." -to $notificationEmail
    }
    Start-Sleep -Seconds 1
}
#Created by Chris Masters