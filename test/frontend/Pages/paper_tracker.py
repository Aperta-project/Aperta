#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Tracker Page. Validates global and dynamic elements and their styles
"""

import logging
import time

from Base.PostgreSQL import PgSQL
from Base.Resources import psql_uname, psql_pw
from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage, application_typeface, manuscript_typeface


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
    self._paper_tracker_table_tbody_row = (By.CSS_SELECTOR, 'tbody tr')

  # POM Actions
  def validate_heading_and_subhead(self, username):
    # Validating Main Heading
    title = self._get(self._paper_tracker_title)
    # The following call to validate consistency in title styles across the app
    # fails due to https://www.pivotaltracker.com/n/projects/880854/stories/100948640
    # self.validate_application_h1_style(title)
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = %s;', (username,))[0][0]
    assert title.text == 'Hello, %s!' % first_name, 'Incorrect Tracker Title: ' + title.text
    # Validate Subhead
    subhead = self._get(self._paper_tracker_subhead)
    # https://www.pivotaltracker.com/story/show/105230462
    assert application_typeface in subhead.value_of_css_property('font-family')
    assert subhead.value_of_css_property('font-size') == '18px'
    assert subhead.value_of_css_property('line-height') == '25.7167px'
    assert subhead.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    # Get total number of papers for users tracker
    uid = PgSQL().query('SELECT id FROM users where username = %s;', (username,))[0][0]
    journal_ids = PgSQL().query('SELECT old_roles.journal_id FROM old_roles INNER JOIN user_roles '
                                'ON old_roles.id = user_roles.old_role_id '
                                'WHERE user_roles.user_id = %s '
                                'AND old_roles.kind IN %s;', (uid, ('flow manager', 'admin', 'editor')))
    journals_list = []
    for journal_id in journal_ids:
      current_journal = journal_id[0]
      if current_journal not in journals_list:
        journals_list.append(current_journal)
    total_count = 0
    for journal in journals_list:
      paper_count = PgSQL().query('SELECT count(*) FROM papers '
                                  'WHERE journal_id IN (%s) AND publishing_state != %s;',
                                  (journal, 'unsubmitted'))[0][0]
      total_count += int(paper_count)

    if total_count == 1:
      assert subhead.text == 'You have {0} paper in your tracker.'.format(total_count), \
        (subhead.text, str(total_count))
    else:
      # Disabled test due to UXA-31
      #assert subhead.text == 'You have {0} papers in your tracker.'.format(total_count), \
      #  (subhead.text, str(total_count))
      pass
    return total_count, journals_list

  def validate_table_presentation_and_function(self, total_count, journal_ids):
    title_th = self._get(self._paper_tracker_table_title_th)
    self.validate_table_heading_style(title_th)
    manid_th = self._get(self._paper_tracker_table_paper_id_th)
    self.validate_table_heading_style(manid_th)
    subdate_th = self._get(self._paper_tracker_table_submit_date_th)
    subdate_th_a = self._get(self._paper_tracker_table_submit_date_th).find_element_by_tag_name('a')
    self.validate_table_heading_style(subdate_th)
    paptype_th = self._get(self._paper_tracker_table_paper_type_th)
    self.validate_table_heading_style(paptype_th)
    members_th = self._get(self._paper_tracker_table_members_th)
    self.validate_table_heading_style(members_th)
    # Validate the contents of the table: papers, links, sorting, roles
    # First step is to grab the papers from the db in the correct order for comparison to the page
    # This is a bit complicated because the ordering should be by submitted_at, but, some of the
    # return set has a NULL value for submitted at. We put these first in an as yet unknown ordering
    # I am going to build two lists then join them.
    # First the papers with submitted_at populated
    submitted_papers = []
    if total_count > 0:
      for journal in journal_ids:
        journal_papers = PgSQL().query('SELECT title, id, submitted_at, paper_type, short_title, doi '
                                       'FROM papers '
                                       'WHERE journal_id IN (%s) AND publishing_state != %s '
                                       'AND submitted_at IS NOT NULL '
                                       'ORDER BY journal_id ASC;', (journal, 'unsubmitted'))
        for paper in journal_papers:
          submitted_papers.append(paper)
      # Now I need to resort this list by the datetime.datetime() objects ASC
      # only trouble is this pukes on the none type objects for papers that are unsubmitted but in other states
      #   (withdrawn)
      ##import pdb; pdb.set_trace()
      submitted_papers = sorted(submitted_papers, key=lambda x: x[1])
    # next the papers with no submitted_at populated (I think this is limited to withdrawn papers with NULL s_a date)
    # https://www.pivotaltracker.com/story/show/105325884 - this ordering is non-deterministic at present so this case
    # will fail until this defect is resolved and the test case updated as needed.
    withdrawn_papers = []
    if total_count > 0:
      for journal in journal_ids:
        journal_papers = PgSQL().query('SELECT title, id, submitted_at, paper_type, short_title, doi '
                                       'FROM papers '
                                       'WHERE journal_id IN (%s) AND publishing_state = %s '
                                       'AND submitted_at IS NULL '
                                       'ORDER BY paper_type ASC;', (journal, 'withdrawn'))
        for paper in journal_papers:
          withdrawn_papers.append(paper)
    # finally combine the two lists, NULL submitted_at first
    papers = withdrawn_papers + submitted_papers
    #import pdb; pdb.set_trace()
    if total_count > 0:
      table_rows = self._gets(self._paper_tracker_table_tbody_row)
      count = 0
      for row in table_rows:
        print('Validating Row: {0}'.format(count))
        # Once again, while less than ideal, these must be defined on the fly
        self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-title-column"]/a'
                                                 % str(count + 1))
        self._paper_tracker_table_tbody_manid = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-paper-id-column"]/a'
                                                 % str(count + 1))
        self._paper_tracker_table_tbody_subdate = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-date-column"]'
                                                   % str(count + 1))
        self._paper_tracker_table_tbody_paptype = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-type-column"]'
                                                   % str(count + 1))
        self._paper_tracker_table_tbody_members = (By.XPATH, '//tbody/tr[%s]/td[@class="paper-tracker-members-column"]'
                                                   % str(count + 1))

        title = self._get(self._paper_tracker_table_tbody_title)
        if not title:
          raise ValueError('Error: No title in db! Illogical, Illogical, Norman Coordinate: Invalid document')
        if papers[count][0]:
          db_title = papers[count][0]
          # strip tags
          db_title = self.get_text(db_title)
          db_title = db_title.strip()
          page_title = title.text.strip()
          if isinstance(db_title, unicode) and isinstance(page_title, unicode):
            # Split both to eliminate differences in whitespace
            db_title = db_title.split()
            page_title = page_title.split()
            assert db_title == page_title, (db_title, page_title)
          else:
            raise TypeError('Database title or Page title are not both unicode objects')
        manid = self._get(self._paper_tracker_table_tbody_manid)
        manid.number = manid.get_attribute('href').split('/')[-1]
        assert '/papers/%s' % manid.number in title.get_attribute('href'), \
          (manid.number, title.get_attribute('href'))
        assert int(manid.number) == papers[count][1]
        assert '/papers/%s' % manid.number in manid.get_attribute('href'), \
          (manid.number, title.get_attribute('href'))
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
                                            'WHERE paper_id= %s AND paper_roles.old_role = %s;', (manid.number, 'participant'))
            name = []
            for participant in db_participants:
              name.append(participant[0] + ' ' + participant[1])
            db_participants = name
            participants.sort()
            db_participants.sort()
            assert participants == db_participants
          elif role.startswith('Collaborator'):
            role = role.split(': ')[1]
            collaborators = role.split(', ')
            db_collaborators = PgSQL().query('SELECT users.first_name, users.last_name '
                                             'FROM paper_roles INNER JOIN users '
                                             'ON paper_roles.user_id = users.id '
                                             'WHERE paper_id= %s AND paper_roles.old_role = %s;', (manid.number, 'collaborator'))
            name = []
            for collaborator in db_collaborators:
              name.append(collaborator[0] + ' ' + collaborator[1])
            db_collaborators = name
            collaborators.sort()
            db_collaborators.sort()
            assert collaborators == db_collaborators
          elif role.startswith('Reviewer'):
            role = role.split(': ')[1]
            reviewers = role.split(', ')
            db_reviewers = PgSQL().query('SELECT users.first_name, users.last_name '
                                         'FROM paper_roles INNER JOIN users '
                                         'ON paper_roles.user_id = users.id '
                                         'WHERE paper_id= %s AND paper_roles.old_role = %s;', (manid.number, 'reviewer'))
            name = []
            for reviewer in db_reviewers:
              name.append(reviewer[0] + ' ' + reviewer[1])
            db_reviewers = name
            reviewers.sort()
            db_reviewers.sort()
            assert reviewers == db_reviewers
          elif role.startswith('Editor'):
            role = role.split(': ')[1]
            editors = role.split(', ')
            db_editors = PgSQL().query('SELECT users.first_name, users.last_name '
                                       'FROM paper_roles INNER JOIN users '
                                       'ON paper_roles.user_id = users.id '
                                       'WHERE paper_id= %s AND paper_roles.old_role = %s;', (manid.number, 'editor'))
            name = []
            for editor in db_editors:
              name.append(editor[0] + ' ' + editor[1])
            db_editors = name
            editors.sort()
            db_editors.sort()
            assert editors == db_editors
          elif role.startswith('Admin'):
            role = role.split(': ')[1]
            admins = role.split(', ')
            db_admins = PgSQL().query('SELECT users.first_name, users.last_name '
                                       'FROM paper_roles INNER JOIN users '
                                       'ON paper_roles.user_id = users.id '
                                       'WHERE paper_id= %s AND paper_roles.old_role = %s;', (manid.number, 'admin'))
            name = []
            for admin in db_admins:
              name.append(admin[0] + ' ' + admin[1])
            db_admins = name
            admins.sort()
            db_admins.sort()
            assert admins == db_admins
          else:
            return False
        count += 1
      logging.info('Validating sort function for Date Submitted')
      subdate_th_a.click()
      time.sleep(2)
      subdate_th_a = self._get(self._paper_tracker_table_submit_date_th).find_element_by_tag_name('a')
      subdate_th_a.click()
      self._paper_tracker_table_tbody_manid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      manid = self._get(self._paper_tracker_table_tbody_manid).text
      doi = papers[len(papers) - 1][5].split('/')[1]
      assert manid == doi, '{0} != {1}'.format(manid, doi)
      self._get(self._paper_tracker_table_header_sort_down).click()
      self._paper_tracker_table_tbody_manid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      manid = self._get(self._paper_tracker_table_tbody_manid).text
      assert manid == papers[0][5], str(manid) + '!=' + papers[0][5]

      logging.info('Sorting by Manuscript ID')
      manid_th = self._get(self._paper_tracker_table_paper_id_th)
      manid_th.click()
      self._paper_tracker_table_tbody_manid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      manid = self._get(self._paper_tracker_table_tbody_manid).text
      orig_manid = manid
      self._get(self._paper_tracker_table_header_sort_up).click()
      self._paper_tracker_table_tbody_manid = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      manid = self._get(self._paper_tracker_table_tbody_manid).text
      if total_count > 1:
          assert manid > orig_manid, manid + '<=' + orig_manid
      else:
          assert manid == orig_manid, manid + '!=' + orig_manid

      print('Sorting by Title')
      title_th = self._get(self._paper_tracker_table_title_th)
      title_th.click()
      self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      title = self._get(self._paper_tracker_table_tbody_title)
      orig_title = title
      self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      self._get(self._paper_tracker_table_header_sort_up).click()
      self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      title = self._get(self._paper_tracker_table_tbody_title)
      if total_count > 1:
        assert title.text > orig_title.text, title.text + '<=' + orig_title.text
      else:
        assert title.text == orig_title.text, title.text + '!=' + orig_title.text
      self._get(self._paper_tracker_table_header_sort_down).click()
      self._paper_tracker_table_tbody_title = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      title = self._get(self._paper_tracker_table_tbody_title)
      assert title.text == orig_title.text, title.text + '!=' + orig_title.text

      print('Sorting by Paper Type')
      paptype_th.click()
      self._paper_tracker_table_tbody_paptype = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-type-column"]')
      type_ = self._get(self._paper_tracker_table_tbody_paptype)
      orig_type = type_
      self._get(self._paper_tracker_table_header_sort_up).click()
      self._paper_tracker_table_tbody_paptype = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-type-column"]')
      type_ = self._get(self._paper_tracker_table_tbody_paptype)
      assert type_.text.lower() >= orig_type.text.lower(), type.text + '<' + orig_type.text
      self._get(self._paper_tracker_table_header_sort_down).click()
      self._paper_tracker_table_tbody_paptype = (By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-type-column"]')
      type_ = self._get(self._paper_tracker_table_tbody_paptype)
      assert type_.text == orig_type.text, type_.text + '!=' + orig_type.text
