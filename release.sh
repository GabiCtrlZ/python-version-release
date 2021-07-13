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

changed=not

if [ $breaking_changes ]
then
  micro=0
  minor=0
  major=$((major + 1))
  changed=changed
elif [ $fix ] || [ $perf ]
then
  micro=$((micro + 1))
  changed=changed
elif [ $feat ]
then
  minor=$((minor + 1))
  changed=changed
fi

echo $major
echo $minor
echo $micro

sed -i 's/version=.*/version='\'$major.$minor.$micro\','/' $file

set -e

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

INPUT_AUTHOR_EMAIL='github-actions[bot]@users.noreply.github.com'
INPUT_AUTHOR_NAME='github-actions[bot]'
INPUT_GITHUB_TOKEN=$2
INPUT_MESSAGE=${3:-"chore(release): [skip ci] ${timestamp}"}
INPUT_BRANCH=${4:-main}
INPUT_EMPTY=${5:-false}
REPOSITORY=$GITHUB_REPOSITORY

echo "Push to branch $INPUT_BRANCH";
[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
    exit 1;
};

if ${INPUT_EMPTY}; then
  _EMPTY='--allow-empty'
fi

remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

git config http.sslVerify false
git config --local user.email "${INPUT_AUTHOR_EMAIL}"
git config --local user.name "${INPUT_AUTHOR_NAME}"

git add -A

git commit -m "{$INPUT_MESSAGE}" $_EMPTY || exit 0

if [ $changed == changed ]; then
  git tag -a -m "updating version to v$major.$minor.$micro" v$major.$minor.$micro
fi

git push "${remote_repo}" HEAD:"${INPUT_BRANCH}" --follow-tags;