#! /usr/bin/env python2

from selenium.webdriver.common.by import By
from authenticated_page import AuthenticatedPage
import time
from Base.PostgreSQL import PgSQL

__author__ = 'jgray@plos.org'


class DashboardPage(AuthenticatedPage):
  """
  Model an aperta dashboard page
  """
  def __init__(self, driver, url_suffix='/'):
    super(DashboardPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Navigation Menu Locators
    self._nav_toggle = (By.CLASS_NAME, 'navigation-toggle')
    self._nav_close = (By.CLASS_NAME, 'navigation-close')
    self._nav_title = (By.CLASS_NAME, 'navigation-title')
    self._nav_profile_link = (By.CSS_SELECTOR, 'div.navigation a[href="/profile"]')
    self._nav_profile_img = (By.CSS_SELECTOR, 'div.navigation a[href="/profile"] img')
    self._nav_dashboard_link = (By.CSS_SELECTOR, 'div.navigation a[href="/"]')
    self._nav_flowmgr_link = (By.CSS_SELECTOR, 'div.navigation a[href="/flow_manager"]')
    self._nav_paper_tracker_link = (By.CSS_SELECTOR, 'div.navigation a[href="/paper_tracker"]')
    self._nav_admin_link = (By.CSS_SELECTOR, 'div.navigation a[href="/admin"]')
    self._nav_signout_link = (By.CSS_SELECTOR, 'div.navigation > a')
    self._nav_feedback_link = (By.CLASS_NAME, 'navigation-item-feedback')

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
  def validate_initial_page_elements_styles(self):
    cns_btn = self._get(self._dashboard_create_new_submission_btn)
    assert cns_btn.text.lower() == 'create new submission'
    assert 'helvetica' in cns_btn.value_of_css_property('font-family')
    assert cns_btn.value_of_css_property('font-size') == '14px'
    assert cns_btn.value_of_css_property('font-weight') == '400'
    assert cns_btn.value_of_css_property('line-height') == '20px'
    assert cns_btn.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert cns_btn.value_of_css_property('text-align') == 'center'
    assert cns_btn.value_of_css_property('text-transform') == 'uppercase'

  def validate_invite_dynamic_content(self, username):
    invitation_count = self.is_invite_stanza_present(username)
    if invitation_count > 0:
      welcome_msg = self._get(self._dashboard_invite_title)
      if invitation_count == 1:
        assert welcome_msg.text == 'You have 1 invitation.', welcome_msg.text
      else:
        assert welcome_msg.text == 'You have ' + str(invitation_count) + ' invitations.', \
                                   welcome_msg.text + ' ' + str(invitation_count)
      assert 'helvetica' in welcome_msg.value_of_css_property('font-family')
      assert welcome_msg.value_of_css_property('font-size') == '48px'
      assert welcome_msg.value_of_css_property('font-weight') == '500'
      assert welcome_msg.value_of_css_property('line-height') == '52.8px'
      assert welcome_msg.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
      view_invites_btn = self._get(self._dashboard_view_invitations_btn)
      assert view_invites_btn.text.lower() == 'view invitations'
      assert 'helvetica' in view_invites_btn.value_of_css_property('font-family')
      assert view_invites_btn.value_of_css_property('font-size') == '14px'
      assert view_invites_btn.value_of_css_property('font-weight') == '400'
      assert view_invites_btn.value_of_css_property('line-height') == '20px'
      assert view_invites_btn.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
      assert view_invites_btn.value_of_css_property('text-align') == 'center'
      assert view_invites_btn.value_of_css_property('text-transform') == 'uppercase'

  def validate_manu_dynamic_content(self, username):
    welcome_msg = self._get(self._dashboard_my_subs_title)
    # Get first name for validation of dashboard welcome message
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = \'' + username + '\';')[0][0]
    uid = PgSQL().query('SELECT id FROM users WHERE username = \'' + username + '\';')[0][0]
    # # Get count of distinct papers from paper_roles for validating count of manuscripts on dashboard welcome message
    manuscript_count = PgSQL().query('SELECT count(distinct paper_id) FROM paper_roles WHERE user_id = \'' + str(uid)
                                     + '\';')[0][0]
    # # Put together a list of papers for user for validating tooltip role display and paper titles on dashboard
    paper_tuples = PgSQL().query('SELECT distinct paper_id FROM paper_roles '
                                 'WHERE user_id = \'' + str(uid) + '\' '
                                 'ORDER BY paper_id DESC;')
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
    assert 'helvetica' in welcome_msg.value_of_css_property('font-family')
    assert welcome_msg.value_of_css_property('font-size') == '48px'
    assert welcome_msg.value_of_css_property('font-weight') == '500'
    assert welcome_msg.value_of_css_property('line-height') == '52.8px'
    assert welcome_msg.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    if manuscript_count > 0:
      papers = self._gets(self._dashboard_paper_title)
      count = 0
      for paper in papers:
        title = PgSQL().query('SELECT title FROM papers WHERE id =\'' + str(db_papers[count]) + '\';')[0][0]
        if not title:
          title = PgSQL().query('SELECT short_title FROM papers WHERE id =\'' + str(db_papers[count]) + '\';')[0][0]
        assert title == paper.text, 'DB: ' + str(title) + ' is not equal to ' + paper.text + ', from page.'
        paper_roles = PgSQL().query('SELECT role FROM paper_roles '
                                    'INNER JOIN papers ON papers.id = paper_roles.paper_id '
                                    'AND paper_roles.paper_id = \'' + str(db_papers[count]) + '\' AND '
                                    'paper_roles.user_id=\'' + str(uid) + '\';')
        is_my_paper = PgSQL().query('SELECT user_id FROM papers  WHERE id = \'' + str(db_papers[count]) + '\' AND '
                                    'user_id=\'' + str(uid) + '\';')
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
        assert 'librebaskerville' in paper.value_of_css_property('font-family')
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

  def click_view_invites_button(self):
    """Click View Invitations button"""
    self._get(self._dashboard_view_invitations_btn).click()

  @staticmethod
  def is_invite_stanza_present(username):
    uid = PgSQL().query('SELECT id FROM users WHERE username = \'' + username + '\';')[0][0]
    invitation_count = PgSQL().query('SELECT COUNT(*) FROM invitations '
                                     'WHERE state = \'invited\' AND invitee_id = \'' + str(uid) + '\';')[0][0]
    return invitation_count

  def validate_view_invites(self, username):
    # global elements
    modal_title = self._get(self._view_invites_title)
    assert 'helvetica' in modal_title.value_of_css_property('font-family')
    assert modal_title.value_of_css_property('font-size') == '48px'
    assert modal_title.value_of_css_property('font-weight') == '500'
    # Current implementation seems wrong Pivotal Ticket:
    #  https://www.pivotaltracker.com/n/projects/880854/stories/100777180
    # Not validating until resolved.
    # assert modal_title.value_of_css_property('line-height') == '43.2px'
    assert modal_title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    # per invite elements
    uid = PgSQL().query('SELECT id FROM users WHERE username = \'' + username + '\';')[0][0]
    invitations = PgSQL().query('SELECT task_id FROM invitations '
                                'WHERE state = \'invited\' AND invitee_id = \'' + str(uid) + '\';')
    tasks = []
    for invite in invitations:
      tasks.append(invite[0])
    print tasks
    count = 1
    for task in tasks:
      paper_id = PgSQL().query('SELECT paper_id FROM phases '
                               'INNER JOIN tasks ON tasks.phase_id = phases.id '
                               'WHERE tasks.id = \'' + str(task) + '\';')[0][0]
      title = PgSQL().query('SELECT title FROM papers WHERE id = \'' + str(paper_id) + '\';')[0][0]
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

  def click_left_nav(self):
    """Click left navigation"""
    self._get(self._nav_toggle).click()

  def validate_nav_elements(self, permissions):
    elevated = ['jgray_flowmgr', 'jgray']
    self._get(self._nav_close)
    self._get(self._nav_title)
    self._get(self._nav_profile_link)
    self._get(self._nav_profile_img)
    self._get(self._nav_dashboard_link)
    self._get(self._nav_signout_link)
    self._get(self._nav_feedback_link)
    # Must have flow mgr, admin or superadmin
    if permissions in elevated:
      self._get(self._nav_flowmgr_link)
      self._get(self._nav_paper_tracker_link)
    # Must have admin or superadmin
    if permissions == ('jgray_oa', 'jgray'):
      self._get(self._nav_admin_link)

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._nav_signout_link).click()
    return self
