#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This Resource File sets variables that are used in individual
test cases. It eventually should be replaced with more robust,
less static, variable definitions.
"""

from os import getenv

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


# Aperta registration resources
user_email = 'admin'
user_pw = 'yetishrimp'

user_data = {'admin': {'password':'yetishrimp',
                      'email':'shrimp@mailinator.com',
                      'full_name':'AD Shrimp',
                      'password':'yetishrimp'}
                      }

login_valid_email = 'sealresq+7@gmail.com'
login_invalid_email = 'jgrey@plos.org'
login_valid_uid = 'jgray_sa'
login_invalid_pw = 'in|fury7'
login_valid_pw = 'in|fury8'
au_login = 'jgray_author'     # author login
rv_login = 'jgray_reviewer'   # reviewer login
ae_login = 'jgray_assocedit'  # associate editor login mm permissions
he_login = 'jgray_editor'     # handling editor login amm permissions
fm_login = 'jgray_flowmgr'    # flow manager permissions
oa_login = 'jgray_oa'         # ordinary admin login
sa_login = 'jgray_sa'         # super admin login

# Define connector information for Aperta's Tahi component postgres instance
# Lean data
psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-54-163-228-35.compute-1.amazonaws.com')
psql_port = getenv('APERTA_PSQL_PORT', '5652')
psql_uname = getenv('APERTA_PSQL_USER', 'u6over81t87q49')
psql_pw = getenv('APERTA_PSQL_PW', 'pch646pphdfqog9v38otlchvvpn')
psql_db = getenv('APERTA_PSQL_DBNAME', 'd1kdmn5r5e9aj5')
# Staging data
psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-46-137-159-123.eu-west-1.compute.amazonaws.com')
psql_port = getenv('APERTA_PSQL_PORT', '5432')
psql_uname = getenv('APERTA_PSQL_USER', 'vdfcjsacderhvg')
psql_pw = getenv('APERTA_PSQL_PW', '9nRe-qddM-NdV8_h56ujh0AwN7')
psql_db = getenv('APERTA_PSQL_DBNAME', 'ddhi6454uf6kmr')

editor_name_0 = 'Hendrik W. van Veen'
user_email_0 = 'trash87567@ariessc.com'
editor_name_1 = 'Anthony George'
user_email_1 = 'trash261121@ariessc.com'
user_pw_editor = 'test_password'

# Fake affiliations
affiliation = {'institution':'Universidad Del Este', 'title': 'Dr.',
               'country':'Argentina', 'start':'12/01/2014',
               'end':'08/11/2015', 'email': 'test@test.org',
               'department':'Molecular Biology',}

# Author for Author card
author = {'first': 'Jane', 'middle': 'M', 'last': 'Doe',
          'title': 'Dr.', 'email': 'test@test.org',
          'department':'Molecular Biology', '1_institution':'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur',}
