param
(
 [string]$Device = $args[0],	
 [string]$PhonehtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Sanity\Apps\Grocery\Automation\Droid\Android_GHS_Phone_Regression\sanity_live.html",
 [string]$PhonererunHtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Sanity\Apps\Grocery\Automation\Droid\Android_GHS_Phone_Regression\sanity_live_rerun.html",
 [string]$TablethtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Sanity\Apps\Grocery\Automation\Droid\Android_GHS_Tablet_Regression\sanity_live.html",
 [string]$TabletrerunHtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Sanity\Apps\Grocery\Automation\Droid\Android_GHS_Tablet_Regression\sanity_live_rerun.html"
)

 
#Set the htmlFile and rerunFile values

if($Device -eq "Phone")
{
	$htmlFile=$PhonehtmlFile
	$rerunHtmlFile=$PhonererunHtmlFile
}
else
{
	$htmlFile=$TablethtmlFile
	$rerunHtmlFile=$TabletrerunHtmlFile
}

 #Email Notifications parameters
 
$SanityLink = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_" + $Device + "_n/"

$CucumberLink = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_" + $Device + "_n/cucumber-html-reports/"
 
$emailSmtpServer = "smtp.gmail.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "hsc.mobci@gmail.com"
$emailSmtpPass = "senihcam"
 
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = "hsc.mobci@gmail.com"
$emailMessage.To.Add( "bharath.shrikanth@in.tesco.com,sharon.valento@in.tesco.com,tapas.saha@in.tesco.com,sandeep.singh@in.tesco.com,Akshata.Tudavekar@in.tesco.com" )
$emailMessage.Subject = "GHS-Android Sanity Report - $Device"
#$emailMessage.Attachments.Add($htmlFile)
#$emailMessage.Attachments.Add($rerunHtmlFile)


# Read the cucumber html file
function ReadHTML([string] $File)
{
 $source = Get-Content -Path $File | Out-String
 $removeSpace = $source -replace "`n|`r" 
 $removeSpace  -match "document.getElementById\(\'totals\'\).innerHTML =(?<value>.*?)<" | Out-Null
 return $matches.value.Trim() -replace '"',"" 
}

# Read the cucumber html file
$htmlFileValue = ReadHTML -File $htmlFile

echo $htmlFileValue


if($htmlFileValue -like '*undefined*')
{
	if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = $matches['failed']
		[int]$Sanfirstpending = $matches['pending']
		[int]$Sanfirstpassed = $matches['passed']
	}
	else
	{
		if($htmlFileValue -like '*passed*')
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<pending>.*?)\sundefined,(?<passed>.*?)\spassed"
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = 0
		[int]$Sanfirstpending = $matches['pending']
		[int]$Sanfirstpassed = $matches['passed']
		}
		else
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined"
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = $matches['failed']
		[int]$Sanfirstpending = $matches['pending']
		[int]$Sanfirstpassed = 0
		}
	}
}
else
{
	if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = $matches['failed']
		[int]$Sanfirstpassed = $matches['passed']
	}
	else
	{
		if($htmlFileValue -like '*passed*')
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = 0
		[int]$Sanfirstpassed = $matches['passed']
		}
		else
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed"
		[int]$Sanfirsttotal = $matches['total']
		[int]$Sanfirstfailed = $matches['failed']
		[int]$Sanfirstpassed = 0
		}
	}
}

echo $Sanfirsttotal
echo $Sanfirstfailed
echo $Sanfirstpassed

# Read the Rerun cucumber html file
$rerunValue = ReadHTML -File $rerunHtmlFile

echo $rerunValue

