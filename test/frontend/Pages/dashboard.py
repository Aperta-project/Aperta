#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import os
import random
import string
import time
import uuid

from psycopg2 import DatabaseError
from selenium.webdriver.common.by import By

from Base.Resources import docs
from Base.PostgreSQL import PgSQL
from authenticated_page import AuthenticatedPage, application_typeface

"""
A page model for the dashboard page that validates state-dependent element existence
and style and functionality of the View Invitations and Create New Submission flows
without executing an invitation accept or reject, and without a CNS creation.
"""

__author__ = 'jgray@plos.org'


class DashboardPage(AuthenticatedPage):
  """
  Model an Aperta dashboard page
  """
  def __init__(self, driver, url_suffix='/'):
    super(DashboardPage, self).__init__(driver, url_suffix)

    self.driver = driver
    # Locators - Instance members
    # Base Page Locators
    self._dashboard_top_menu_paper_tracker = (By.ID, 'nav-paper-tracker')
    self._dashboard_logo = (By.CLASS_NAME, 'dashboard-plos-logo')
    self._dashboard_invite_title = (By.CSS_SELECTOR, 'h2.welcome-message')
    self._dashboard_view_invitations_btn = \
        (By.CSS_SELECTOR, 'section.dashboard-section button.button-primary.button--green')
    self._dashboard_my_subs_title = \
        (By.CSS_SELECTOR, 'section#dashboard-my-submissions h2.welcome-message')
    self._dashboard_create_new_submission_btn = \
        (By.CSS_SELECTOR, 'section#dashboard-my-submissions button.button-primary.button--green')
    self._dash_active_section_title = (By.CSS_SELECTOR, 'thead.active-papers tr th')
    self._dash_active_role_th = (By.XPATH,
                                 "//div[@class='table-responsive'][1]/table/thead/tr/th[2]")
    self._dash_active_status_th = (By.XPATH,
                                   "//div[@class='table-responsive'][1]/table/thead/tr/th[3]")

    self._dash_active_title = (By.CSS_SELECTOR, 'td.active-paper-title a')
    self._dash_active_manu_id = (By.CSS_SELECTOR, 'td.active-paper-title a + div')
    self._dash_active_role = (By.CSS_SELECTOR, 'td.active-paper-title + td')
    self._dash_active_status = (By.CSS_SELECTOR, 'td.active-paper-title + td + td div')

    self._dash_inactive_section_title = (By.CSS_SELECTOR, 'thead.inactive-papers tr th')
    self._dash_inactive_role_th = (By.XPATH,
                                   "//div[@class='table-responsive'][2]/table/thead/tr/th[2]")
    self._dash_inactive_status_th = (By.XPATH,
                                     "//div[@class='table-responsive'][2]/table/thead/tr/th[3]")
    self._dash_inactive_title = (By.CSS_SELECTOR, 'td.inactive-paper-title a')
    self._dash_inactive_manu_id = (By.CSS_SELECTOR, 'td.inactive-paper-title a + div')
    self._dash_inactive_role = (By.CSS_SELECTOR, 'td.inactive-paper-title + td')
    self._dash_inactive_status = (By.CSS_SELECTOR, 'td.inactive-paper-title + td + td div')

    self._dashboard_paper_icon = (By.CLASS_NAME, 'manuscript-icon')
    self._dashboard_info_text = (By.CLASS_NAME, 'dashboard-info-text')

    # View Invitations Modal Static Locators
    self._view_invites_title = (By.CLASS_NAME, 'overlay-header-title')
    self._view_invites_invite_listing = (By.CSS_SELECTOR, 'div.pending-invitation')
    self._invite_yes_btn = (By.CSS_SELECTOR, 'p + button')
    self._invite_no_btn = (By.CSS_SELECTOR, 'p + button + button')
    self._view_invites_close = (By.CLASS_NAME, 'overlay-close-x')

    # Create New Submission Modal
    self._cns_base_overlay_div = (By.CSS_SELECTOR, 'div.overlay--fullscreen')
    self._cns_error_div = (By.CLASS_NAME, 'flash-messages')
    self._cns_error_message = (By.CLASS_NAME, 'flash-message-content')
    self._cns_title_field = (By.XPATH, './/div[@id="new-paper-title"]/div')
    self._cns_manuscript_title_label = (By.CLASS_NAME, 'paper-new-label')
    self._cns_manuscript_title_field = (By.CLASS_NAME, 'content-editable-muted')
    self._cns_manuscript_italic_icon = (By.CLASS_NAME, 'fa-italic')
    self._cns_manuscript_superscript_icon = (By.CLASS_NAME, 'fa-superscript')
    self._cns_manuscript_subscript_icon = (By.CLASS_NAME, 'fa-subscript')
    self._cns_journal_chooser_label = (By.XPATH, "//div[@class='overlay-body']/div/div[3]/label")
    self._cns_journal_chooser = (By.CSS_SELECTOR, 'div.paper-new-select-trigger')
    self._cns_paper_type_dd = (By.ID, 'paper-new-paper-type-select')
    self._cns_opened_option_dropdown = (By.CSS_SELECTOR, 'div.select-box-list')
    self._cns_option_dropdown_item = (By.CSS_SELECTOR, 'div.select-box-item')
    self._cns_paper_type_chooser_label = (By.XPATH, "//div[@class='overlay-body']/div/div[4]/label")
    self._cns_paper_type_chooser = (By.ID, 'paper-new-paper-type-select')
    self._cns_journal_chooser_dd = (By.ID, 'paper-new-journal-select')
    self._cns_journal_chooser_placeholder = (By.CLASS_NAME, 'ember-power-select-placeholder')
    self._cns_journal_chooser_active = (By.CLASS_NAME, 'select-box-element--active')
    self._cns_chooser_chosen = (By.CLASS_NAME, 'select-box-item')
    self._cns_chooser_dropdown_arrow = (By.CLASS_NAME, 'select2-arrow')
    self._cns_upload_document = (By.CLASS_NAME, 'fileinput-button')
    self._upload_btn = (By.CLASS_NAME, 'paper-new-upload-button')

    self._submitted_papers = (By.CLASS_NAME, 'dashboard-paper-title')
    # First article
    self._first_paper = (By.CSS_SELECTOR, 'div.table-responsive a')
    # View invitations
    self._invitations = (By.CSS_SELECTOR, 'div.pending-invitation')
    self._view_invitations = (By.TAG_NAME, 'button')
    self._yes_button = (By.TAG_NAME, 'button')
    self._yes_no_button = (By.CSS_SELECTOR, 'ul.dashboard-submitted-papers button')

  # POM Actions
  def click_on_existing_manuscript_link(self, title):
    """
    Click on a link given a title
    :param title: title to click
    :return: self
    """
    first_matching_manuscript_link = self._get((By.LINK_TEXT, title))
    first_matching_manuscript_link.click()
    return self

  def click_view_invitations(self):
    """Click on view invitations"""
    self._get(self._view_invitations).click()

  def accept_all_invitations(self):
    """Accepts all invitations"""
    invite_listings = self._gets(self._view_invites_invite_listing)
    for listing in invite_listings:
      yes_btn = listing.find_element(*self._invite_yes_btn)
      yes_btn.click()

  def accept_invitation(self, title):
    """
    Accepts a given invitation
    :param title: Title of the publication to accept the invitation
    :return: void function
    """
    invite_listings = self._gets(self._view_invites_invite_listing)
    for listing in invite_listings:
      try:
        # Remember to use single quotes outside to ensure you don't run afoul of
        #  a single quote in the title - More often, double-quotes in titles are
        #  rendered as smart quotes (unicode) so don't as often cause problems.
        self._driver.find_element_by_xpath('//*[contains(text(), "{0}")]'.format(title))
      except UnicodeEncodeError:
        self._driver.find_element_by_xpath('//*[contains(text(), "{0}")]'
                                           .format(title.encode('utf8')))
      yes_btn = listing.find_element(*self._invite_yes_btn)
      yes_btn.click()

  def accept_or_reject_invitation(self, title):
    """
    Returns a random response to a given invitation
    :param title: Title of the publication for the invitation
    :return: decision
    """
    choices = ['Accept', 'Reject']
    response = random.choice(choices)
    invite_listings = self._gets(self._view_invites_invite_listing)
    for listing in invite_listings:
      try:
        # Remember to use single quotes outside to ensure you don't run afoul of
        #  a single quote in the title - More often, double-quotes in titles are
        #  rendered as smart quotes (unicode) so don't as often cause problems.
        self._driver.find_element_by_xpath('//*[contains(text(), "{0}")]'.format(title))
      except UnicodeEncodeError:
        self._driver.find_element_by_xpath('//*[contains(text(), "{0}")]'
                                           .format(title.encode('utf8')))
      if response == 'Accept':
        yes_btn = listing.find_element(*self._invite_yes_btn)
        btn = yes_btn
      else:
        no_btn = listing.find_element(*self._invite_no_btn)
        btn = no_btn
      btn.click()
    return response

  def click_on_existing_manuscript_link_partial_title(self, partial_title):
    """
    Click on existing manuscript link using partial title
    :param partial_title: substring to match
    """
    first_article_link = self.driver.find_element_by_partial_link_text(partial_title)
    title = first_article_link.text
    first_article_link.click()
    return title

  def click_on_first_manuscript(self):
    """
    Click on first available manuscript link
    :return: String with manuscript title
    """
    first_article_link = self._get(self._first_paper)
    first_article_link.click()
    return first_article_link.text

  def get_upload_button(self):
    """Returns the upload button in the dashboard submit manuscript modal"""
    return self._get(self._cns_upload_document)

  def validate_initial_page_elements_styles(self):
    """
    Validates the static page elements existence and styles
    """
    logo = self._get(self._dashboard_logo)
    assert '/images/plos_logo.png' in logo.get_attribute('src'), logo.get_attribute('src')
    cns_btn = self._get(self._dashboard_create_new_submission_btn)
    assert cns_btn.text.lower() == 'create new submission'
    self.validate_primary_big_green_button_style(cns_btn)

  def validate_invite_dynamic_content(self, username):
    """
    Validates the "view invites" stanza and function if present
    :param username: username
    """
    invitation_count = self.is_invite_stanza_present(username)
    if invitation_count > 0:
      welcome_msg = self._get(self._dashboard_invite_title)
      if invitation_count == 1:
        assert welcome_msg.text == 'You have 1 invitation.', welcome_msg.text
      else:
        assert welcome_msg.text == 'You have {0} invitations.'.format(invitation_count), \
                                   '{0} {1}'.format(welcome_msg.text, str(invitation_count))
      self.validate_application_title_style(welcome_msg)
      view_invites_btn = self._get(self._dashboard_view_invitations_btn)
      self.validate_primary_big_green_button_style(view_invites_btn)

  def validate_manuscript_section_main_title(self, user):
    """
    Validates the title section of the manuscript presentation part of the page
    This is always present and follows the Invite section if present. The paper
    content of the active and inactive sections are presented separately.
    :param user: user dictionary for validating Dashboard welcome message
    :return: A tuple containing: (active_manuscripts (a count),
                                  active_manuscript_list (ordered by assignment.created_at),
                                  uid (of user))
    """
    logging.debug(user)
    username = user['user']
    welcome_msg = self._get(self._dashboard_my_subs_title)
    # Get first name for validation of dashboard welcome message
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = %s;',
                               (username,))[0][0]
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    # Get count of distinct papers from paper_roles for validating count of manuscripts on
    # dashboard welcome message
    active_manuscript_list = []
    try:
      activ_manu_unsbmtd_tuples = PgSQL().query('SELECT DISTINCT assignments.assigned_to_id, '
                                                'papers.updated_at '
                                                'FROM assignments '
                                                'JOIN roles ON assignments.role_id=roles.id '
                                                'JOIN papers ON '
                                                'papers.id=assignments.assigned_to_id '
                                                'WHERE assignments.user_id=%s AND '
                                                'roles.participates_in_papers=True AND '
                                                'assignments.assigned_to_type=\'Paper\' AND '
                                                'papers.publishing_state NOT '
                                                'IN (\'withdrawn\', \'rejected\', \'submitted\', '
                                                '\'checking\', \'initially_submitted\', '
                                                '\'in_revision\', \'invited_for_full_submission\') '
                                                'ORDER BY papers.updated_at DESC;', (uid,))
      # APERTA-6352 We are not correctly sorting active submitted documents on the dashboard
      active_manu_sbmtd_tuples = PgSQL().query('SELECT DISTINCT assignments.assigned_to_id, '
                                               'assignments.created_at '
                                               'FROM assignments '
                                               'JOIN roles ON assignments.role_id=roles.id '
                                               'JOIN papers ON '
                                               'papers.id=assignments.assigned_to_id '
                                               'WHERE assignments.user_id=%s AND '
                                               'roles.participates_in_papers=True AND '
                                               'assignments.assigned_to_type=\'Paper\' AND '
                                               'papers.publishing_state '
                                               'IN (\'submitted\', \'checking\', '
                                               '\'initially_submitted\', \'in_revision\', '
                                               '\'invited_for_full_submission\') '
                                               'ORDER BY assignments.created_at ASC;', (uid,))
      for amt in activ_manu_unsbmtd_tuples:
        active_manuscript_list.append(amt[0])
      for amt in active_manu_sbmtd_tuples:
        active_manuscript_list.append(amt[0])

      logging.info(active_manuscript_list)
    except DatabaseError:
      logging.error('Database access error.')
      raise
    active_manuscripts = len(active_manuscript_list)
    logging.info('Expecting {0} active manuscripts'.format(active_manuscripts))
    if active_manuscripts > 1:
      assert 'Hi, {0}. You have {1} active manuscripts.'.format(first_name, active_manuscripts) \
             in welcome_msg.text, welcome_msg.text + str(active_manuscripts)
    elif active_manuscripts == 1:
      assert 'Hi, {0}. You have {1} active manuscript.'.format(first_name, active_manuscripts) \
             in welcome_msg.text, welcome_msg.text + str(active_manuscripts)
    else:
      active_manuscripts = 0
      assert 'Hi, {0}. You have no manuscripts.'.format(first_name) \
             in welcome_msg.text, welcome_msg.text
    self.validate_application_title_style(welcome_msg)
    return active_manuscripts, active_manuscript_list, uid

  def validate_active_manuscript_section(self,
                                         uid,
                                         active_manuscript_count,
                                         active_manuscript_list):
    """
    Validates the display of the active manuscripts section of the dashboard. This may or may not
    be present.
    It consists of a title with a parenthetical count of active manuscripts and then a listing of
    each active manuscript ordered by submitted vs unsubmitted (with unsubmitted first) and display
    in descending order thereafter.
    :param uid: uid of the user under test
    :param active_manuscript_count: integer representing the total number of active manuscripts for
      uid
    :param active_manuscript_list: active_manuscript_list (paper.id ordered by
      assignments.created_at)
    :return: None
    """
    try:
      int(active_manuscript_count)
    except ValueError:
      print('Manuscript Count passed in to function is not an integer.')
      return False
    if active_manuscript_count == 0:
      print('No Active Manuscript Section expected')
      return
    else:
      self.set_timeout(1)
      active_section_title = self._get(self._dash_active_section_title)
      self.restore_timeout()
    if active_section_title:
      if active_manuscript_count == 1:
        number = 'Manuscript'
      else:
        number = 'Manuscripts'
      assert active_section_title.text == 'Active {0} ({1})'.format(number,
                                                                    str(active_manuscript_count))
      # APERTA-6352 The sorting of Active, submitted titles is incorrect, commenting out
      # self.validate_manu_dynamic_content(uid, active_manuscript_list, 'active')
      assert self._get(self._dash_active_role_th).text == 'Role'
      assert self._get(self._dash_active_status_th).text == 'Status'
    else:
      print('No manuscripts are active for user.')

  def validate_inactive_manuscript_section(self, uid):
    """
    Validates the display of the inactive manuscripts section of the dashboard. This may or may
      not be present.
    It consists of a title with a parenthetical count of inactive manuscripts (unsubmitted and
      rejected) and then a listing of each inactive manuscript ordered by role created_at in
      descending order thereafter.
    :param uid: uid of user under test (derived from Dashboard Title validation)
    :return: inactive_manuscript_count and inactive_manuscript_list (ordered by
      assignments.created_at)
    """
    logging.info('Validating Inactive manuscript display on dashboard')
    inactive_manuscript_list = []
    try:
      inactive_manuscripts_tuples = PgSQL().query('SELECT DISTINCT assignments.assigned_to_id, '
                                                  'papers.updated_at '
                                                  'FROM assignments '
                                                  'JOIN roles ON assignments.role_id=roles.id '
                                                  'JOIN papers ON '
                                                  'papers.id=assignments.assigned_to_id '
                                                  'WHERE assignments.user_id=%s AND '
                                                  'roles.participates_in_papers=True AND '
                                                  'assignments.assigned_to_type=\'Paper\' AND '
                                                  'papers.publishing_state '
                                                  'IN (\'withdrawn\', \'rejected\') '
                                                  'ORDER BY papers.updated_at DESC;', (uid,))
      for imt in inactive_manuscripts_tuples:
        inactive_manuscript_list.append(imt[0])
      logging.info(inactive_manuscript_list)
    except DatabaseError:
      logging.error('Database access error.')
      raise
    inactive_manuscripts = len(inactive_manuscript_list)
    if inactive_manuscripts <= 0:
      print('No manuscripts are inactive for user.')
    else:
      if inactive_manuscripts == 1:
        number = 'Manuscript'
      else:
        number = 'Manuscripts'
      inactive_section_title = self._get(self._dash_inactive_section_title)
      assert inactive_section_title.text == 'Inactive {0} ({1})'.format(number,
                                                                        str(inactive_manuscripts))
      assert self._get(self._dash_inactive_role_th).text == 'Role'
      assert self._get(self._dash_inactive_status_th).text == 'Status'
      # TODO: Correct this call for the new R&P
      self.validate_manu_dynamic_content(uid, inactive_manuscript_list, 'inactive')
    return inactive_manuscripts, inactive_manuscript_list

  def validate_no_manus_info_msg(self):
    """
    If there are both no active and no inactive manuscripts, we should present an informational
      message.
    :return: None
    """
    info_text = self._get(self._dashboard_info_text)
    assert info_text.text == 'Your scientific paper submissions will\nappear here.'
    assert application_typeface in info_text.value_of_css_property('font-family')
    assert info_text.value_of_css_property('font-size') == '24px'
    assert info_text.value_of_css_property('font-style') == 'italic'
    assert info_text.value_of_css_property('line-height') == '24px'
    assert info_text.value_of_css_property('color') == 'rgba(128, 128, 128, 1)'

  def validate_manu_dynamic_content(self, uid, manuscript_list, list_):
    """
    Validates the manuscript listings dynamic display based on assigned roles for papers. Papers
      should be ordered by paper_role.created_at DESC
    :param uid: uid of user for whom to validate dashboard section
    :param manuscript_list: list of documents for list_ type in assignments.created_at order
    :param list_: Whether we are validating the active or inactive list display
    :return: None
    """
    logging.info('Starting validation of {0} papers for user: {1}'.format(list_, uid))
    # We MUST validate that manuscript_count is > 0 for list before calling this
    if list_ == 'inactive':
      paper_tuple_list = []
      papers = self._gets(self._dash_inactive_title)
      manu_ids = self._gets(self._dash_inactive_manu_id)
      roles = self._gets(self._dash_inactive_role)
      statuses = self._gets(self._dash_inactive_status)
      db_papers_list = manuscript_list
      logging.info('The Inactive papers list from the db is {0}'.format(db_papers_list))
    else:
      papers = self._gets(self._dash_active_title)
      manu_ids = self._gets(self._dash_active_manu_id)
      roles = self._gets(self._dash_active_role)
      statuses = self._gets(self._dash_active_status)
      unsubmitted_list = []
      submitted_list = []
      for paper in manuscript_list:
        submitted_state = PgSQL().query('SELECT publishing_state '
                                        'FROM papers '
                                        'WHERE id=%s;', (paper,))
        if submitted_state == 'unsubmitted':
          unsubmitted_list.append(paper)
        else:
          submitted_list.append(paper)
      logging.info('The unsubmitted active papers list is {0}'.format(unsubmitted_list))
      logging.info('The submitted active papers list is {0}'.format(submitted_list))

      # Create one complete list from the two
      db_papers_list = unsubmitted_list + submitted_list
      logging.info('The Active papers list from the db is {0}'.format(db_papers_list))

    if db_papers_list:
      count = 0
      for paper in papers:  # List of papers for section from page
        # Validate paper title display and ordering
        # Get title of paper from db based on db ordered list of papers, then compare to papers
        #   ordered on page.
        title = PgSQL().query('SELECT title '
                              'FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        title = self.get_text(title)
        title = title.strip()
        # Split both to eliminate differences in whitespace
        db_title = title.split()
        paper_text = paper.text.split()
        logging.debug('db_title: {0}'.format(db_title))
        logging.debug('paper_text: {0}'.format(paper_text))
        if not title:
          logging.info('Paper id: {0}'.format(db_papers_list[count]))
          raise ValueError('Error: No title in db! Illogical, Illogical, Norman Coordinate: '
                           'Invalid document')
        if isinstance(title, unicode) and isinstance(paper.text, unicode):
          assert db_title == paper_text, \
              unicode(title) + unicode(' is not equal to ') + unicode(paper.text)
        else:
          raise TypeError('Database title or Page title are not both unicode objects')
        # Sort out paper role display
        paper_roles = PgSQL().query('SELECT old_role FROM paper_roles '
                                    'INNER JOIN papers ON papers.id = paper_roles.paper_id '
                                    'WHERE paper_roles.paper_id = %s AND '
                                    'paper_roles.user_id= %s '
                                    'ORDER BY paper_roles.created_at DESC;', (db_papers_list[count],
                                                                              uid))
        rolelist = []
        for role in paper_roles:
          rolelist.append(role[0])
        # print(db_papers_list[count])
        paper_owner = PgSQL().query('SELECT user_id '
                                    'FROM papers where id = %s;', (db_papers_list[count],))[0][0]
        if paper_owner == uid:
          rolelist.append('my paper')

        # Validate Status Display
        page_status = statuses[count].text
        dbstatus = PgSQL().query('SELECT publishing_state '
                                 'FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        # For display of status on the home page, we replace '_' with a space.
        transtab = string.maketrans('_', ' ')
        dbstatus = dbstatus.translate(transtab)
        if dbstatus == 'unsubmitted':
          dbstatus = 'draft'
        assert page_status.lower() == dbstatus.lower(), \
            page_status.lower() + ' is not equal to: ' + dbstatus.lower()

        # Validate Manuscript ID display
        dbmanuid = PgSQL().query('SELECT doi '
                                 'FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        manu_id = manu_ids[count].text
        manu_id = manu_id.split(': ')[1]
        logging.debug(manu_id)
        logging.debug(dbmanuid)
        dbmanuid = 'ID: {0}'.format(dbmanuid.split('/')[1]) if dbmanuid else 'ID:'
        assert manu_id in dbmanuid, '{0} not found in {1}'.format(manu_id, dbmanuid)
        # Finally increment counter
        count += 1

  def click_create_new_submission_button(self):
    """Click Create new submission button"""
    self._get(self._dashboard_create_new_submission_btn).click()
    return self

  def enter_title_field(self, title):
    """
    Enter title for the publication
    :param title: Title you wish to use for your paper
    """
    title_field = self._get(self._cns_title_field)
    title_field.click()
    title_field.send_keys(title)

  def click_upload_button(self):
    """Click create button"""
    self._get(self._upload_btn).click()

  def close_cns_overlay(self):
    """Click X link"""
    self._get(self._overlay_header_close).click()

  def select_journal_and_type(self, journal, paper_type):
    """
    Select a journal with its type
    :param journal: Title of the journal
    :param paper_type: Paper type
    :return: void function
    """
    journal_dd, type_dd = self._gets((By.CLASS_NAME, 'ember-basic-dropdown-trigger'))
    journal_dd.click()
    time.sleep(.5)
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))

    # for item in self._gets((By.CLASS_NAME, 'select-box-item')):
    for item in parent_div.find_elements_by_tag_name('li'):
      if item.text == journal:
        item.click()
        time.sleep(1)
        break
    selected_journal = self._get(self._cns_journal_chooser)
    assert journal in selected_journal.text, '{0} != {1}'.format(selected_journal.text, journal)
    # Time to change select contents
    time.sleep(.1)
    type_dd.click()
    # Note have to recall this element here because is not the same as last call
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))
    # div.find_element_by_class_name('ember-power-select-options').click()
    for item in self._gets((By.CLASS_NAME, 'ember-power-select-option')):
      if item.text == paper_type:
        item.click()
        time.sleep(1)
        break
    selected_type = self._gets(self._cns_paper_type_dd)
    assert paper_type in selected_type[0].text, '{0} != {1}'.format(selected_type.text, paper_type)

  def select_journal_get_types(self, journal):
    """
    Select a journal and get the ordered type list
    :param journal: Title of the journal
    :return paper_type list: ordered list of paper_types
    """
    journal_dd, type_dd = self._gets((By.CLASS_NAME, 'ember-basic-dropdown-trigger'))
    journal_dd.click()
    time.sleep(.5)
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))

    # for item in self._gets((By.CLASS_NAME, 'select-box-item')):
    for item in parent_div.find_elements_by_tag_name('li'):
      if item.text == journal:
        item.click()
        time.sleep(1)
        break
    selected_journal = self._get(self._cns_journal_chooser)
    assert journal in selected_journal.text, '{0} != {1}'.format(selected_journal.text, journal)
    # Time to change select contents
    time.sleep(.1)
    type_dd.click()
    # Note have to recall this element here because is not the same as last call
    parent_div = self._get((By.ID, 'ember-basic-dropdown-wormhole'))
    ordered_pap_type_list = []
    for item in self._gets((By.CLASS_NAME, 'ember-power-select-option')):
      ordered_pap_type_list.append(item.text)
    return ordered_pap_type_list

  @staticmethod
  def title_generator(prefix='', random_bit=True):
    """
    Creates a new unique title
    :param prefix: string to prepend to generated string
    :param random_bit: If true generate unique uuid
    :return: generated title
    """
    if not prefix:
      return str(uuid.uuid4())
    elif prefix and random_bit:
      return '{0} {1}'.format(prefix, uuid.uuid4())
    elif prefix and not random_bit:
      return prefix

  def click_view_invites_button(self):
    """Click View Invitations button"""
    self._get(self._dashboard_view_invitations_btn).click()
    return self

  @staticmethod
  def is_invite_stanza_present(username):
    """
    Determine whether the View Invites stanza should be present for username
    :param username: a user object tuple bearing a full name ('name'),
                                                 a username ('user'), and
                                                 an email address ('email')
    :return: Count of unaccepted invites (does not include rejected or accepted invites)
    """
    username = username['user']
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    invitation_count = PgSQL().query('SELECT COUNT(*) FROM invitations '
                                     'WHERE state = %s '
                                     'AND invitee_id = %s;', ('invited', uid))[0][0]
    return invitation_count

  def validate_view_invites(self, username):
    """
    Validates the display of the View Invites overlay and the dynamic presentation of the
    current pending invitations for username.
    :param username: username
    """
    # global elements
    logging.info(username)
    modal_title = self._get(self._view_invites_title)
    self.validate_application_title_style(modal_title)
    assert application_typeface in modal_title.value_of_css_property('font-family'), \
        modal_title.value_of_css_property('font-family')
    assert modal_title.value_of_css_property('font-size') == '48px', \
        modal_title.value_of_css_property('font-size')
    assert modal_title.value_of_css_property('font-weight') == '500', \
        modal_title.value_of_css_property('font-weight')
    # TODO: APERTA-3013 Re-enable check when issue resolved.
    # assert modal_title.value_of_css_property('line-height') == '43.2px', \
    #     modal_title.value_of_css_property('line-height')
    assert modal_title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', \
        modal_title.value_of_css_property('color')
    # per invite elements
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    invitations = PgSQL().query('SELECT task_id FROM invitations '
                                'WHERE state = %s AND invitee_id = %s;', ('invited', uid))
    tasks = []
    for invite in invitations:
      tasks.append(invite[0])
    count = 1
    for task in tasks:
      paper_id = PgSQL().query('SELECT paper_id FROM tasks '
                               'WHERE tasks.id = %s;', (task,))[0][0]
      title = PgSQL().query('SELECT title FROM papers WHERE id = %s;', (paper_id,))[0][0]
      # TODO: APERTA-3000 The ultimate plan here is to compare titles from the database to those
      # presented on the page, however, the ordering of the presentation of the invite blocks is
      # currently non-deterministic, so this can't currently be done.
      # For the time being, just printing the titles to the test run log
      logging.info('Title from the database: \n{0}'.format(title))
      # The following locators are dynamically assigned and must be defined inline in this loop to
      #   succeed.
      self._view_invites_pending_invite_div = \
          (By.XPATH, '//div[@class="pending-invitation"][' + str(count) + ']')
      self._view_invites_pending_invite_heading = (By.TAG_NAME, 'h4')
      self._view_invites_pending_invite_paper_title = (By.CSS_SELECTOR,
                                                       'li.dashboard-paper-title h3')
      self._view_invites_pending_invite_manuscript_icon = (By.CLASS_NAME, 'manuscript-icon')
      self._view_invites_pending_invite_abstract = (By.CSS_SELECTOR, 'li.dashboard-paper-title p')
      self._view_invites_pending_invite_yes_btn = (By.CSS_SELECTOR,
                                                   'li.dashboard-paper-title button')
      self._view_invites_pending_invite_no_btn = (By.XPATH,
                                                  '//li[@class="dashboard-paper-title"]/button[2]')

      self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_heading)
      pt = self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_paper_title)
      logging.info('Title presented on the page: \n{0}'.format(pt.text.encode('utf-8')))
      self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_manuscript_icon)
      self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_abstract)
      self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_yes_btn)
      self._get(self._view_invites_pending_invite_div)\
          .find_element(*self._view_invites_pending_invite_no_btn)
      count += 1
    self._get(self._overlay_header_close).click()
    time.sleep(1)

  def validate_create_new_submission(self):
    """
    Validates the function of the Create New Submissions button, and the elements and error handling
    of the overlay that the CNS button launches.
    :return: None
    """
    overlay_title = self._get(self._overlay_header_title)
    closer = self._get(self._overlay_header_close)
    assert overlay_title.text == 'Create a New Submission'
    manuscript_title_field_label = self._get(self._cns_manuscript_title_label)
    assert manuscript_title_field_label.text == 'Give your paper a title'
    manuscript = self._get(self._cns_manuscript_title_field)
    assert manuscript.get_attribute('placeholder') == 'Crystalized Magnificence in the Modern World'
    # For the time being only validating the presence of these as they may be removed
    self._get(self._cns_manuscript_italic_icon)
    self._get(self._cns_manuscript_superscript_icon)
    self._get(self._cns_manuscript_subscript_icon)
    journal_chooser_label = self._get(self._cns_journal_chooser_label)
    assert 'What journal are you submitting to?' in journal_chooser_label.text, \
        journal_chooser_label.text
    journal_chooser = self._get((By.CLASS_NAME, 'ember-power-select-placeholder'))
    assert 'Select a journal' in journal_chooser.text, journal_chooser.text
    paper_type_chooser_label = self._get(self._cns_paper_type_chooser_label)
    assert "Choose the type of paper you're submitting" in paper_type_chooser_label.text, \
        paper_type_chooser_label.text
    paper_type_chooser = self._get(self._cns_paper_type_chooser)
    assert "Select a paper type" in paper_type_chooser.text, paper_type_chooser.text
    upload_btn = self._get(self._upload_btn)
    doc2upload = random.choice(docs)
    fn = os.path.join(os.getcwd(), 'frontend/assets/docs/', doc2upload)
    logging.info('Sending document: {0}'.format(fn))
    if os.path.isfile(fn):
      self._driver.find_element_by_id('upload-files').send_keys(fn)
    else:
      raise IOError('Docx file: {0} not found'.format(doc2upload))
    self.click_upload_button()
    # TODO: Check this when fixed bug APERTA-2831 is resolved
    # self.validate_secondary_big_green_button_style(upload_btn)
    self._get(self._cns_error_div)
    error_msgs = self._gets(self._cns_error_message)
    # I can't quite make out why the previous returns two iterations of the error messages, but,
    # this fixes it
    for i in range(len(error_msgs) / 2):
      error_msgs.pop()
    errors = []
    for error in error_msgs:
      error = error.text.split('\n')[0]
      errors.append(error)
    assert 'Journal can\'t be blank' in errors
    assert 'Paper type can\'t be blank' in errors
    closer.click()

  def validate_mmt_ordering(self, journals=()):
    """
    Validates that the manuscript manager templates are listed in order of creation on the
      create new manuscript overlay paper_type drop-down list
    :param journals: a list of journal tuples (id, name) for which to validate the order.
      Defaults to all journals
    :return:
    """
    # Open the overlay
    self.click_create_new_submission_button()
    if not journals:
      # First things first, get the list of journal names and their ids
      journal_info = PgSQL().query('SELECT id, name FROM journals;')
    else:
      list(journals)
      journal_info = journals
    for journal_entry in journal_info:
      mmt_list = []
      journal_id, journal_name = journal_entry
      # Get list of mmts for journal in id order ASC
      ordered_mmts = PgSQL().query('SELECT paper_type FROM manuscript_manager_templates '
                                   'WHERE journal_id = %s ORDER BY id ASC;', (journal_id,))
      # turn db returned tuples into a simple list
      for mmt in ordered_mmts:
        mmt_list.append(mmt[0])
      # Now look at the ordering in the interface
      page_paper_type_list = self.select_journal_get_types(journal_name)
      assert mmt_list == page_paper_type_list, '{0} != {1}'.format(mmt_list, page_paper_type_list)
    self.close_modal()
    time.sleep(1)

  def return_cns_base_overlay_div(self):
    """Method for debugging purposes only"""
    return self._get(self._cns_base_overlay_div)
