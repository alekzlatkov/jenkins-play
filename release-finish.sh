#!/bin/sh -xe

set -e

ORIGIN_URL=$1
VERSION=$2
NEXT_VERSION=$3
SNAPSHOT_VERSION=$NEXT_VERSION"-SNAPSHOT"
RELEASE_BRANCH="release/$VERSION"
TAG=$VERSION

# Validate input
if [ -z "$NEXT_VERSION" ]
then
    echo "NEXT_VERSION is empty"
    exit 1
fi

if [ -z "$VERSION" ]
then
    echo "VERSION is empty"
    exit 1
fi

RELEASE_BRANCH_EXISTS=$(git ls-remote --heads origin $RELEASE_BRANCH | wc -l)
if [ "$RELEASE_BRANCH_EXISTS" == "0" ]
then
    echo "Release branch does not exists: $RELEASE_BRANCH"
    exit 1
fi

TAG_EXISTS=$(git ls-remote --tags origin $TAG | wc -l)
if [ "$TAG_EXISTS" == "1" ]
then
    echo "Tag alread exists: $TAG"
    exit 1
fi

exit 99

# Set origin url
git remote set-url origin $ORIGIN_URL

# Merge release into develop and set next snapshot version
git checkout develop
git merge --no-ff origin/$RELEASE_BRANCH
./mvnw versions:set -DnewVersion=$SNAPSHOT_VERSION
git commit -am "Bump version to $SNAPSHOT_VERSION"


# Merge release into master and create tag
git checkout master
git merge --no-ff origin/$RELEASE_BRANCH
git tag -a $TAG -m $TAG


# Push master, develop and tag
git push origin develop
git push origin master
git push origin $TAG

# Delete release branch
git push origin --delete $RELEASE_BRANCH
