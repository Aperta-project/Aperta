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

friendly_testhostname = 'http://ci.aperta.tech/'

local_tz = 'US/Pacific'
test_journal = 'PLOS Wombat'

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

au_login = {'user': 'jgray_author',
            'name': ''}
co_login = {'user': 'jgray_collab',
            'name': 'Jeffrey Collaborator',
            'password': login_invalid_pw}  # collaborator login
rv_login = {'user': 'jgray_reviewer',
            'name': 'Jeffrey RV Gray'}  # reviewer login
ae_login = {'user': 'jgray_assocedit'}  # associate editor login mm permissions
he_login = {'user': 'jgray_editor',
            'name': 'Jeffrey AMM Gray',
            'email': 'sealresq+4@gmail.com'}  # handling editor login amm permissions
fm_login = {'user': 'jgray_flowmgr'}   # flow manager permissions
oa_login = {'user': 'jgray_oa'}        # ordinary admin login
sa_login = {'user': 'jgray_sa'}        # super admin login

# Accounts for CAS permissions scheme
prod_verify_login = {'user'               : 'jgrayplos',
                     'name'               : 'Jeffrey Gray',
                     'initials'           : 'jgp',
                     'email'              : 'jgray@plos.org'
                     }
creator_login1 = {'user'               : 'aauthor1',
                  'name'               : 'atest author1',
                  'initials'           : 'aa1',
                  'email'              : 'sealresq+1000@gmail.com',
                  'orcidid'            : '0000-0002-3438-8942',
                  'profile_image'      : 'bohr.jpg',
                  'affiliation-name'   : 'University of Copenhagen',
                  'affiliation-dept'   : 'Physics',
                  'affiliation-title'  : 'Professor',
                  'affiliation-country': 'Denmark',
                  'affiliation-from'   : '10/07/1885',
                  'affiliation-to'     : '11/18/1962',
                  }
creator_login2 = {'user'               : 'aauthor2',
                  'name'               : 'atest author2',
                  'initials'           : 'aa2',
                  'email'              : 'sealresq+1001@gmail.com',
                  'orcidid'            : '0000-0002-5386-5943',
                  'profile_image'      : '160px-Bernado_Houssay.jpg',
                  'affiliation-name'   : 'Universidad de Buenos Aires',
                  'affiliation-dept'   : 'Medicine',
                  'affiliation-title'  : 'Dr.',
                  'affiliation-country': 'Argentina',
                  'affiliation-from'   : '04/10/1887',
                  'affiliation-to'     : '09/21/1971',
                  }
creator_login3 = {'user'               : 'aauthor3',
                  'name'               : 'atest author3',
                  'initials'           : 'aa3',
                  'email'              : 'sealresq+1002@gmail.com',
                  'orcidid'            : '0000-0003-3734-6040',
                  'profile_image'      : '220px-Ernest_Lawrence.jpg',
                  'affiliation-name'   : 'University of California, Berkeley',
                  'affiliation-dept'   : 'Physics',
                  'affiliation-title'  : 'Dr.',
                  'affiliation-country': 'United States of America',
                  'affiliation-from'   : '08/08/1901',
                  'affiliation-to'     : '08/27/1958',
                  }
creator_login4 = {'user'               : 'aauthor4',
                  'name'               : 'atest author4',
                  'initials'           : 'aa4',
                  'email'              : 'sealresq+1003@gmail.com',
                  'orcidid'            : '0000-0002-4585-6043',
                  'profile_image'      : 'varmus_postcard.jpg',
                  'affiliation-name'   : 'University of California, San Francisco',
                  'affiliation-dept'   : 'Microbiology & Immunology',
                  'affiliation-title'  : 'Dr.',
                  'affiliation-country': 'United States of America',
                  'affiliation-from'   : '12/18/1939',
                  'affiliation-to'     : 'Present',
                  }
