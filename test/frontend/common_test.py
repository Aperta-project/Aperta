#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""

"""

from Base.FrontEndTest import FrontEndTest
from Base.Resources import login_valid_email, login_valid_pw
from Pages.login_page import LoginPage
from Pages.dashboard import DashboardPage


class CommonTest(FrontEndTest):
  """
  Model an aperta paper editor page
  """
  #def __init__():
    #super(CommonTest).__init__()

  def login(self, email=login_valid_email, password=login_valid_pw):
    """Login into Aperta"""
    login_page = LoginPage(self.getDriver())
    login_page.enter_login_field(email)
    login_page.enter_password_field(password)
    login_page.click_sign_in_button()
    return DashboardPage(self.getDriver())

  def select_preexisting_article(self, title='Hendrik', init=True, first=False):
    """
    Select a preexisting article using a word as a partial name
    for the title. init is True when the user is not logged in
    and need to invoque login script to reach the homepage.
    """
    dashboard = self.login() if init else DashboardPage(self.getDriver())
    if first:
      return dashboard.click_on_first_manuscript()
    else:
      return dashboard.click_on_existing_manuscript_link_partial_title(title)

  def create_article(self, title='', journal='journal', type_='Research1'):
    """Create a new article"""
    dashboard = self.login()
    dashboard.click_create_new_submision_button()
    # Create new submission
    if not title:
      title = dashboard.title_generator()
    dashboard.enter_title_field(title)
    dashboard.select_journal(journal, type_)
    dashboard.click_create_button()
    return title
