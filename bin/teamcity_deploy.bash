#!/bin/bash
# It is necessary to define an environment var TARGET_ENV
#  that is one of vagrant, production, rc, ci or stage 
sudo -u aperta -i /bin/bash << "EOF"
cd %teamcity.build.checkoutDir%
export BRANCH_NAME=%teamcity.build.branch%
export VCS_NUMBER=%build.vcs.number%
echo "Deploying release..."
echo $BRANCH_NAME
echo $VCS_NUMBER
# Can't use -i as have to stay in checkout directory
# Need to set any needed vars in Parameters as env vars
eval `ssh-agent -s`
echo $SSH_AGENT_PID
ssh-add /home/aperta/.ssh/id_rsa
ssh-add -l
source /usr/share/chruby/chruby.sh
chruby `cat .ruby-version` || exit 1
gem install bundler && bundle install && bundle exec cap $TARGET_ENV deploy || exit 1
EOF
