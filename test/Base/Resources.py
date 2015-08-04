#!/usr/bin/env python2
# -*- coding: utf-8 -*-
'''
This Resource File sets variables that are used in individual
test cases. It eventually should be replaced with more robust,
less static, variable definitions.
'''

# General resources
# set friendly_testhostname to 'prod' to run suite against production
# Two fields need to be changed to support running tests in your local development
# environment, first, set friendly_testhostname to localhost, then correct the
# base_url value if you are using a port or key different than 8081 and plosmatch.
'''
friendly_testhostname = 'tahitest'
friendly_testhostname = 'heroku'
if friendly_testhostname == 'prod':
  base_url = ''
elif friendly_testhostname == 'localhost':
  base_url = 'http://localhost:8081/'
else:
  base_url = 'localhost:5000/'
'''

friendly_testhostname = 'https://plos:shrimp@tahi-assess.herokuapp.com/'


# registration resources
user_email = 'admin'
user_pw= 'yetishrimp'

user_data = {'admin': {'password':'yetishrimp',
                      'email':'shrimp@mailinator.com',
                      'full_name':'AD Shrimp',
                      'password':'yetishrimp'}
                      }

login_valid_email = 'jgray@plos.org'
login_invalid_email = 'jgrey@plos.org'
login_valid_uid = 'jgray'
login_invalid_pw = 'in|fury7'
login_valid_pw = 'in|fury8'

editor_name_0='Hendrik W. van Veen'
user_email_0 = 'trash87567@ariessc.com'
editor_name_1='Anthony George'
user_email_1 = 'trash261121@ariessc.com'
user_pw_editor= 'test_password'

# Apache AuthType
#aa_username = 'plos'
#aa_password = 'shrimp'