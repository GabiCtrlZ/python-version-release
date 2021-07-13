#!/bin/bash

file=setup.py

version=$(cat $file | grep version= | grep -o -E '[0-9.0-9.0-9]')
version=$(echo $version | sed 's/ //g')

major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)
micro=$(echo $version | cut -d. -f3)

option=$1
breaking_changes=$2

echo $major
echo $minor
echo $micro

if [ $breaking_changes ]
then
  micro=0
  minor=0
  major=$((major + 1))
elif [ $option == fix ]
then
  micro=$((micro + 1)) 
elif [ $option == feat ]
then
  minor=$((minor + 1)) 
elif [ $option == perf ]
then
  micro=$((micro + 1))
fi

echo $major
echo $minor
echo $micro

sed -i "" 's/version=.*/version='\'$major.$minor.$micro\','/' $file