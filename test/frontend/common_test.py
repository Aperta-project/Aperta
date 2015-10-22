#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

"""

import time

from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_email, login_valid_pw
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage


class CommonTest(FrontEndTest):
  """
  Model an aperta paper editor page
  """

  def login(self, email=login_valid_email, password=login_valid_pw):
    """Login into Aperta"""
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
    and need to invoque login script to reach the homepage.
    """
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    if first:
      return dashboard.click_on_first_manuscript()
    else:
      return dashboard.click_on_existing_manuscript_link_partial_title(title)

  def create_article(self, title='', journal='journal', type_='Research1',
      random_bit=False, init=True):
    """
    Create a new article.
    title: Title of the article.
    journal: Journal name of the article.
    type_: Type of article
    random_bit: If true, append some random string
    init: Flag when need to invoque login script to reach the homepage
    Return the title of the article.
    """
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    dashboard.click_create_new_submission_button()
    # Create new submission
    title = dashboard.title_generator(prefix=title, random_bit=random_bit)
    dashboard.enter_title_field(title)
    dashboard.select_journal(journal, type_)
    time.sleep(2)
    # upload file
    upload_btn = dashboard._get(dashboard._cns_upload_document)
    import pdb; pdb.set_trace()
    ##dashboard._get(dashboard._cns_create_btn).click()
    time.sleep(10)
    return title

  def check_article(self, title):
    """Check if article is in the dashboard"""
    dashboard = self.login()
    submitted_papers = dashboard._get(dashboard._submitted_papers)
    return True if title in submitted_papers.text else False
