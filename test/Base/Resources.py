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


# Aperta native registration resources
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

au_login = {'user': 'jgray_author', 'name': ''}     # author login
co_login = {'user': 'jgray_collab', 'name': 'Jeffrey Collaborator',
            'password': login_invalid_pw}  # collaborator login
rv_login = {'user': 'jgray_reviewer', 'name': 'Jeffrey RV Gray'}  # reviewer login
ae_login = {'user': 'jgray_assocedit'} # associate editor login mm permissions
he_login = {'user':'jgray_editor', 'name': 'Jeffrey AMM Gray',
            'email': 'sealresq+4@gmail.com'}  # handling editor login amm permissions
fm_login = {'user': 'jgray_flowmgr'}   # flow manager permissions
oa_login = {'user': 'jgray_oa'}        # ordinary admin login
sa_login = {'user': 'jgray_sa'}        # super admin login

# Accounts for new permissions scheme
# These are NED CAS logins.
creator_login1 = {'user': 'aauthor1', 'name': 'atest author1', 'email': 'sealresq+1000@gmail.com'}
creator_login2 = {'user': 'aauthor2', 'name': 'atest author2', 'email': 'sealresq+1001@gmail.com'}
creator_login3 = {'user': 'aauthor3', 'name': 'atest author3', 'email': 'sealresq+1002@gmail.com'}
creator_login4 = {'user': 'aauthor4', 'name': 'atest author4', 'email': 'sealresq+1003@gmail.com'}
creator_login5 = {'user': 'aauthor5', 'name': 'atest author5', 'email': 'sealresq+1004@gmail.com'}
reviewer_login = {'user': 'areviewer', 'name': 'atest reviewer', 'email': 'sealresq+1005@gmail.com'}
staff_admin_login = {'user': 'astaffadmin',
                     'name': 'atest staffadmin',
                     'email': 'sealresq+1006@gmail.com'}
handling_editor_login = {'user': 'ahandedit',
                         'name': 'atest handedit',
                         'email': 'sealresq+1007@gmail.com'}
pub_svcs_login = {'user': 'apubsvcs', 'name': 'atest pubsvcs', 'email': 'sealresq+1008@gmail.com'}
academic_editor_login = {'user':'aacadedit',
                         'name': 'atest acadedit',
                         'email': 'sealresq+1009@gmail.com'}
internal_editor_login = {'user':'aintedit',
                         'name': 'atest intedit',
                         'email': 'sealresq+1010@gmail.com'}
super_admin_login = {'user':'asuperadm',
                     'name': 'atest superadm',
                     'email': 'sealresq+1011@gmail.com'}
cover_editor_login = {'user':'acoveredit',
                      'name': 'atest coveredit',
                      'email': 'sealresq+1012@gmail.com'}
prod_staff_login = {'user': 'aprodstaff',
                    'name': 'atest prodstaff',
                    'email': 'sealresq+1013@gmail.com'}
# anyone can be a discussion_participant
# everyone has a user role for their own profile page

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
author = {'first': 'Jane', 'middle': 'M', 'last': 'Doe', 'initials': 'JMD',
          'title': 'Dr.', 'email': 'test@test.org',
          'department':'Molecular Biology', '1_institution':'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur',}

group_author = {'group_name': 'Rebel Alliance', 'group_inits': 'RA',
                'first': 'Jackson', 'middle': 'V', 'last': 'Stoeffer', 'email': 'test@test.org'}

billing_data = {'first': 'Jane', 'last': 'Doe',
          'title': 'Dr.', 'email': 'test@test.org',
          'department':'Molecular Biology', 'affiliation':'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur',
          'address1': 'Codoba 2231',
          'phone': '123-4567-8900', 'city': 'Azul',
          'state': 'CABA', 'ZIP': '12345', 'country':'Argentina'}


