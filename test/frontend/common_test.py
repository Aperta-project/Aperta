#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

"""

import time
import os
import random

from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_email, login_valid_pw, docs
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage


class CommonTest(FrontEndTest):
  """
  Model an aperta paper editor page
  """

  def login(self, email=login_valid_email, password=login_valid_pw):
    """Login into Aperta"""
    print('Logging in as user: {}'.format(email))
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(email)
    login_page.enter_password_field(password)
    login_page.click_sign_in_button()
    return DashboardPage(self.getDriver())

  def select_preexisting_article(self, title='Hendrik', init=True, first=False):
    """
    Select a preexisting article.
    first is true for selecting first article in list.
    init is True when the user needs to logged in
    and needs to invoque login script to reach the homepage.
    """
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    if first:
      return dashboard.click_on_first_manuscript()
    else:
      return dashboard.click_on_existing_manuscript_link_partial_title(title)

  def create_article(self, title='', journal='journal', type_='Research1',
      random_bit=False, init=True, doc='random', user='jgray_author'):
    """
    Create a new article.
    title: Title of the article.
    journal: Journal name of the article.
    type_: Type of article
    random_bit: If true, append some random string
    init: Flag when need to invoke login script to reach the homepage
    doc: Name of the document to upload. If blank will default to 'random', this will choose
    on of available papers
    user: Username
    Return the title of the article.
    """
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    dashboard.click_create_new_submission_button()
    # Create new submission
    title = dashboard.title_generator(prefix=title, random_bit=random_bit)
    print('Creating paper in {} journal, in {} type with {} as title'.format(journal,
          type_, title))
    dashboard.enter_title_field(title)
    dashboard.select_journal_and_type(journal, type_)
    time.sleep(2)

    #fn = os.path.join(os.getcwd()+'/frontend/assets/docs/sample.docx')
    #self._driver.find_element_by_id('upload-files').send_keys(fn)
    #dashboard.click_upload_button()
    if doc == 'random':
      doc2upload = random.choice(docs)
      print('Sending document: ' + os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload))
      fn = os.path.join(os.getcwd() + '/frontend/assets/docs/' + doc2upload)
    else:
      fn = os.path.join(os.getcwd(),'/frontend/assets/docs/{}'.format(doc))
    self._driver.find_element_by_id('upload-files').send_keys(fn)
    dashboard.click_upload_button()

    # Time needed for script execution.
    time.sleep(10)
    return title

  def check_article(self, title, user='jgray_author'):
    """Check if article is in the dashboard"""
    dashboard = self.login(email=user)
    submitted_papers = dashboard._get(dashboard._submitted_papers)
    return True if title in submitted_papers.text else False
