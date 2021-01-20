#!/bin/zsh

tagname="pengwyn/julia-python-base:jl1.5-py3.8-$(git describe --tags)"
docker build -t $tagname . || exit 1
docker push $tagname || exit 1