# Note: Commented out doc until APERTA-5935 is addressed
docs = ['10yearsRabiesSL20140723.doc',
        '11-OvCa-Collab-HeightBMI-paper-July.doc',
        '120220_PLoS_Genetics_review.docx',
        '2011_10_28_PLOS-final.doc',
        '2014_04_27_Bakowski_et_al_main_text_subm.docx',
        '3.User_Testing3_MS_File.docx',
        'Aedes_hensilli_vector_capacity-final-3-clean-plosntd.doc',
        'April_editorial_2012.doc',
        'C6_Text_Final.doc',
        'CRX.pone.0103411.docx',
        'Chemical Synthesis of Bacteriophage G4.doc',
        'Commentary_Jan_19_2012.docx',
        'EGFR_PLOS_GENETICS.docx',
        'GIANT-gender-main_20130310.docx',
        'Hamilton_Yu_121611.doc',
        'Hotez-NTDs_2_0_shifting_policy_landscape_PLOS_NTDs_figs_extracted_for_submish.docx',
        'IPDms1_textV5.doc',
        'IPTc_Review_FINAL_v5_100111_clean.doc',
        'Institutional_Predictors-8-14_clean_copy_1_HB_MW.docx',
        'July_Blue_Marble_Editorial_final_for_accept_16June.docx',
        'LifeExpectancyART10_PM_RM_edits_FINAL.doc',
        'Manuscript_Monitoring_HIV_Viral_Load_in_Resource_Limited_PLoSONE-1_MA_28082012.docx',
        'ModularModeling-PLoSCompBioPerspective_2ndREVISION.doc',
        'Moon_and_Wilusz-PLoS_Pearl_REVISED_Version_FINAL_9-25.docx',
        'Ms_clean.docx',
        'NF-kB-Paper_manuscript.docx',
        'NLP-PLoS4Unhighlighted.doc',
        'NMR_for_submission_7_Feb_2011.doc',
        'Nazzi_ms_def.doc',
        'NonMarked_Maxwell_PLoSBiol_060611.doc',
        'NorenzayanetalPLOS.docx',
        'PGENETICS-D-13-02065R1_FTC.docx',
        'PLOS_Comp_Bio_Second_Revision.docx',
        'PLP_D-14-00383R1-7.9.14.doc',
        'PLoS-ACUDep_Primary_Clinical_Results-version12-6August2013-final.docx',
        'PLoS_article.doc',
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
        'Pope_et_al._revised_11-12-10.docx',
        'RTN.pone.0072333.docx',
        'RTN.pone.0072333_edited.docx',
        'Revisedmanuscript11_1.doc',
        'Rohde_PLoS_Pathogens.doc',
        'Schallmo_PLOS_RevisedManuscript.docx',
        'Schallmo_PLOS_RevisedManuscript_edited.docx',
        'Spindler_2014_rerevised.docx',
        'Stroke_review_resubmission4_LR.docx',
        'Text_Mouillot_et_al._Plos_Biology_Final3RJ.docx',
        'Text_Mouillot_et_al._Plos_Biology_Final3RJ_edited.docx',
        'Thammasri_PONE_D13_12078_wo.docx',
        'Thammasri_PONE_D13_12078_wo_edited.docx',
        'chiappini_et_al.doc',
        'importeddoslinefeeds.docx',
        'importedunixlinefeeds.docx',
        'iom_essay02.doc',
        'manuscript.doc',
        'manuscript_clean.doc',
        'pgen.1004127.docx',
        'pone.0100365.docx',
        'pone.0100948.docx',
        'ppat.1004210.docx',
        'resubmission_text_ethics_changed.doc',
        'sample.docx',
        'simpledocepsimageinline.docx',
        'simpledocjpgimageinline.docx',
        'simpledocpngimageinline.docx',
        'simpledoctiffnocompress.docx',
        'tbParBSASpl1.docx',
        ]

# Note that this usage of task names doesn't differentiate between presentations as tasks, in the accordion, and
#   as cards, on the workflow page. This label is being used generically here.
task_names = ['Ad-hoc',
              'Additional Information',
              'Assign Admin',
              'Assign Team',
              'Authors',
              'Billing',
              'Competing Interests',
              'Cover Letter',
              'Data Availability',
              'Editor Discussion',
              'Ethics Statement',
              'Figures',
              'Final Tech Check',
              'Financial Disclosure',
              'Initial Decision',
              'Initial Tech Check',
              'Invite Academic Editor',
              'Invite Reviewers',
              'New Taxon',
              'Production Metadata',
              'Register Decision',
              'Reporting Guidelines',
              'Reviewer Candidates',
              'Revision Tech Check',
              'Send to Apex',
              'Supporting Info',
              'Upload Manuscript']

yeti_task_names = ['Ad-hoc',
                   'Additional Information',
                   'Assign Admin',
                   'Assign Team',
                   'Authors',
                   'Billing',
                   'Competing Interests',
                   'Cover Letter',
                   'Data Availability',
                   'Editor Discussion',
                   'Ethics Statement',
                   'Figures',
                   'Final Tech Check',
                   'Financial Disclosure',
                   'Initial Decision',
                   'Initial Tech Check',
                   'Invite Academic Editor',
                   'Invite Reviewers',
                   'New Taxon',
                   'Production Metadata',
                   'Register Decision',
                   'Reporting Guidelines',
                   'Reviewer Candidates',
                   'Revision Tech Check',
                   'Send to Apex',
                   'Supporting Info',
                   'Test Task',
                   'Upload Manuscript']

paper_tracker_search_queries = ['0000003',
                                'Genome',
                                'DOI IS pwom',
                                'TYPE IS research',
                                'DECISION IS major revision',
                                'STATUS IS submitted',
                                'TITLE IS genome',
                                'STATUS IS rejected OR STATUS IS withdrawn',
                                'TYPE IS research AND (STATUS IS rejected OR STATUS IS withdrawn)',
                                'STATUS IS NOT unsubmitted',
                                'USER aacadedit HAS ROLE academic editor',
                                'USER ahandedit HAS ANY ROLE',
                                'ANYONE HAS ROLE cover editor',
                                'USER aacadedit HAS ROLE academic editor AND STATUS IS submitted',
                                'USER astaffadmin HAS ROLE staff admin AND NO ONE HAS ROLE '
                                'academic editor',
                                'NO ONE HAS ROLE staff admin',
                                'SUBMITTED > 3 DAYS AGO',
                                'SUBMITTED < 1 DAY AGO',
                                'USER me HAS ANY ROLE',
                                'TASK invite reviewers HAS OPEN INVITATIONS',
                                'TASK invite academic editors HAS OPEN INVITATIONS',
                                'ALL REVIEWS COMPLETE',
                                'NOT ALL REVIEWS COMPLETE'
                                ]