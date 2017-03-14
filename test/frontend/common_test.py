#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
POM Definition for the Tests common to all (or most) pages
"""

import logging
import os
import random
import time

from selenium.common.exceptions import TimeoutException

from Base.FrontEndTest import FrontEndTest
from Base.PostgreSQL import PgSQL
from Base.Resources import login_valid_pw, docs, users, editorial_users, external_editorial_users, \
    au_login, co_login, rv_login, ae_login, he_login, fm_login, oa_login, pdfs
from Pages.login_page import LoginPage
from Pages.akita_login_page import AkitaLoginPage
from Pages.dashboard import DashboardPage
from Pages.manuscript_viewer import ManuscriptViewerPage


class CommonTest(FrontEndTest):
  """
  Common methods for all tests
  """

  def login(self, email='', password=login_valid_pw):
    """
    Used for Native Aperta Login, when enabled.
    :param email: used to force a specific user
    :param password: pw for user
    :return: DashboardPage
    """
    logins = (au_login['user'],
              co_login['user'],
              rv_login['user'],
              ae_login['user'],
              he_login['user'],
              fm_login['user'],
              oa_login['user'],
              # sa_login['user'],
              )
    if not email:
      email = random.choice(logins)
    # Login to Aperta
    logging.info('Logging in as user: {0}'.format(email))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(email)
    login_page.enter_password_field(password)
    login_page.click_sign_in_button()
    return DashboardPage(self.getDriver())

  def cas_login(self, email='', password=login_valid_pw):
    """
    Used for NED CAS login, when enabled.
    :param email: used to force a specific user
    :param password: pw for user
    :return: DashboardPage
    """
    logins = (users + editorial_users + external_editorial_users)
    if not email:
      user = random.choice(logins)
      email = user['email']
    # Login to Aperta
    logging.info('Logging in as user: {0}'.format(email))
    login_page = LoginPage(self.getDriver())
    login_page.login_cas()
    cas_signin_page = AkitaLoginPage(self.getDriver())
    cas_signin_page.enter_login_field(email)
    cas_signin_page.enter_password_field(password)
    cas_signin_page.click_sign_in_button()
    return DashboardPage(self.getDriver())

  @staticmethod
  def select_cas_user():
    """
    A method for selecting a single CAS user when needed to track which user was chosen
    :return: selected user dictionary
    """
    cas_users = (users + editorial_users + external_editorial_users)
    user = random.choice(cas_users)
    return user

  def select_preexisting_article(self, title='Hendrik', first=False):
    """
    Select a preexisting article.
    first is true for selecting first article in list.
    init is True when the user needs to logged in
    and needs to invoke login script to reach the homepage.
    """
    dashboard_page = DashboardPage(self.getDriver())
    # Need delay to ensure articles are attached to DOM
    time.sleep(1)
    if first:
      logging.debug('Clicking first pre-existent article')
      return dashboard_page.click_on_first_manuscript()
    else:
      return dashboard_page.click_on_existing_manuscript_link_partial_title(title)

  def create_article(self, title='', journal='', type_='', document='', random_bit=False,
                     format='word'):
    """
    Create a new article. Assumes you have already launched the Create New Submission overlay.
    :param format:
    :param title: Title of the article.
    :param journal: Journal name of the article.
    :param type_: Type of article
    :param random_bit: If true, append some random string
    :param format: string indicating whether to choose word or pdf upload or randomly choose.
       Valid values: 'word' (default), pdf, any.
    :param document: Name of the document to upload. If blank will default to 'random', this will
    choose
      one of available papers
    :return title: Return the title of the article.
    """
    dashboard = DashboardPage(self.getDriver())
    # Create new submission
    title = dashboard.title_generator(prefix=title, random_bit=random_bit)
    logging.info('Creating paper in {0} journal, in {1} type with {2} as title'.format(journal,
                 type_, title))
    dashboard.enter_title_field(title)
    dashboard.select_journal_and_type(journal, type_)
    # Validate that the selected journal supports pdf if format = pdf or any
    if format in ('any', 'pdf'):
      pdf_allowed = PgSQL().query('SELECT pdf_allowed '
                                  'FROM journals '
                                  'WHERE name = %s;', (journal,))[0][0]
      if not pdf_allowed:
        raise ValueError('You specified a potential pdf upload for a journal that does not '
                      'support them: {0}'.format(journal))
    # This time helps to avoid random upload failures
    time.sleep(3)
    current_path = os.getcwd()
    # Download tests change dir to /tmp. If for some reason, they do not return to the correct
    #   directory, catch and abort - no good will follow
    assert current_path != '/tmp', 'WARN: Get current working directory returned ' \
                                   'incorrect value, aborting: {0}'.format(current_path)
    if document:
      fn = os.path.join(current_path, '{0}'.format(document))
    else:
      if format == 'word':
        doc2upload = random.choice(docs)
      elif format == 'pdf':
        doc2upload = random.choice(pdfs)
      elif format == 'any':
        doc2upload = random.choice(docs + pdfs)
      fn = os.path.join(current_path, '{0}'.format(doc2upload))
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-files').\
      send_keys(fn)
    # Time needed for script execution.
    time.sleep(7)
    return title

  def check_article(self, title, user='sealresq+1000@gmail.com'):
    """Check if article is in the dashboard"""
    dashboard = self.login(email=user)
    submitted_papers = dashboard._get(dashboard._submitted_papers)
    return True if title in submitted_papers.text else False

  def check_article_access(self, paper_url):
    """
    Check if current logged user has access to given article
    :paper_url: String with the paper url. Eg: http://aperta.tech/papers/22
    Returns True if the user has access and False when not
    """
    self._driver.get(paper_url)
    ms_page = ManuscriptViewerPage(self.getDriver())
    # change timeout
    ms_page.set_timeout(10)
    try:
      ms_page._get(ms_page._paper_title)
      ms_page.restore_timeout()
      return True
    except TimeoutException:
      ms_page.restore_timeout()
      return False

  @staticmethod
  def set_editors_in_db(paper_id):
    """
    Set up a handling editor, academic editor and cover editor for a given paper.
    Also set up Freelance editor role (journal scope) for Cover Editor and Handling Editor
    This is used for seeding data in new environments.
    :paper_id: Integer with the paper id
    Returns None
    """
    # Set up a handling editor, academic editor and cover editor for this paper
    wombat_journal_id = PgSQL().query('SELECT id FROM journals WHERE name = \'PLOS Wombat\';')[0][0]
    handling_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                 'name = \'Handling Editor\';',
                                                 (wombat_journal_id,))[0][0]
    cover_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                              'name = \'Cover Editor\';',
                                              (wombat_journal_id,))[0][0]
    academic_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                 'name = \'Academic Editor\';',
                                                 (wombat_journal_id,))[0][0]

    handedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'ahandedit\';')[0][0]
    covedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'acoveredit\';')[0][0]
    acadedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'aacadedit\';')[0][0]

    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (handedit_user_id, handling_editor_role_for_env, paper_id))
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (covedit_user_id, cover_editor_role_for_env, paper_id))
    PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Paper\', now(), now());',
                   (acadedit_user_id, academic_editor_role_for_env, paper_id))

  @staticmethod
  def set_staff_in_db():
    """
    Set up a internal editor, staff admin, billing_staff, publishing services and production staff
      for a given journal.
    This supports seeding data in a new environment
    Returns None
    """
    # Set up a handling editor, academic editor and cover editor for this paper
    wombat_journal_id = PgSQL().query('SELECT id FROM journals WHERE name = \'PLOS Wombat\';')[0][0]
    internal_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                 'name = \'Internal Editor\';',
                                                 (wombat_journal_id,))[0][0]
    staff_admin_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                             'name = \'Staff Admin\';',
                                             (wombat_journal_id,))[0][0]
    billstaff_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                             'name = \'Billing Staff\';',
                                             (wombat_journal_id,))[0][0]
    pubsvcs_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                         'name = \'Publishing Services\';',
                                         (wombat_journal_id,))[0][0]
    prodstaff_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                           'name = \'Production Staff\';',
                                           (wombat_journal_id,))[0][0]

    intedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'aintedit\';')[0][0]
    staffadm_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'astaffadmin\';')[0][0]
    billstaff_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'abillstaff\';')[0][0]
    pubsvcs_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'apubsvcs\';')[0][0]
    prodstaff_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'aprodstaff\';')[0][0]

    # test if assignment already exists, add it NOT present
    try:
      intedit_role_exists = PgSQL().query('SELECT roles.name '
                                          'FROM assignments '
                                          'JOIN roles ON roles.id = assignments.role_id '
                                          'WHERE assignments.user_id=%s '
                                          'AND roles.name=\'Internal Editor\' '
                                          'AND assignments.assigned_to_type=\'Journal\';',
                                          (intedit_user_id,))[0][0]
      logging.info('Internal editor assignment already exists')
    except IndexError:
      logging.info('Internal Editor user lack Internal Editor role. Adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                   'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                   (intedit_user_id, internal_editor_role_for_env, wombat_journal_id))

    try:
      staffadm_role_exists = PgSQL().query('SELECT roles.name '
                                          'FROM assignments '
                                          'JOIN roles ON roles.id = assignments.role_id '
                                          'WHERE assignments.user_id=%s '
                                          'AND roles.name=\'Staff Admin\' '
                                          'AND assignments.assigned_to_type=\'Journal\';',
                                          (staffadm_user_id,))[0][0]
      logging.info('Staff Admin assignment already exists')
    except IndexError:
      logging.info('Staff Admin user lack Staff Admin role. Adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (staffadm_user_id, staff_admin_role_for_env, wombat_journal_id))

    try:
      billstaff_role_exists = PgSQL().query('SELECT roles.name '
                                            'FROM assignments '
                                            'JOIN roles ON roles.id = assignments.role_id '
                                            'WHERE assignments.user_id=%s '
                                            'AND roles.name=\'Billing Staff\' '
                                            'AND assignments.assigned_to_type=\'Journal\';',
                                            (billstaff_user_id,))[0][0]
      logging.info('Billing Staff assignment already exists')
    except IndexError:
      logging.info('Billing Staff user lack Billing Staff role. Adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (billstaff_user_id, billstaff_role_for_env, wombat_journal_id))

    try:
      pubsvcs_role_exists = PgSQL().query('SELECT roles.name '
                                          'FROM assignments '
                                          'JOIN roles ON roles.id = assignments.role_id '
                                          'WHERE assignments.user_id=%s '
                                          'AND roles.name=\'Publishing Services\' '
                                          'AND assignments.assigned_to_type=\'Journal\';',
                                          (pubsvcs_user_id,))[0][0]
      logging.info('Publishing Services assignment already exists')
    except IndexError:
      logging.info('Publishing Services user lack Publishing Services role. Adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (pubsvcs_user_id, pubsvcs_role_for_env, wombat_journal_id))

    try:
      prodstaff_role_exists = PgSQL().query('SELECT roles.name '
                                            'FROM assignments '
                                            'JOIN roles ON roles.id = assignments.role_id '
                                            'WHERE assignments.user_id=%s '
                                            'AND roles.name=\'Production Staff\' '
                                            'AND assignments.assigned_to_type=\'Journal\';',
                                            (prodstaff_user_id,))[0][0]
      logging.info('Production Staff assignment already exists')
    except IndexError:
      logging.info('Production Staff user lack Production Staff role. Adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (prodstaff_user_id, prodstaff_role_for_env, wombat_journal_id))


  @staticmethod
  def set_freelance_eds_in_db():
    """
    Set up a freelance editor role for cover editor and handling editor in plos wombat test journal
    This supports seeding data in a new environment
    Returns None
    """
    # Set up a handling editor, academic editor and cover editor for this paper
    wombat_journal_id = PgSQL().query('SELECT id FROM journals WHERE name = \'PLOS Wombat\';')[0][0]
    freelance_editor_role_for_env = PgSQL().query('SELECT id FROM roles WHERE journal_id = %s AND '
                                                  'name = \'Freelance Editor\';',
                                                  (wombat_journal_id,))[0][0]

    handedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'ahandedit\';')[0][0]
    covedit_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'acoveredit\';')[0][0]

    # test if assignment already exists, add it NOT present
    try:
      handedit_fe_role_exists = PgSQL().query('SELECT roles.name '
                                              'FROM assignments '
                                              'JOIN roles ON roles.id = assignments.role_id '
                                              'WHERE assignments.user_id=%s '
                                              'AND roles.name=\'Freelance Editor\' '
                                              'AND assignments.assigned_to_type=\'Journal\';',
                                              (handedit_user_id,))[0][0]
      logging.info('Handling editors\' Freelance Editor assignment already exists')
    except IndexError:
      logging.info('Handling editor user lacks Freeland Editor role, adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (handedit_user_id, freelance_editor_role_for_env, wombat_journal_id))

    try:
      covedit_fe_role_exists = PgSQL().query('SELECT roles.name '
                                             'FROM assignments '
                                             'JOIN roles ON roles.id = assignments.role_id '
                                             'WHERE assignments.user_id=%s '
                                             'AND roles.name=\'Freelance Editor\' '
                                             'AND assignments.assigned_to_type=\'Journal\';',
                                             (covedit_user_id,))[0][0]
      logging.info('Cover editor\' Freelance Editor assignment already exists')
    except IndexError:
      logging.info('Cover editor user lacks Freeland Editor role, adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, %s, \'Journal\', now(), now());',
                     (covedit_user_id, freelance_editor_role_for_env, wombat_journal_id))

  @staticmethod
  def set_site_admin_in_db():
    """
    Set up a site admin for the system
    This supports seeding data in a new environment
    Returns None
    """
    site_admin_role_for_env = PgSQL().query('SELECT id '
                                            'FROM roles '
                                            'WHERE name = \'Site Admin\';')[0][0]
    logging.info(site_admin_role_for_env)
    siteadmin_user_id = PgSQL().query('SELECT id FROM users WHERE username = \'asuperadm\';')[0][0]
    logging.info(siteadmin_user_id)
    # test if assignment already exists, add it NOT present
    try:
      x = PgSQL().query('SELECT roles.name '
                        'FROM assignments '
                        'JOIN roles ON roles.id = assignments.role_id '
                        'WHERE assignments.user_id=%s '
                        'AND roles.name=\'Site Admin\' '
                        'AND assignments.assigned_to_type=\'System\';',
                        (siteadmin_user_id,))[0][0]
      logging.info('Site Admin assignment already exists')
    except IndexError:
      logging.info('Site Admin user lacks Site Admin role, adding...')
      PgSQL().modify('INSERT INTO assignments (user_id, role_id, assigned_to_id, assigned_to_type, '
                     'created_at, updated_at) VALUES (%s, %s, 1, \'System\', now(), now());',
                     (siteadmin_user_id, site_admin_role_for_env))
