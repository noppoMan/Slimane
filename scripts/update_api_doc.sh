#!/bin/sh

cd ./Xcode

jazzy \
  --clean \
  --author Yuki Takei \
  --author_url https://github.com/noppoMan/Slimane \
  --github_url https://github.com/noppoMan/Slimane \
  --module Slimane \
  --output ../docs/api
