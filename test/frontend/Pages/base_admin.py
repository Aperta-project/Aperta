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
import os
import random
import time

from selenium.webdriver.common.by import By

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from .authenticated_page import AuthenticatedPage

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
    self._base_admin_workflows_link = (By.LINK_TEXT, 'Workflows')
    self._base_admin_cards_link = (By.LINK_TEXT, 'Cards')
    self._base_admin_emails_link = (By.LINK_TEXT, 'Emails')
    self._base_admin_users_link = (By.LINK_TEXT, 'Users')
    self._base_admin_settings_link = (By.LINK_TEXT, 'Settings')
    self._base_admin_toolbar_active_link = (By.CSS_SELECTOR, 'div.tab-bar > a.ember-view.active')
    self._base_admin_add_jrnl_btn = (By.CLASS_NAME, 'admin-drawer-item-button')
    # Add New Journal Overlay Elements
    self._anj_edit_journal_div = (By.CLASS_NAME, 'labeled-input-form')
    self._anj_edit_logo_upload_btn = (By.CLASS_NAME, 'fileinput-button')
    self._anj_edit_logo_upload_note = (By.CSS_SELECTOR, 'div.journal-logo-uploader p')
    self._anj_edit_logo_input_field = (By.ID, 'upload-journal-logo-button')
    self._anj_edit_title_label = (By.CSS_SELECTOR, 'label.name')
    self._anj_edit_title_field = (By.NAME, 'name')
    self._anj_edit_desc_label = (By.CSS_SELECTOR, 'label.description')
    self._anj_edit_desc_field = (By.CLASS_NAME, 'ember-text-area')
    self._anj_edit_doi_jrnl_prefix_label = (By.CSS_SELECTOR, 'label.doi-journal-prefix')
    self._anj_edit_doi_jrnl_prefix_field = (By.NAME, 'doiJournalPrefix')
    self._anj_edit_doi_publ_prefix_label = (By.CSS_SELECTOR, 'label.doi-publisher-prefix')
    self._anj_edit_doi_publ_prefix_field = (By.NAME, 'doiPublisherPrefix')
    self._anj_edit_last_doi_label = (By.CSS_SELECTOR, 'label.last-doi-issued')
    self._anj_edit_last_doi_field = (By.NAME, 'lastDoiIssued')
    self._anj_edit_cancel_link = (By.CSS_SELECTOR, '.admin-new-journal-overlay-cancel')
    self._anj_edit_save_button = (By.CSS_SELECTOR, '.admin-new-journal-overlay-save')

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
                               'FROM journals;')
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
      if regular and journal.text not in ('All My Journals', 'All'):
          journal_names.append(journal.text)
      else:
        journal_names.append(journal.text)
    rand_selection = random.choice(journal_names)
    logging.info('Selected {0}'.format(rand_selection))
    for journal in journal_links:
      if journal.text == rand_selection:
        journal.click()
        break
    time.sleep(2)
    return rand_selection

  def select_named_journal(self, journal):
    """
    Given a journal name, identifies the journal block index on the admin page for that journal
    :param journal: The journal name
    :return: True if journal exists, False if not exist
    """
    journal_links = self._gets(self._base_admin_journal_links)
    for journal_link in journal_links:
      if journal_link.text == journal:
        journal_link.click()
        time.sleep(1)
        return True
      else:
        continue
    return False

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
    time.sleep(2)

  def launch_add_journal_overlay(self):
    """
    Click the Add New Journal button, Note this button is only present for the Superadmin
    Returns: Void Function
    """
    self._wait_for_element(self._get(self._base_admin_add_jrnl_btn))
    anj_btn = self._get(self._base_admin_add_jrnl_btn)
    anj_btn.click()
    self._wait_for_element(self._get(self._anj_edit_title_field))

  def validate_add_new_journal(self, journal_name='', journal_desc='', logo='', doi_jrnl_prefix='',
                               last_doi_issued=1000000, doi_publ_prefix='', commit=False):
    """
    If commit == False, validate the elements of the form, if True, create the new journal
    :param doi_jrnl_prefix: string, The DOI Journal prefix for the new Journal
    :param last_doi_issued: integer, The most recently issued doi numeric. Defaults to 1000000
    :param doi_publ_prefix: string, The DOI Publisher prefix for the publisher of the new journal
    :param journal_name: An optional journal_name to create
    :param journal_desc: An optional description for the journal being created
    :param logo: A filename representing the journal logo - should be a valid file in assets/imgs/
    :param commit: Boolean, default False. If true, commit creation of the journal
    :return: void function
    """
    self._wait_for_element(self._get(self._anj_edit_save_button))
    upload_button = self._get(self._anj_edit_logo_upload_btn)
    assert upload_button.text == 'UPLOAD NEW'
    journal_title_label = self._get(self._anj_edit_title_label)
    assert journal_title_label.text == 'Journal Title', journal_title_label.text
    journal_title_field = self._get(self._anj_edit_title_field)
    journal_desc_label = self._get(self._anj_edit_desc_label)
    assert journal_desc_label.text == 'Journal Description', journal_desc_label.text
    journal_desc_field = self._get(self._anj_edit_desc_field)
    doi_jrnl_prefix_label = self._get(self._anj_edit_doi_jrnl_prefix_label)
    assert doi_jrnl_prefix_label.text == 'DOI Journal Prefix', doi_jrnl_prefix_label.text
    doi_jrnl_prefix_field = self._get(self._anj_edit_doi_jrnl_prefix_field)
    doi_publ_prefix_label = self._get(self._anj_edit_doi_publ_prefix_label)
    assert doi_publ_prefix_label.text == 'DOI Publisher Prefix', doi_publ_prefix_label.text
    doi_publ_prefix_field = self._get(self._anj_edit_doi_publ_prefix_field)
    last_doi_issued_label = self._get(self._anj_edit_last_doi_label)
    assert last_doi_issued_label.text == 'Last DOI Issued', last_doi_issued_label.text
    last_doi_issued_field = self._get(self._anj_edit_last_doi_field)
    cancel_link = self._get(self._anj_edit_cancel_link)
    save_button = self._get(self._anj_edit_save_button)
    assert cancel_link.text == 'cancel', cancel_link.text
    assert save_button.text == 'SAVE JOURNAL', save_button.text
    if commit:
      logging.info('Committing new journal: {0}'.format(journal_name))
      journal_title_field.send_keys(journal_name)
      journal_desc_field.send_keys(journal_desc)
      doi_jrnl_prefix_field.send_keys(doi_jrnl_prefix)
      doi_publ_prefix_field.send_keys(doi_publ_prefix)
      last_doi_issued_field.send_keys(last_doi_issued)
      logo_input = self._iget(self._anj_edit_logo_input_field)
      current_path = os.getcwd()
      logging.info(current_path)
      logo_path = os.path.join(current_path, 'frontend/assets/imgs/{0}'.format(logo))
      logo_input.send_keys(logo_path)
      save_button.click()
      self._populate_journal_db_values(journal_name, 'apertadevteam@plos.org')

  @staticmethod
  def _populate_journal_db_values(jname, staff_email):
    """
    A method to populate values into the journal table for journal named jname. There is no current
      interface to populated these in the GUI.
    :param jname: The name of the journal
    :param staff_email: The email address to populate staff_email in journal table for jname
    :return: void function
    """
    if jname and staff_email:
      PgSQL().modify('UPDATE journals SET  staff_email=%s WHERE name=%s;', (staff_email, jname))
    else:
      raise(ValueError, 'Incorrect number of parameters passed. Send, journal_name, staff_email')
