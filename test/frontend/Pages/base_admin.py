#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the base Admin Page. This page defines common elements used by all the admin
  sub-pages. Validates global and dynamic elements and their styles.
  Offers:
    page_ready()
    validate_page_elements_styles()
    get_journal_selector_drawer_state()
    toggle_journal_drawer()
    get_selected_journal()
    select_journal()
    get_active_admin_tab()
"""
import logging
import random
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class BaseAdminPage(AuthenticatedPage):
  """
  Model the common base Admin page elements and their functions
  """
  def __init__(self, driver, url_suffix='/'):
    super(BaseAdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Left Drawer Elements
    self._base_admin_drawer_open_state = (By.CLASS_NAME, 'left-drawer-open')
    self._base_admin_drawer_closed_state = (By.CLASS_NAME, 'left-drawer-closed')
    self._base_admin_drawer_title = (By.CLASS_NAME, 'left-drawer-title')
    self._base_admin_drawer_toggle_button = (By.CLASS_NAME, 'left-drawer-toggle')
    # If more than one, first item is the All My Journals item
    self._base_admin_journal_links = (By.CLASS_NAME, 'admin-drawer-item')
    # TODO: This next selector is returning both the hidden and the visible element - need to fix!
    self._base_admin_selected_journal = (By.CSS_SELECTOR,
                                         'div.admin-drawer-item > a.active')
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

  def validate_page_elements_styles(self, username):
    """
    Provided an accessing username, validates the presented UI elements
    :param username: a privileged username
    :return: void function
    """
    # Validate Common Elements
    # We need to be able to validate the journal drawer title in either state
    choices = ['expanded', 'contracted']
    test_drawer_state = random.choice(choices)
    drawer_state = self.journal_selector_drawer_state()
    logging.info('Testing Journals drawer in {0} state, '
                 'current state is {1}'.format(test_drawer_state, drawer_state))
    if drawer_state != test_drawer_state:
      self.toggle_journal_drawer()
    # The drawer title only appears in expanded state
    if test_drawer_state == 'expanded':
      drawer_title = self._get(self._base_admin_drawer_title)
      self.validate_application_subheading_style(drawer_title)
      assert drawer_title.text == 'Journals', drawer_title.text
    else:
      drawer_title = self._get(self._base_admin_drawer_title)
      self.validate_application_subheading_style(drawer_title)
      assert drawer_title.text != 'Journals', drawer_title.text
    # Put away our toys:
    if drawer_state != test_drawer_state:
      self.toggle_journal_drawer()
    self._validate_journal_drawer_display(username)

  def _validate_journal_drawer_display(self, username):
    """
    Provided a privileged username, validates the display of journal elements in the left drawer
      for user. Randomly chooses whether to validate the list in expanded or contracted view
    :param username: a privileged username for determining which journal blocks should be
      displayed per the db
    :return: void function
    """
    # We need to be able to validate the journal drawer in either state
    choices = ['expanded', 'contracted']
    test_drawer_state = random.choice(choices)
    drawer_state = self.journal_selector_drawer_state()
    logging.info('Testing Journals drawer in {0} state, '
                 'current state is {1}'.format(test_drawer_state, drawer_state))
    if drawer_state != test_drawer_state:
      self.toggle_journal_drawer()
    logging.info(username)
    db_journals = ['All My Journals']
    if username == 'asuperadm':
      logging.info('Validating journal links for Super Admin user')
      # Validate the presentation of journal links in the left drawer
      # Super Admin gets all journals
      db_jrnls = PgSQL().query('SELECT name '
                               'FROM journals')
      logging.info(db_jrnls)
      for jrnl in db_jrnls:
        db_journals.append(jrnl[0])
      logging.info('SuperAdmin journals list: {0}'.format(db_journals))
    else:
      # Ordinary Admin role is assigned on a per journal basis
      logging.info('Validating admin page elements for Ordinary Admin user')
      uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
      journals = []
      journals.append(PgSQL().query('SELECT assigned_to_id '
                                    'FROM assignments '
                                    'WHERE user_id = %s AND assigned_to_type=\'Journal\';',
                                    (uid,))[0][0])
      for journal in journals:
        logging.info(journal)
        db_journals.append(PgSQL().query('SELECT journals.name '
                                         'FROM journals '
                                         'WHERE journals.id = %s ', (journal,))[0][0])
    logging.info(db_journals)
    if test_drawer_state == 'contracted':
      db_journals = self._abbreviate_jrnls_list(db_journals)
    logging.info(db_journals)
    journal_links = self._gets(self._base_admin_journal_links)
    for link in journal_links:
      journal_title = link.text
      assert journal_title in db_journals, '{0} not found in \n{1}'.format(journal_title,
                                                                           db_journals)
    # finally, put the drawer state back to what it was originally
    if drawer_state != test_drawer_state:
      self.toggle_journal_drawer()

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
    # Give a moment for the animation
    time.sleep(1)

  def get_selected_journal(self):
    """
    Returns the name (text) of the currently selected journal, note that the teext can be full
      or abbreviated.
    :return: a string, of the active journal of the admin page. Can be full text or initials/all
    """
    active_journal = self._get(self._base_admin_selected_journal)
    return active_journal.text

  def select_journal(self, regular=False):
    """
    Select a random journal
    :param regular: If True, will not include the 'All My Journals/All' item in random selection
    :return:  Name of Selected Journal
    """
    journal_names = []
    journal_links = self._gets(self._base_admin_journal_links)
    for journal in journal_links:
      if regular:
        if journal.text not in ('All My Journals', 'All'):
          journal_names.append(journal.text)
      else:
        journal_names.append(journal.text)
    rand_selection = random.choice(journal_names)
    logging.info('Selected {0}'.format(rand_selection))
    for journal in journal_links:
      if journal.text == rand_selection:
        journal.click()
    return rand_selection

  def get_active_admin_tab(self):
    """
    Determine the active selected tab of the admin page
    :return:  a string, of the active tab of the admin page. One of 'workflows', 'cards',
      'users', or 'settings'.
    """
    active_tab = self._get(self._base_admin_toolbar_active_link)
    return active_tab.text.to_lower()

  @staticmethod
  def _abbreviate_jrnls_list(jrnls_list):
    """
    Given a list of journals, returns the canonical abbreviated form of that list (apropos of the
    journal drawer of the admin page)
    :param jrnls_list: the full name of a list of journals
    :return: abbreviated_journals_list
    """
    logging.info('Passed journals list: {0}'.format(jrnls_list))
    abbreviated_journals_list = []
    for jrnl in jrnls_list:
      if jrnl == 'All My Journals':
        abbreviated_journals_list.append('All')
      else:
        entry = jrnl.split(' ')
        jrnl_abbr = []
        for word in entry:
          jrnl_abbr.append(word[0])
        abbreviation = ''.join(jrnl_abbr)
        abbreviated_journals_list.append(abbreviation)
    return abbreviated_journals_list

  def select_admin_top_link(self, linkname):
    """Clicks the named link from the admin toolbar"""
    if linkname == 'Workflows':
      self._get(self._base_admin_workflows_link).click()
    elif linkname == 'Cards':
      self._get(self._base_admin_cards_link).click()
    elif linkname == 'Users':
      self._get(self._base_admin_users_link).click()
    elif linkname == 'Settings':
      self._get(self._base_admin_settings_link).click()
    else:
      logging.error('Invalid linkname specified: {0}'.format(linkname))
    # Allow time for the UI to update
    time.sleep(1)
