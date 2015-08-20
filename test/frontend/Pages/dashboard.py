#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A page model for the dashboard page that validates state-dependent element existence
and style and functionality of the View Invitations and Create New Submission flows
without executing an invitation accept or reject, and without a CNS creation.
"""

import time
import uuid

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.PostgreSQL import PgSQL
from authenticated_page import AuthenticatedPage


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
    self._dashboard_invite_title = (By.CSS_SELECTOR, 'h2.welcome-message')
    self._dashboard_view_invitations_btn = (By.CSS_SELECTOR,
                                            'section.dashboard-section button.button-primary.button--green')
    self._dashboard_my_subs_title = (By.CSS_SELECTOR, 'section#dashboard-my-submissions h2.welcome-message')
    self._dashboard_create_new_submission_btn = (By.CSS_SELECTOR,
                                                 'section#dashboard-my-submissions button.button-primary.button--green')
    self._dashboard_paper_title = (By.CSS_SELECTOR, 'li.dashboard-paper-title a')
    self._dashboard_paper_icon = (By.CLASS_NAME, 'manuscript-icon')
    self._dashboard_info_text = (By.CLASS_NAME, 'dashboard-info-text')

    # View Invitations Modal Static Locators
    self._view_invites_title = (By.CLASS_NAME, 'overlay-header-title')
    self._view_invites_close = (By.CLASS_NAME, 'overlay-close-x')

    # Create New Submission Modal
    self._cns_closer = (By.CLASS_NAME, 'overlay-close-x')
    self._cns_title = (By.CSS_SELECTOR, 'div.overlay-title-text h1')
    self._cns_error_div = (By.CLASS_NAME, 'flash-messages')
    self._cns_error_message = (By.CLASS_NAME, 'flash-message-content')

    self._cns_short_title_label = (By.CLASS_NAME, 'inset-form-control-text')
    self._cns_short_title_field = (By.CLASS_NAME, 'inset-form-control-input')
    self._cns_journal_chooser_div = (By.CLASS_NAME, 'paper-new-journal-select')

    self._cns_paper_type_chooser_div = (By.CLASS_NAME, 'paper-new-paper-type-select')

    self._cns_chooser_chosen = (By.CLASS_NAME, 'select2-chosen')
    self._cns_chooser_dropdown_arrow = (By.CLASS_NAME, 'select2-arrow')
    self._cns_action_buttons_div = (By.CLASS_NAME, 'overlay-action-buttons')
    self._cns_cancel = (By.CLASS_NAME, 'button-link')
    self._cns_create = (By.CLASS_NAME, 'button-primary')

  # POM Actions
  def click_on_existing_manuscript_link(self, title):
    """Click on a link given a title"""
    first_matching_manuscript_link = self._get((By.LINK_TEXT,title))
    first_matching_manuscript_link.click()
    return self

  def click_on_existing_manuscript_link_partial_title(self, partial_title):
    """Click on existing manuscript link using partial title"""
    first_article_link = self.driver.find_element_by_partial_link_text(partial_title)
    first_article_link.click()
    return first_article_link.text

  def validate_initial_page_elements_styles(self):
    """
    Validates the static page elements existence and styles
    :return: None
    """
    cns_btn = self._get(self._dashboard_create_new_submission_btn)
    assert cns_btn.text.lower() == 'create new submission'
    self.validate_green_backed_button_style(cns_btn)

  def validate_invite_dynamic_content(self, username):
    """
    Validates the "view invites" stanza and function if present
    :param username: username
    :return: None
    """
    invitation_count = self.is_invite_stanza_present(username)
    if invitation_count > 0:
      welcome_msg = self._get(self._dashboard_invite_title)
      if invitation_count == 1:
        assert welcome_msg.text == 'You have 1 invitation.', welcome_msg.text
      else:
        assert welcome_msg.text == 'You have %s invitations.' % invitation_count, \
                                   welcome_msg.text + ' ' + str(invitation_count)
      self.validate_page_title_style(welcome_msg)
      view_invites_btn = self._get(self._dashboard_view_invitations_btn)
      self.validate_green_backed_button_style(view_invites_btn)

  def validate_manu_dynamic_content(self, username):
    """
    Validates the manuscript stanza dynamic display based on assigned papers and roles
    :param username: username
    :return: None
    """
    welcome_msg = self._get(self._dashboard_my_subs_title)
    # Get first name for validation of dashboard welcome message
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = %s;', (username,))[0][0]
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    # # Get count of distinct papers from paper_roles for validating count of manuscripts on dashboard welcome message
    manuscript_count = PgSQL().query('SELECT count(distinct paper_id) FROM paper_roles WHERE user_id=%s;', (uid,))[0][0]
    # # Put together a list of papers for user for validating tooltip role display and paper titles on dashboard
    paper_tuples = PgSQL().query('SELECT distinct paper_id FROM paper_roles '
                                 'WHERE user_id = %s '
                                 'ORDER BY paper_id DESC;', (uid,))
    db_papers = []
    for i in paper_tuples:
      db_papers.append(i[0])
    if manuscript_count > 1:
      assert 'Hi, ' + first_name + '. You have ' + str(manuscript_count) + ' manuscripts.' in welcome_msg.text, \
             welcome_msg.text
    elif manuscript_count == 1:
      assert 'Hi, ' + first_name + '. You have ' + str(manuscript_count) + ' manuscript.' in welcome_msg.text, \
             welcome_msg.text
    else:
      assert 'Hi, ' + first_name + '. You have no manuscripts.' in welcome_msg.text, welcome_msg.text
    self.validate_application_h1_style(welcome_msg)
    if manuscript_count > 0:
      papers = self._gets(self._dashboard_paper_title)
      count = 0
      for paper in papers:
        title = PgSQL().query('SELECT title FROM papers WHERE id = %s ;', (db_papers[count],))[0][0]
        if not title:
          title = PgSQL().query('SELECT short_title FROM papers WHERE id = %s ;', (db_papers[count],))[0][0]
        assert title == paper.text, 'DB: ' + str(title) + ' is not equal to ' + paper.text + ', from page.'
        paper_roles = PgSQL().query('SELECT role FROM paper_roles '
                                    'INNER JOIN papers ON papers.id = paper_roles.paper_id '
                                    'AND paper_roles.paper_id = %s AND '
                                    'paper_roles.user_id= %s ;', (db_papers[count], uid))
        is_my_paper = PgSQL().query('SELECT user_id FROM papers  WHERE id = %s AND '
                                    'user_id=%s ;', (db_papers[count], uid))
        if is_my_paper:
          paper_roles.append(('my paper',))
        role_list = []
        for role in paper_roles:
          role_list.append(role[0])
        page_derived_role_list = paper.get_attribute('data-original-title').lower().split(', ')
        for role in role_list:
          assert role in page_derived_role_list
        count += 1
        self._actions.move_to_element(welcome_msg).perform()
        time.sleep(1)  # make sure the focus is not accidentally on a paper link, and account for transition
        # font-family is in transition just now, so validating on the 2nd fallback font until this stabilizes
        assert 'helvetica' in paper.value_of_css_property('font-family')
        assert paper.value_of_css_property('font-size') == '18px'
        assert paper.value_of_css_property('line-height') == '27px'
        assert paper.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
        self._actions.move_to_element(paper).perform()
        time.sleep(1)  # for some reason, it is taking a second for the transition to show, I blame Ember
        assert paper.value_of_css_property('color') == 'rgba(57, 163, 41, 1)', 'ERROR: Paper link color is ' + \
                                                                               paper.value_of_css_property('color')
    else:
      info_text = self._get(self._dashboard_info_text)
      assert info_text.text == 'Your scientific paper submissions will\nappear here.'
      assert 'helvetica' in info_text.value_of_css_property('font-family')
      assert info_text.value_of_css_property('font-size') == '24px'
      assert info_text.value_of_css_property('font-style') == 'italic'
      assert info_text.value_of_css_property('line-height') == '24px'
      assert info_text.value_of_css_property('color') == 'rgba(128, 128, 128, 1)'

  def click_create_new_submission_button(self):
    """Click Create new submission button"""
    self._get(self._dashboard_create_new_submission_btn).click()
    return self

  def enter_title_field(self, title):
    """Enter title for the publication"""
    self._get(self._title_text_field).clear()
    self._get(self._title_text_field).send_keys(title)
    return self

  def click_create_button(self):
    """Click create button"""
    self._get(self._create_button).click()
    return self

  def click_cancel_button(self):
    """Click cancel button"""
    self._get(self._create_button).click()
    return self

  def select_journal(self, jtitle='Assess', jtype='Research'):
    """Select a journal with its type"""
    self._get(self._first_select).click()
    self._get(self._select_journal_from_dropdown).send_keys(jtitle + Keys.ENTER)
    self._get(self._second_select).click()
    self._get(self._select_type_from_dropdown).send_keys(jtype + Keys.ENTER)
    return self

  def title_generator(self):
    """Creates a new unique title"""
    return 'Hendrik %s'%uuid.uuid4()

  def click_view_invites_button(self):
    """Click View Invitations button"""
    self._get(self._dashboard_view_invitations_btn).click()
    return self

  @staticmethod
  def is_invite_stanza_present(username):
    """
    Determine whether the View Invites stanza should be present for username
    :param username: username
    :return: Count of unaccepted invites (does not include rejected or accepted invites)
    """
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    invitation_count = PgSQL().query('SELECT COUNT(*) FROM invitations '
                                     'WHERE state = %s AND invitee_id = %s;', ('invited', uid))[0][0]
    return invitation_count

  def validate_view_invites(self, username):
    """
    Validates the display of the View Invites overlay and the dynamic presentation of the
    current pending invitations for username.
    :param username: username
    :return: None
    """
    # global elements
    modal_title = self._get(self._view_invites_title)
    # The following call will fail because of an inconsistent implementation of the style of this heading
    # thus for the time being, I am using the one off validations. These should be removed when the bug
    # is fixed.
    # self.validate_application_h1_style(modal_title)
    assert 'helvetica' in modal_title.value_of_css_property('font-family')
    assert modal_title.value_of_css_property('font-size') == '48px'
    assert modal_title.value_of_css_property('font-weight') == '500'
    # Current implementation seems wrong Pivotal Ticket:
    #  https://www.pivotaltracker.com/n/projects/880854/stories/100777180
    # Not validating until resolved.
    # assert modal_title.value_of_css_property('line-height') == '43.2px'
    assert modal_title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    # per invite elements
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    invitations = PgSQL().query('SELECT task_id FROM invitations '
                                'WHERE state = %s AND invitee_id = %s;', ('invited', uid))
    tasks = []
    for invite in invitations:
      tasks.append(invite[0])
    print tasks
    count = 1
    for task in tasks:
      paper_id = PgSQL().query('SELECT paper_id FROM phases '
                               'INNER JOIN tasks ON tasks.phase_id = phases.id '
                               'WHERE tasks.id = %s;', (task,))[0][0]
      title = PgSQL().query('SELECT title FROM papers WHERE id = %s;', (paper_id,))[0][0]
      # The ultimate plan here is to compare titles from the database to those presented on the page,
      # however, the ordering of the presentation of the invite blocks is currently non-deterministic, so this
      # can't currently be done. https://www.pivotaltracker.com/n/projects/880854/stories/100832196
      # For the time being, just printing the titles to the test run log
      print('Title from the database: \n' + title)
      # The following locators are dynamically assigned and must be defined inline in this loop to succeed.
      self._view_invites_pending_invite_div = (By.XPATH, '//div[@class="pending-invitation"][' + str(count) + ']')
      self._view_invites_pending_invite_heading = (By.TAG_NAME, 'h4')
      self._view_invites_pending_invite_paper_title = (By.CSS_SELECTOR, 'li.dashboard-paper-title h3')
      self._view_invites_pending_invite_manuscript_icon = (By.CLASS_NAME, 'manuscript-icon')
      self._view_invites_pending_invite_abstract = (By.CSS_SELECTOR, 'li.dashboard-paper-title p')
      self._view_invites_pending_invite_yes_btn = (By.CSS_SELECTOR, 'li.dashboard-paper-title button')
      self._view_invites_pending_invite_no_btn = (By.XPATH, '//li[@class="dashboard-paper-title"]/button[2]')

      self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_heading)
      pt = self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_paper_title)
      print('Title presented on the page: \n' + pt.text)
      self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_manuscript_icon)
      self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_abstract)
      self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_yes_btn)
      self._get(self._view_invites_pending_invite_div).find_element(*self._view_invites_pending_invite_no_btn)
      count += 1
    self._get(self._view_invites_close).click()
    time.sleep(1)

  def validate_create_new_submission(self):
    """
    Validates the function of the Create New Submissions button, and the elements and error handling
    of the overlay that the CNS button launches.
    :return: None
    """
    closer = self._get(self._cns_closer)
    overlay_title = self._get(self._cns_title)
    assert overlay_title.text == 'Create a New Submission'
    short_title_field_label = self._get(self._cns_short_title_label)
    assert short_title_field_label.text == 'Short Title'
    short_title_input_field = self._get(self._cns_short_title_field)
    assert short_title_input_field.get_attribute('placeholder') == 'Crystalized Magnificence in the Modern World'
    journal_chooser = self._get(self._cns_journal_chooser_div).find_element(*self._cns_chooser_chosen)
    assert journal_chooser.text == 'Choose Journal'
    paper_type_chooser = self._get(self._cns_paper_type_chooser_div).find_element(*self._cns_chooser_chosen)
    assert paper_type_chooser.text == 'Choose Paper Type'
    create_btn = self._get(self._cns_action_buttons_div).find_element(*self._cns_create)
    self.validate_green_backed_button_style(create_btn)
    create_btn.click()
    self._get(self._cns_error_div)
    error_msgs = self._gets(self._cns_error_message)
    # I can't quite make out why the previous returns two iterations of the error messages, but, this fixes it
    for i in range(len(error_msgs) / 2):
      error_msgs.pop()
    errors = []
    for error in error_msgs:
      error = error.text.split('\n')[0]
      errors.append(error)
    assert 'Journal can\'t be blank' in errors
    assert 'Paper type can\'t be blank' in errors
    assert 'Short title can\'t be blank' in errors
    closer.click()
