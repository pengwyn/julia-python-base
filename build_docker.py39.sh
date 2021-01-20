#!/bin/zsh

sed -e 's/FROM python:3.8-slim/FROM python:3.9-slim/' Dockerfile > Dockerfile.py39 || exit 1
tagname="pengwyn/julia-python-base:jl1.5-py3.9-$(git describe --tags)"
docker build -t $tagname -f Dockerfile.py39 . || exit 1
docker push $tagname || exit 1
