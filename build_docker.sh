#!/bin/zsh

if [[ -z "$VERSION_STRING" ]] ; then
    VERSION_STRING=$(git tag --points-at HEAD)
    if [[ -z "$VERSION_STRING" ]] ; then
        echo "Git HEAD doesn't have a tag - either set one or specify VERSION_STRING manually"
        exit 1
    fi
fi

tagname="pengwyn/julia-python-base:jl1.5-py3.8-$VERSION_STRING"
docker build -t $tagname . || exit 1
docker push $tagname || exit 1
