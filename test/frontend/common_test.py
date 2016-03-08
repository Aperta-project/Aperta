#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

"""

import logging
import os
import random
import time


from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_pw, docs, creator_login1, creator_login2, creator_login3, creator_login4, \
    creator_login5, reviewer_login, handling_editor_login, academic_editor_login, internal_editor_login, \
    staff_admin_login, pub_svcs_login, super_admin_login, cover_editor_login, au_login, co_login, rv_login, ae_login, \
  he_login, fm_login, oa_login, sa_login
from Pages.login_page import LoginPage
from Pages.akita_login_page import AkitaLoginPage
from Pages.dashboard import DashboardPage


class CommonTest(FrontEndTest):
  """
  Model an aperta page
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
    """Login into Aperta"""
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
    logins = (creator_login1['email'],
              creator_login2['email'],
              creator_login3['email'],
              creator_login4['email'],
              creator_login5['email'],
              reviewer_login['email'],
              handling_editor_login['email'],
              cover_editor_login['email'],
              academic_editor_login['email'],
              internal_editor_login['email'],
              staff_admin_login['email'],
              pub_svcs_login['email'],
              super_admin_login['email'],
              )
    if not email:
      email = random.choice(logins)
    """Login into Aperta"""
    logging.info('Logging in as user: {0}'.format(email))
    login_page = LoginPage(self.getDriver())
    login_page.login_cas()
    cas_signin_page = AkitaLoginPage(self.getDriver())
    cas_signin_page.enter_login_field(email)
    cas_signin_page.enter_password_field(password)
    cas_signin_page.click_sign_in_button()
    return DashboardPage(self.getDriver())

  def select_preexisting_article(self, title='Hendrik', init=True, first=False):
    """
    Select a preexisting article.
    first is true for selecting first article in list.
    init is True when the user needs to logged in
    and needs to invoke login script to reach the homepage.
    """
    dashboard_page = DashboardPage(self.getDriver())
    if first:
      return dashboard_page.click_on_first_manuscript()
    else:
      return dashboard_page.click_on_existing_manuscript_link_partial_title(title)

  def create_article(self, title='', journal='journal', type_='Research1',
      random_bit=False, doc='random'):
    """
    Create a new article.
    title: Title of the article.
    journal: Journal name of the article.
    type_: Type of article
    random_bit: If true, append some random string
    doc: Name of the document to upload. If blank will default to 'random', this will choose
    on of available papers
    Return the title of the article.
    """
    dashboard = DashboardPage(self.getDriver())
    # Create new submission
    title = dashboard.title_generator(prefix=title, random_bit=random_bit)
    logging.info('Creating paper in {0} journal, in {1} type with {2} as title'.format(journal,
        type_, title))
    dashboard.enter_title_field(title)
    dashboard.select_journal_and_type(journal, type_)
    # This time helps to avoid random upload failures
    time.sleep(3)

    if doc == 'random':
      doc2upload = random.choice(docs)
      fn = os.path.join(os.getcwd(), 'frontend/assets/docs/{0}'.format(doc2upload))
    else:
      fn = os.path.join(os.getcwd(),'frontend/assets/docs/{0}'.format(doc))
    logging.info('Sending document: {0}'.format(fn))
    time.sleep(1)
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    dashboard.click_upload_button()
    # Time needed for script execution.
    time.sleep(7)
    return title

  def check_article(self, title, user='sealresq+1000@gmail.com'):
    """Check if article is in the dashboard"""
    dashboard = self.login(email=user)
    submitted_papers = dashboard._get(dashboard._submitted_papers)
    return True if title in submitted_papers.text else False

  def invalidate_cas_token(self):
    """
    Currently there is a bug in the Akita code base in which the CAS token is not invalidated on logout.
    This is a temporary method that works around this bug by explicitly calling into CAS to invalidate the token.
    :return: void function
    """
    invalidation_url = 'https://cas-aperta-integration.plos.org/cas/logout'
    self._driver.get(invalidation_url)
    self._driver.navigated = True
    time.sleep(2)

  def return_to_login_page(self, login_url):
    self._driver.get(login_url)
    self._driver.navigated = True
    time.sleep(2)
