#!/bin/bash

# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# TeamCity build script for prod, rc, stage and vagrant deploys
#   with fail_unless_env_var check function by zdennis@mutuallyhuman.com

sudo -u aperta -i /bin/bash << "EOF"
# It is necessary to define an environment var TARGET_ENV
#  that is one of dev, qa, stage or prod
function fail_unless_env_var {
  # use variable indirection to perform variable expansion on the value of $1
  var_name=$1
  val="${!var_name}"
  if [ -z $val ]; then
    echo "Need to set $var_name"
    exit 1
  fi
}

cd %teamcity.build.checkoutDir%
export BRANCH_NAME=%teamcity.build.branch%
export VCS_NUMBER=%build.vcs.number%
export TARGET_ENV=%env.TARGET_ENV%
echo "Deploying release..."
echo $BRANCH_NAME
echo $VCS_NUMBER
echo $TARGET_ENV
# Can't use -i as have to stay in checkout directory
# Need to set any needed vars in Parameters as env vars
eval `ssh-agent -s`
fail_unless_env_var SSH_AGENT_PID
ssh-add /home/aperta/.ssh/id_rsa
ssh-add -l
source /usr/share/chruby/chruby.sh
cat .ruby-version
chruby `cat .ruby-version` || exit 1
fail_unless_env_var TARGET_ENV
gem install bundler && bundle install && bundle exec cap $TARGET_ENV deploy || exit 1
ssh-agent -k
EOF
