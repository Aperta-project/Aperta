#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Admin Page. Validates global and dynamic elements and their styles
"""

import logging
import random

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from .authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class AdminPage(AuthenticatedPage):
  """
  Model an aperta Admin page
  still have to user details update
  """
  def __init__(self, driver, url_suffix='/'):
    super(AdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Base Admin Page

  # POM Actions
  def validate_page_elements_styles(self, username):
    """
    Provided an accessing username, validates the presented UI elements
    :param username: a privileged username
    :return: void function
    """
    # Validate User section elements
    # Validate Journals section elements
    journals_title = self._get(self._base_admin_journals_section_title)
    self.validate_application_h2_style(journals_title)
    logging.info(username)
    if username == 'asuperadm':
      logging.info('Validating super admin specific page element')
      self._get(self._base_admin_journals_su_add_new_journal_btn)
    self.validate_journal_block_display(username)


  def select_random_journal(self):
    """
    For all the blocks presented on the page, opens the journal specific admin page for a random
    choice
    :return: Name of selected journal
    """
    journal_blocks = self._gets(self._base_admin_journals_section_journal_block)
    selected_journal_index = random.randint(1, len(journal_blocks))
    self._base_admin_journal_block_name = (
        By.XPATH, '//div[@class="ember-view journal-thumbnail"][{0}]/div/a\
        /h3[@class="journal-thumbnail-name"]'.format(selected_journal_index))
    journal_link = self._get(self._base_admin_journal_block_name)
    journal_name = journal_link.text
    logging.info('Opening {0} journal.'.format(journal_name))
    self._actions.click_and_hold(journal_link).release().perform()
    return journal_name

  def select_named_journal(self, journal, click=False):
    """
    Given a journal name, identifies the journal block index on the admin page for that journal
    :param journal: The journal name
    :param click: whether to click the named journal rather than just return its index.
    :return: the index of the named journal block, or False if the journal block is not found
    """
    journal_blocks = self._gets(self._base_admin_journals_section_journal_block)
    count = 0
    while count < len(journal_blocks):
      self._base_admin_journal_block_name = \
          (By.XPATH, '//div[@class="ember-view journal-thumbnail"][{0}]/div/a\
           /h3[@class="journal-thumbnail-name"]'.format(count + 1))
      journal_title = self._get(self._base_admin_journal_block_name)
      logging.debug(journal_title.text)
      logging.debug(journal)
      if journal_title.text == journal:
        if click:
          journal_title.click()
        return count + 1
      count += 1
    return False

  def go_to_journal(self, journal_id):
    """
    Go to a given journal from the admin page
    :param journal_id: Journal id
    :return: None
    """
    url = '{0}/{1}'.format(self._driver.current_url, journal_id)
    self._driver.get(url)

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
      PgSQL().modify('UPDATE journals SET  staff_email=%s WHERE name=%s;', (staff_email,jname))
    else:
      raise(ValueError, 'Incorrect number of parameters passed. Send, journal_name, staff_email')
