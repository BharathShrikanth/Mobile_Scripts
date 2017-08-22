# Move the old files to archive	
	$Date = (Get-Date).AddDays(-1).ToString('dd-MM-yyyy')
	echo $Date
	$TodaysDate = (Get-Date).ToString('dd-MM-yyyy')
	echo $TodaysDate
	cd D:\jenkins-slave\Reporting\GHS\Android
	mkdir $TodaysDate 
	if(Test-Path D:\jenkins-slave\Reporting\GHS\GHS-Android.json)
	{
		$path_android = "D:\jenkins-slave\Reporting\GHS\Android\$Date.json"
		echo $path_android
		Copy-Item D:\jenkins-slave\Reporting\GHS\GHS-Android.json $path_android
		Remove-Item  D:\jenkins-slave\Reporting\GHS\GHS-Android.json
	}