creator_login5 = {'user'               : 'aauthor5',
                  'name'               : 'atest author5',
                  'initials'           : 'aa5',
                  'email'              : 'sealresq+1004@gmail.com',
                  'orcidid'            : '0000-0001-9057-7206',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
creator_login6 = {'user'               : 'aauthor6',
                  'name'               : 'atest author6',
                  'initials'           : 'aa6',
                  'email'              : 'sealresq+1014@gmail.com',
                  'orcidid'            : '0000-0002-4174-4562',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
creator_login7 = {'user'               : 'aauthor7',
                  'name'               : 'atest author7',
                  'initials'           : 'aa7',
                  'email'              : 'sealresq+1015@gmail.com',
                  'orcidid'            : '0000-0001-7783-4896',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
creator_login8 = {'user'               : 'aauthor8',
                  'name'               : 'atest author8',
                  'initials'           : 'aa8',
                  'email'              : 'sealresq+1016@gmail.com',
                  'orcidid'            : '0000-0002-5835-6769',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
creator_login9 = {'user'               : 'aauthor9',
                  'name'               : 'atest author9',
                  'initials'           : 'aa9',
                  'email'              : 'sealresq+1017@gmail.com',
                  'orcidid'            : '0000-0003-0264-7847',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
creator_login10 = {'user'               : u'hgrœnßmøñé',
                   'name'               : u'Hęrmänn. Grœnßmøñé',
                   'initials'           : u'HG',
                   'email'              : 'sealresq+1018@gmail.com',
                   'orcidid'            : '0000-0002-3690-7769',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login11 = {'user'               : 'aauthor11',
                   'name'               : 'atest author11',
                   'initials'           : 'aa11',
                   'email'              : 'sealresq+1019@gmail.com',
                   'orcidid'            : '0000-0003-2130-0806',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login12 = {'user'               : u'æöxfjørd',
                   'name'               : u'Ænid Öxfjørd',
                   'initials'           : u'ÆÖ',
                   'email'              : 'sealresq+1020@gmail.com',
                   'orcidid'            : '0000-0001-7138-9832',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login13 = {'user'               : 'aauthor13',
                   'name'               : 'atest author13',
                   'initials'           : 'aa13',
                   'email'              : 'sealresq+1021@gmail.com',
                   'orcidid'            : '0000-0002-5213-1315',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login14 = {'user'               : 'aauthor14',
                   'name'               : 'atest author14',
                   'initials'           : 'aa14',
                   'email'              : 'sealresq+1022@gmail.com',
                   'orcidid'            : '0000-0002-2633-0070',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login15 = {'user'               : 'aauthor15',
                   'name'               : 'atest author15',
                   'initials'           : 'aa15',
                   'email'              : 'sealresq+1023@gmail.com',
                   'orcidid'            : '0000-0002-5584-8776',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login16 = {'user'               : 'aauthor16860',
                   'name'               : 'atest author16',
                   'initials'           : 'aa16',
                   'email'              : 'sealresq+1024@gmail.com',
                   'orcidid'            : '0000-0002-1452-605X',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login17 = {'user'               : 'aauthor17',
                   'name'               : 'atest author17',
                   'initials'           : 'aa17',
                   'email'              : 'sealresq+1025@gmail.com',
                   'orcidid'            : '0000-0002-7908-5267',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login18 = {'user'               : 'aauthor18',
                   'name'               : 'atest author18',
                   'initials'           : 'aa18',
                   'email'              : 'sealresq+1026@gmail.com',
                   'orcidid'            : '0000-0002-5235-7496',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login19 = {'user'               : 'aauthor19',
                   'name'               : 'atest author19',
                   'initials'           : 'aa19',
                   'email'              : 'sealresq+1027@gmail.com',
                   'orcidid'            : '0000-0002-9668-0287',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login20 = {'user'               : 'aauthor20',
                   'name'               : 'atest author20',
                   'initials'           : 'aa20',
                   'email'              : 'sealresq+1028@gmail.com',
                   'orcidid'            : '0000-0003-3671-1317',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
# This user should never get an ORCID ID Registered or linked
creator_login21 = {'user'               : 'aauthor21',
                   'name'               : 'atest author21',
                   'initials'           : 'aa21',
                   'email'              : 'sealresq+1029@gmail.com',
                   'orcidid'            : '',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
# This user should never get an ORCID ID Registered or linked
creator_login22 = {'user'               : 'aauthor22',
                   'name'               : 'atest author22',
                   'initials'           : 'aa22',
                   'email'              : 'sealresq+1030@gmail.com',
                   'orcidid'            : '',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
creator_login23 = {'user'               : u'성민준',
                   'name'               : u'성 민준',
                   'initials'           : u'성민',
                   'email'              : 'sealresq+1031@gmail.com',
                   'orcidid'            : '0000-0001-6681-307X',
                   'profile_image'      : 'korean_flag.png',
                   'affiliation-name'   : 'Korea Science Academy of KAIST',
                   'affiliation-dept'   : 'Computer Science',
                   'affiliation-title'  : 'Associate Professor',
                   'affiliation-country': 'Korea (the Republic of)',
                   'affiliation-from'   : '01/01/2010',
                   'affiliation-to'     : 'Present',
                    }
creator_login24 = {'user'               : u'志張',
                   'name'               : u'志明 張',
                   'initials'           : u'志張',
                   'email'              : 'sealresq+1032@gmail.com',
                   'orcidid'            : '0000-0002-7119-7504',
                   'profile_image'      : 'NTPU_Logo2.jpg',
                   'affiliation-name'   : 'University of Taipei',
                   'affiliation-dept'   : 'Molecular Biology',
                   'affiliation-title'  : 'Dr.',
                   'affiliation-country': 'Taiwan',
                   'affiliation-from'   : '12/01/2014',
                   'affiliation-to'     : '08/11/2015',
                   }
creator_login25 = {'user'               : u'文孙',
                   'name'               : u'文 孙',
                   'initials'           : u'文孙',
                   'email'              : 'sealresq+1033@gmail.com',
                   'orcidid'            : '0000-0002-6327-3204',
                   'profile_image'      : 'peking_university_logo_resized-175x175.jpg',
                   'affiliation-name'   : 'Peking University',
                   'affiliation-dept'   : 'Biology',
                   'affiliation-title'  : 'Associate Professor',
                   'affiliation-country': 'China',
                   'affiliation-from'   : '01/01/2010',
                   'affiliation-to'     : 'Present',
                   }
creator_login26 = {'user'               : 'aauthor23',
                   'name'               : 'atest author23',
                   'initials'           : 'aa23',
                   'email'              : 'sealresq+1036@gmail.com',
                   'orcidid'            : '0000-0002-5502-9551',
                   'profile_image'      : '',
                   'affiliation-name'   : 'PLOS',
                   'affiliation-dept'   : '',
                   'affiliation-title'  : '',
                   'affiliation-country': '',
                   'affiliation-from'   : '',
                   'affiliation-to'     : '',
                   }
reviewer_login = {'user'               : 'areviewer',
                  'name'               : 'atest reviewer',
                  'initials'           : 'ar',
                  'email'              : 'sealresq+1005@gmail.com',
                  'orcidid'            : '0000-0002-6070-9631',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
reviewer_login2 = {'user'              : 'areviewer2',
                  'name'               : 'atest reviewer',
                  'initials'           : 'ar2',
                  'email'              : 'sealresq+1037@gmail.com',
                  'orcidid'            : '0000-0002-3410-8410',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
reviewer_login3 = {'user'              : 'areviewer3',
                  'name'               : 'atest reviewer',
                  'initials'           : 'ar3',
                  'email'              : 'sealresq+1038@gmail.com',
                  'orcidid'            : '0000-0002-1350-6890',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
staff_admin_login = {'user'               : 'astaffadmin',
                     'name'               : 'atest staffadmin',
                     'initials'           : 'ast',
                     'email'              : 'sealresq+1006@gmail.com',
                     'orcidid'            : '0000-0001-6135-4476',
                     'profile_image'      : '',
                     'affiliation-name'   : 'PLOS',
                     'affiliation-dept'   : '',
                     'affiliation-title'  : '',
                     'affiliation-country': '',
                     'affiliation-from'   : '',
                     'affiliation-to'     : '',
                     }
handling_editor_login = {'user'               : 'ahandedit',
                         'name'               : 'atest handedit',
                         'initials'           : 'ah',
                         'email'              : 'sealresq+1007@gmail.com',
                         'orcidid'            : '0000-0001-5098-2987',
                         'profile_image'      : '',
                         'affiliation-name'   : 'PLOS',
                         'affiliation-dept'   : '',
                         'affiliation-title'  : '',
                         'affiliation-country': '',
                         'affiliation-from'   : '',
                         'affiliation-to'     : '',
                         }
pub_svcs_login = {'user'               : 'apubsvcs',
                  'name'               : 'atest pubsvcs',
                  'initials'           : 'apu',
                  'email'              : 'sealresq+1008@gmail.com',
                  'orcidid'            : '0000-0002-6498-0533',
                  'profile_image'      : '',
                  'affiliation-name'   : 'PLOS',
                  'affiliation-dept'   : '',
                  'affiliation-title'  : '',
                  'affiliation-country': '',
                  'affiliation-from'   : '',
                  'affiliation-to'     : '',
                  }
academic_editor_login = {'user'               : 'aacadedit',
                         'name'               : 'atest acadedit',
                         'initials'           : 'aae',
                         'email'              : 'sealresq+1009@gmail.com',
                         'orcidid'            : '0000-0003-3638-9145',
                         'profile_image'      : '',
                         'affiliation-name'   : 'PLOS',
                         'affiliation-dept'   : '',
                         'affiliation-title'  : '',
                         'affiliation-country': '',
                         'affiliation-from'   : '',
                         'affiliation-to'     : '',
                         }
internal_editor_login = {'user'               : 'aintedit',
                         'name'               : 'atest intedit',
                         'initials'           : 'ai',
                         'email'              : 'sealresq+1010@gmail.com',
                         'orcidid'            : '0000-0002-0920-796X',
                         'profile_image'      : '',
                         'affiliation-name'   : 'PLOS',
                         'affiliation-dept'   : '',
                         'affiliation-title'  : '',
                         'affiliation-country': '',
                         'affiliation-from'   : '',
                         'affiliation-to'     : '',
                         }
super_admin_login = {'user'               : 'asuperadm',
                     'name'               : 'atest superadm',
                     'initials'           : 'asu',
                     'email'              : 'sealresq+1011@gmail.com',
                     'orcidid'            : '0000-0002-5252-774X',
                     'profile_image'      : '',
                     'affiliation-name'   : 'PLOS',
                     'affiliation-dept'   : '',
                     'affiliation-title'  : '',
                     'affiliation-country': '',
                     'affiliation-from'   : '',
                     'affiliation-to'     : '',
                     }
cover_editor_login = {'user'               : 'acoveredit',
                      'name'               : 'atest coveredit',
                      'initials'           : 'ace',
                      'email'              : 'sealresq+1012@gmail.com',
                      'orcidid'            : '0000-0001-5515-4566',
                      'profile_image'      : '',
                      'affiliation-name'   : 'PLOS',
                      'affiliation-dept'   : '',
                      'affiliation-title'  : '',
                      'affiliation-country': '',
                      'affiliation-from'   : '',
                      'affiliation-to'     : '',
                      }
prod_staff_login = {'user'               : 'aprodstaff',
                    'name'               : 'atest prodstaff',
                    'initials'           : 'apr',
                    'email'              : 'sealresq+1013@gmail.com',
                    'orcidid'            : '0000-0002-7120-5260',
                    'profile_image'      : '',
                    'affiliation-name'   : 'PLOS',
                    'affiliation-dept'   : '',
                    'affiliation-title'  : '',
                    'affiliation-country': '',
                    'affiliation-from'   : '',
                    'affiliation-to'     : '',
                    }
billing_staff_login = {'user'               : 'abillstaff',
                       'name'               : 'atest billstaff',
                       'initials'           : 'ab',
                       'email'              : 'sealresq+1034@gmail.com',
                       'orcidid'            : '0000-0002-6492-1189',
                       'profile_image'      : '',
                       'affiliation-name'   : 'PLOS',
                       'affiliation-dept'   : '',
                       'affiliation-title'  : '',
                       'affiliation-country': '',
                       'affiliation-from'   : '',
                       'affiliation-to'     : '',
                       }
jrnl_setup_adm_login = {'user'               : 'ajsadm',
                        'name'               : 'atest jsadm',
                        'initials'           : 'aj',
                        'email'              : 'sealresq+1035@gmail.com',
                        'orcidid'            : '0000-0002-0993-0066',
                        'profile_image'      : '',
                        'affiliation-name'   : 'PLOS',
                        'affiliation-dept'   : '',
                        'affiliation-title'  : '',
                        'affiliation-country': '',
                        'affiliation-from'   : '',
                        'affiliation-to'     : '',
                        }

# User groupings, users are authors, collaborators, discussion participants, etc.
users = [creator_login1,
         creator_login2,
         creator_login3,
         creator_login4,
         creator_login5,
         creator_login6,
         creator_login7,
         creator_login8,
         creator_login9,
         creator_login10,
         creator_login11,
         creator_login12,
         creator_login13,
         creator_login14,
         creator_login15,
         creator_login16,
         creator_login17,
         creator_login18,
         creator_login19,
         creator_login20,
         creator_login23,
         creator_login24,
         creator_login25,
         creator_login26,
         ]

# In order to properly exercise the tests for orcid connectivity, we should include tests with users
#   that lack an ORCID id. However, such users cannot be used in cases where the Author card needs
#   to be completed - we end up in an endless loop. Therefore, use a different set of users for
#   ORCID tests.
non_orcid_users = [creator_login21,
                   creator_login22
                   ]

# This list is a, hopefully temporary, need based on bugs in the discussion forums being unable
#   to handled non-ascii usernames in @mentions, and in floating links to discussions,
ascii_only_users = [creator_login1,
                    creator_login2,
                    creator_login3,
                    creator_login4,
                    creator_login5,
                    creator_login6,
                    creator_login7,
                    creator_login8,
                    creator_login9,
                    creator_login11,
                    creator_login13,
                    creator_login14,
                    creator_login15,
                    creator_login16,
                    creator_login17,
                    creator_login18,
                    creator_login19,
                    creator_login20,
                    creator_login21,
                    creator_login22,
                    creator_login26,
                    ]

editorial_users = [internal_editor_login,
                   staff_admin_login,
                   super_admin_login,
                   prod_staff_login,
                   pub_svcs_login,
                   ]

external_editorial_users = [cover_editor_login,
                            handling_editor_login,
                            academic_editor_login,
                            ]

admin_users = [staff_admin_login,
               super_admin_login,
               ]

reviewer_users = [reviewer_login,
                  reviewer_login2,
                  reviewer_login3,
                  ]

all_orcid_users = [
                   creator_login1,
                   creator_login2,
                   creator_login3,
                   creator_login4,
                   creator_login5,
                   creator_login6,
                   creator_login7,
                   creator_login8,
                   creator_login9,
                   creator_login10,
                   creator_login11,
                   creator_login12,
                   creator_login13,
                   creator_login14,
                   creator_login15,
                   creator_login16,
                   creator_login17,
                   creator_login18,
                   creator_login19,
                   creator_login20,
                   creator_login23,
                   creator_login24,
                   creator_login25,
                   creator_login26,
                   internal_editor_login,
                   staff_admin_login,
                   prod_staff_login,
                   pub_svcs_login,
                   cover_editor_login,
                   handling_editor_login,
                   academic_editor_login,
                   billing_staff_login,
                   jrnl_setup_adm_login,
                   reviewer_login,
                   reviewer_login2,
                   reviewer_login3,
                  ]
# anyone can be a discussion_participant
# everyone has a user role for their own profile page

# NED Country List
country_list = [u'Andorra',
                u'United Arab Emirates',
                u'Afghanistan',
                u'Antigua and Barbuda',
                u'Anguilla',
                u'Albania',
                u'Armenia',
                u'Angola',
                u'Antarctica',
                u'Argentina',
                u'American Samoa',
                u'Austria',
                u'Australia',
                u'Aruba',
                u'Åland Islands',
                u'Azerbaijan',
                u'Bosnia and Herzegovina',
                u'Barbados',
                u'Bangladesh',
                u'Belgium',
                u'Burkina Faso',
                u'Bulgaria',
                u'Bahrain',
                u'Burundi',
                u'Benin',
                u'Saint Barthélemy',
                u'Bermuda',
                u'Brunei Darussalam',
                u'Bolivia (Plurinational State of)',
                u'Bonaire, Sint Eustatius and Saba',
                u'Brazil',
                u'Bahamas',
                u'Bhutan',
                u'Bouvet Island',
                u'Botswana',
                u'Belarus',
                u'Belize',
                u'Canada',
                u'Cocos (Keeling) Islands',
                u'Congo (the Democratic Republic of the)',
                u'Central African Republic',
                u'Congo',
                u'Switzerland',
                u'Côte d\'Ivoire',
                u'Cook Islands',
                u'Chile',
                u'Cameroon',
                u'China',
                u'Colombia',
                u'Costa Rica',
                u'Cuba',
                u'Cabo Verde',
                u'Curaçao',
                u'Christmas Island',
                u'Cyprus',
                u'Czech Republic',
                u'Germany',
                u'Djibouti',
                u'Denmark',
                u'Dominica',
                u'Dominican Republic',
                u'Algeria',
                u'Ecuador',
                u'Estonia',
                u'Egypt',
                u'Western Sahara',
                u'Eritrea',
                u'Spain',
                u'Ethiopia',
                u'Finland',
                u'Fiji',
                u'Falkland Islands (Malvinas)',
                u'Micronesia (Federated States of)',
                u'Faroe Islands',
                u'France',
                u'Gabon',
                u'United Kingdom of Great Britain and Northern Ireland',
                u'Grenada',
                u'Georgia',
                u'French Guiana',
                u'Guernsey',
                u'Ghana',
                u'Gibraltar',
                u'Greenland',
                u'Gambia',
                u'Guinea',
                u'Guadeloupe',
                u'Equatorial Guinea',
                u'Greece',
                u'South Georgia and the South Sandwich Islands',
                u'Guatemala',
                u'Guam',
                u'Guinea-Bissau',
                u'Guyana',
                u'Hong Kong',
                u'Heard Island and McDonald Islands',
                u'Honduras',
                u'Croatia',
                u'Haiti',
                u'Hungary',
                u'Indonesia',
                u'Ireland',
                u'Israel',
                u'Isle of Man',
                u'India',
                u'British Indian Ocean Territory',
                u'Iraq',
                u'Iran (Islamic Republic of)',
                u'Iceland',
                u'Italy',
                u'Jersey',
                u'Jamaica',
                u'Jordan',
                u'Japan',
                u'Kenya',
                u'Kyrgyzstan',
                u'Cambodia',
                u'Kiribati',
                u'Comoros',
                u'Saint Kitts and Nevis',
                u'Korea (the Democratic People\'s Republic of)',
                u'Korea (the Republic of)',
                u'Kuwait',
                u'Cayman Islands',
                u'Kazakhstan',
                u'Lao People\'s Democratic Republic',
                u'Lebanon',
                u'Saint Lucia',
                u'Liechtenstein',
                u'Sri Lanka',
                u'Liberia',
                u'Lesotho',
                u'Lithuania',
                u'Luxembourg',
                u'Latvia',
                u'Libya',
                u'Morocco',
                u'Monaco',
                u'Moldova (the Republic of)',
                u'Montenegro',
                u'Saint Martin (French part)',
                u'Madagascar',
                u'Marshall Islands',
                u'Macedonia (the former Yugoslav Republic of)',
                u'Mali',
                u'Myanmar',
                u'Mongolia',
                u'Macao',
                u'Northern Mariana Islands',
                u'Martinique',
                u'Mauritania',
                u'Montserrat',
                u'Malta',
                u'Mauritius',
                u'Maldives',
                u'Malawi',
                u'Mexico',
                u'Malaysia',
                u'Mozambique',
                u'Namibia',
                u'New Caledonia',
                u'Niger',
                u'Norfolk Island',
                u'Nigeria',
                u'Nicaragua',
                u'Netherlands',
                u'Norway',
                u'Nepal',
                u'Nauru',
                u'Niue',
                u'New Zealand',
                u'Oman',
                u'Panama',
                u'Peru',
                u'French Polynesia',
                u'Papua New Guinea',
                u'Philippines',
                u'Pakistan',
                u'Poland',
                u'Saint Pierre and Miquelon',
                u'Pitcairn',
                u'Puerto Rico',
                u'Palestine, State of',
                u'Portugal',
                u'Palau',
                u'Paraguay',
                u'Qatar',
                u'Réunion',
                u'Romania',
                u'Serbia',
                u'Russian Federation',
                u'Rwanda',
                u'Saudi Arabia',
                u'Solomon Islands',
                u'Seychelles',
                u'Sudan',
                u'Sweden',
                u'Singapore',
                u'Saint Helena, Ascension and Tristan da Cunha',
                u'Slovenia',
                u'Svalbard and Jan Mayen',
                u'Slovakia',
                u'Sierra Leone',
                u'San Marino',
                u'Senegal',
                u'Somalia',
                u'Suriname',
                u'South Sudan',
                u'Sao Tome and Principe',
                u'El Salvador',
                u'Sint Maarten (Dutch part)',
                u'Syrian Arab Republic',
                u'Swaziland',
                u'Turks and Caicos Islands',
                u'Chad',
                u'French Southern Territories',
                u'Togo',
                u'Thailand',
                u'Tajikistan',
                u'Tokelau',
                u'Timor-Leste',
                u'Turkmenistan',
                u'Tunisia',
                u'Tonga',
                u'Turkey',
                u'Trinidad and Tobago',
                u'Tuvalu',
                u'Taiwan',
                u'Tanzania, United Republic of',
                u'Ukraine',
                u'Uganda',
                u'United States Minor Outlying Islands',
                u'United States of America',
                u'Uruguay',
                u'Uzbekistan',
                u'Holy See',
                u'Saint Vincent and the Grenadines',
                u'Venezuela (Bolivarian Republic of)',
                u'Virgin Islands (British)',
                u'Virgin Islands (U.S.)',
                u'Viet Nam',
                u'Vanuatu',
                u'Wallis and Futuna',
                u'Samoa',
                u'Yemen',
                u'Mayotte',
                u'South Africa',
                u'Zambia',
                u'Zimbabwe',
                ]

#Define FTP connection Information for APEX
APEX_FTP_USER, APEX_FTP_PASS = getenv('APEX_FTP_CREDENTIALS', 'user:password').split(':')
APEX_FTP_DOMAIN = getenv('APEX_FTP_DOMAIN', 'delivery-test.plos.org')
APEX_FTP_DIR = getenv('APEX_FTP_DIR', 'aperta2apextest')

# Define connector information for Aperta's Tahi component postgres instance
# NOTA BENE: Production data should NEVER be included in this file.
# DEV/CI
psql_hname = getenv('APERTA_PSQL_HOST', 'db-aperta-201.soma.plos.org')
# QA/RC
# psql_hname = getenv('APERTA_PSQL_HOST', 'db-aperta-301.soma.plos.org')
# Stage
# psql_hname = getenv('APERTA_PSQL_HOST', 'db-aperta-stage.soma.plos.org')
# Global
psql_port = getenv('APERTA_PSQL_PORT', '5432')
psql_uname = getenv('APERTA_PSQL_USER', 'tahi')
psql_pw = getenv('APERTA_PSQL_PW', '')
psql_db = getenv('APERTA_PSQL_DBNAME', 'tahi')

editor_name_0 = 'Hendrik W. van Veen'
user_email_0 = 'trash87567@ariessc.com'
editor_name_1 = 'Anthony George'
user_email_1 = 'trash261121@ariessc.com'
user_pw_editor = 'test_password'

# Author for Author card
author = {'first': 'Jane',
          'middle': 'M',
          'last': 'Doe',
          'initials': 'JMD',
          'title': 'Dr.',
          'email': 'test@test.org',
          'department': 'Molecular Biology',
          '1_institution': 'Universidad Del Este',
          '2_institution': 'Universidad Nacional del Sur'}

group_author = {'group_name': 'Rebel Alliance',
                'group_inits': 'RA',
                'first': 'Jackson',
                'middle': 'V',
                'last': 'Stoeffer',
                'email': 'test@test.org'}

billing_data = {'first': 'Jane',
                'last': 'Doe',
                'title': 'Dr.',
                'email': 'test@test.org',
                'department': 'Molecular Biology',
                'affiliation': 'Universidad Del Este',
                '2_institution': 'Universidad Nacional del Sur',
                'address1': 'Codoba 2231',
                'phone': '123-4567-8900',
                'city': 'Azul',
                'state': 'CABA',
                'ZIP': '12345',
                'country': 'Argentina'}

# Generally, a random choice is made from among these documents when we create a new manuscript in
#   the test suite.
docs = \
  ['frontend/assets/docs/ANATOMICAL_BRAIN_IMAGES_ALONE_CAN_ACCURATELY_DIAGNOSE_NEUROPSYCHIATRIC_'
   'ILLNESSES.docx',
   'frontend/assets/docs/A_Division_in_PIN-Mediated_Auxin_Patterning_During_Organ_Initiation_in_'
   'Grasses.docx',
   'frontend/assets/docs/A_Novel_Alpha_Kinase_EhAK1_Phosphorylates_Actin_and_Regulates_'
   'Phagocytosis_in_.docx',
   'frontend/assets/docs/A_Systematic_Review_and_Meta-analysis_of_the_Efficacy_and_Safety_of_'
   'Intermittent_.doc',
   'frontend/assets/docs/A_laboratory_critical_incident_and_error_reporting_system_for_'
   'experimental_.docx',
   'frontend/assets/docs/A_reappraisal_of_how_to_build_modular_reusable_models_of_biological_'
   'systems.doc',
   'frontend/assets/docs/A_unified_framework_for_partitioning_biological_diversity.docx',
   'frontend/assets/docs/Abby_normal_Contextual_Modulation.docx',
   'frontend/assets/docs/Abnormal_Contextual_Modulation_of_Visual_Contour_Detection_in_Patients_'
   'with_.docx',
   'frontend/assets/docs/Abundance_of_commercially_important_reef_fish_indicates_different_levels_'
   'of_.docx',
   'frontend/assets/docs/Actin_turnover_in_lamellipodial_fragments.DOCX',
   'frontend/assets/docs/Acupuncture_and_Counselling_for_Depression_in_Primary_Care_a_Randomised_'
   'Controlled.docx',
   'frontend/assets/docs/Adaptation_to_Temporally_Fluctuating_Environments_by_the_Evolution_of_'
   'Maternal_.docx',
   'frontend/assets/docs/Aedes_hensilli_as_a_Potential_Vector_of_Chikungunya_and_Zika_Viruses.doc',
   'frontend/assets/docs/AgMicrobiomesSynthesisPaperRevision_2_21_17_IB.docx',
   'frontend/assets/docs/Alternative_Immunomodulatory_Strategies_for_Xenotransplantation_'
   'CD80_CD86-CTLA4_.doc',
   'frontend/assets/docs/An_In-Depth_Analysis_of_a_Piece_of_Shit_Distribution_of_Schistosoma_'
   'mansoni_and_.doc',
   'frontend/assets/docs/Antibiotic_prescription_for_COPD_exacerbations_admitted_to_hospital_'
   'European_COPD_.docx',
   'frontend/assets/docs/Association_of_Medical_Students_Reports_of_Interactions_with_the_'
   'Pharmaceutical_and_.docx',
   'frontend/assets/docs/Benefit_from_B-lymphocyte_Depletion_using_the_Anti-CD20_Antibody_'
   'Rituximab_in_Chronic.doc',
   'frontend/assets/docs/Beyond_the_Whole-Genome_Duplication_Phylogenetic_Evidence_for_an_'
   'Ancient_.docx',
   'frontend/assets/docs/Blue_Marble_Health_A_Call_for_Papers.docx',
   'frontend/assets/docs/Budding_Yeast_a_Simple_Model_for_Complex_Traits.docx',
   'frontend/assets/docs/Caloric_Restriction_Regulates_Stem_Cell_Homeostasis_Promoting_'
   'Enhanced_.docx',
   'frontend/assets/docs/Chemical_Synthesis_of_Bacteriophage_G4.doc',
   'frontend/assets/docs/Chikungunya_Disease_Infection-Associated_Markers_from_the_Acute_to_the_'
   'Chronic_Phase_.doc',
   'frontend/assets/docs/Chromosome_X-wide_association_study_identifies_loci_for_fasting_insulin_'
   'and_height_.docx',
   'frontend/assets/docs/Clinical_trial_data_open_for_all_A_regulators_view.doc',
   'frontend/assets/docs/Cognitive_Impairment_Induced_by_Delta9-tetrahydrocannabinol_Occurs_'
   'through_.docx',
   'frontend/assets/docs/Correction_Macrophage_Control_of_Phagocytosed_Mycobacteria_Is_Increased_'
   'by_Factors_.docx',
   'frontend/assets/docs/Cytoplasmic_Viruses_Rage_Against_the_Cellular_RNA_Decay_Machine.docx',
   'frontend/assets/docs/DNA_Fragments_Assembly_Based_on_Nicking_Enzyme_System.docx',
   'frontend/assets/docs/Demographic_transition_and_the_dynamics_of_measles_in_China.docx',
   'frontend/assets/docs/Diet_shifts_provoke_complex_and_variable_changes_in_the_metabolic_'
   'networks_of_the_.docx',
   'frontend/assets/docs/Dietary_non-esterified_oleic_acid_decreases_the_jejunal_levels_of_'
   'anorectic_.docx',
   'frontend/assets/docs/Discovery_of_covalent_ligands_via_non-covalent_docking_by_dissecting_'
   'covalent_.docx',
   'frontend/assets/docs/Does_conflict_of_interest_disclosure_worsen_bias.doc',
   'frontend/assets/docs/Dynamic_Modulation_of_Mycobacterium_tuberculosis_Regulatory_Networks_'
   'During_.doc',
   'frontend/assets/docs/Effect_of_Heterogeneous_Investments_on_the_Evolution_of_Cooperation_in_'
   'Spatial_.docx',
   'frontend/assets/docs/Epidermal_Growth_Factor_Receptor-dependent_Mutual_Amplification_between_'
   'Netrin-1_.docx',
   'frontend/assets/docs/Evidence_of_a_bacterial_receptor_for_lysozyme_Binding_of_lysozyme_to_the_'
   'anti-.docx',
   'frontend/assets/docs/Expanding_the_diversity_of_mycobacteriophages_Insights_into_genome_'
   'architecture_and_.docx',
   'frontend/assets/docs/Ext_Safe_Vers_Test_1.docx',
   'frontend/assets/docs/Ext_Safe_Vers_Test_2.docx',
   'frontend/assets/docs/Ext_Safe_Vers_Test_3.docx',
   'frontend/assets/docs/Ext_Safe_Vers_Test_4.docx',
   'frontend/assets/docs/Externally_Safe_Test.docx',
   'frontend/assets/docs/Fecal_contamination_of_drinking-water_in_low_and_middle-income_countries_'
   'a_.docx',
   'frontend/assets/docs/Fitness_costs_of_noise_in_biochemical_reaction_networks_and_the_'
   'evolutionary_edited.docx',
   'frontend/assets/docs/Fitness_costs_of_noise_in_biochemical_reaction_networks_and_the_'
   'evolutionary_limits_.docx',
   'frontend/assets/docs/Gene_expression_signature_predicts_human_islet_integrity_and_transplant_'
   'functionality.docx',
   'frontend/assets/docs/Genetic_testing_for_TMEM154_mutations_associated_with_lentivirus_'
   'susceptibility_in.docx',
   'frontend/assets/docs/Genome-wide_diversity_in_the_Levant_reveals_recent_structuring_by_'
   'culture.doc',
   'frontend/assets/docs/Here_is_a_test_paper_with_some_Caption-styled_text.docx',
   'frontend/assets/docs/High_Reinfection_Rate_after_Preventive_Chemotherapy_for_Fishborne_'
   'Zoonotic_.doc',
   'frontend/assets/docs/HomeRun_Vector_Assembly_System_A_Flexible_and_Standardized_Cloning_'
   'System_for_.docx',
   'frontend/assets/docs/Honing_the_Priorities_and_Making_the_Investment_Case_for_Global_'
   'Health.docx',
   'frontend/assets/docs/HowOpenIsIt_Open_Access_Spectrum_FAQ.docx',
   'frontend/assets/docs/Human_Parvovirus_B19_Induced_Apoptotic_Bodies_Contain_Self-Altered_'
   'Antigens_edited.docx',
   'frontend/assets/docs/Human_Parvovirus_B19_Induced_Apoptotic_Bodies_Contain_Self-Altered_'
   'Antigens_that_.docx',
   'frontend/assets/docs/Identification_of_a_Major_Phosphopeptide_in_Human_Tristetraprolin_by_'
   'Phosphopeptide_.docx',
   'frontend/assets/docs/Impairment_of_TrkB-PSD-95_signaling_in_Angelman_Syndrome.doc',
   'frontend/assets/docs/Improved_glomerular_filtration_rate_estimation_by_artificial_neural_'
   'network.doc',
   'frontend/assets/docs/Interplay_between_BRCA1_and_RHAMM_Regulates_Epithelial_Apicobasal_'
   'Polarization_and_.doc',
   'frontend/assets/docs/Life_Expectancies_of_South_African_Adults_Starting_Antiretroviral_'
   'Treatment_.doc',
   'frontend/assets/docs/Mentalizing_Deficits_Constrain_Belief_in_a_Personal_God.docx',
   'frontend/assets/docs/Microbial_Hub_Taxa_Link_Host_and_Abiotic_Factors_to_Plant_Microbiome_'
   'Variation.docx',
   'frontend/assets/docs/Modifier_genes_and_the_plasticity_of_genetic_networks_in_mice.doc',
   'frontend/assets/docs/Modulation_of_Cortical_Oscillations_by_Low-Frequency_Direct_Cortical_'
   'Stimulation_is_.docx',
   'frontend/assets/docs/Multidrug-resistant_tuberculosis_treatment_regimens_and_patient_'
   'outcomes.doc',
   'frontend/assets/docs/Musical_Training_Modulates_Listening_Strategies_Evidence_for_'
   'Action-based_.docx',
   'frontend/assets/docs/NTDs_V.2.0_Blue_Marble_Health-Neglected_Tropical_Disease_Control_and_'
   'Elimination_in_.docx',
   'frontend/assets/docs/Neonatal_mortality_rates_for_193_countries_in_2009_with_trends_since_'
   '1990_progress_.doc',
   'frontend/assets/docs/Neural_phase_locking_predicts_BOLD_response_in_human_auditory_'
   'cortex.docx',
   'frontend/assets/docs/New_material_of_Beelzebufo_a_hyperossified-frog_Amphibia_Anura_from_the_'
   'Late-.docx',
   'frontend/assets/docs/OVARIAN_CANCER_AND_BODY_SIZE.doc',
   'frontend/assets/docs/Parallel_evolution_of_HIV-1_in_a_long-term_experiment-with_caption_'
   'style_removed.docx',
   'frontend/assets/docs/Polymorphisms_in_genes_involved_in_the_NF-KB_signalling_pathway_are_'
   'associated_with_.docx',
   'frontend/assets/docs/Potential_role_of_M._tuberculosis_specific_IFN-_and_IL-2_ELISPOT_'
   'assays_in_.doc',
   'frontend/assets/docs/Preclinical_Applications_of_3-Deoxy-3-18F_Fluorothymidine_in_Oncology-'
   'A_Systematic_.docx',
   'frontend/assets/docs/Probing_the_anti-obesity_effect_of_grape_seed_extracts_reveals_that_'
   'purified_.docx',
   'frontend/assets/docs/Promoter_sequence_determines_the_relationship_between_expression_level_'
   'and_noise.doc',
   'frontend/assets/docs/Protonic_Faraday_cage_effect_of_cell_envelopes_protects_microorganisms_'
   'from_.docx',
   'frontend/assets/docs/Rare_species_support_semi-vulnerable_functions_in_high-diversity_'
   'ecosystems.docx',
   'frontend/assets/docs/Rare_species_support_semi-vulnerable_functions_in_high-diversity_'
   'ecosystems_edited.docx',
   'frontend/assets/docs/Reduction_of_the_Cholesterol_Sensor_SCAP_in_the_Brains_of_Mice_Causes_'
   'Impaired_.doc',
   'frontend/assets/docs/Relative_impact_of_multimorbid_chronic_conditions_on_health-related_'
   'quality_of_life-.doc',
   'frontend/assets/docs/Remotely_sensed_high-resolution_global_cloud_dynamics_for_predicting_'
   'ecosystem_and_.docx',
   'frontend/assets/docs/Research_Chimpanzees_May_Get_a_Break.doc',
   'frontend/assets/docs/Retraction_Polymorphism_of_9p21.3_Locus_Associated_with_5-Year_Survival_'
   'in_High-.docx',
   'frontend/assets/docs/Retraction_Polymorphism_of_9p21.3_Locus_Associated_with_5-Year_Survival_'
   'in_edited.docx',
   'frontend/assets/docs/Rnf165_Ark2C_Enhances_BMP-Smad_Signaling_to_Mediate_Motor_Axon_'
   'Extension.docx',
   'frontend/assets/docs/Schmallenberg_Virus_Pathogenesis_Tropism_and_Interaction_With_the_Innate_'
   'Immune_.doc',
   'frontend/assets/docs/Scientific_Prescription_to_Avoid_Dangerous_Climate_Change_to_Protect_'
   'Young_People_.docx',
   'frontend/assets/docs/Serological_Evidence_of_Ebola_Virus_Infection_in_Indonesian_'
   'Orangutans.doc',
   'frontend/assets/docs/Sex-stratified_genome-wide_association_studies_including_270000_'
   'individuals_show_.docx',
   'frontend/assets/docs/Sliding_rocks_on_Racetrack_Playa_Death_Valley_National_Park_first_'
   'observation_of_.docx',
   'frontend/assets/docs/Social_network_analysis_shows_direct_evidence_for_social_transmission_of_'
   'tool_use_.docx',
   'frontend/assets/docs/Standardized_Assessment_of_Biodiversity_Trends_in_Tropical_Forest_'
   'Protected_Areas_.docx',
   'frontend/assets/docs/Stat_and_Erk_signalling_superimpose_on_a_GTPase_network_to_promote_'
   'dynamic_Escort_.docx',
   'frontend/assets/docs/Structural_Basis_for_the_Recognition_of_Human_Cytomegalovirus_'
   'Glycoprotein_B_by_a_.docx',
   'frontend/assets/docs/Structural_mechanism_of_ER_retrieval_of_MHC_class_I_by_cowpox.docx',
   'frontend/assets/docs/Synergistic_Parasite-Pathogen_Interactions_Mediated_by_Host_Immunity_Can_'
   'Drive_the_.doc',
   'frontend/assets/docs/TOLL-LIKE_RECEPTOR_8_AGONIST_AND_BACTERIA_TRIGGER_POTENT_ACTIVATION_OF_'
   'INNATE_.docx',
   'frontend/assets/docs/Test_Manuscript_for_Disappearing_Figure_Legends.docx',
   'frontend/assets/docs/The_Circadian_Clock_Coordinates_Ribosome_Biogenesis_R2.doc',
   'frontend/assets/docs/The_Circadian_Clock_Coordinates_Ribosome_Biogenesis_R5.docx',
   'frontend/assets/docs/The_Epidermal_Growth_Factor_Receptor_Critically_Regulates_Endometrial_'
   'Function_.docx',
   'frontend/assets/docs/The_Impact_of_Psychological_Stress_on_Mens_Judgements_of_Female_Body_'
   'Size.docx',
   'frontend/assets/docs/The_Relationship_between_Leukocyte_Mitochondrial_DNA_Copy_Number_and_'
   'Telomere_Length_.doc',
   'frontend/assets/docs/The_earliest_evolutionary_stages_of_mitochondrial_adaptation_to_low_'
   'oxygen.docx',
   'frontend/assets/docs/The_eyes_dont_have_it_Lie_detection_and_Neuro-Linguistic_Programming.doc',
   'frontend/assets/docs/The_internal_organization_of_the_mycobacterial_partition_assembly_does_'
   'the_DNA_wrap_.docx',
   'frontend/assets/docs/The_natural_antimicrobial_carvacrol_inhibits_quorum_sensing_in_'
   'Chromobacterium_.docx',
   'frontend/assets/docs/Thresher_Sharks_Use_Tail-Slaps_as_a_Hunting_Strategy.docx',
   'frontend/assets/docs/Twelve_years_of_rabies_surveillance_in_Sri_Lanka_1999-2010.doc',
   'frontend/assets/docs/Ubiquitin-mediated_response_to_microsporidia_and_virus_infection_in-'
   'C._elegans.docx',
   'frontend/assets/docs/Uncovering_Treatment_Burden_As_A_Key_Concept_For_Stroke_Care_A_'
   'Systematic_Review_of_.docx',
   'frontend/assets/docs/Vaccinia_Virus_Protein_C6_is_a_Virulence_Factor_that_Binds_TBK-1_Adaptor_'
   'Proteins_.doc',
   'frontend/assets/docs/Why_Do_Cuckolded_Males_Provide_Paternal_Care.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_WordArt.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_Text_Box.docx',
   # APERTA-8505
   # 'frontend/assets/docs/Word_Document_with_Inserted_Object_ExcelWorksheet.docx',
   # 'frontend/assets/docs/Word_Document_with_Inserted_Object_ExcelChart.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_Object_Equation.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_File_Movie.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_File_Audio.docx',
   'frontend/assets/docs/Word_Document_with_Inserted_Equation.docx',
  ]

# Resources for future needs - we will be supporting pdf ingestion at some point
pdfs = \
  [
  'frontend/assets/pdfs/ANATOMICAL_BRAIN_IMAGES_ALONE_CAN_ACCURATELY_DIAGNOSE_NEUROPSYCHIATRIC_'
  'ILLNESSES.pdf',
  'frontend/assets/pdfs/A_Division_in_PIN-Mediated_Auxin_Patterning_During_Organ_Initiation_in_'
  'Grasses.pdf',
  'frontend/assets/pdfs/A_Novel_Alpha_Kinase_EhAK1_Phosphorylates_Actin_and_Regulates_'
  'Phagocytosis_in_.pdf',
  'frontend/assets/pdfs/A_Systematic_Review_and_Meta-analysis_of_the_Efficacy_and_Safety_of_'
  'Intermittent_.pdf',
  'frontend/assets/pdfs/A_laboratory_critical_incident_and_error_reporting_system_for_'
  'experimental_.pdf',
  'frontend/assets/pdfs/A_reappraisal_of_how_to_build_modular_reusable_models_of_biological_'
  'systems.pdf',
  'frontend/assets/pdfs/A_unified_framework_for_partitioning_biological_diversity.pdf',
  'frontend/assets/pdfs/Abby_normal_Contextual_Modulation.pdf',
  'frontend/assets/pdfs/Abnormal_Contextual_Modulation_of_Visual_Contour_Detection_in_Patients_'
  'with_.pdf',
  'frontend/assets/pdfs/Abundance_of_commercially_important_reef_fish_indicates_different_levels_'
  'of_.pdf',
  'frontend/assets/pdfs/Actin_turnover_in_lamellipodial_fragments.pdf',
  'frontend/assets/pdfs/Acupuncture_and_Counselling_for_Depression_in_Primary_Care_a_Randomised_'
  'Controlled.pdf',
  'frontend/assets/pdfs/Adaptation_to_Temporally_Fluctuating_Environments_by_the_Evolution_of_'
  'Maternal_.pdf',
  'frontend/assets/pdfs/Aedes_hensilli_as_a_Potential_Vector_of_Chikungunya_and_Zika_Viruses.pdf',
  'frontend/assets/pdfs/Alternative_Immunomodulatory_Strategies_for_Xenotransplantation_'
  'CD80_CD86-CTLA4_.pdf',
  'frontend/assets/pdfs/An_In-Depth_Analysis_of_a_Piece_of_Shit_Distribution_of_Schistosoma_'
  'mansoni_and_.pdf',
  'frontend/assets/pdfs/Antibiotic_prescription_for_COPD_exacerbations_admitted_to_hospital_'
  'European_COPD_.pdf',
  'frontend/assets/pdfs/Association_of_Medical_Students_Reports_of_Interactions_with_the_'
  'Pharmaceutical_and_.pdf',
  'frontend/assets/pdfs/Benefit_from_B-lymphocyte_Depletion_using_the_Anti-CD20_Antibody_'
  'Rituximab_in_Chronic.pdf',
  'frontend/assets/pdfs/Beyond_the_Whole-Genome_Duplication_Phylogenetic_Evidence_for_an_'
  'Ancient_.pdf',
  'frontend/assets/pdfs/Blue_Marble_Health_A_Call_for_Papers.pdf',
  'frontend/assets/pdfs/Budding_Yeast_a_Simple_Model_for_Complex_Traits.pdf',
  'frontend/assets/pdfs/Caloric_Restriction_Regulates_Stem_Cell_Homeostasis_Promoting_'
  'Enhanced_.pdf',
  'frontend/assets/pdfs/Chemical_Synthesis_of_Bacteriophage_G4.pdf',
  'frontend/assets/pdfs/Chikungunya_Disease_Infection-Associated_Markers_from_the_Acute_to_the_'
  'Chronic_Phase_.pdf',
  'frontend/assets/pdfs/Chromosome_X-wide_association_study_identifies_loci_for_fasting_insulin_'
  'and_height_.pdf',
  'frontend/assets/pdfs/Clinical_trial_data_open_for_all_A_regulators_view.pdf',
  'frontend/assets/pdfs/Cognitive_Impairment_Induced_by_Delta9-tetrahydrocannabinol_Occurs_'
  'through_.pdf',
  'frontend/assets/pdfs/Correction_Macrophage_Control_of_Phagocytosed_Mycobacteria_Is_Increased_'
  'by_Factors_.pdf',
  'frontend/assets/pdfs/Cytoplasmic_Viruses_Rage_Against_the_Cellular_RNA_Decay_Machine.pdf',
  'frontend/assets/pdfs/DNA_Fragments_Assembly_Based_on_Nicking_Enzyme_System.pdf',
  'frontend/assets/pdfs/Demographic_transition_and_the_dynamics_of_measles_in_China.pdf',
  'frontend/assets/pdfs/Diet_shifts_provoke_complex_and_variable_changes_in_the_metabolic_'
  'networks_of_the_.pdf',
  'frontend/assets/pdfs/Dietary_non-esterified_oleic_acid_decreases_the_jejunal_levels_of_'
  'anorectic_.pdf',
  'frontend/assets/pdfs/Discovery_of_covalent_ligands_via_non-covalent_docking_by_dissecting_'
  'covalent_.pdf',
  'frontend/assets/pdfs/Does_conflict_of_interest_disclosure_worsen_bias.pdf',
  'frontend/assets/pdfs/Dynamic_Modulation_of_Mycobacterium_tuberculosis_Regulatory_Networks_'
  'During_.doc',
  'frontend/assets/pdfs/Effect_of_Heterogeneous_Investments_on_the_Evolution_of_Cooperation_in_'
  'Spatial_.pdf',
  'frontend/assets/pdfs/Epidermal_Growth_Factor_Receptor-dependent_Mutual_Amplification_between_'
  'Netrin-1_.pdf',
  'frontend/assets/pdfs/Evidence_of_a_bacterial_receptor_for_lysozyme_Binding_of_lysozyme_to_the_'
  'anti-_.pdf',
  'frontend/assets/pdfs/Expanding_the_diversity_of_mycobacteriophages_Insights_into_genome_'
  'architecture_and_.pdf',
  'frontend/assets/pdfs/Externally_Safe_Test.pdf',
  'frontend/assets/pdfs/Fecal_contamination_of_drinking-water_in_low_and_middle-income_countries_'
  'a_.pdf',
  # The following two manuscripts are really unique in that they won't display/populate title
    # and abstract
  'frontend/assets/pdfs/Fitness_costs_of_noise_in_biochemical_reaction_networks_and_the_'
  'evolutionary_edited.pdf',
  'frontend/assets/pdfs/Fitness_costs_of_noise_in_biochemical_reaction_networks_and_the_'
  'evolutionary_limits_.pdf',
  'frontend/assets/pdfs/Gene_expression_signature_predicts_human_islet_integrity_and_transplant_'
  'functionality.pdf',
  'frontend/assets/pdfs/Genetic_testing_for_TMEM154_mutations_associated_with_lentivirus_'
  'susceptibility_in.pdf',
  'frontend/assets/pdfs/Genome-wide_diversity_in_the_Levant_reveals_recent_structuring_by_'
  'culture.pdf',
  'frontend/assets/pdfs/Here_is_a_test_paper_with_some_Caption-styled_text.pdf',
  'frontend/assets/pdfs/High_Reinfection_Rate_after_Preventive_Chemotherapy_for_Fishborne_'
  'Zoonotic_.pdf',
  'frontend/assets/pdfs/HomeRun_Vector_Assembly_System_A_Flexible_and_Standardized_Cloning_'
  'System_for_.pdf',
  'frontend/assets/pdfs/Honing_the_Priorities_and_Making_the_Investment_Case_for_Global_Health.pdf',
  'frontend/assets/pdfs/HowOpenIsIt_Open_Access_Spectrum_FAQ.pdf',
  'frontend/assets/pdfs/Human_Parvovirus_B19_Induced_Apoptotic_Bodies_Contain_Self-Altered_'
  'Antigens_edited.pdf',
  'frontend/assets/pdfs/Human_Parvovirus_B19_Induced_Apoptotic_Bodies_Contain_Self-Altered_'
  'Antigens_that_.pdf',
  'frontend/assets/pdfs/Identification_of_a_Major_Phosphopeptide_in_Human_Tristetraprolin_by_'
  'Phosphopeptide_.pdf',
  'frontend/assets/pdfs/Impairment_of_TrkB-PSD-95_signaling_in_Angelman_Syndrome.pdf',
  'frontend/assets/pdfs/Improved_glomerular_filtration_rate_estimation_by_artificial_neural_'
  'network.pdf',
  'frontend/assets/pdfs/Interplay_between_BRCA1_and_RHAMM_Regulates_Epithelial_Apicobasal_'
  'Polarization_and_.pdf',
  'frontend/assets/pdfs/Life_Expectancies_of_South_African_Adults_Starting_Antiretroviral_'
  'Treatment_.pdf',
  'frontend/assets/pdfs/Mentalizing_Deficits_Constrain_Belief_in_a_Personal_God.pdf',
  'frontend/assets/pdfs/Microbial_Hub_Taxa_Link_Host_and_Abiotic_Factors_to_Plant_Microbiome_'
  'Variation.pdf',
  'frontend/assets/pdfs/Modifier_genes_and_the_plasticity_of_genetic_networks_in_mice.pdf',
  'frontend/assets/pdfs/Modulation_of_Cortical_Oscillations_by_Low-Frequency_Direct_Cortical_'
  'Stimulation_is_.pdf',
  'frontend/assets/pdfs/Multidrug-resistant_tuberculosis_treatment_regimens_and_patient_'
  'outcomes.pdf',
  'frontend/assets/pdfs/Musical_Training_Modulates_Listening_Strategies_Evidence_for_'
  'Action-based_.pdf',
  'frontend/assets/pdfs/NTDs_V.2.0_Blue_Marble_Health-Neglected_Tropical_Disease_Control_and_'
  'Elimination_in_.pdf',
  'frontend/assets/pdfs/Neonatal_mortality_rates_for_193_countries_in_2009_with_trends_since_'
  '1990_progress_.pdf',
  'frontend/assets/pdfs/Neural_phase_locking_predicts_BOLD_response_in_human_auditory_cortex.pdf',
  'frontend/assets/pdfs/New_material_of_Beelzebufo_a_hyperossified-frog_Amphibia_Anura_from_the_'
  'Late-.pdf',
  'frontend/assets/pdfs/OVARIAN_CANCER_AND_BODY_SIZE.pdf',
  'frontend/assets/pdfs/Parallel_evolution_of_HIV-1_in_a_long-term_experiment-with_caption_style_'
  'removed.pdf',
  'frontend/assets/pdfs/Polymorphisms_in_genes_involved_in_the_NF-KB_signalling_pathway_are_'
  'associated_with_.pdf',
  'frontend/assets/pdfs/Potential_role_of_M._tuberculosis_specific_IFN-_and_IL-2_ELISPOT_assays_'
  'in_.pdf',
  'frontend/assets/pdfs/Preclinical_Applications_of_3-Deoxy-3-18F_Fluorothymidine_in_Oncology-A_'
  'Systematic_.pdf',
  'frontend/assets/pdfs/Probing_the_anti-obesity_effect_of_grape_seed_extracts_reveals_that_'
  'purified_.pdf',
  'frontend/assets/pdfs/Promoter_sequence_determines_the_relationship_between_expression_level_'
  'and_noise.pdf',
  'frontend/assets/pdfs/Protonic_Faraday_cage_effect_of_cell_envelopes_protects_microorganisms_'
  'from_.pdf',
  'frontend/assets/pdfs/Rare_species_support_semi-vulnerable_functions_in_high-diversity_'
  'ecosystems.pdf',
  'frontend/assets/pdfs/Rare_species_support_semi-vulnerable_functions_in_high-diversity_'
  'ecosystems_edited.pdf',
  'frontend/assets/pdfs/Reduction_of_the_Cholesterol_Sensor_SCAP_in_the_Brains_of_Mice_Causes_'
  'Impaired_.pdf',
  'frontend/assets/pdfs/Relative_impact_of_multimorbid_chronic_conditions_on_health-related_'
  'quality_of_life-.pdf',
  'frontend/assets/pdfs/Remotely_sensed_high-resolution_global_cloud_dynamics_for_predicting_'
  'ecosystem_and_.pdf',
  'frontend/assets/pdfs/Research_Chimpanzees_May_Get_a_Break.pdf',
  'frontend/assets/pdfs/Retraction_Polymorphism_of_9p21.3_Locus_Associated_with_5-Year_Survival_'
  'in_High-.pdf',
  'frontend/assets/pdfs/Retraction_Polymorphism_of_9p21.3_Locus_Associated_with_5-Year_Survival_'
  'in_edited.pdf',
  'frontend/assets/pdfs/Rnf165_Ark2C_Enhances_BMP-Smad_Signaling_to_Mediate_Motor_Axon_'
  'Extension.pdf',
  'frontend/assets/pdfs/Schmallenberg_Virus_Pathogenesis_Tropism_and_Interaction_With_the_Innate_'
  'Immune_.pdf',
  'frontend/assets/pdfs/Scientific_Prescription_to_Avoid_Dangerous_Climate_Change_to_Protect_'
  'Young_People_.pdf',
  'frontend/assets/pdfs/Serological_Evidence_of_Ebola_Virus_Infection_in_Indonesian_Orangutans.pdf',
  'frontend/assets/pdfs/Sex-stratified_genome-wide_association_studies_including_270000_'
  'individuals_show_.pdf',
  'frontend/assets/pdfs/Sliding_rocks_on_Racetrack_Playa_Death_Valley_National_Park_first_'
  'observation_of_.pdf',
  'frontend/assets/pdfs/Social_network_analysis_shows_direct_evidence_for_social_transmission_of_'
  'tool_use_.pdf',
  'frontend/assets/pdfs/Standardized_Assessment_of_Biodiversity_Trends_in_Tropical_Forest_'
  'Protected_Areas_.pdf',
  'frontend/assets/pdfs/Stat_and_Erk_signalling_superimpose_on_a_GTPase_network_to_promote_'
  'dynamic_Escort_.pdf',
  'frontend/assets/pdfs/Structural_Basis_for_the_Recognition_of_Human_Cytomegalovirus_'
  'Glycoprotein_B_by_a_.pdf',
  'frontend/assets/pdfs/Structural_mechanism_of_ER_retrieval_of_MHC_class_I_by_cowpox.pdf',
  'frontend/assets/pdfs/Synergistic_Parasite-Pathogen_Interactions_Mediated_by_Host_Immunity_Can_'
  'Drive_the_.pdf',
  'frontend/assets/pdfs/TOLL-LIKE_RECEPTOR_8_AGONIST_AND_BACTERIA_TRIGGER_POTENT_ACTIVATION_OF_'
  'INNATE_.pdf',
  'frontend/assets/pdfs/Test_Manuscript_for_Disappearing_Figure_Legends.pdf',
  'frontend/assets/pdfs/The_Circadian_Clock_Coordinates_Ribosome_Biogenesis_R2.pdf',
  'frontend/assets/pdfs/The_Circadian_Clock_Coordinates_Ribosome_Biogenesis_R5.pdf',
  'frontend/assets/pdfs/The_Epidermal_Growth_Factor_Receptor_Critically_Regulates_Endometrial_'
  'Function_.pdf',
  'frontend/assets/pdfs/The_Impact_of_Psychological_Stress_on_Mens_Judgements_of_Female_Body_'
  'Size.pdf',
  'frontend/assets/pdfs/The_Relationship_between_Leukocyte_Mitochondrial_DNA_Copy_Number_and_'
  'Telomere_Length_.pdf',
  'frontend/assets/pdfs/The_earliest_evolutionary_stages_of_mitochondrial_adaptation_to_low_'
  'oxygen.pdf',
  'frontend/assets/pdfs/The_eyes_dont_have_it_Lie_detection_and_Neuro-Linguistic_Programming.pdf',
  'frontend/assets/pdfs/The_internal_organization_of_the_mycobacterial_partition_assembly_does_the_'
  'DNA_wrap_.pdf',
  'frontend/assets/pdfs/The_natural_antimicrobial_carvacrol_inhibits_quorum_sensing_in_'
  'Chromobacterium_.pdf',
  'frontend/assets/pdfs/Thresher_Sharks_Use_Tail-Slaps_as_a_Hunting_Strategy.pdf',
  'frontend/assets/pdfs/Twelve_years_of_rabies_surveillance_in_Sri_Lanka_1999-2010.pdf',
  'frontend/assets/pdfs/Ubiquitin-mediated_response_to_microsporidia_and_virus_infection_in-C._'
  'elegans.pdf',
  'frontend/assets/pdfs/Uncovering_Treatment_Burden_As_A_Key_Concept_For_Stroke_Care_A_Systematic_'
  'Review_of_.pdf',
  'frontend/assets/pdfs/Vaccinia_Virus_Protein_C6_is_a_Virulence_Factor_that_Binds_TBK-1_Adaptor_'
  'Proteins_.pdf',
  'frontend/assets/pdfs/Why_Do_Cuckolded_Males_Provide_Paternal_Care.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_WordArt.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_Text_Box.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_Object_ExcelWorksheet.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_Object_ExcelChart.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_Object_Equation.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_File_Photo.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_File_Movie.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_File_Audio.pdf',
  'frontend/assets/pdfs/Word_Document_with_Inserted_Equation.pdf',
  ]

cover_letters = \
  ['frontend/assets/coverletters/2. User Test4_Cover Letter.docx',
   'frontend/assets/coverletters/2. User Testing3_Cover Letter 2.docx',
   'frontend/assets/coverletters/2. User Testing3_Cover Letter.docx',
   'frontend/assets/coverletters/Cover Letter R0.docx',
   # APERTA-9881
   # 'frontend/assets/coverletters/Cover Letter R2.doc',
   'frontend/assets/coverletters/Cover Letter R0 2.docx',
   'frontend/assets/coverletters/Cover Letter.docx',
   # APERTA-9881
   # 'frontend/assets/coverletters/Cover.letter.doc',
   'frontend/assets/coverletters/CoverLetter_Final.docx',
   # When we download the pdf of the coverletter, we don't seem to be setting the
   #  content type correctly - so it attempts to load into the browser instead of
   #  saving - this is leading to a failure of the MD5 comparison as we end up
   #  comparing two different files.
   # 'frontend/assets/coverletters/PONE_coverletter_v2.pdf',
  ]

# Generally, a random choice is made from among these figures when we create a new figure in
#   the test suite.
# Note that many of these are temporarily commented because of two defects: APERTA-8280, 8281
figures = [# 'frontend/assets/imgs/FIG1.TIF',
           # 'frontend/assets/imgs/FIGURE_0.TIFF',
           'frontend/assets/imgs/FIg1_2B_281_29.eps',
           'frontend/assets/imgs/FIgure_1.tif',
           # 'frontend/assets/imgs/Fig 1.eps',
           # 'frontend/assets/imgs/Fig 2.tif',
           # 'frontend/assets/imgs/Fig 3.tif',
           # 'frontend/assets/imgs/Fig 4.tif',
           # 'frontend/assets/imgs/Fig 5.tif',
           # 'frontend/assets/imgs/Fig 6.TIF',
           # 'frontend/assets/imgs/Fig 7.tif',
           # 'frontend/assets/imgs/Fig#1.tiff',
           # 'frontend/assets/imgs/Fig#12.TIFF',
           # 'frontend/assets/imgs/Fig#2.EPS',
           # 'frontend/assets/imgs/Fig#3.TIFF',
           # 'frontend/assets/imgs/Fig#8.tif',
           # 'frontend/assets/imgs/Fig+2.pngposingaseps.eps',
           'frontend/assets/imgs/Fig.13.tif',
           # 'frontend/assets/imgs/Fig.2.TIFF',
           'frontend/assets/imgs/Fig.3.eps',
           'frontend/assets/imgs/Fig.4.tif',
           'frontend/assets/imgs/Fig.9.tiff',
           # 'frontend/assets/imgs/Fig1 2.tif',
           # 'frontend/assets/imgs/Fig1 3.tif',
           # 'frontend/assets/imgs/Fig1 4.tif',
           # 'frontend/assets/imgs/Fig1 5.tif',
           # 'frontend/assets/imgs/Fig1 6.tif',
           # 'frontend/assets/imgs/Fig1 7.tif',
           'frontend/assets/imgs/Fig10.tiff',
           # 'frontend/assets/imgs/Fig11.TIF',
           # 'frontend/assets/imgs/Fig2 2.tif',
           # 'frontend/assets/imgs/Fig2 copy.tif',
           # 'frontend/assets/imgs/Fig2.TIF',
           'frontend/assets/imgs/Fig2_2B_282_29.eps',
           # 'frontend/assets/imgs/Fig3 2.tif',
           'frontend/assets/imgs/Fig3.tif',
           'frontend/assets/imgs/Fig3_2B_282_29.eps',
           # 'frontend/assets/imgs/Fig4 2.tif',
           # 'frontend/assets/imgs/Fig4 copy.tif',
           'frontend/assets/imgs/Fig4.tif',
           'frontend/assets/imgs/Fig5.tif',
           'frontend/assets/imgs/Fig5.tiff',
           # 'frontend/assets/imgs/Fig7.TIFF',
           'frontend/assets/imgs/Fig_14.tiff',
           # 'frontend/assets/imgs/Fig_2.TIF',
           'frontend/assets/imgs/Fig_3.tif',
           # 'frontend/assets/imgs/Fig_4.EPS',
           # 'frontend/assets/imgs/Figure 1 PLoS.tif',
           # 'frontend/assets/imgs/Figure 1_updated.tif',
           # 'frontend/assets/imgs/Figure 2 PLoS.tiff',
           # 'frontend/assets/imgs/Figure 2.revised.tiff',
           # 'frontend/assets/imgs/Figure 3 PLoS.tif',
           # 'frontend/assets/imgs/Figure 3.tiff',
           # 'frontend/assets/imgs/Figure 4.tiff',
           # 'frontend/assets/imgs/Figure 5.tiff',
           # 'frontend/assets/imgs/Figure 7.TIFF',
           # 'frontend/assets/imgs/Figure 7.eps',
           # 'frontend/assets/imgs/Figure#16.TIFF',
           # 'frontend/assets/imgs/Figure#4.tif',
           # 'frontend/assets/imgs/Figure#6.EPS',
           # 'frontend/assets/imgs/Figure#6.TIF',
           # 'frontend/assets/imgs/Figure+1.pngposingastiff.tif',
           'frontend/assets/imgs/Figure.17.tif',
           'frontend/assets/imgs/Figure.8.tif',
           # 'frontend/assets/imgs/Figure.9.EPS',
           'frontend/assets/imgs/Figure18.tiff',
           # 'frontend/assets/imgs/Figure2.TIFF',
           'frontend/assets/imgs/Figure5.tiff',
           'frontend/assets/imgs/Figure8.tiff',
           # 'frontend/assets/imgs/Figure_15.TIF',
           'frontend/assets/imgs/Figure_2.tif',
           # 'frontend/assets/imgs/Figure_3.TIFF',
           'frontend/assets/imgs/Figure_3.tif',
           'frontend/assets/imgs/Figure_4.tif',
           'frontend/assets/imgs/Figure_5.eps',
           'frontend/assets/imgs/Figure_5.tif',
           'frontend/assets/imgs/Figure_5.tiff',
           'frontend/assets/imgs/Figure_6.tif',
           'frontend/assets/imgs/Figure_7.tif',
           # 'frontend/assets/imgs/Kelly_Figure 9_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S1_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S2_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S3_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S4_25-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S5_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S6_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S7_23-02-13.tif',
           # 'frontend/assets/imgs/Kelly_Figure S8_23-02-13.tif',
           # Too Large
           #  'frontend/assets/imgs/StrikingImage_Seasonality.tif',
           'frontend/assets/imgs/Strikingimage.tiff',
           # 'frontend/assets/imgs/ant foraging_journal.pcbi.1002670.g003.tiff',
           'frontend/assets/imgs/ardea_herodias_lzw.tiff',
           'frontend/assets/imgs/ardea_herodias_lzw_sm.tiff',
           'frontend/assets/imgs/are_you_edible_packbits.tiff',
           'frontend/assets/imgs/cameroon_journal.pntd.0004001.g009.tiff',
           'frontend/assets/imgs/dengue virus_journal.ppat.1002631.g001.tiff',
           # 'frontend/assets/imgs/fig 1.tif',
           # 'frontend/assets/imgs/fig#1.TIF',
           # 'frontend/assets/imgs/fig+4.jpgposingastiff.tif',
           # 'frontend/assets/imgs/fig.1.TIFF',
           'frontend/assets/imgs/fig1.eps',
           'frontend/assets/imgs/fig1.tiff',
           'frontend/assets/imgs/fig2.eps',
           'frontend/assets/imgs/fig3.eps',
           'frontend/assets/imgs/fig4.eps',
           'frontend/assets/imgs/fig5.eps',
           'frontend/assets/imgs/fig6.eps',
           'frontend/assets/imgs/fig10.eps',
           # 'frontend/assets/imgs/fig+11.eps',
           'frontend/assets/imgs/fig_1.tif',
           # 'frontend/assets/imgs/figure 1.TIFF',
           # 'frontend/assets/imgs/figure#1.TIF',
           # 'frontend/assets/imgs/figure+5.jpgposingaseps.EPS',
           'frontend/assets/imgs/figure.1.tif',
           'frontend/assets/imgs/figure1.tiff',
           'frontend/assets/imgs/figure1_tiff_lzw.tiff',
           'frontend/assets/imgs/figure1_tiff_nocompress.tiff',
           'frontend/assets/imgs/figure1_tiff_packbits.tiff',
           'frontend/assets/imgs/figure1eps.eps',
           'frontend/assets/imgs/figure2_tiff_lzw.tiff',
           'frontend/assets/imgs/figure2_tiff_nocompress.tiff',
           'frontend/assets/imgs/figure2_tiff_packbits.tiff',
           'frontend/assets/imgs/figure2eps.eps',
           'frontend/assets/imgs/figure3_tiff_lzw.tiff',
           'frontend/assets/imgs/figure3_tiff_nocompress.tiff',
           'frontend/assets/imgs/figure3_tiff_packbits.tiff',
           'frontend/assets/imgs/figure3eps.eps',
           'frontend/assets/imgs/figure_1.tiff',
           # 'frontend/assets/imgs/figure_3.pngposingastiff.TIFF',
           'frontend/assets/imgs/fur_elise_nocompress.tiff',
           'frontend/assets/imgs/genetics_journal.pgen.1003059.g001.tiff',
           # 'frontend/assets/imgs/ion selectivity_journal.pbio.1002238.g005.tiff',
           'frontend/assets/imgs/jag_rtha_lzw.tiff',
           'frontend/assets/imgs/jag_rtha_nocompress.tiff',
           'frontend/assets/imgs/jag_rtha_packbits.tiff',
           # 'frontend/assets/imgs/killer whale vocalisations_journal.pone.0136535.g001.tiff',
           # 'frontend/assets/imgs/monkey brain_journal.pbio.1002245.g003.tiff',
           'frontend/assets/imgs/monkey.eps',
           'frontend/assets/imgs/monkey_lzw_compress.tiff',
           'frontend/assets/imgs/monkey_nocompress.tiff',
           'frontend/assets/imgs/monkey_packbits_compress.tiff',
           'frontend/assets/imgs/p10x.tif',
           'frontend/assets/imgs/p11x.tif',
           'frontend/assets/imgs/p1x.tif',
           'frontend/assets/imgs/p2x.tif',
           'frontend/assets/imgs/p3x.tif',
           'frontend/assets/imgs/p4x.tif',
           'frontend/assets/imgs/p5x.tif',
           'frontend/assets/imgs/p6x.tif',
           'frontend/assets/imgs/p7x.tif',
           'frontend/assets/imgs/p8x.tif',
           'frontend/assets/imgs/p9x.tif',
           # 'frontend/assets/imgs/production performance.tiff',
           # Too Large
           # 'frontend/assets/imgs/reggie-watts_15057274790_o.tif',
           'frontend/assets/imgs/snakebite_journal.pntd.0002302.g001.tiff',
           'frontend/assets/imgs/stripedshorecrab.eps',
           # 'frontend/assets/imgs/unuploadable_Fig_1.tif',
           'frontend/assets/imgs/wild rhinos_journal.pone.0136643.g001.tiff',
           ]

supporting_info_files = [
                         'frontend/assets/supportingInfo/S10_data.xlsx',
                         'frontend/assets/supportingInfo/S10_figure.TIF',
                         'frontend/assets/supportingInfo/S10_other.tiff',
                         'frontend/assets/supportingInfo/S10_table.DOC',
                         'frontend/assets/supportingInfo/S10_text.docx',
                         'frontend/assets/supportingInfo/S11_data.DOCX',
                         'frontend/assets/supportingInfo/S11_figure.TIF',
                         'frontend/assets/supportingInfo/S11_other.tiff',
                         'frontend/assets/supportingInfo/S11_table.doc',
                         'frontend/assets/supportingInfo/S11_text.doc',
                         'frontend/assets/supportingInfo/S12_data.XLS',
                         'frontend/assets/supportingInfo/S12_other.DOCX',
                         'frontend/assets/supportingInfo/S12_table.XLS',
                         'frontend/assets/supportingInfo/S12_text.docx',
                         'frontend/assets/supportingInfo/S13_other.docx',
                         'frontend/assets/supportingInfo/S13_table.DOC',
                         'frontend/assets/supportingInfo/S13_text.docx',
                         'frontend/assets/supportingInfo/S14_other.docx',
                         'frontend/assets/supportingInfo/S14_table.DOCX',
                         'frontend/assets/supportingInfo/S14_text.doc',
                         'frontend/assets/supportingInfo/S15_other.DOCX',
                         'frontend/assets/supportingInfo/S15_table.DOCX',
                         'frontend/assets/supportingInfo/S15_text.docx',
                         'frontend/assets/supportingInfo/S16_other.docx',
                         'frontend/assets/supportingInfo/S16_table.DOCX',
                         'frontend/assets/supportingInfo/S16_text.docx',
                         'frontend/assets/supportingInfo/S1_data.XLSX',
                         'frontend/assets/supportingInfo/S1_figure.TIF',
                         'frontend/assets/supportingInfo/S1_other.pdf',
                         'frontend/assets/supportingInfo/S1_table.xlsx',
                         'frontend/assets/supportingInfo/S1_text.DOCX',
                         'frontend/assets/supportingInfo/S2_data.xlsx',
                         'frontend/assets/supportingInfo/S2_figure.tif',
                         'frontend/assets/supportingInfo/S2_other.XSLX',
                         'frontend/assets/supportingInfo/S2_table.xslx',
                         'frontend/assets/supportingInfo/S2_text.DOCX',
                         'frontend/assets/supportingInfo/S3_data.CSV',
                         'frontend/assets/supportingInfo/S3_figure.tif',
                         'frontend/assets/supportingInfo/S3_other.DOCX',
                         'frontend/assets/supportingInfo/S3_table.docx',
                         'frontend/assets/supportingInfo/S3_text.DOCX',
                         'frontend/assets/supportingInfo/S4_data.xls',
                         'frontend/assets/supportingInfo/S4_figure.TIF',
                         'frontend/assets/supportingInfo/S4_other.doc',
                         'frontend/assets/supportingInfo/S4_table.docx',
                         'frontend/assets/supportingInfo/S4_text.docx',
                         'frontend/assets/supportingInfo/S5_data.CSV',
                         'frontend/assets/supportingInfo/S5_figure.TIF',
                         'frontend/assets/supportingInfo/S5_other.tar',
                         'frontend/assets/supportingInfo/S5_table.doc',
                         'frontend/assets/supportingInfo/S5_text.docx',
                         'frontend/assets/supportingInfo/S6_data.CSV',
                         'frontend/assets/supportingInfo/S6_figure.TIF',
                         'frontend/assets/supportingInfo/S6_other.mp4',
                         'frontend/assets/supportingInfo/S6_table.doc',
                         'frontend/assets/supportingInfo/S6_text.pdf',
                         'frontend/assets/supportingInfo/S7_data.txt',
                         'frontend/assets/supportingInfo/S7_figure.tif',
                         'frontend/assets/supportingInfo/S7_other.txt',
                         'frontend/assets/supportingInfo/S7_table.DOCX',
                         'frontend/assets/supportingInfo/S7_text.doc',
                         'frontend/assets/supportingInfo/S8_data.txt',
                         'frontend/assets/supportingInfo/S8_figure.tif',
                         'frontend/assets/supportingInfo/S8_other.MPEG',
                         'frontend/assets/supportingInfo/S8_table.DOCX',
                         'frontend/assets/supportingInfo/S8_text.doc',
                         'frontend/assets/supportingInfo/S9_data.txt',
                         'frontend/assets/supportingInfo/S9_figure.TIF',
                         'frontend/assets/supportingInfo/S9_other.pdf',
                         'frontend/assets/supportingInfo/S9_table.doc',
                         'frontend/assets/supportingInfo/S9_text.docx',
                         ]

# Note that this usage of task names doesn't differentiate between presentations as tasks, in the
#   accordion, and as cards, on the workflow page. This label is being used generically here.
task_names = ['Ad-hoc',
              'Additional Information',
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
              'Front Matter Reviewer Report',
              'Initial Decision',
              'Initial Tech Check',
              'Invite Academic Editor',
              'Invite Reviewers',
              'New Taxon',
              'Production Metadata',
              'Register Decision',
              'Related Articles',
              'Reporting Guidelines',
              'Reviewer Candidates',
              'Revision Tech Check',
              'Send to Apex',
              'Similarity Check',
              'Supporting Info',
              'Title And Abstract',
              'Upload Manuscript']

# The developer test journal PLOS Yeti contains a custom set of task names
yeti_task_names = ['Ad-hoc',
                   'Additional Information',
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
                   'Front Matter Reviewer Report',
                   'Initial Decision',
                   'Initial Tech Check',
                   'Invite Academic Editor',
                   'Invite Reviewers',
                   'New Taxon',
                   'Production Metadata',
                   'Register Decision',
                   'Related Articles',
                   'Reporting Guidelines',
                   'Reviewer Candidates',
                   'Revision Tech Check',
                   'Send to Apex',
                   'Similarity Check',
                   'Supporting Info',
                   'Test Task',
                   'Title And Abstract',
                   'Upload Manuscript']

# This is a list of valid paper tracker queries from which one is chosen during the test of that
#   feature.
paper_tracker_search_queries = ['1000003',
                                'Genome',
                                'DOI IS pwom',
                                'TYPE IS research',
                                'DECISION IS major revision',
                                'STATUS IS submitted',
                                'TITLE IS genome',
                                'STATUS IS rejected OR STATUS IS withdrawn',
                                '(TYPE IS NoCards OR TYPE IS OnlyInitialDecisionCard) AND '
                                '(STATUS IS rejected OR STATUS IS withdrawn)',
                                'STATUS IS NOT unsubmitted',
                                'USER aacadedit HAS ROLE academic editor',
                                'USER ahandedit HAS ANY ROLE',
                                'ANYONE HAS ROLE cover editor',
                                'USER aacadedit HAS ROLE academic editor AND STATUS IS submitted',
                                'USER areviewer HAS ROLE reviewer AND NO ONE HAS ROLE academic '
                                'editor',
                                'NO ONE HAS ROLE cover editor',
                                'VERSION DATE > 3 DAYS AGO',
                                'SUBMISSION DATE < 2 DAYS AGO',
                                'SUBMISSION DATE = 2016/10/13',
                                'VERSION DATE > 10/01/2016',
                                'SUMBISSION DATE = 09/2016',
                                'SUBMISSION DATE > last Friday',
                                'SUBMISSION DATE > November, 2015',
                                'USER me HAS ANY ROLE',
                                'TASK invite reviewers HAS OPEN INVITATIONS',
                                'ALL REVIEWS COMPLETE',
                                'NOT ALL REVIEWS COMPLETE',
                                ]

# The following MMT definitions are seed data for our integration test suite
only_init_dec_mmt = {'name'              : 'OnlyInitialDecisionCard',
                     'user_tasks'        : ['Initial Decision', 'Upload Manuscript'],
                     'staff_tasks'       : ['Assign Team', 'Editor Discussion', 'Final Tech Check',
                                            'Initial Tech Check', 'Invite Academic Editor',
                                            'Invite Reviewers', 'Register Decision',
                                            'Related Articles',
                                            'Revision Tech Check', 'Similarity Check',
                                            'Send to Apex', 'Title And Abstract'],
                     'uses_resrev_report': True
                     }
only_rev_cands_mmt = {'name'              : 'OnlyReviewerCandidates',
                      'user_tasks'        : ['Reviewer Candidates', 'Upload Manuscript'],
                      'staff_tasks'       : ['Assign Team', 'Editor Discussion', 'Final Tech Check',
                                             'Initial Tech Check', 'Invite Academic Editor',
                                             'Invite Reviewers', 'Production Metadata',
                                             'Register Decision', 'Related Articles',
                                             'Revision Tech Check', 'Send to Apex',
                                              'Similarity Check', 'Title And Abstract'],
                      'uses_resrev_report': True
                      }
front_matter_mmt = {'name'              : 'Front-Matter-type',
                    'user_tasks'        : ['Additional Information', 'Authors', 'Figures',
                                           'Supporting Info', 'Upload Manuscript'],
                    'staff_tasks'       : ['Invite Reviewers', 'Production Metadata',
                                           'Register Decision', 'Related Articles', 'Send to Apex',
                                           'Similarity Check', 'Title And Abstract'],
                    'uses_resrev_report': False
                    }
research_mmt = {'name'              : 'Research',
                'user_tasks'        : ['Authors', 'Billing', 'Cover Letter', 'Figures',
                                       'Financial Disclosure', 'Supporting Info',
                                       'Upload Manuscript'],
                'staff_tasks'       : ['Assign Team', 'Invite Academic Editor',
                                       'Invite Reviewers', 'Register Decision',
                                       'Similarity Check', 'Title And Abstract'],
                'uses_resrev_report': True
                }
resrch_w_init_dec = {'name'              : 'Research w/Initial Decision Card',
                     'user_tasks'        : ['Authors', 'Billing', 'Cover Letter', 'Figures',
                                            'Financial Disclosure', 'Supporting Info',
                                            'Upload Manuscript'],
                     'staff_tasks'       : ['Assign Team', 'Initial Decision',
                                            'Invite Academic Editor', 'Invite Reviewers',
                                            'Register Decision', 'Title And Abstract',
                                            'Similarity Check'],
                     'uses_resrev_report': True
                     }
imgs_init_dec_mmt = {'name'              : 'Images+InitialDecision',
                     'user_tasks'        : ['Figures', 'Initial Decision', 'Upload Manuscript'],
                     'staff_tasks'       : ['Assign Team', 'Editor Discussion', 'Final Tech Check',
                                            'Invite Academic Editor', 'Invite Reviewers',
                                            'Production Metadata', 'Register Decision',
                                            'Related Articles', 'Revision Tech Check',
                                            'Send to Apex', 'Similarity Check',
                                            'Title And Abstract'],
                     'uses_resrev_report': True
                     }
gen_cmplt_apexdata = {'name'              : 'generateCompleteApexData',
                      'user_tasks'        : ['Additional Information', 'Authors', 'Billing',
                                             'Competing Interests', 'Cover Letter',
                                             'Data Availability', 'Early Article Posting',
                                             'Ethics Statement', 'Figures', 'Financial Disclosure',
                                             'New Taxon', 'Reporting Guidelines',
                                             'Reviewer Candidates', 'Supporting Info',
                                             'Upload Manuscript'],
                      'staff_tasks'       : ['Assign Team', 'Editor Discussion', 'Final Tech Check',
                                             'Invite Academic Editor', 'Invite Reviewers',
                                             'Production Metadata', 'Register Decision',
                                             'Related Articles', 'Revision Tech Check',
                                             'Send to Apex', 'Similarity Check',
                                             'Title And Abstract'],
                      'uses_resrev_report': True
                      }
no_cards_mmt = {'name'              : 'NoCards',
                'user_tasks'        : ['Upload Manuscript'],
                'staff_tasks'       : ['Assign Team', 'Editor Discussion', 'Final Tech Check',
                                       'Invite Academic Editor', 'Invite Reviewers',
                                       'Production Metadata', 'Register Decision',
                                       'Related Articles', 'Revision Tech Check', 'Send to Apex',
                                       'Similarity Check', 'Title And Abstract'],
                'uses_resrev_report': True
                }
# The following MMT definitions are seed data for our lean environment
bio_essay = {'name':               'Essay',
             'user_tasks':         ['Cover Letter', 'Upload Manuscript', 'Authors',
                                    'Ethics Statement', 'Figures', 'Reviewer Candidates',
                                    'Supporting Info', 'Competing Interests',
                                    'Financial Disclosure', 'Additional Information',
                                    'Early Article Posting'],
             'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check', 'Final Tech Check',
                                    'Assign Team', 'Invite Academic Editor', 'Invite Reviewers',
                                    'Register Decision', 'Send to Apex', 'Production Metadata',
                                    'Similarity Check', 'Title And Abstract'],
             'uses_resrev_report': True
             }
bio_resart = {'name':               'Research Article',
              'user_tasks':         ['Upload Manuscript', 'Cover Letter', 'Figures',
                                     'Supporting Info', 'Additional Information',
                                     'Early Article Posting'],
              'staff_tasks':        ['Assign Team', 'Initial Decision', 'Invite Academic Editor',
                                     'Title And Abstract', 'Initial Tech Check',
                                     'Revision Tech Check', 'Final Tech Check', 'Invite Reviewers',
                                     'Register Decision', 'Production Metadata',
                                     'Similarity Check', 'Send to Apex'],
              'uses_resrev_report': True
              }
bio_genres = {'name':               'Genetics Research',
              'user_tasks':         ['Additional Information', 'Authors', 'Billing',
                                     'Competing Interests', 'Cover Letter', 'Data Availability',
                                     'Ethics Statement', 'Figures', 'Financial Disclosure',
                                     'Reporting Guidelines', 'Reviewer Candidates',
                                     'Supporting Info', 'Upload Manuscript',
                                     'Early Article Posting'],
              'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check',
                                     'Final Tech Check', 'Assign Team', 'Invite Academic Editor',
                                     'Invite Reviewers', 'Register Decision', 'Send to Apex',
                                     'Related Articles', 'Production Metadata', 'Similarity Check',
                                     'Title And Abstract'],
              'uses_resrev_report': True
              }
bio_mystery = {'name':               'Unsolved Mystery',
               'user_tasks':         ['Cover Letter', 'Upload Manuscript', 'Authors',
                                      'Ethics Statement', 'Figures', 'Reviewer Candidates',
                                      'Supporting Info', 'Competing Interests',
                                      'Financial Disclosure', 'Additional Information',
                                      'Early Article Posting'],
               'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check',
                                      'Final Tech Check', 'Assign Team', 'Invite Academic Editor',
                                      'Invite Reviewers', 'Register Decision', 'Send to Apex',
                                      'Production Metadata', 'Similarity Check',
                                      'Title And Abstract'],
               'uses_resrev_report': True
               }
bio_commpage = {'name':               'Community Page',
                'user_tasks':         ['Cover Letter', 'Upload Manuscript', 'Authors',
                                       'Ethics Statement', 'Figures', 'Reviewer Candidates',
                                       'Supporting Info', 'Competing Interests',
                                       'Financial Disclosure', 'Additional Information',
                                       'Early Article Posting'],
                'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check',
                                       'Final Tech Check', 'Invite Academic Editor',
                                       'Invite Reviewers', 'Register Decision', 'Send to Apex',
                                       'Production Metadata', 'Similarity Check',
                                       'Title And Abstract'],
                'uses_resrev_report': True
                }
bio_formcomm = {'name':               'Formal Comment',
                'user_tasks':         ['Cover Letter', 'Upload Manuscript', 'Authors',
                                       'Ethics Statement', 'Figures', 'Reviewer Candidates',
                                       'Supporting Info', 'Competing Interests',
                                       'Financial Disclosure', 'Additional Information',
                                       'Early Article Posting'],
                'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check',
                                       'Final Tech Check', 'Assign Team', 'Invite Academic Editor',
                                       'Invite Reviewers', 'Register Decision', 'Send to Apex',
                                       'Production Metadata', 'Similarity Check',
                                       'Title And Abstract'],
                'uses_resrev_report': True
                }
bio_nwc = {'name':               'New Workflow Concept',
           'user_tasks':         ['Upload Manuscript', 'Supporting Info', 'Cover Letter',
                                  'Additional Information', 'Reviewer Candidates', 'Figures',
                                  'Authors', 'Ethics Statement', 'Data Availability',
                                  'Competing Interests', 'Financial Disclosure',
                                  'Early Article Posting'],
           'staff_tasks':        ['Assign Team', 'Initial Decision', 'Title And Abstract',
                                  'Initial Tech Check', 'Invite Reviewers', 'Register Decision',
                                  'Revision Tech Check', 'Final Tech Check',
                                  'Production Metadata', 'Send to Apex', 'Related Articles',
                                  'Similarity Check'],
           'uses_resrev_report': True
           }
gen_resart = {'name':               'Research Article',
              'user_tasks':         ['Additional Information', 'Authors', 'Billing',
                                     'Competing Interests', 'Cover Letter', 'Data Availability',
                                     'Ethics Statement', 'Figures', 'Financial Disclosure',
                                     'Reporting Guidelines', 'Reviewer Candidates',
                                     'Supporting Info', 'Upload Manuscript',
                                     'Early Article Posting'],
              'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check',
                                     'Final Tech Check', 'Assign Team', 'Invite Academic Editor',
                                     'Invite Reviewers', 'Register Decision', 'Send to Apex',
                                     'Related Articles', 'Production Metadata', 'Similarity Check',
                                     'Title And Abstract'],
              'uses_resrev_report': True
              }
gen_persp = {'name':               'Perspective',
             'user_tasks':         ['Cover Letter', 'Upload Manuscript', 'Authors', 'Figures',
                                    'Supporting Info', 'Competing Interests',
                                    'Financial Disclosure', 'Additional Information',
                                    'Early Article Posting'],
             'staff_tasks':        ['Initial Tech Check', 'Revision Tech Check', 'Final Tech Check',
                                    'Assign Team', 'Invite Academic Editor', 'Register Decision',
                                    'Production Metadata', 'Send to Apex', 'Similarity Check',
                                    'Title And Abstract'],
             'uses_resrev_report': False
             }
