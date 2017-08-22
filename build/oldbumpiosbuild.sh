#Usage
#./bumpiosbuild.sh jenkins_build_no configfilepath
#Example --> ./bumpiosbuild.sh 108 /Users/hscbuild01/Info.plist

#Get the current build number from jenkins
VAR=$1
echo Jenkins Build : ${VAR}

#Get the Application Release version from Info.plist - iOS
xml sel -t -v "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" $2>currentrelease
VAR2=$(head -n 1 currentrelease)
echo Current Version : $VAR2

#Concatenate the bumped build number to versionc
VAR3=${VAR2}.${VAR}
echo Updated Build : $VAR3

#Append the bumped build number to version
xml ed --inplace -u "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" -v $VAR3 $2
xml ed --inplace -u "//key[contains(text(),\"CFBundleShortVersionString\")]/following-sibling::string[1]/text()" -v $VAR3 $2 
