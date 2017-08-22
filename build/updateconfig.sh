#!/bin/bash
#Usage
#./modifybundleid.sh bundleName configfilepath
#Example --> ./modifybundleid.sh com.tesco.dc.PPE /Users/hscbuild01/AndroidManifest.xml
jenkinsbuild=$1
bundlename=$2
filename=$3
echo Jenkins Build : ${jenkinsbuild}
echo New Bundle Name : ${bundlename}
# Take extension available in a filename
ext=${filename##*\.}
case "$ext" in
        plist) echo "$filename : iOS config file"
        xml ed --inplace -u "//key[contains(text(),\"CFBundleIdentifier\")]/following-sibling::string[1]/text()" -v $bundlename $filename

        #Get the Application Release version from Info.plist - iOS
        xml sel -t -v "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" $filename>currentrelease
        currentversion=$(head -n 1 currentrelease)
        echo Current Version : $currentversion

        #Concatenate the bumped build number to versionc
        updatedversion=${currentversion}.${jenkinsbuild}
        echo Updated Build : $updatedversion

        #Append the bumped build number to version
        xml ed --inplace -u "//key[contains(text(),\"CFBundleVersion\")]/following-sibling::string[1]/text()" -v $updatedversion $filename
        xml ed --inplace -u "//key[contains(text(),\"CFBundleShortVersionString\")]/following-sibling::string[1]/text()" -v $updatedversion $filename
        ;;
        xml) echo "$filename : Android config file"

        #Get the Application Release version from AndroidManifest.xml - Android
        xml sel -t -v "/manifest/@android:versionName" $filename>currentrelease
        currentversion=$(head -n 1 currentrelease)
        echo Current Build : $currentversion

        #Concatenate the bumped build number to versionc
        updatedversion=${currentversion}-build${jenkinsbuild}
        echo Updated Build : $updatedversion

        #Append the bumped build number to version
        xml ed --inplace -u "/manifest/@android:versionName" -v $updatedversion $filename

        #Get the bundle name from jenkins
        xml sel -t -v "/manifest/@package" $filename>pkgname
        pkg=$(head -n 1 pkgname)
        echo Old Bundle Name : $pkg
        #Replace the bundle name in config file
        xml ed --inplace -u "/manifest/@package" -v $bundlename $filename
        sed -i "" s/$pkg/$bundlename/g $filename
        rm pkgname
	    ;;
esac
