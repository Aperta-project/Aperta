#!/bin/bash
# TeamCity build script for prod, rc, stage and vagrant deploys
# current_author = jgray@plos.org
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
fail_unless_env_var $SSH_AGENT_PID
ssh-add /home/aperta/.ssh/id_rsa
ssh-add -l
source /usr/share/chruby/chruby.sh
cat .ruby-version
chruby `cat .ruby-version` || exit 1
fail_unless_env_var $TARGET_ENV
gem install bundler && bundle install && bundle exec cap $TARGET_ENV deploy || exit 1
EOF

