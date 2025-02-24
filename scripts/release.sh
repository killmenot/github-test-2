#!/bin/bash

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

# GETOPT=/usr/local/opt/gnu-getopt/bin/getopt
# # GETOPT=getopt

# # More safety, by turning some bugs into errors.
# set -o errexit -o pipefail -o noclobber -o nounset

# # ignore errexit with `&& true`
# $GETOPT --test > /dev/null && true
# if [[ $? -ne 4 ]]; then
#     echo 'I’m sorry, `getopt --test` failed in this environment.'
#     exit 1
# fi

# # option --output/-o requires 1 argument
# LONGOPTS=region:,env:,version:

# # -temporarily store output to be able to check for errors
# # -activate quoting/enhanced mode (e.g. by writing out “--options”)
# # -pass arguments only via   -- "$@"   to separate them correctly
# # -if getopt fails, it complains itself to stderr
# PARSED=$($GETOPT --longoptions=$LONGOPTS --name "$0" -- "$@") || exit 2
# # read getopt’s output this way to handle the quoting right:
# eval set -- "$PARSED"

REGION=ru
ENV=staging
VERSION=patch
PRE=
APP_NAME=

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --region)
      REGION="$2"
      shift 2
      ;;
    --env)
      ENV="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --preid)
      PRE="$2"
      shift 2
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# echo "region: $region, env: $env, version: $version, app: $1"

APP_NAME=$1
RELEASE_BRANCH=release/$REGION/$APP_NAME/$ENV

git checkout develop
git pull origin develop
npm version $VERSION --preid prerelease-id --no-commit-hooks --no-git-tag-version
git fetch origin $RELEASE_BRANCH:$RELEASE_BRANCH
git checkout $RELEASE_BRANCH
git merge develop
git push origin $RELEASE_BRANCH
git checkout develop
git push origin develop
git branch -D $RELEASE_BRANCH

TAG=$(jq -r .version package.json)+$1
TITLE="v$TAG"

case "$b" in
 5) a=$c ;;
 *) a=$d ;;
esac

echo $TAG
echo $TITLE

if [ "$ENV" == "production" ]; then
  gh release create "$TAG" --title $TITLE --target $RELEASE_BRANCH
else
  gh release create "$TAG" --title $TITLE --target $RELEASE_BRANCH --prerelease
fi





#  ./scripts/release.sh --region fr --env production --version minor maps-api
#  ./scripts/release.sh --env=prod121212maps-api

# ./scripts/release.sh --region ru --env production --version minor maps-api