if($rerunValue -like '*undefined*')
{
	if($rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = $matches['failed']
		[int]$Sanrerunpending = $matches['pending']
		[int]$Sanrerunpassed = $matches['passed']
	}
	else
	{
		if($rerunValue -like '*passed*')
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<pending>.*?)\sundefined,(?<passed>.*?)\spassed"
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = 0
		[int]$Sanrerunpending = $matches['pending']
		[int]$Sanrerunpassed = $matches['passed']
		}
		else
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined"
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = $matches['failed']
		[int]$Sanrerunpending = $matches['pending']
		[int]$Sanrerunpassed = 0
		}
	}
}
else
{
	if($rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = $matches['failed']
		[int]$Sanrerunpassed = $matches['passed']
	}
	else
	{
		if($rerunValue -like '*passed*')
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = 0
		[int]$Sanrerunpassed = $matches['passed']
		}
		else
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed"
		[int]$Sanreruntotal = $matches['total']
		[int]$Sanrerunfailed = $matches['failed']
		[int]$Sanrerunpassed = 0
		}
	}
}

echo reruntotal=$Sanreruntotal
echo rerunpassed=$Sanrerunpassed
echo rerunfailed=$Sanrerunfailed

# Calculate the pass percentage
[int]$totalPassed = $Sanfirstpassed + $Sanrerunpassed
[int]$passPercentage = ($totalPassed/$Sanfirsttotal)*100

# Calculate the number of failed/skipped scenarios
[int]$totalFailed = $Sanrerunfailed
if($passPercentage -eq 100)
{
	$bgcolor = 'bgcolor="#99FF33"'
}elseif(($passPercentage -lt 100) -and ($passPercentage -gt 50))
{
	$bgcolor = 'bgcolor="#FF9933"'
}else
{
	$bgcolor = 'bgcolor="#FF3333"'
}

$Date = (Get-Date).ToString('dd-MM-yyyy')
echo $Date

$emailMessage.IsBodyHtml = $true
$emailMessage.Body = @"
<html>
<head>
<style>
	.tab-1, .tab-1_row{
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
	}
	
	.tab-1_data {
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
		height: 25px;
		width:220px;
		background-color: #FFF5EB;
	}
	
	.tab-2_data {
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
		height: 25px;
		width:80px;
		background-color: #FFF5EB;
	}
	
	.tab-1_heading {
		
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
		height: 25px;
		width:100px;
		background-color: #71A9FF;
	}
	.tab-1_heading_main {
		
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
		height: 25px;
		background-color: #FF944D;
		font-family: "Lucida Console", 
	}
</style>
</head>
<body>
	<h2>GHS Android - Sanity Report - $Date</h2>
	<table class="tab-1">
		<tr class="tab-1_row">
			<th class="tab-1_heading_main"; colspan="2">Testing Summary</th>
		</tr>
		<tr class="tab-1_row">
			<th class="tab-1_heading">Application Name</th>
			<td class="tab-1_data">GHS-Android Sanity</td>
		</tr>
		<tr class="tab-1_row">
			<th class="tab-1_heading">Environment</th>
			<td class="tab-1_data"><strong>LIVE</strong></td>
		</tr>
	</table>
	</br>
	</br>
	<table class="tab-1">
		<tr class="tab-1_row">
			<th class="tab-1_heading_main"; colspan="3">Test Run Summary</th>
		</tr>
		<tr class="tab-1_row">
			<th class="tab-1_heading"></th>
			<th class="tab-1_heading">Passed</th>
			<th class="tab-1_heading">Failed</th>
		</tr>
		<tr>
			<th class="tab-1_heading">Sanity</th>
			<td class="tab-2_data">$Sanfirstpassed</td>
			<td class="tab-2_data">$Sanfirstfailed</td>
		</tr>
		<tr>
			<th class="tab-1_heading">Rerun</th>
			<td class="tab-2_data">$Sanrerunpassed</td>
			<td class="tab-2_data">$Sanrerunfailed</td>
		</tr>
		<tr>
			<th class="tab-1_heading">Total</th>
			<td class="tab-2_data">$totalPassed</td>
			<td class="tab-2_data">$totalFailed</td>
		</tr>
		<tr>
			<td colspan="3"; $bgcolor>Pass Percentage : $passPercentage</td>
		</tr>
	</table>
	
	</br>
	<h4>For Cucumber Report : <a href="$CucumberLink"><strong> Click here </strong></a></h4>
	</br>
	<h4>For detailed sanity reports : <a href="$SanityLink"><strong> Click here </strong></a></h4>
</body>
</html>
"@
 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )
