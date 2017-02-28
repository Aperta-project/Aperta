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
    select_regular_journal()
    get_active_admin_tab()
"""
import logging
import random

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
    state = self.journal_selector_drawer_state()
    if state == 'expanded':
      drawer_title = self._get(self._base_admin_drawer_title)
      self.validate_application_subheading_style(drawer_title)
      assert drawer_title.text == 'Journals', drawer_title.text
      self._get(self._base_admin_drawer_toggle_button)
    else:
      toggle = self._get(self._base_admin_drawer_toggle_button)
      toggle.click()
      drawer_title = self._get(self._base_admin_drawer_title)
      self.validate_application_subheading_style(drawer_title)
      assert drawer_title.text == 'Journals', drawer_title.text
    self._validate_journal_drawer_display(username)
    pass

  def _validate_journal_drawer_display(self, username):
    """
    Provided a privileged username, validates the display of journal elements in the left drawer
      for user
    :param username: a privileged username for determining which journal blocks should be
      displayed per the db
    :return: void function
    """
    logging.info(username)
    if username == 'asuperadm':
      logging.info('Validating journal links for Super Admin user')
      # Validate the presentation of journal links in the left drawer
      # Super Admin gets all journals
      db_journals = PgSQL().query('SELECT journals.name,journals.description,count(papers.id)'
                                  'FROM journals LEFT JOIN papers '
                                  'ON journals.id = papers.journal_id '
                                  'GROUP BY journals.id;')
    else:
      # Ordinary Admin role is assigned on a per journal basis
      logging.info('Validating admin page elements for Ordinary Admin user')
      uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
      journals = []
      journals.append(PgSQL().query('SELECT assigned_to_id '
                                    'FROM assignments '
                                    'WHERE user_id = %s AND assigned_to_type=\'Journal\';',
                                    (uid,))[0][0])
      db_journals = []
      for journal in journals:
        logging.info(journal)
        db_journals.append(PgSQL().query('SELECT journals.name, journals.description, '
                                         'COUNT(papers.id) '
                                         'FROM journals LEFT JOIN papers '
                                         'ON journals.id = papers.journal_id '
                                         'WHERE journals.id = %s '
                                         'GROUP BY journals.id;', (journal,))[0])
    logging.debug(db_journals)
    journal_links = self._gets(self._base_admin_journal_links)
    logging.debug(journal_links)
    count = 0
    while count < len(journal_links):
      # Once again, while less than ideal, these must be defined on the fly
      self._base_admin_journal_block_name = \
        (By.XPATH, '//div[@class="ember-view journal-thumbnail"][%s]\
          /div/a/h3[@class="journal-thumbnail-name"]' % str(count + 1))
      journal_title = self._get(self._base_admin_journal_block_name)
      journal_t = (journal_title.text)
      assert journal_t in db_journals, '{0} not found in \n{1}'.format(journal_t, db_journals)
      count += 1

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

  def select_regular_journal(self):
    """
    Select a random normal journal - excludes the All My Journals or All selection
    :return:  void function
    """
    journal_names = []
    journal_links = self._gets(self._base_admin_journal_links)
    for journal in journal_links:
      if journal.text not in ('All My Journals', 'All'):
        journal_names.append(journal.text)
    rand_selection = random.choice(journal_names)
    logging.info('Selected {0}'.format(rand_selection))
    for journal in journal_links:
      if journal.text == rand_selection:
        journal.click()

  def get_active_admin_tab(self):
    """
    Determine the active selected tab of the admin page
    :return:  a string, of the active tab of the admin page. One of 'workflows', 'cards',
      'users', or 'settings'.
    """
    active_tab = self._get(self._base_admin_toolbar_active_link)
    return active_tab.text.to_lower()
