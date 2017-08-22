
Invoke-RestMethod -Uri http://192.168.2.201:8086/view/Develop%20Branch/job/GHS-Android-Build-DEV-CI/lastBuild/api/json | Out-File "D:\jenkins-slave\jobStatus.txt"


[string]$buildStats0 = (Get-Content "D:\jenkins-slave\jobStatus.txt")
echo $buildStats0
[string]$buildStats1 = $buildStats0 -replace "`n|`r" 
echo $buildStats1
[string]$buildStats = $buildStats0 -replace " ",""
echo $buildStats

# Build Status
$buildStats -match "result:(?<build_status>.*?)timestamp" | Out-Null
[string]$buildStatus = $matches['build_status'] 

# Build Time
$buildStats -match "duration:(?<build_time>.*?)estimatedDuration" | Out-Null
[int]$buildTime = $matches['build_time'] 
[int]$buildTimeSec = ($buildTime % 60000) / 1000
[int]$buildTimeMin = ($buildTime - ($buildTime % 60000)) / 60000
[string]$buildTimeVal = "$buildTimeMin min, $buildTimeSec sec"

# Build Number 
$buildStats -match "number:(?<build_number>.*?)queueId" | Out-Null
[string]$buildNumber = $matches['build_number'] 


echo $buildNumber
echo $buildStatus
echo $buildTimeVal

# Populate the json file 
$TodaysDate = (Get-Date).ToString('dd-MM-yyyy')
	echo $TodaysDate

$filename = "_" + $buildNumber
@{buildNumber="$buildNumber";buildStatus="$buildStatus";buildTimeVal="$buildTimeVal"} | ConvertTo-Json -depth 1 | Out-File -Append "D:\jenkins-slave\Reporting\GHS\Android\$TodaysDate\$filename.json"

Clear-variable buildNumber
Clear-variable buildStatus
Clear-variable buildTimeVal