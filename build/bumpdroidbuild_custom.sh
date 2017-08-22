#Usage
#./bumpdroidbuild.sh jenkins_build_no configfilepath
#Example --> ./bumpdroidbuild.sh 108 /Users/hscbuild01/AndroidManifest.xml

#Get the current build number from jenkins
VAR=$1
echo Jenkins Build : ${VAR}

#Get the Application Release version from AndroidManifest.xml - Android
xml sel -t -v "/manifest/@android:versionName" $2>currentrelease
VAR2=$(head -n 1 currentrelease)
echo Current Build : $VAR2

#Concatenate the bumped build number to versionc
VAR3=${VAR2}
#VAR3=${VAR2}-build${VAR}
echo Updated Build : $VAR3

#Append the bumped build number to version
xml ed --inplace -u "/manifest/@android:versionName" -v $VAR3 $2 
