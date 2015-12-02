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

user_data = {'admin': {'email': 'shrimp@mailinator.com',
                       'full_name': 'AD Shrimp',
                       'password': 'yetishrimp'}
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
# psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-54-163-228-35.compute-1.amazonaws.com')
# psql_port = getenv('APERTA_PSQL_PORT', '5652')
# psql_uname = getenv('APERTA_PSQL_USER', 'u6over81t87q49')
# psql_pw = getenv('APERTA_PSQL_PW', 'pch646pphdfqog9v38otlchvvpn')
# psql_db = getenv('APERTA_PSQL_DBNAME', 'd1kdmn5r5e9aj5')
# Staging data
psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-54-83-5-30.compute-1.amazonaws.com')
psql_port = getenv('APERTA_PSQL_PORT', '6262')
psql_uname = getenv('APERTA_PSQL_USER', 'u2kgbfse1i57n')
psql_pw = getenv('APERTA_PSQL_PW', 'p76is3gn1m2f557s4crfgb7l6qi')
psql_db = getenv('APERTA_PSQL_DBNAME', 'dd2kjrv61vaj33')
# Release Candidate data
# psql_hname = getenv('APERTA_PSQL_HOST', 'ec2-54-204-30-115.compute-1.amazonaws.com')
# psql_port = getenv('APERTA_PSQL_PORT', '5432')
# psql_uname = getenv('APERTA_PSQL_USER', 'ytosewhffqfypg')
# psql_pw = getenv('APERTA_PSQL_PW', 'bS0R1f6NY3-BrB70A49jOAzuTJ')
# psql_db = getenv('APERTA_PSQL_DBNAME', 'd1n1umf877c2e3')


editor_name_0 = 'Hendrik W. van Veen'
user_email_0 = 'trash87567@ariessc.com'
editor_name_1 = 'Anthony George'
user_email_1 = 'trash261121@ariessc.com'
user_pw_editor = 'test_password'

# Fake affiliations
affiliation = {'institution':'Universidad Del Este', 'title': 'Dr.',
               'country':'Argentina', 'start':'12/01/2014',
               'end':'08/11/2015', 'email': 'test@test.org',
               'department':'Molecular Biology', }

# Author for Author card
author = {'first': 'Jane', 'middle': 'M', 'last': 'Doe',
          'title': 'Dr.', 'email': 'test@test.org',
          'department':'Molecular Biology', '1_institution':'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur',}

billing_data = {'first': 'Jane', 'last': 'Doe',
          'title': 'Dr.', 'email': 'test@test.org',
          'department':'Molecular Biology', 'affiliation':'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur',
          'phone': '123-4567-8900', 'city': 'Azul',
          'state': 'CABA', 'ZIP': '12345', 'country':'Argentina'}

docs = ['10yearsRabiesSL20140723.doc',
        '11-OvCa-Collab-HeightBMI-paper-July.doc',
        '120220_PLoS_Genetics_review.docx',
        '2011_10_28_PLOS-final.doc',
        '2014_04_27 Bakowski et al main text_subm.docx',
        'Aedes hensilli vector capacity - final-3 - clean - plosntd.doc',
        'April editorial 2012.doc',
        'C6 Text Final.doc',
        'CRX.pone.0103411.docx',
        'Chemical Synthesis of Bacteriophage G4.doc',
        'Commentary Jan 19 2012.docx',
        'EGFR PLOS GENETICS.docx',
        'GIANT-gender-main_20130310.docx',
        'Hamilton_Yu_121611.doc',
        'Hotez - NTDs 2 0 shifting policy landscape PLOS NTDs figs extracted for submish.docx',
        'IPDms1 textV5.doc',
        'IPTc Review FINAL v5 100111_clean.doc',
        'Institutional Predictors - 8 14 clean copy (1)_HB_MW.docx',
        'July Blue Marble Editorial final for accept 16June.docx',
        'LifeExpectancyART10 PM RM edits_FINAL.doc',
        'Manuscript Monitoring HIV Viral Load in Resource Limited PLoSONE-1_MA 28082012.docx',
        'Manuscript revised final.doc',
        'Manuscript_resubmission_1 April2014_REVISED.docx',
        'ModularModeling-PLoSCompBioPerspective_2ndREVISION.doc',
        'Moon and Wilusz - PLoS Pearl REVISED Version FINAL 9-25.docx',
        'Ms clean.docx',
        'NF-kB-Paper_manuscript.docx',
        'NLP-PLoS4Unhighlighted.doc',
        'NMR for submission 7 Feb 2011.doc',
        'Nazzi ms def.doc',
        'NonMarked_Maxwell_PLoSBiol_060611.doc',
        'NorenzayanetalPLOS.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLOS Comp Bio Second Revision.docx',
        'PLP D-14-00383R1-7.9.14.doc',
        'PLoS - ACUDep Primary Clinical Results - version12- 6August2013 - final.docx',
        'PLoS article.doc',
        'PLosOne_Main_Body_Ravi_Bansal_Brad_REVISED.docx',
        'PNTD-D-12-00578_Revised manuscript Final_(5.9.2012).doc',
        'PONE-D-12-25504.docx',
        'PONE-D-12-27950.docx',
        'PONE-D-12-30946.doc',
        'PONE-D-13-00751.doc',
        'PONE-D-13-02344.docx',
        'PONE-D-13-04452.doc',
        'PONE-D-13-11786.doc',
        'PONE-D-13-14162.docx',
        'PONE-D-13-19782.docx',
        'PONE-D-13-38666.docx',
        'PONE-D-14-12686.docx',
        'PONE-D-14-17217.docx',
        'PPATHOGENS-D-14-01213.docx',
        'Pope et al., revised 11-12-10.docx',
        'RTN.pone.0072333.docx',
        'Revisedmanuscript11 (1).doc',
        'Rohde PLoS Pathogens.doc',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Sialyllactose_Final_PLoS.pdf',
        'Spindler_2014_rerevised.docx',
        'Stroke review resubmission4_LR.docx',
        'Text Mouillot et al. Plos Biology Final3RJ.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        'chiappini et al.doc',
        'importeddoslinefeeds.docx',
        'importedunixlinefeeds.docx',
        'iom_essay02.doc',
        'manuscript clean.doc',
        'manuscript.doc',
        'paper.bib',
        'paper.tex',
        'pgen.1004127.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'resubmission_text_ethics changed.doc',
        'sample.docx',
        'tbParBSASpl1.docx',
        ]
