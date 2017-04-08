#!/bin/bash -xe
echo "hello world"
source /home/osmc/.rvm/scripts/rvm
cd /home/osmc/dotstarlib
git fetch origin
git reset --hard origin/master
cp settings.yaml.local settings.yaml
bundle exec ruby -Ilib lib/strip_app.rb
