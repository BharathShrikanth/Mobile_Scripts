#!/bin/bash
codepath=$1
jobpath=$2
tarname=$3
branch=$4
pullhash=$5

cd $codepath

#Update the local Repo

if [[ -z $pullhash ]]
then
  echo No hash value mentioned
  git reset --hard HEAD
  git reset --hard $branch
  git clean -f -d
  git pull --prune
  git submodule init
  git submodule update --init --recursive
else
  echo Hash value is $pullhash
  git reset --hard HEAD
  git reset --hard $branch
  git clean -f -d
  git pull --prune
  git submodule init
  git submodule update --init --recursive
  git reset --hard $pullhash
fi

#Zip the updated repo
tar cf ../$tarname .
mv ../$tarname $jobpath
cd $jobpath
tar xvf $tarname
rm $tarname