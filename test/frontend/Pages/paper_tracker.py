#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Tracker Page. Validates global and dynamic elements and their styles
"""

from Base.PostgreSQL import PgSQL
from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage
import time

__author__ = 'jgray@plos.org'


class PaperTrackerPage(AuthenticatedPage):
  """
  Model an aperta paper tracker page
  """
  def __init__(self, driver, url_suffix='/'):
    super(PaperTrackerPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
    self._paper_tracker_subhead = (By.CLASS_NAME, 'paper-tracker-paper-count')
    self._paper_tracker_table = (By.CLASS_NAME, 'paper-tracker-table')
    self._paper_tracker_table_title_th = (By.XPATH, '//th[2]')
    self._paper_tracker_table_paper_id_th = (By.XPATH, '//th[3]')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._paper_tracker_table_paper_type_th = (By.XPATH, '//th[5]')
    self._paper_tracker_table_members_th = (By.XPATH, '//th[6]')
    self._paper_tracker_table_header_sort_up = (By.CLASS_NAME, 'fa-caret-up')
    self._paper_tracker_table_header_sort_down = (By.CLASS_NAME, 'fa-caret-down')

  # POM Actions
  def validate_initial_page_elements_styles(self, username):
    title = self._get(self._paper_tracker_title)
    # The following call to validate consistency in title styles across the app
    # fails due to https://www.pivotaltracker.com/n/projects/880854/stories/100948640
    # self.validate_title_style(title)
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = %s;', (username,))[0][0]
    assert title.text == 'Hello, %s!' % first_name, 'Incorrect Tracker Title: ' + title.text
    subhead = self._get(self._paper_tracker_subhead)
    assert 'helvetica' in subhead.value_of_css_property('font-family')
    assert subhead.value_of_css_property('font-size') == '18px'
    assert subhead.value_of_css_property('line-height') == '25.7167px'
    assert subhead.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    uid = PgSQL().query('SELECT id FROM users where username = %s;', (username,))[0][0]
    journal_ids = PgSQL().query('SELECT roles.journal_id FROM roles INNER JOIN user_roles '
                                'ON roles.id = user_roles.role_id '
                                'WHERE user_roles.user_id = %s AND roles.kind IN %s;', (uid, ('flow manager', 'admin')))
    # This rather ridiculous bit is necessary to create a string that can be passed in as a set to the query
    journals = ''
    count = 1
    for journal in journal_ids:
      journals += str(journal[0])
      if len(journal_ids) > count:
        journals += ','
      count += 1
    paper_count = PgSQL().query('SELECT count(*) FROM papers where journal_id IN (%s) AND publishing_state = %s;',
                                (journals, 'submitted'))[0][0]
    if paper_count == 1:
      assert subhead.text == 'You have ' + str(paper_count) + ' paper in your tracker.'
    else:
      assert subhead.text == 'You have ' + str(paper_count) + ' papers in your tracker.'
    title_th = self._get(self._paper_tracker_table_title_th)
    self.validate_table_heading_style(title_th)
    papid_th = self._get(self._paper_tracker_table_paper_id_th)
    self.validate_table_heading_style(papid_th)
    subdate_th = self._get(self._paper_tracker_table_submit_date_th)
    self.validate_table_heading_style(subdate_th)
    paptype_th = self._get(self._paper_tracker_table_paper_type_th)
    self.validate_table_heading_style(paptype_th)
    members_th = self._get(self._paper_tracker_table_members_th)
    self.validate_table_heading_style(members_th)
    # Need to do some validation of the displayed papers here
    # TODO: validate the complete list of papers in the list
    # TODO: validate the function of the submit date sort arrows
    self._get(self._paper_tracker_table_header_sort_up).click()
    self._get(self._paper_tracker_table_header_sort_down).click()
