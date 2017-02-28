#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page, Users Tab. Validates elements and their styles,
and functions.
"""

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
    # Left Drawer Elements
    self._base_admin_drawer_open_state = (By.CLASS_NAME, 'left-drawer-open')
    self._base_admin_drawer_closed_state = (By.CLASS_NAME, 'left-drawer-closed')
    self._base_admin_drawer_title = (By.CLASS_NAME, 'left-drawer-title')
    self._base_admin_drawer_toggle_button = (By.CLASS_NAME, 'left-drawer-toggle')
    # If more than one, first item is the All My Journals item
    self._base_admin_journal_links = (By.CLASS_NAME, 'admin-drawer-item')
    self._base_admin_selected_journal = (By.CSS_SELECTOR,
                                         'div.admin-drawer-item > a.active > div')
    # Admin Toolbar Elements
    self._base_admin_workflows_link = (By.CSS_SELECTOR, 'div.tab-bar > a.ember-view:nth-of-type(1)')
    self._base_admin_cards_link = (By.CSS_SELECTOR, 'div.tab-bar > a.ember-view:nth-of-type(2)')
    self._base_admin_users_link = (By.CSS_SELECTOR,
                                   'div.tab-bar > a.ember-view:nth-of-type(3)')
    self._base_admin_settings_link = (By.CSS_SELECTOR,
                                      'div.tab-bar > a.ember-view:nth-of-type(4)')
    self._base_admin_toolbar_active_link = (By.CSS_SELECTOR, 'div.tab-bar > a.ember-view.active')

  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    self._wait_for_element(self._get(self._base_admin_toolbar_active_link))

  def journal_selector_drawer_state(self):
    """
    Returns the state of the Journal Selector drawer. It can be expanded (default) or
    contracted
    :return string, contracted or expanded
    """
    try:
      self._get(self._base_admin_drawer_open_state)
    except ElementDoesNotExistAssertionError:
      self._get(self._base_admin_drawer_closed_state)
      return 'contracted'
    return 'expanded'

  def toggle_journal_drawer(self):
    """
    Toggle the expansion/contraction state of the journal drawer.
    :return: void function
    """
    drawer_toggle = self._get(self._base_admin_drawer_toggle_button)
    drawer_toggle.click()

  def get_selected_journal(self):
    """
    Returns the name (text) of the currently selected journal, note that the teext can be full
      or abbreviated.
    :return: a string, of the active journal of the admin page. Can be full text or initials/all
    """
    active_journal = self._get(self._base_admin_selected_journal)
    return active_journal.text

  def get_active_admin_tab(self):
    """
    Determine the active selected tab of the admin page
    :return:  a string, of the active tab of the admin page. One of 'workflows', 'cards',
      'users', or 'settings'.
    """
    active_tab = self._get(self._base_admin_toolbar_active_link)
    return active_tab.text.to_lower()
