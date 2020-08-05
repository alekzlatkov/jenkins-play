#!/bin/sh -xe

set -e

ORIGIN_URL=$1
VERSION=$2
RELEASE_BRANCH="release/"$VERSION

# Validate
if [ -z "$ORIGIN_URL" ]
then
    echo "ORIGIN_URL is empty"
    exit 1
fi

# Set origin url
git remote set-url origin $ORIGIN_URL

if [ -z "$VERSION" ]
then
    echo "VERSION is empty"
    exit 1
fi

RELEASE_BRANCH_EXISTS=$(git ls-remote --heads origin $RELEASE_BRANCH | wc -l)
if [ "$RELEASE_BRANCH_EXISTS" == "1" ]
then
    echo "Release branch exists: $RELEASE_BRANCH"
    exit 1
fi

TAG_EXISTS=$(git ls-remote --tags origin $TAG | wc -l)
if [ "$TAG_EXISTS" == "1" ]
then
    echo "Tag alread exists: $TAG"
    exit 1
fi

# Create release brnach
git checkout -b $RELEASE_BRANCH
./mvnw versions:set -DnewVersion=$VERSION
git commit -am "Bump version to $VERSION"

# Push release branch
git push --set-upstream origin $RELEASE_BRANCH
