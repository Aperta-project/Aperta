#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page, Users Tab. Validates elements and their styles,
and functions.
"""
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from base_admin import BaseAdminPage

__author__ = 'jgray@plos.org'


class AdminUsersPage(BaseAdminPage):
  """
  Model the common base Admin page, users Tab elements and their functions
  """
  def __init__(self, driver):
    super(AdminUsersPage, self).__init__(driver)

    # Locators - Instance members
    self._admin_users_pane_title = (By.CSS_SELECTOR, 'div.admin-page-content > div > h2')



  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    # self._wait_for_element(self._get(self._admin_users_))
    pass

  def validate_users_pane(self, selected_jrnl):
    """
    Assert the existence and function of the elements of the Workflows pane.
    Validate Add new template, edit/delete existing templates, validate presentation.
    :param selected_jrnl: The name of the selected journal for which to validate the workflow pane
    :return: void function
    """
    # Time to fully populate MMT for selected journal
    time.sleep(1)
    all_journals = False
    dbmmts = []
    dbids = []
    mmts = []
    # users_pane_title = self._get(self._admin_users_pane_title)
    # self.validate_application_h2_style(users_pane_title)
