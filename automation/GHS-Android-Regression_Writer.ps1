param
(
	[string]$Reports_Location = $args[0],
	[string]$DeviceType = $args[1]
)

$Date = (Get-Date).ToString('dd-MM-yyyy')
echo $Date

$Date_yest = (Get-Date).AddDays(-1).ToString('dd-MM-yyyy')

# Get the device names 

$Device_Names = split-path "$Reports_Location\*.html" -leaf -resolve

$i = 0
while ($i -lt $n)
{
	echo $Device_Names[$i]
	$Device_Names[$i] -match "Automation_report_(?<Name>.*?).html"
	[string]$Device = $matches['Name']
	$Devices += @($Device.Substring(0,$Device.Length-0))
	echo $Devices[$i]
	$i++
}
 
$n = $Devices.length


#Email Notifications parameters

$emailSmtpServer = "smtp.gmail.com"
$emailSmtpServerPort = "587"
$emailSmtpUser = "hsc.mobci@gmail.com"
$emailSmtpPass = "senihcam"
 
$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = "hsc.mobci@gmail.com"
$emailMessage.To.Add( "bharath.shrikanth@in.tesco.com" )
$emailMessage.Subject = "GHS-Android-Regression Test Report - $DeviceType"

$emailMessage.IsBodyHtml = $true


#Read the json files and generate html content

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

$emailRegression = @"
	<table class="tab-1">
		<tr class="tab-1_row">
			<th class="tab-1_heading_main"; colspan="5">$DeviceType</th>
		</tr>
		<tr class="tab-1_row">
			<th class="tab-1_heading">Device</th>
			<th class="tab-1_heading">Passed</th>
			<th class="tab-1_heading">Failed</th>
			<th class="tab-1_heading">Pending</th>
			<th class="tab-1_heading">Device Pass Percentage</th>
		</tr>
"@


$TotalScenarios=0
$TotalPass=0
$TotalFail=0
$TotalPending=0
$TotalPassPercentage=0

$i=0

while($i -lt $n)
{
	$Device = $Devices[$i]
	echo $Device
	$htmlDeviceRow = ""

		$File = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\$DeviceType\Regression.json"
		$source = Get-Content -Path $File | Out-String
		$removeSpace = $source -replace "\s+" 
		$Values = $removeSpace -replace '"' 
		$Values  -match "$Device\:{(?<value>.*?)}{" | Out-Null
		echo "---"$matches['value']
		$matches['value'] -match "passPercentage\:(?<passPercentage>.*?),pending\:(?<pending>.*?),failed\:(?<failed>.*?),passed\:(?<passed>.*?)}" | Out-Null
		echo $matches['passPercentage']
		echo $matches['pending']
		echo $matches['failed']
		echo $matches['passed']
		
		[int]$passPercent = $matches['passPercentage']
		[int]$pending = $matches['pending']
		[int]$failures = $matches['failed']
		[int]$pass = $matches['passed']
		
		if($passPercent -eq 100)
		{
			$bgcolor = 'bgcolor="#0066FF"'
		}elseif(($passPercent -le 99) -and ($passPercent -gt 86))
		{
			$bgcolor = 'bgcolor="#47B547"'
		}elseif(($passPercent -le 86) -and ($passPercent -ge 51))
		{
			$bgcolor = 'bgcolor="#FFCC00"'
		}else
		{
			$bgcolor = 'bgcolor="#FF3333"'
		}
		
		#Calculate the totals
		$TotalPass = $TotalPass + $pass
		$TotalFail = $TotalFail + $failures
		$TotalPending = $TotalPending + $pending
		$TotalPassPercentage = $TotalPassPercentage + $passPercent
		
		#Construct the HTML content
		$htmlDeviceRow = $htmlDeviceRow + "<td class='tab-3_data'>$Device</td>
			<td class='tab-1_data'>$pass</td>
            <td class='tab-1_data'>$failures</td>
			<td class='tab-1_data'>$pending</td> 
            <td class='td-2'; $bgcolor>$passPercent</td>"
			
		echo $passPercent "before clearing"	
		Clear-Variable passPercent  
		Clear-Variable failures
		Clear-Variable pass
		Clear-Variable pending
		Clear-Variable matches['passPercentage']
		Clear-Variable matches['failed']
		Clear-Variable matches['passed']
		Clear-Variable matches['pending']
		Clear-Variable bgcolor
		echo $passPercent "after clearing"

    
	$htmlEntireRow = "<tr>" + $htmlDeviceRow + "</tr>"
	echo "--------------------------------------------------"
	echo $htmlEntireRow
	echo "--------------------------------------------------"
	
	$emailRegression = $emailRegression + $htmlEntireRow
	$emailMessage.Body = $emailMessage.Body + $htmlEntireRow
	$i++
	
	(Get-Content $File | Select-Object -Skip 8) | Set-Content $File
}

$TotalPassPercentage = $TotalPassPercentage/$n
		if($TotalPassPercentage -eq 100)
		{
			$bgcolor = 'bgcolor="#0066FF"'
		}elseif(($TotalPassPercentage -le 99) -and ($TotalPassPercentage -ge 85))
		{
			$bgcolor = 'bgcolor="#47B547"'
		}elseif(($TotalPassPercentage -lt 85) -and ($TotalPassPercentage -ge 51))
		{
			$bgcolor = 'bgcolor="#FFCC00"'
		}else
		{
			$bgcolor = 'bgcolor="#FF3333"'
		}
		
if($DeviceType -like "Phone")
{
	$RegressionLink = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Regression_Phone_n/"
}
else{
	$RegressionLink = "http://192.168.2.201:8086/view/Nightly-Builds/job/GHS_Android_Regression_Tablet_n/"
}
		
		
$Footer = @"
		<tr>
			<td class='tab-1_heading'>Totals</td>
			<td class='tab-1_heading'>$TotalPass</td>
            <td class='tab-1_heading'>$TotalFail</td>
			<td class='tab-1_heading'>$TotalPending</td> 
            <td class='td-2'; $bgcolor>$TotalPassPercentage</td>
		</tr>
		<tr>
            <td colspan="5" class="th_5" height=10; $bgcolor>-----  $TotalPassPercentage % tests passed  -----</td>
        </tr>
        </table>
    </table>
	</br>
	<h4>For detailed Regression reports : <a href="$RegressionLink"><strong> Click here </strong></a></h4>

"@

$emailRegression = $emailRegression + $Footer
$emailMessage.Body = $emailMessage.Body + $Footer

echo $emailMessage.Body 

$Output_file = "D:\jenkins-slave\Reporting\GHS\Android\" + $Date_yest + "Regression" + $DeviceType + ".html"

$emailRegression | Out-File $Output_file

#Mailer
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass ); 
#$SMTPClient.Send( $emailMessage )