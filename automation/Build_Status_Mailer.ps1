param
(	
 [string]$PhonehtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Report-Mailer\Android_GHS_Phone_Regression\sanity_live.html",
 [string]$PhonererunHtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Report-Mailer\Android_GHS_Phone_Regression\sanity_live_rerun.html",
 [string]$TablethtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Report-Mailer\Android_GHS_Tablet_Regression\sanity_live.html",
 [string]$TabletrerunHtmlFile = "D:\jenkins-slave\workspace\GHS-Android-Report-Mailer\Android_GHS_Tablet_Regression\sanity_live_rerun.html"
)


########################################################################################################################################################
##############################################           Analysis Status html generation            ####################################################
########################################################################################################################################################

	$TodaysDate = (Get-Date).ToString('dd-MM-yyyy')
	$YestDate = (Get-Date).AddDays(-1).ToString('dd-MM-yyyy')
	echo $TodaysDate
	
	
	$AnalysisLink = "http://192.168.3.246:9000/dashboard/index/1"
	$emailAnalysisReport = "
		<h2>Analysis Reports</h2>
		<h4>For analysis reports, <a href='$AnalysisLink'>click here</a></h4>
		</br>
	"
	
	
	
	 

########################################################################################################################################################
################################################           Build Status html generation            #####################################################
########################################################################################################################################################

	$TodaysDate = (Get-Date).ToString('dd-MM-yyyy')
	$YestDate = (Get-Date).AddDays(-1).ToString('dd-MM-yyyy')
	echo $TodaysDate
	
	$tableBodyHeading = "<h2>Build Status</h2>
						<table class='tab-1'>
							<tr class='tab-1_row'>
								<th class='tab-1_heading_main'; colspan='3'>Build Status</th>
							</tr>
							<tr class='tab-1_row'>
								<th class='tab-1_heading'>Build No.</th>
								<th class='tab-1_heading'>Result</th>
								<th class='tab-1_heading'>Duration</th>
							</tr>"
	$tableBodyRow = ""
	$Files = $files = Get-ChildItem "D:\jenkins-slave\Reporting\GHS\Android\$YestDate\"
	echo $Files
	
	for ($i=0; $i -lt $Files.Count; $i++) {
		$filepath = "D:\jenkins-slave\Reporting\GHS\Android\" + $YestDate + "\" + $Files[$i]
		echo $filepath
		$JSON = Get-Content $filepath | Out-String | ConvertFrom-Json
		[string]$buildNumber = $JSON.buildNumber
		[string]$buildStatus = $JSON.buildStatus
		[string]$buildTimeVal = $JSON.buildTimeVal
		$tableBodyRow = $tableBodyRow + "<tr>
		<td class='tab-2_data'>$buildNumber</td>
		<td class='tab-2_data'>$buildStatus</td>
		<td class='tab-2_data'>$buildTimeVal</td>
	</tr>"
	}

	#echo $tableBodyRow
	
	$bodyBuildStatus = $tableBodyHeading + $tableBodyRow + "</table></br></br>"
	echo $bodyBuildStatus
	
	
########################################################################################################################################################
################################################         Sanity Report html generation - PHONE       ###################################################
########################################################################################################################################################

  
#Set the htmlFile and rerunFile values

	$Device="Phone"
	$htmlFile=$PhonehtmlFile
	$rerunHtmlFile=$PhonererunHtmlFile


 #Email Notifications parameters
 
$SanityLinkp = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_Phone_n/"

$CucumberLinkp = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_Phone_n/cucumber-html-reports/"
 
$emailSmtpServer = "smtp.gmail.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "hsc.mobci@gmail.com"
$emailSmtpPass = "senihcam"
 
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = "hsc.mobci@gmail.com"
$emailMessage.To.Add( "bharath.shrikanth@in.tesco.com,ruthvik.prasad@in.tesco.com")
$emailMessage.Subject = "GHS-Android Daily Report - $YestDate"
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
Clear-variable Device
Clear-variable htmlFile
Clear-variable rerunHtmlFile

########################################################################################################################################################
################################################       Sanity Report html generation - TABLET        ###################################################
########################################################################################################################################################

  
#Set the htmlFile and rerunFile values
	$Device = "Tablet"
	$htmlFile=$TablethtmlFile
	$rerunHtmlFile=$TabletrerunHtmlFile

 #Email Notifications parameters
 
$SanityLinkt = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_Tablet_n/"

$CucumberLinkt = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Sanity_Tablet_n/cucumber-html-reports/"

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
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = $matches['failed']
		[int]$Sanfirstpendingt = $matches['pending']
		[int]$Sanfirstpassedt = $matches['passed']
	}
	else
	{
		if($htmlFileValue -like '*passed*')
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<pending>.*?)\sundefined,(?<passed>.*?)\spassed"
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = 0
		[int]$Sanfirstpendingt = $matches['pending']
		[int]$Sanfirstpassedt = $matches['passed']
		}
		else
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined"
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = $matches['failed']
		[int]$Sanfirstpendingt = $matches['pending']
		[int]$Sanfirstpassedt = 0
		}
	}
}
else
{
	if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = $matches['failed']
		[int]$Sanfirstpassedt= $matches['passed']
	}
	else
	{
		if($htmlFileValue -like '*passed*')
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = 0
		[int]$Sanfirstpassedt = $matches['passed']
		}
		else
		{
		$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed"
		[int]$Sanfirsttotalt = $matches['total']
		[int]$Sanfirstfailedt = $matches['failed']
		[int]$Sanfirstpassedt = 0
		}
	}
}

