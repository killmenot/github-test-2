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
PRE_ID=
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
    --pre-id)
      PRE_ID="$2"
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

APP_NAME=$1
RELEASE_BRANCH=release/$REGION/$APP_NAME/$ENV

git checkout develop
git pull origin develop

git fetch origin $RELEASE_BRANCH:$RELEASE_BRANCH
git checkout $RELEASE_BRANCH
git merge develop

npm version $VERSION --preid $PRE_ID --no-commit-hooks --no-git-tag-version
TAG=$(jq -r .version package.json)+$1
TITLE="v$TAG"

git commit -a -m "chore(release): release $TITLE"

git push origin $RELEASE_BRANCH
git checkout develop
git branch -D $RELEASE_BRANCH

if [ "$ENV" == "production" ]; then
  gh release create "$TAG" --title $TITLE --notes "bugfix release" --target $RELEASE_BRANCH --latest=false
else
  gh release create "$TAG" --title $TITLE --notes "bugfix release" --target $RELEASE_BRANCH --prerelease --latest=false
fi

