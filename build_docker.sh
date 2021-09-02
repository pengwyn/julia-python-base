#!/bin/zsh

if [[ -z "$VERSION_STRING" ]] ; then
    if ! ( git diff --quiet > /dev/null 2>&1 ) ; then
        echo "Git is dirty, not going to get automatic version."
        exit 1
    fi
    VERSION_STRING=$(git tag --points-at HEAD)
    if [[ -z "$VERSION_STRING" ]] ; then
        echo "Git HEAD doesn't have a tag - either set one or specify VERSION_STRING manually"
        exit 1
    fi
fi

if [[ -z "$JULIA_VERSION" ]] ; then
    export JULIA_VERSION=1.6.0
fi
if [[ -z "$PYTHON_VERSION" ]] ; then
    export PYTHON_VERSION=3.8
fi

dockerfile=Dockerfile.py${PYTHON_VERSION}

export DOCKER_BUILDKIT=1

sed -e "s/FROM python:pyversion-/FROM python:${PYTHON_VERSION}-/" Dockerfile > $dockerfile || exit 1
tagname="pengwyn/julia-python-base:jl${JULIA_VERSION}-py${PYTHON_VERSION}-$VERSION_STRING"
docker build --build-arg JULIA_VERSION -t $tagname -f $dockerfile . || exit 1
docker push $tagname || exit 1
