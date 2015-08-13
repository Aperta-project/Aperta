#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Admin Page. Validates global and dynamic elements and their styles
"""

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
from authenticated_page import AuthenticatedPage

__author__ = 'jgray@plos.org'


class AdminPage(AuthenticatedPage):
  """
  Model an aperta Admin page
  """
  def __init__(self, driver, url_suffix='/'):
    super(PaperTrackerPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Base Admin Page
    self._base_admin_user_search_field = (By.CLASS_NAME, 'admin-user-search-input')
    self._base_admin_user_search_button = (By.CLASS_NAME, 'admin-user-search-button')
    self._base_admin_user_search_results_table = (By.CLASS_NAME, 'admin-users')
    self._base_admin_user_search_results_table_fname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[1]')
    self._base_admin_user_search_results_table_lname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[2]')
    self._base_admin_user_search_results_table_uname_header = (By.XPATH, '//table[@class="admin-users"]/tr/th[3]')
    self._base_admin_journals_section_title = (By.CLASS_NAME, 'admin-section-title')

    self._base_admin_journals_su_add_new_journal_btn = (By.CLASS_NAME, 'add-new-journal')
    self._base_admin_journals_edit_journal_div = (By.CLASS_NAME, 'journal-thumbnail-edit-form')


    self._base_admin_journals_section_journal_block = (By.CLASS_NAME, 'journal-thumbnail')
    self._base_admin_journal_block_link = (By.CLASS_NAME, 'journal-thumbnail-show')
    self._base_admin_journal_block_logo_blank = (By.CSS_SELECTOR, 'div.journal-thumbnail-logo svg')
    self._base_admin_journal_block_logo_img = (By.CSS_SELECTOR, 'div.journal-thumbnail-logo img')
    self._base_admin_journal_block_paper_count = (By.CLASS_NAME, 'journal-thumbnail-paper-count')
    self._base_admin_journal_block_name = (By.CLASS_NAME, 'journal-thumbnail-name')
    self._base_admin_journal_block_desc = (By.CSS_SELECTOR, 'a.journal-thumbnail-show p')
    # User Details Overlay
    self._ud_overlay_title = (By.CSS_SELECTOR, 'div.overlay-container div h1')
    self._ud_overlay_closer = (By.CLASS_NAME, 'overlay-close-x')
    self._ud_overlay_uname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[1]/label')
    self._ud_overlay_uname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[1]/div/input')
    self._ud_overlay_fname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[2]/label')
    self._ud_overlay_fname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[2]/div/input')
    self._ud_overlay_lname_label = (By.XPATH, '//div[@class="overlay-container"]/div/div[3]/label')
    self._ud_overlay_lname_field = (By.XPATH, '//div[@class="overlay-container"]/div/div[3]/div/input')
    self._ud_overlay_reset_pw_btn = (By.CSS_SELECTOR, 'div.reset-password a')
    self._ud_overlay_reset_pw_success_msg = (By.CLASS_NAME, 'success')
    self._ud_overlay_cancel_link = (By.CLASS_NAME, 'cancel-link')
    self._ud_overlay_save_btn = (By.CSS_SELECTOR, 'div.overlay-action-buttons button')




  # POM Actions
  def validate_page_elements_styles_functions(self, username):
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

    # Validate the contents of the table: papers, links, sorting, roles
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
    papers = PgSQL().query('SELECT title, id, submitted_at, paper_type, short_title '
                           'FROM papers '
                           'WHERE journal_id IN (%s) AND publishing_state = %s '
                           'ORDER BY submitted_at ASC;', (journals, 'submitted'))
    table_rows = self._gets(self._paper_tracker_table_tbody_row)
    count = 0
    for row in table_rows:
      # Once again, while less than ideal, these must be defined on the fly
      self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-title-column"]/a'
                                               % str(count + 1))
      self._paper_tracker_table_tbody_papid = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-paper-id-column"]/a'
                                               % str(count + 1))
      self._paper_tracker_table_tbody_subdate = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-date-column"]'
                                                 % str(count + 1))
      self._paper_tracker_table_tbody_paptype = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-type-column"]'
                                                 % str(count + 1))
      self._paper_tracker_table_tbody_members = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-members-column"]'
                                                 % str(count + 1))

      title = self._get(self._paper_tracker_table_tbody_title)
      if papers[count][0]:
        # Oi! Dirty data - how do tabs get into one spot and spaces in another?
        assert ' '.join(title.text.split()) == ' '.join(papers[count][0].split())
      else:
        # Oi! Dirty data - how do tabs get into one spot and spaces in another?
        assert ' '.join(title.text.split()) == ' '.join(papers[count][4].split())
      papid = self._get(self._paper_tracker_table_tbody_papid)
      assert '/papers/%s/edit' % papid.text in title.get_attribute('href')
      assert int(papid.text) == papers[count][1]
      assert '/papers/%s/edit' % papid.text in papid.get_attribute('href')
      self._get(self._paper_tracker_table_tbody_subdate)
      paptype = self._get(self._paper_tracker_table_tbody_paptype)
      assert paptype.text == papers[count][3]
      members = self._get(self._paper_tracker_table_tbody_members)
      page_members_by_role = members.text.split('\n')
      for role in page_members_by_role:
        if role.startswith('Participant'):
          role = role.split(': ')[1]
          participants = role.split(', ')
          db_participants = PgSQL().query('SELECT users.first_name, users.last_name '
                                          'FROM paper_roles INNER JOIN users '
                                          'ON paper_roles.user_id = users.id '
                                          'WHERE paper_id= %s AND paper_roles.role = %s;', (papid.text, 'participant'))
          name = []
          for participant in db_participants:
            name.append(participant[0] + ' ' + participant[1])
          db_participants = name
          assert participants.sort() == db_participants.sort()
        elif role.startswith('Collaborator'):
          role = role.split(': ')[1]
          collaborators = role.split(', ')
          db_collaborators = PgSQL().query('SELECT users.first_name, users.last_name '
                                           'FROM paper_roles INNER JOIN users '
                                           'ON paper_roles.user_id = users.id '
                                           'WHERE paper_id= %s AND paper_roles.role = %s;', (papid.text, 'collaborator'))
          name = []
          for collaborator in db_collaborators:
            name.append(collaborator[0] + ' ' + collaborator[1])
          db_collaborators = name
          assert collaborators.sort() == db_collaborators.sort()
        elif role.startswith('Reviewer'):
          role = role.split(': ')[1]
          reviewers = role.split(', ')
          db_reviewers = PgSQL().query('SELECT users.first_name, users.last_name '
                                       'FROM paper_roles INNER JOIN users '
                                       'ON paper_roles.user_id = users.id '
                                       'WHERE paper_id= %s AND paper_roles.role = %s;', (papid.text, 'reviewer'))
          name = []
          for reviewer in db_reviewers:
            name.append(reviewer[0] + ' ' + reviewer[1])
          db_reviewers = name
          assert reviewers.sort() == db_reviewers.sort()
        elif role.startswith('Editor'):
          role = role.split(': ')[1]
          editors = role.split(', ')
          db_editors = PgSQL().query('SELECT users.first_name, users.last_name '
                                     'FROM paper_roles INNER JOIN users '
                                     'ON paper_roles.user_id = users.id '
                                     'WHERE paper_id= %s AND paper_roles.role = %s;', (papid.text, 'collaborator'))
          name = []
          for editor in db_editors:
            name.append(editor[0] + ' ' + editor[1])
          db_editors = name
          assert editors.sort() == db_editors.sort()
        else:
          print(role)
          return False
      count += 1
    # Validate sort function
    self._get(self._paper_tracker_table_header_sort_up).click()
    self._paper_tracker_table_tbody_papid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
    papid = int(self._get(self._paper_tracker_table_tbody_papid).text)
    assert papid == papers[len(papers) - 1][1]
    self._get(self._paper_tracker_table_header_sort_down).click()
    self._paper_tracker_table_tbody_papid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
    papid = int(self._get(self._paper_tracker_table_tbody_papid).text)
    assert papid == papers[0][1]