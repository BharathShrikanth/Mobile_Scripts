param
(
	[string]$Reports_Location = $args[0],
	[string]$DeviceType = $args[1]
)

# Calculate the number of devices connected

$Number_of_devices = (Get-ChildItem $Reports_Location -filter "*.html").Count

$n = $Number_of_devices

echo Number_of_devices = $n

New-Item -ItemType directory -Path D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\$DeviceType

Copy-Item $Reports_Location\*.html D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\$DeviceType


# Get the device names 

$Device_Names = split-path "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\$DeviceType\*.html" -leaf -resolve

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
 
# Rename the output files to Regression_1, Regression_2, ...... 

$i = 1

#while ($i -le $n)
#{
#	Rename-Item -Path D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\Tablet\Automation_report_*_$i.html -newname Regression_$i.html	
#	$i++
#}

# Read the Regression files and populate the json file
$i = 1
$j = 0
while ($i -le $n)
{
	while ($j -lt $n)
	{
		$Device_info = $Devices[$j]
		$Filepath = "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\Tablet\" + $i+ "_Automation_report_" + $Device_info + ".html"
		$Filename = "$i_Automation_report_" + $Device_info + ".html"
		#Rename-Item -Path D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\Tablet\$Filename -newname Regression_$i.html
		echo $Filename
		echo $Filepath
		echo $Device_info
		Invoke-Expression "C:\Users\Administrator\Documents\GHS-Android-Regression_Reader.ps1 $Filepath $Filename $Device_info $DeviceType"
		$i++
		$j++
	}
}

Add-Content D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\Tablet\Regression.json "`n{"

# Generate the html content and mail the same 

Invoke-Expression "C:\Users\Administrator\Documents\GHS-Android-Regression_Writer.ps1 $Reports_Location $DeviceType"