echo $Sanfirsttotalt
echo $Sanfirstfailedt
echo $Sanfirstpassedt

# Read the Rerun cucumber html file
$rerunValue = ReadHTML -File $rerunHtmlFile

echo $rerunValue

if($rerunValue -like '*undefined*')
{
	if($rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = $matches['failed']
		[int]$Sanrerunpendingt = $matches['pending']
		[int]$Sanrerunpassedt = $matches['passed']
	}
	else
	{
		if($rerunValue -like '*passed*')
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<pending>.*?)\sundefined,(?<passed>.*?)\spassed"
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = 0
		[int]$Sanrerunpendingt = $matches['pending']
		[int]$Sanrerunpassedt = $matches['passed']
		}
		else
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\sundefined"
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = $matches['failed']
		[int]$Sanrerunpendingt = $matches['pending']
		[int]$Sanrerunpassedt = 0
		}
	}
}
else
{
	if($rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<passed>.*?)\spassed") 
	{
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = $matches['failed']
		[int]$Sanrerunpassedt = $matches['passed']
	}
	else
	{
		if($rerunValue -like '*passed*')
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<passed>.*?)\spassed"
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = 0
		[int]$Sanrerunpassedt = $matches['passed']
		}
		else
		{
		$rerunValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed"
		[int]$Sanreruntotalt = $matches['total']
		[int]$Sanrerunfailedt = $matches['failed']
		[int]$Sanrerunpassedt = 0
		}
	}
}

echo reruntotal=$Sanreruntotalt
echo rerunpassed=$Sanrerunpassedt
echo rerunfailed=$Sanrerunfailedt

# Calculate the pass percentage
[int]$totalPassedt = $Sanfirstpassedt + $Sanrerunpassedt
[int]$passPercentaget = ($totalPassedt/$Sanfirsttotalt)*100

# Calculate the number of failed/skipped scenarios
[int]$totalFailedt = $Sanrerunfailedt
if($passPercentaget -eq 100)
{
	$bgcolort = 'bgcolor="#99FF33"'
}elseif(($passPercentaget -lt 100) -and ($passPercentaget -gt 50))
{
	$bgcolort = 'bgcolor="#FF9933"'
}else
{
	$bgcolort = 'bgcolor="#FF3333"'
}

Clear-variable Device
Clear-variable htmlFile
Clear-variable rerunHtmlFile

########################################################################################################################################################
####################################################       Regression Report html generation       #####################################################
########################################################################################################################################################


$emailRegression = "<h2>Regression Report</h2>
					</br>"
$RegressionPhoneFile = "D:\jenkins-slave\Reporting\GHS\Android\" + $YestDate + "RegressionPhone.html"
echo $RegressionPhoneFile
$RegressionTabletFile = "D:\jenkins-slave\Reporting\GHS\Android\" + $YestDate + "RegressionTablet.html"
echo $RegressionTabletFile
$emailRegressionPhone = Get-Content -Path $RegressionPhoneFile
$emailRegressionTablet = Get-Content -Path $RegressionTabletFile
$emailRegression = $emailRegression + $emailRegressionPhone + "</br>" + $emailRegressionTablet 


#########################################################################################################################################################
#############################################################      Email Body      ######################################################################
#########################################################################################################################################################

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
	
	.tab-3_data {
		text-align: center;
		border: 1px solid #BAD6FF;
		border-collapse: collapse;
		height: 25px;
		width:80px;
		background-color: #b3ffcc;
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
"@

$emailMessageSanity = @"

	<h2>Sanity Report </h2>
	
	<table>
		<tr>
			<td>
				<table class="tab-1">
					<tr class="tab-1_row">
						<th class="tab-1_heading_main"; colspan="3">Phone</th>
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
			</td>
			<td>
				<table class="tab-1">
					<tr class="tab-1_row">
						<th class="tab-1_heading_main"; colspan="3">Tablet</th>
					</tr>
					<tr class="tab-1_row">
						<th class="tab-1_heading"></th>
						<th class="tab-1_heading">Passed</th>
						<th class="tab-1_heading">Failed</th>
					</tr>
					<tr>
						<th class="tab-1_heading">Sanity</th>
						<td class="tab-2_data">$Sanfirstpassedt</td>
						<td class="tab-2_data">$Sanfirstfailedt</td>
					</tr>
					<tr>
						<th class="tab-1_heading">Rerun</th>
						<td class="tab-2_data">$Sanrerunpassedt</td>
						<td class="tab-2_data">$Sanrerunfailedt</td>
					</tr>
					<tr>
						<th class="tab-1_heading">Total</th>
						<td class="tab-2_data">$totalPassedt</td>
						<td class="tab-2_data">$totalFailedt</td>
					</tr>
					<tr>
						<td colspan="3"; $bgcolort>Pass Percentage : $passPercentaget</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</br>
	<h4>For Cucumber Report : <a href="$CucumberLinkp"><strong> Phone </strong></a> , <a href="$CucumberLinkt"><strong> Tablet </strong></a></h4>
	<h4>For detailed sanity reports : <a href="$SanityLinkp"><strong> Phone </strong></a> , <a href="$SanityLinkt"><strong> Tablet </strong></a></h4>
</body>
</html>
"@ 
 
 

 
$emailMessage.Body = $emailMessage.Body + $emailAnalysisReport + $bodyBuildStatus + $emailMessageSanity + $emailRegression

echo $emailMessage.Body


$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )
 