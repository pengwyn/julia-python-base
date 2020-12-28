#!/bin/zsh

tagname="pengwyn/julia-python-base:jl1.5-py3.9-$(git tag)"
docker build -t $tagname . || exit 1
docker push $tagname || exit 1
