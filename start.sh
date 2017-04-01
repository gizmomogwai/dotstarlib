#!/bin/bash -xe
echo "hello world"
source /home/osmc/.rvm/scripts/rvm
cd /home/osmc/dotstarlib
bundle exec ruby -Ilib lib/strip_app.rb
