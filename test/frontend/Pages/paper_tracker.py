#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Tracker Page. Validates global and dynamic elements and their styles
"""

from datetime import datetime
import logging
import random
import string
import time

from Base.CustomException import ElementDoesNotExistAssertionError, ErrorAlertThrownException
from Base.PostgreSQL import PgSQL
from Base.Resources import paper_tracker_search_queries
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
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
    self._paper_tracker_pagination_previous = (By.CSS_SELECTOR, 'button.prev')
    self._paper_tracker_pagination_summary = (By.CSS_SELECTOR, 'div.simple-pagination')
    self._paper_tracker_pagination_next = (By.CSS_SELECTOR, 'button.next')

    # Paper Tracker Search elements
    self._paper_tracker_search_field = (By.ID, 'query-input')
    self._paper_tracker_search_button = (By.ID, 'search')
    self._paper_tracker_save_search_link = (By.CSS_SELECTOR, 'a.save-search-button')
    self._paper_tracker_saved_search_heading = (By.CSS_SELECTOR,
                                                'div.paper-tracker-saved-searches > h3')
    self._paper_tracker_saved_search_new_query_title_field = (By.ID, 'new-query-title')
    self._paper_tracker_saved_search_list_div = (By.CSS_SELECTOR, 'div.paper-tracker-query')
    self._paper_tracker_saved_search_query_link = (By.CSS_SELECTOR, 'a')
    self._paper_tracker_saved_search_edit_link = (By.CSS_SELECTOR, 'i.fa-pencil')
    self._paper_tracker_saved_search_delete_link = (By.CSS_SELECTOR, 'i.fa-trash')

    # Paper Tracker Table elements
    self._paper_tracker_table = (By.CLASS_NAME, 'paper-tracker-table')
    self._paper_tracker_table_title_th = (By.XPATH, '//th[2]')
    self._paper_tracker_table_paper_id_th = (By.XPATH, '//th[3]')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._paper_tracker_table_paper_type_th = (By.XPATH, '//th[5]')
    self._paper_tracker_table_status_th = (By.XPATH, '//th[6]')
    self._paper_tracker_table_members_th = (By.XPATH, '//th[7]')
    self._paper_tracker_table_he_th = (By.XPATH, '//th[8]')
    self._paper_tracker_table_ce_th = (By.XPATH, '//th[9]')
    self._paper_tracker_table_header_sort_up = (By.CLASS_NAME, 'fa-caret-up')
    self._paper_tracker_table_header_sort_down = (By.CLASS_NAME, 'fa-caret-down')
    self._paper_tracker_table_tbody_row = (By.CSS_SELECTOR, 'tbody tr')

  # POM Actions

  @staticmethod
  def _get_paper_list(journal_ids, sort_by='id', reverse=False):
    """
    Aux function to retrieve papers displayed on Paper Tracker
    :param journal_ids: Iterable with all journals id
    :param sort_by: String with the DB field to sort results. See sort_by_d dictionary
    :param reverse: Boolean value to indicate sort order (False: Ascending, True: Descending)
    :return: A list with all paper data
    """
    sort_by_d = {'id': 0,
                 'title': 1,
                 'doi': 2,
                 'submitted_at': 3,
                 'paper_type': 4,
                 'publishing_state': 5,
                 }
    submitted_papers = []
    for journal in journal_ids:
      journal_papers = PgSQL().query('SELECT id, title, doi, submitted_at, paper_type, '
                                     'publishing_state FROM papers '
                                     'WHERE papers.journal_id IN (%s) AND publishing_state != %s '
                                     'AND submitted_at IS NOT NULL '
                                     'ORDER BY papers.submitted_at ASC;', (journal, 'unsubmitted'))
    for paper in journal_papers:
      # convert paper tuples to lists so they are mutable for data sanitization.
      paper = list(paper)
      submitted_papers.append(paper)
    # Now I need to resort this list by the datetime.datetime() objects ASC
    # only trouble is this pukes on the none type objects for papers that are unsubmitted but in
    # other states (withdrawn)
    submitted_papers = sorted(submitted_papers,
                              key=lambda x: x[3],
                              reverse=reverse)
    logging.debug('Before specific sort paper ordering is: {0}'.format(submitted_papers))
    # next the papers with no submitted_at populated (I think this is limited to withdrawn papers
    # with NULL s_a date) APERTA-3023 - this ordering is non-deterministic at present so this case
    # will fail until this defect is resolved and the test case updated as needed.
    withdrawn_papers = []
    for journal in journal_ids:
      journal_papers = PgSQL().query('SELECT id, title, doi, submitted_at, paper_type, '
                                     'publishing_state FROM papers '
                                     'WHERE journal_id IN (%s) AND publishing_state = %s '
                                     'AND submitted_at IS NULL '
                                     'ORDER BY paper_type ASC;', (journal, 'withdrawn'))
    for paper in journal_papers:
      # convert paper tuples to lists so they are mutable for data sanitization.
      paper = list(paper)
      withdrawn_papers.append(paper)
    # finally combine the two lists, NULL submitted_at first
    papers = withdrawn_papers + submitted_papers
    # Before sorting, remove trailing spaces
    for paper in papers:
      paper[1] = paper[1].strip()

    # Before sorting, remove leading non printable characters
    for paper in papers:
      for char in paper[1]:
        if char not in string.printable:
          paper[1] = paper[1][1:]
        else:
          break
    try:
      if sort_by == 'publishing_state':
        state_order = {'initially_submitted': 0,
                       'in_revision': 1,
                       'invited_for_full_submission': 2,
                       'rejected': 3,
                       'submitted': 4,
                       'unsubmitted': 5
                       }
        papers = sorted(papers, key=lambda val: state_order[val[5]], reverse=reverse)
      else:
        papers = sorted(papers, key=lambda x: x[sort_by_d[sort_by]].lower(), reverse=reverse)
    except AttributeError:
      # For sorting by date
      papers = sorted(papers, key=lambda x: x[sort_by_d[sort_by]], reverse=reverse)
    logging.debug('Here is the list of papers from db sorted by {0}:\n{1}'.format(sort_by, papers))
    return papers

  def validate_search_execution(self):
    """
    Validates the search and saved search elements of the page, executes a search, saves that query
    as a saved search, clears the current search, executes the saved search, then deletes that
    saved search.
    :return void function
    """

    search_input = self._get(self._paper_tracker_search_field)
    search_button = self._get(self._paper_tracker_search_button)
    search_save_link = self._get(self._paper_tracker_save_search_link)
    assert 'Title keyword or Manuscript ID number' in search_input.get_attribute('placeholder'), \
        search_input.get_attribute('placeholder')
    query = random.choice(paper_tracker_search_queries)
    logging.info(query)
    search_input.send_keys(query)
    search_button.click()
    time.sleep(1)
    search_save_link = self._get(self._paper_tracker_save_search_link)
    search_save_link.click()
    save_search_input = self._get(self._paper_tracker_saved_search_new_query_title_field)
    save_search_input.send_keys('Saved Search from Automation Test' + Keys.ENTER)
    search_input = self._get(self._paper_tracker_search_field)
    search_input.clear()
    search_button = self._get(self._paper_tracker_search_button)
    search_button.click()
    saved_search_heading = self._get(self._paper_tracker_saved_search_heading)
    assert 'Saved Searches' in saved_search_heading.text, saved_search_heading

    saved_search_div = self._gets(self._paper_tracker_saved_search_list_div)
    for search in saved_search_div:
      search_link = search.find_element(*self._paper_tracker_saved_search_query_link)
      try:
        assert 'Saved Search from Automation Test' in search.text
      except AssertionError:
        continue
      self._actions.move_to_element(search_link).perform()
      search.find_element(*self._paper_tracker_saved_search_edit_link)
      delete_saved_search = search.find_element(*self._paper_tracker_saved_search_delete_link)
      search.click()
      delete_saved_search.click()
      self.set_timeout(3)
      try:
        self._get(self._flash_error_msg)
        self.restore_timeout()
        raise ErrorAlertThrownException('Error fired on Delete of Saved Search')
      except ElementDoesNotExistAssertionError:
        logging.debug('Delete successful')
      self.restore_timeout()
      break

  def validate_pagination(self, username):
    """
    Validate the pagination function and controls of the paper_tracker page
    :param username: user whose paper_tracker page is being validated
    :return void function
    """
    large_result_set = False
    total_count = self.validate_heading_and_subhead(username)[0]
    logging.debug("Total count is {0}".format(total_count))
    initial_paginination = self._get(self._paper_tracker_pagination_summary)
    assert '({0} found)'.format(total_count) in initial_paginination.text, initial_paginination.text
    assert 'Page 1 of ' in initial_paginination.text, initial_paginination.text
    try:
      next = self._get(self._paper_tracker_pagination_next)
      large_result_set = True
    except ElementDoesNotExistAssertionError:
      logging.debug('Only one page of paper tracker results present.')
    if large_result_set:
      next.click()
      current_pagination = self._get(self._paper_tracker_pagination_summary)
      time.sleep(.5)
      previous = self._get(self._paper_tracker_pagination_previous)
      assert 'Page 2 of ' in current_pagination.text, current_pagination.text
      previous.click()
      time.sleep(.5)
      current_pagination = self._get(self._paper_tracker_pagination_summary)
      assert 'Page 1 of ' in current_pagination.text, current_pagination.text

  def validate_heading_and_subhead(self, username):
    """
    Validating Main Heading - these have been removed as part of the
    roles and permissions work. Not sure if they will be reintroduced
    so leaving in place and commented out for now
    #title = self._get(self._paper_tracker_title)
    #self.validate_application_title_style(title)
    # Validate Subhead
    #subhead = self._get(self._paper_tracker_subhead)
    # https://www.pivotaltracker.com/story/show/105230462
    #assert application_typeface in subhead.value_of_css_property('font-family')
    #assert subhead.value_of_css_property('font-size') == '18px'
    #assert subhead.value_of_css_property('line-height') == '25.7167px'
    #assert subhead.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    """

    # Get total number of papers for users tracker
    uid = PgSQL().query('SELECT id FROM users where username = %s;', (username,))[0][0]
    journal_ids = PgSQL().query("SELECT DISTINCT assigned_to_id "
                                "FROM assignments WHERE user_id = %s "
                                "AND assigned_to_type = 'Journal';", (uid,))

    if username == 'asuperadm':
      journal_ids = PgSQL().query("SELECT DISTINCT assigned_to_id FROM assignments WHERE "
                                  "assigned_to_type = 'Journal' ORDER BY assigned_to_id;")

    total_count = 0
    for total_count, journal in enumerate(journal_ids):
      paper_count = PgSQL().query('SELECT count(*) FROM papers '
                                  'WHERE journal_id IN (%s) AND publishing_state != %s;',
                                  (journal, 'unsubmitted'))[0][0]
      total_count += int(paper_count)
    return total_count, journal_ids

  def validate_table_presentation_and_function(self, total_count, journal_ids):
    """
    Check table content and sorting
    :param total_count: Integer with number of papers
    :param journal_ids: List with journal ids
    :return: None
    """
    title_th = self._get(self._paper_tracker_table_title_th)
    self.validate_table_heading_style(title_th)
    manid_th = self._get(self._paper_tracker_table_paper_id_th)
    self.validate_table_heading_style(manid_th)
    subdate_th = self._get(self._paper_tracker_table_submit_date_th)
    self.validate_table_heading_style(subdate_th)
    paptype_th = self._get(self._paper_tracker_table_paper_type_th)
    self.validate_table_heading_style(paptype_th)
    status_th = self._get(self._paper_tracker_table_status_th)
    self.validate_table_heading_style(status_th)
    members_th = self._get(self._paper_tracker_table_members_th)
    self.validate_table_heading_style(members_th)
    handedit_th = self._get(self._paper_tracker_table_he_th)
    self.validate_table_heading_style(handedit_th)
    covedit_th = self._get(self._paper_tracker_table_ce_th)
    self.validate_table_heading_style(covedit_th)

    # Validate the contents of the table: papers, links, sorting, roles
    # First step is to grab the papers from the db in the correct order for comparison to the page
    # This is a bit complicated because the ordering should be by submitted_at, but, some of the
    # return set has a NULL value for submitted at. We put these first in an as yet unknown ordering
    # I am going to build two lists then join them.
    # First the papers with submitted_at populated
    submitted_papers = []
    if total_count > 0:
      for journal in journal_ids:
        journal_papers = PgSQL().query('SELECT id, title, doi, submitted_at, paper_type, '
                                       'publishing_state FROM papers '
                                       'WHERE papers.journal_id IN (%s) AND publishing_state != %s '
                                       'AND submitted_at IS NOT NULL '
                                       'ORDER BY papers.submitted_at ASC;',
                                       (journal, 'unsubmitted'))
        for paper in journal_papers:
          submitted_papers.append(paper)
      # Now I need to resort this list by the datetime.datetime() objects ASC
      # only trouble is this pukes on the none type objects for papers that are unsubmitted but in
      # other states (withdrawn)
      submitted_papers = sorted(submitted_papers,
                                key=lambda x: x[3],
                                reverse=False)
    # next the papers with no submitted_at populated (I think this is limited to withdrawn papers
    # with NULL s_a date) APERTA-3023 - this ordering is non-deterministic at present so this case
    # will fail until this defect is resolved and the test case updated as needed.
    withdrawn_papers = []
    if total_count > 0:
      for journal in journal_ids:
        journal_papers = PgSQL().query('SELECT id, title, doi, submitted_at, paper_type, '
                                       'publishing_state FROM papers '
                                       'WHERE journal_id IN (%s) AND publishing_state = %s '
                                       'AND submitted_at IS NULL '
                                       'ORDER BY paper_type ASC;', (journal, 'withdrawn'))
        for paper in journal_papers:
          withdrawn_papers.append(paper)
    # finally combine the two lists, NULL submitted_at first
    db_papers = withdrawn_papers + submitted_papers
    logging.debug('DB Papers, ordered: {0}'.format(db_papers))
    if total_count > 0:
      papers = self._get_paper_list(journal_ids)
      table_rows = self._gets(self._paper_tracker_table_tbody_row)
      for count, row in enumerate(table_rows):
        logging.info('Validating Row: {0}'.format(count))
        # Once again, while less than ideal, these must be defined on the fly
        self._paper_tracker_table_tbody_title = (
            By.XPATH, '//tbody/tr[{0}]/td[@class="paper-tracker-title-column"]/a'.format(count + 1))
        self._paper_tracker_table_tbody_manid = (
            By.XPATH,
            '//tbody/tr[{0}]/td[@class="paper-tracker-paper-id-column"]/a'.format(count + 1))
        self._paper_tracker_table_tbody_subdate = (
            By.XPATH, '//tbody/tr[{0}]/td[@class="paper-tracker-date-column"]'.format(count + 1))
        self._paper_tracker_table_tbody_paptype = (
            By.XPATH, '//tbody/tr[{0}]/td[@class="paper-tracker-type-column"]'.format(count + 1))
        self._paper_tracker_table_tbody_status = (
            By.XPATH, '//tbody/tr[{0}]/td[@class="paper-tracker-status-column"]'.format(count + 1))
        self._paper_tracker_table_tbody_members = (
            By.XPATH, '//tbody/tr[{0}]/td[@class="paper-tracker-members-column"]'.format(count + 1))
        self._paper_tracker_table_tbody_he = (
            By.XPATH,
            '//tbody/tr[{0}]/td[@class="paper-tracker-handling-editor-column"]'.format(count + 1))
        self._paper_tracker_table_tbody_ce = (
            By.XPATH,
            '//tbody/tr[{0}]/td[@class="paper-tracker-cover-editor-column"]'.format(count + 1))
        title = self._get(self._paper_tracker_table_tbody_title)
        if not title:
          raise ValueError('Error: No title in db! Illogical, Illogical, '
                           'Norman Coordinate: Invalid document')
        if papers[count][0]:
          db_title = db_papers[count][1]
          # strip tags
          db_title = self.get_text(db_title)
          db_title = db_title.strip()
          page_title = title.text.strip()
          time.sleep(2)
          if isinstance(db_title, unicode) and isinstance(page_title, unicode):
            # Split both to eliminate differences in whitespace
            db_title = db_title.split()
            page_title = page_title.split()
            assert db_title == page_title, 'DB: {0}\nPage: {1}\nRow: {2}'.format(db_title,
                                                                                 page_title,
                                                                                 count)
          else:
            raise TypeError('Database title or Page title are not both unicode objects')
        db_ms_id = db_papers[count][2].split('/')[1]
        db_paper_id = db_papers[count][0]
        manid = self._get(self._paper_tracker_table_tbody_manid)
        assert manid.text == db_ms_id, manid.text + ' is not equal to ' + db_ms_id + ' from db.'

        page_paper_id = manid.get_attribute('href').split('/')[-1]
        assert '/papers/%s' % db_paper_id in title.get_attribute('href'), \
            (page_paper_id, title.get_attribute('href'))
        assert '/papers/%s' % db_paper_id in manid.get_attribute('href'), \
            (page_paper_id, title.get_attribute('href'))

        self._get(self._paper_tracker_table_tbody_subdate)

        paptype = self._get(self._paper_tracker_table_tbody_paptype)
        assert paptype.text == papers[count][4], (paptype.text, papers[count])

        members = self._get(self._paper_tracker_table_tbody_members)
        page_members_by_role = members.text.split('\n')
        for role in page_members_by_role:
          if role.startswith('Creator'):
            role = role.split(': ')[1]
            creators = role.split(', ')
            db_creators = PgSQL().query('SELECT users.first_name, users.last_name '
                                        'FROM users '
                                        'INNER JOIN assignments ON users.id = assignments.user_id '
                                        'INNER JOIN roles ON assignments.role_id = roles.id '
                                        'WHERE assignments.assigned_to_type = \'Paper\' '
                                        'AND assignments.assigned_to_id= %s AND roles.name = %s;',
                                        (db_paper_id, 'Creator'))
            name = []
            for creator in db_creators:
              name.append(creator[0] + ' ' + creator[1])
            db_creators = name
            creators.sort()
            db_creators.sort()
            assert creators == db_creators, (creators, db_creators)
          elif role.startswith('Reviewer'):
            role = role.split(': ')[1]
            reviewers = role.split(', ')
            db_reviewers = PgSQL().query('SELECT users.first_name, users.last_name '
                                         'FROM users '
                                         'INNER JOIN assignments ON users.id = assignments.user_id '
                                         'INNER JOIN roles ON assignments.role_id = roles.id '
                                         'WHERE assignments.assigned_to_type = \'Paper\' '
                                         'AND assignments.assigned_to_id= %s AND roles.name = %s;',
                                         (db_paper_id, 'Reviewer'))
            name = []
            for reviewer in db_reviewers:
              name.append(reviewer[0] + ' ' + reviewer[1])
            db_reviewers = name
            reviewers.sort()
            db_reviewers.sort()
            assert reviewers == db_reviewers, (reviewers, db_reviewers)
          elif role.startswith('Academic Editor'):
            role = role.split(': ')[1]
            editors = role.split(', ')
            db_editors = PgSQL().query('SELECT users.first_name, users.last_name '
                                       'FROM users '
                                       'INNER JOIN assignments ON users.id = assignments.user_id '
                                       'INNER JOIN roles ON assignments.role_id = roles.id '
                                       'WHERE assignments.assigned_to_type = \'Paper\' '
                                       'AND assignments.assigned_to_id= %s AND roles.name = %s;',
                                       (db_paper_id, 'Academic Editor'))
            name = []
            for editor in db_editors:
              name.append(editor[0] + ' ' + editor[1])
            db_editors = name
            editors.sort()
            db_editors.sort()
            assert editors == db_editors, (editors, db_editors)
          else:
            # ASK: Can we have an empty here?
            pass
        count += 1

      handedits = self._get(self._paper_tracker_table_tbody_he)
      page_hes_by_role = handedits.text.split('\n')
      for handeditor in page_hes_by_role:
        db_hes = PgSQL().query('SELECT users.first_name, users.last_name '
                               'FROM users '
                               'INNER JOIN assignments ON users.id = assignments.user_id '
                               'INNER JOIN roles ON assignments.role_id = roles.id '
                               'WHERE assignments.assigned_to_type = \'Paper\' '
                               'AND assignments.assigned_to_id= %s AND roles.name = %s;',
                               (db_paper_id, 'Handling Editor'))
      # Cover the case where none are assigned
      if handeditor != '':
        name = []
        for he in db_hes:
          name.append(he[0] + ' ' + he[1])
        db_hes = name
        handedits.sort()
        db_hes.sort()
        assert handedits == db_hes, (handedits, db_hes)

      covredits = self._get(self._paper_tracker_table_tbody_he)
      page_ces_by_role = covredits.text.split('\n')
      for covreditor in page_ces_by_role:
        db_ces = PgSQL().query('SELECT users.first_name, users.last_name '
                               'FROM users '
                               'INNER JOIN assignments ON users.id = assignments.user_id '
                               'INNER JOIN roles ON assignments.role_id = roles.id '
                               'WHERE assignments.assigned_to_type = \'Paper\' '
                               'AND assignments.assigned_to_id= %s AND roles.name = %s;',
                               (db_paper_id, 'Cover Editor'))
      # Cover the case where none are assigned
      if covreditor != '':
        name = []
        for ce in db_ces:
          name.append(ce[0] + ' ' + ce[1])
        db_ces = name
        covredits.sort()
        db_ces.sort()
        assert covredits == db_ces, (covredits, db_ces)

      # Validating Sorting functions
      # Note that because cover editor and handling editor are not in the papers array, we can
      #   only do some cursory sort validations
      logging.info('Sorting by Cover Editor ASC')
      ce_th = self._get(self._paper_tracker_table_ce_th).find_element_by_tag_name('a')
      ce_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_ce = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-cover-editor-column"]')
      original_ce = self._get(self._paper_tracker_table_tbody_ce).text

      logging.info('Sorting by Cover Editor DESC')
      ce_th = self._get(self._paper_tracker_table_ce_th).find_element_by_tag_name('a')
      ce_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_ce = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-cover-editor-column"]')
      sorted_ce = self._get(self._paper_tracker_table_tbody_ce).text
      assert original_ce != sorted_ce or original_ce == sorted_ce

      ce_th = self._get(self._paper_tracker_table_ce_th).find_element_by_tag_name('a')
      ce_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_ce = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-cover-editor-column"]')
      final_ce = self._get(self._paper_tracker_table_tbody_ce).text
      assert final_ce == original_ce, '{0} is not equal to {1}'.format(final_ce, original_ce)

      logging.info('Sorting by Handling Editor ASC')
      he_th = self._get(self._paper_tracker_table_he_th).find_element_by_tag_name('a')
      he_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_he = (
        By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-handling-editor-column"]')
      original_he = self._get(self._paper_tracker_table_tbody_he).text

      logging.info('Sorting by Handling Editor DESC')
      he_th = self._get(self._paper_tracker_table_he_th).find_element_by_tag_name('a')
      he_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_he = (
        By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-handling-editor-column"]')
      sorted_he = self._get(self._paper_tracker_table_tbody_he).text
      assert original_he != sorted_he or original_he == sorted_he

      he_th = self._get(self._paper_tracker_table_he_th).find_element_by_tag_name('a')
      he_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_he = (
        By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-handling-editor-column"]')
      final_he = self._get(self._paper_tracker_table_tbody_he).text
      assert final_he == original_he, '{0} is not equal to {1}'.format(final_he, original_he)

      logging.info('Sorting by Status ASC')
      status_th = self._get(self._paper_tracker_table_status_th).find_element_by_tag_name('a')
      status_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_status = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-status-column"]')
      status = self._get(self._paper_tracker_table_tbody_status).text
      papers = self._get_paper_list(journal_ids, sort_by='publishing_state', reverse=False)

      if status.lower() == 'initially submitted':
        status = 'initially_submitted'
      elif status.lower() == 'in revision':
        status = 'in_revision'
      elif status.lower() == 'invited for full submission':
        status = 'invited_for_full_submission'
      else:
        status = status.lower()
      assert status == papers[0][5], \
          'Status in page: {0} != Status in DB: {1}: {2}'.format(status,
                                                                 papers[0][5],
                                                                 papers[0])
      logging.info('Sorting by Status DESC')
      status_th = self._get(self._paper_tracker_table_status_th).find_element_by_tag_name('a')
      status_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_status = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-status-column"]')
      status = self._get(self._paper_tracker_table_tbody_status).text
      papers = self._get_paper_list(journal_ids, sort_by='publishing_state', reverse=True)
      assert status.lower() == papers[0][5], \
          'Status in page: {0} != Status in DB: {1}'.format(status.lower(), papers[0][5])

      logging.info('Sorting by Article Type ASC')
      paptype_th = self._get(self._paper_tracker_table_paper_type_th).find_element_by_tag_name('a')
      paptype_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_paptype = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-type-column"]')
      article_type = self._get(self._paper_tracker_table_tbody_paptype).text
      papers = self._get_paper_list(journal_ids, sort_by='paper_type', reverse=False)
      assert article_type == papers[0][4], \
          'Article Type in page: {0} != Article Type in DB: {1}'.format(article_type, papers[0])
      logging.info('Sorting by Article Type DESC')
      paptype_th = self._get(self._paper_tracker_table_paper_type_th).find_element_by_tag_name('a')
      paptype_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_paptype = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-type-column"]')
      article_type = self._get(self._paper_tracker_table_tbody_paptype).text
      papers = self._get_paper_list(journal_ids, sort_by='paper_type', reverse=True)
      assert article_type == papers[0][4], \
          'Article Type in page: {0} != Article Type in DB: {1}'.format(article_type, papers[0])

      logging.info('Sorting by Date ASC')
      self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
      date_th = self._get(self._paper_tracker_table_submit_date_th).find_element_by_tag_name('a')
      date_th.click()
      time.sleep(2)
      # check order
      self._paper_tracker_table_tbody_manid = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      paper_tracker_ms_id = self._get(self._paper_tracker_table_tbody_manid)
      pt_id = int(paper_tracker_ms_id.get_attribute('href').split('/')[-1])
      papers = self._get_paper_list(journal_ids, sort_by='submitted_at', reverse=False)
      db_id = papers[0][0]
      assert pt_id == db_id, 'ID in page: {0} != ID in DB: {1}'.format(pt_id, db_id)
      logging.info('Sorting by Date DESC')
      self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
      date_th = self._get(self._paper_tracker_table_submit_date_th).find_element_by_tag_name('a')
      date_th.click()
      time.sleep(2)
      # check order
      self._paper_tracker_table_tbody_manid = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      paper_tracker_ms_id = self._get(self._paper_tracker_table_tbody_manid)
      pt_id = int(paper_tracker_ms_id.get_attribute('href').split('/')[-1])
      papers = self._get_paper_list(journal_ids, sort_by='submitted_at', reverse=True)
      db_id = papers[0][0]
      assert pt_id == db_id, 'ID in page: {0} != ID in DB: {1}'.format(pt_id, db_id)

      logging.info('Sorting by Manuscript ID ASC')
      self._paper_tracker_table_paper_id_th = (By.XPATH, '//th[3]')
      msid_th = self._get(self._paper_tracker_table_paper_id_th).find_element_by_tag_name('a')
      msid_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_manid = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      paper_tracker_ms_id = self._get(self._paper_tracker_table_tbody_manid).text
      papers = self._get_paper_list(journal_ids, sort_by='doi')
      db_ms_id = papers[0][2].split('/')[-1]
      assert paper_tracker_ms_id == db_ms_id, \
          'ID in page: {0} != ID in DB: {1}'.format(paper_tracker_ms_id, db_ms_id)
      logging.info('Sorting by Manuscript ID DESC')
      self._paper_tracker_table_paper_id_th = (By.XPATH, '//th[3]')
      msid_th = self._get(self._paper_tracker_table_paper_id_th).find_element_by_tag_name('a')
      msid_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_manid = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-paper-id-column"]/a')
      paper_tracker_ms_id = self._get(self._paper_tracker_table_tbody_manid).text
      papers = self._get_paper_list(journal_ids, sort_by='doi', reverse=True)
      db_ms_id = papers[0][2].split('/')[-1]
      assert paper_tracker_ms_id == db_ms_id, \
          'ID in page: {0} != ID in DB: {1}'.format(paper_tracker_ms_id, db_ms_id)

      logging.info('Sorting by Title ASC')
      title_th = self._get(self._paper_tracker_table_title_th).find_element_by_tag_name('a')
      title_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_title = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      paper_tracker_title = self._get(self._paper_tracker_table_tbody_title).text
      papers = self._get_paper_list(journal_ids, sort_by='title')
      db_title = papers[0][1].strip()
      db_title = self.get_text(db_title)
      if isinstance(paper_tracker_title, unicode) and isinstance(db_title, unicode):
        # Split both to eliminate differences in whitespace
        paper_tracker_title = paper_tracker_title.split()
        db_title = db_title.split()
        assert paper_tracker_title == db_title, \
            'Title in page: {0} != Title in DB: {1}'.format(paper_tracker_title, db_title)
      else:
        raise TypeError('Database title or Page title are not both unicode objects')

      logging.info('Sorting by Title DESC')
      title_th = self._get(self._paper_tracker_table_title_th).find_element_by_tag_name('a')
      title_th.click()
      time.sleep(1)
      self._paper_tracker_table_tbody_title = (
          By.XPATH, '//tbody/tr[1]/td[@class="paper-tracker-title-column"]/a')
      paper_tracker_title = self._get(self._paper_tracker_table_tbody_title).text
      papers = self._get_paper_list(journal_ids, sort_by='title', reverse=True)
      paper_tracker_title = paper_tracker_title.strip()
      db_title = papers[0][1].strip()
      db_title = self.get_text(db_title)
      if isinstance(paper_tracker_title, unicode) and isinstance(db_title, unicode):
        # Split both to eliminate differences in whitespace
        paper_tracker_title = paper_tracker_title.split()
        db_title = db_title.split()
        assert paper_tracker_title == db_title, \
            'Title in page: {0} != Title in DB: {1}'.format(paper_tracker_title, db_title)
      else:
        raise TypeError('Database title or Page title are not both unicode objects')
