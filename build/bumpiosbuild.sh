#Usage
#./bumpiosbuild.sh jenkins_build_no configfilepath
#Example --> ./bumpiosbuild.sh 108 /Users/hscbuild01/Info.plist

#Get the current build number from jenkins
VAR=$1
echo Jenkins Build : ${VAR}

#Get the Application Release version from Info.plist - iOS
xml sel -t -v "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" $2>currentrelease
xml sel -t -v "//key[contains(text(),\"CFBundleShortVersionString\")]/following-sibling::string[1]/text()" $2>currentrelease1
VAR2=$(head -n 1 currentrelease)
VAR4=$(head -n 1 currentrelease1)
echo Current Version : $VAR2
echo Current Short Version : $VAR4

#Concatenate the bumped build number to versionc
VAR3=${VAR2}.${VAR}
VAR5=${VAR4}.${VAR}
echo Updated Version Build : $VAR3
echo Updated ShortVersion Build : $VAR5

#Append the bumped build number to version
xml ed --inplace -u "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" -v $VAR3 $2
xml ed --inplace -u "//key[contains(text(),\"CFBundleShortVersionString\")]/following-sibling::string[1]/text()" -v $VAR5 $2 
