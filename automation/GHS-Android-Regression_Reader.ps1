param
(
 [string]$htmlFile = $args[0],
 [string]$Filename = $args[1],
 [string]$DeviceName = $args[2],
 [string]$DeviceType = $args[3]
)

# Read the cucumber html file
function ReadHTML([string] $File)
{
 $source = Get-Content -Path $File | Out-String
 $removeSpace = $source -replace "`n|`r" 
 $removeSpace  -match "document.getElementById\(\'totals\'\).innerHTML =(?<value>.*?)<" | Out-Null
 return $matches.value.Trim() -replace '"',""
}

$htmlFileValue = ReadHTML -File $htmlFile

echo $htmlFileValue


# Extract the values
if($htmlFileValue -like '*undefined*')
{
	if($htmlFileValue -like '*pending*')
	{
		if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<undefined>.*?)\sundefined,\s(?<pending>.*?)\spending,\s(?<passed>.*?)\spassed") 
		{
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = $matches['failed']
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpending = $matches['pending']
			[int]$Sanfirstpassed = $matches['passed']
		}
		else
		{
			if($htmlFileValue -like '*passed*')
			{
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<undefined>.*?)\sundefined,\s(?<pending>.*?)\spending,(?<passed>.*?)\spassed"
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = 0
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpending = $matches['pending']
			[int]$Sanfirstpassed = $matches['passed']
			}
			else
			{
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<undefined>.*?)\sundefined,\s(?<pending>.*?)\spending"
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = $matches['failed']
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpending = $matches['pending']
			[int]$Sanfirstpassed = 0
			}
		}
	}
	else
	{
		if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<undefined>.*?)\sundefined,\s(?<passed>.*?)\spassed") 
		{
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = $matches['failed']
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpassed = $matches['passed']
		}
		else
		{
			if($htmlFileValue -like '*passed*')
			{
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<undefined>.*?)\sundefined,(?<passed>.*?)\spassed"
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = 0
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpassed = $matches['passed']
			}
			else
			{
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<undefined>.*?)\sundefined"
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = $matches['failed']
			[int]$Sanfirstundefined = $matches['undefined']
			[int]$Sanfirstpassed = 0
			}
		}
	}
}
else
{
	if($htmlFileValue -like '*pending*'){
		if($htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\spending,\s(?<passed>.*?)\spassed") 
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
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<pending>.*?)\spending,(?<passed>.*?)\spassed"
			[int]$Sanfirsttotal = $matches['total']
			[int]$Sanfirstfailed = 0
			[int]$Sanfirstpending = $matches['pending']
			[int]$Sanfirstpassed = $matches['passed']
			}
			else
			{
			$htmlFileValue -match "(?<total>^.*?)\s.*\((?<failed>.*?)\sfailed,\s(?<pending>.*?)\spending"
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
}
echo "Sanity : total , failed , pending, passed"
echo $Sanfirsttotal
echo $Sanfirstfailed
echo $Sanfirstpending
echo $Sanfirstpassed
echo "----------------------------"

[int]$Sanitytotal = $Sanfirsttotal
[int]$Sanitytotalpassed = $Sanfirstpassed 
[int]$Sanitytotalfailed = $Sanfirstfailed
[int]$Sanitytotalpending = $Sanfirstpending


# Calculate the pass percentage

[int]$passPercentage = ($Sanfirstpassed/$Sanfirsttotal)*100

echo $passPercentage

#Converting to JSON

@{$DeviceName=@{passed="$Sanfirstpassed";failed="$Sanfirstfailed";pending="$Sanfirstpending";passPercentage="$passPercentage"}} | ConvertTo-Json -depth 2 | Out-File -Append "D:\jenkins-slave\workspace\GHS-Android-Email_Notifier-Regression\$DeviceType\Regression.json"