#!/bin/bash

file=setup.py

commit_message=$1

version=$(cat $file | grep version= | grep -o -E '[0-9.0-9.0-9]')
version=$(echo $version | sed 's/ //g')

major=$(echo $version | cut -d. -f1)
minor=$(echo $version | cut -d. -f2)
micro=$(echo $version | cut -d. -f3)

fix=$(echo $commit_message | grep -o 'fix(')
feat=$(echo $commit_message | grep -o 'feat(')
perf=$(echo $commit_message | grep -o 'perf(')
breaking_changes=$(echo $commit_message | grep -o 'BREAKING_CHANGES:')

echo $major
echo $minor
echo $micro

if [ $breaking_changes ]
then
  micro=0
  minor=0
  major=$((major + 1))
elif [ $fix ] || [ $perf ]
then
  micro=$((micro + 1)) 
elif [ $feat ]
then
  minor=$((minor + 1)) 
fi

echo $major
echo $minor
echo $micro

sed -i 's/version=.*/version='\'$major.$minor.$micro\','/' $file