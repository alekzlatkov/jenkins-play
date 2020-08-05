ORIGIN_URL=$1
VERSION=$2
RELEASE_BRANCH="release/"$VERSION

# Create release brnach
git checkout -b $RELEASE_BRANCH
./mvnw versions:set -DnewVersion=$VERSION
git commit -am "Bump version to $VERSION"

# Push release branch
git remote set-url origin $ORIGIN_URL
git push --set-upstream origin $RELEASE_BRANCH
