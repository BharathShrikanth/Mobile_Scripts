param
(
 [string]$Device = $args[0],	
 [string]$iPadHtmlFile = "D:\jenkins-slave\workspace\GHS-iOS-Email-Notifier\GHSiPadRegression\Ipad_sanity\iPad_sanity.html"
 #[string]$PhonererunHtmlFile = "D:\jenkins-slave\workspace\GHS-iOS-Email-Notifier\GHSiPadRegression\Ipad_sanity\iPad_sanity_rerun.html"
)

 
#Set the htmlFile and rerunFile values


	$htmlFile=$iPadHtmlFile
	#$rerunHtmlFile=$PhonererunHtmlFile


 #Email Notifications parameters

 
$emailSmtpServer = "smtp.gmail.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "hsc.mobci@gmail.com"
$emailSmtpPass = "senihcam"
 
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = "hsc.mobci@gmail.com"
$emailMessage.To.Add( "bharath.shrikanth@in.tesco.com" )
$emailMessage.Subject = "GHS-iOS Sanity Report"
$emailMessage.Attachments.Add($htmlFile)
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


if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") {}
elseif($htmlFileValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"){}
else
{
  $htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed" | out-null
}

[int]$total = $matches['total']
[int]$failed = $matches['failed']
[int]$passed = $matches['passed']

echo $total
echo $failed
echo $passed

# Read the Rerun cucumber html file
#$rerunValue = ReadHTML -File $rerunHtmlFile

#echo $rerunValue

#if($rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") {}
#elseif($rerunValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"){}
#else
#{
#  $rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed)" | out-null
#}

[int]$reruntotal = 0
[int]$rerunfailed = 0
[int]$rerunpassed = 0

#echo reruntotal=$reruntotal
#echo rerunpassed=$rerunpassed
#echo rerunfailed=$rerunfailed

# Calculate the pass percentage
[int]$totalPassed = $passed + $rerunpassed
[int]$passPercentage = ($totalPassed/$total)*100

# Calculate the number of failed/skipped scenarios
[int]$totalFailed = $total - $totalPassed
echo $passPercentage
if($passPercentage -eq 100)
{
	$bgcolor = 'bgcolor="#0066FF"'
}elseif(($passPercentage -lt 100) -and ($passPercentage -gt 85))
{
	$bgcolor = 'bgcolor="#99FF33"'
}elseif(($passPercentage -lt 86) -and ($passPercentage -ge 50))
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
	<h2>GHS iOS - Sanity Report $Device - $Date</h2>
	<table class="tab-1">
		<tr class="tab-1_row">
			<th class="tab-1_heading_main"; colspan="2">Testing Summary</th>
		</tr>
		<tr class="tab-1_row">
			<th class="tab-1_heading">Application Name</th>
			<td class="tab-1_data">GHS-iOS Sanity - $Device</td>
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
			<td class="tab-2_data">$passed</td>
			<td class="tab-2_data">$failed</td>
		</tr>
		<!--<tr>
			<th class="tab-1_heading">Rerun</th>
			<td class="tab-2_data">$rerunpassed</td>
			<td class="tab-2_data">$rerunfailed</td>
		</tr> -->
		<tr>
			<th class="tab-1_heading">Total</th>
			<td class="tab-2_data">$totalPassed</td>
			<td class="tab-2_data">$totalFailed</td>
		</tr>
		<tr>
			<td colspan="3"; $bgcolor>Pass Percentage : $passPercentage</td>
		</tr>
	</table>
</body>
</html>
"@
 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )