#!/bin/sh
set -e

cd test && go test -v -timeout 30m
