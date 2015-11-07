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
from authenticated_page import AuthenticatedPage, application_typeface, manuscript_typeface, tahi_green


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
    self._dash_active_section_title = (By.CSS_SELECTOR, 'thead.active-papers tr th')
    self._dash_active_role_th = (By.XPATH, "//div[@class='table-responsive'][1]/table/thead/tr/th[2]")
    self._dash_active_status_th = (By.XPATH, "//div[@class='table-responsive'][1]/table/thead/tr/th[3]")

    self._dash_active_title = (By.CSS_SELECTOR,
                               'td.active-paper-title a')
    self._dash_active_manu_id = (By.CSS_SELECTOR, 'td.active-paper-title a + div')
    self._dash_active_role = (By.CSS_SELECTOR, 'td.active-paper-title + td')
    self._dash_active_status = (By.CSS_SELECTOR, 'td.active-paper-title + td + td div')

    self._dash_inactive_section_title = (By.CSS_SELECTOR, 'thead.inactive-papers tr th')
    self._dash_inactive_role_th = (By.XPATH, "//div[@class='table-responsive'][2]/table/thead/tr/th[2]")
    self._dash_inactive_status_th = (By.XPATH, "//div[@class='table-responsive'][2]/table/thead/tr/th[3]")
    self._dash_inactive_title = (By.CSS_SELECTOR,
                                 'td.inactive-paper-title a')
    self._dash_inactive_manu_id = (By.CSS_SELECTOR, 'td.inactive-paper-title a + div')
    self._dash_inactive_role = (By.CSS_SELECTOR, 'td.inactive-paper-title + td')
    self._dash_inactive_status = (By.CSS_SELECTOR, 'td.inactive-paper-title + td + td div')

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
    self._cns_short_title_field = (By.XPATH, './/div[@id="paper-short-title"]/div')
    self._cns_manuscript_title_label = (By.CLASS_NAME, 'paper-new-label')
    self._cns_manuscript_title_field = (By.CLASS_NAME, 'content-editable-muted')
    self._cns_manuscript_italic_icon = (By.CLASS_NAME, 'fa-italic')
    self._cns_manuscript_superscript_icon = (By.CLASS_NAME, 'fa-superscript')
    self._cns_manuscript_subscript_icon = (By.CLASS_NAME, 'fa-subscript')
    self._cns_journal_chooser = (By.XPATH, './/div[@class="inner-content"]/div[2]/label')
    self._cns_journal_chooser_dd = (By.CLASS_NAME, 'paper-new-journal-select')
    self._cns_papertype_chooser_dd = (By.CLASS_NAME, 'paper-new-paper-type-select')

    self._cns_journal_chooser_active = (By.CLASS_NAME, 'select-box-element--active')
    self._cns_paper_type_chooser = (By.XPATH, './/div[@class="inner-content"]/div[3]/label')

    self._cns_chooser_chosen = (By.CLASS_NAME, 'select-box-item')
    self._cns_chooser_dropdown_arrow = (By.CLASS_NAME, 'select2-arrow')
    self._cns_upload_document = (By.CLASS_NAME, 'fileinput-button')
    self._upload_btn = (By.CLASS_NAME, 'paper-new-upload-button')

    self._cns_cancel = (By.CLASS_NAME, 'button-link')
    self._cns_create = (By.CLASS_NAME, 'button-primary')
    self._submitted_papers = (By.CLASS_NAME, 'dashboard-paper-title')
    # First article
    self._first_paper = (By.CSS_SELECTOR, 'li.dashboard-paper-title > a')


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

  def click_on_existing_manuscript_link_partial_title(self, partial_title):
    """Click on existing manuscript link using partial title"""
    first_article_link = self.driver.find_element_by_partial_link_text(partial_title)
    title = first_article_link.text
    first_article_link.click()
    return title

  def click_on_first_manuscript(self):
    """Click on first available manuscript link"""
    first_article_link = self._get(self._first_paper)
    first_article_link.click()
    return first_article_link.text

  def get_upload_button(self):
    """Returns the upload button in the dashboard submit manuscript modal"""
    return self._get(self._cns_upload_document)

  def validate_initial_page_elements_styles(self):
    """
    Validates the static page elements existence and styles
    :return: None
    """
    cns_btn = self._get(self._dashboard_create_new_submission_btn)
    assert cns_btn.text.lower() == 'create new submission'
    # self.validate_primary_big_green_button_style(cns_btn)

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
      # self.validate_application_h1_style(welcome_msg)
      view_invites_btn = self._get(self._dashboard_view_invitations_btn)
      self.validate_primary_big_green_button_style(view_invites_btn)

  def validate_manuscript_section_main_title(self, username):
    """
    Validates the title section of the manuscript presentation part of the page
    This is always present and follows the Invite section if present. The paper
    content of the active and inactive sections are presented separately.
    :param username: username
    :return: active_manuscript_count
    """
    welcome_msg = self._get(self._dashboard_my_subs_title)
    # Get first name for validation of dashboard welcome message
    first_name = PgSQL().query('SELECT first_name FROM users WHERE username = %s;', (username,))[0][0]
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    # Get count of distinct papers from paper_roles for validating count of manuscripts on dashboard welcome message
    active_manuscripts = []
    try:
      active_manuscripts = PgSQL().query('SELECT DISTINCT paper_roles.paper_id, papers.publishing_state '
                                         'FROM paper_roles INNER JOIN papers ON paper_roles.paper_id = papers.id '
                                         'WHERE paper_roles.user_id=%s '
                                         'AND papers.publishing_state NOT IN (\'withdrawn\', \'rejected\');', (uid,))
    except:
      print('Database access error.')
      return False
    manuscript_count = len(active_manuscripts)
    print('Expecting ' + str(manuscript_count) + ' active manuscripts')
    if manuscript_count > 1:
      assert 'Hi, ' + first_name + '. You have {0} active manuscripts.'.format(manuscript_count) in welcome_msg.text, \
             welcome_msg.text + str(manuscript_count)
    elif manuscript_count == 1:
      assert 'Hi, ' + first_name + '. You have {0} active manuscript.'.format(manuscript_count) in welcome_msg.text, \
             welcome_msg.text + str(manuscript_count)
    else:
      manuscript_count = 0
      assert 'Hi, ' + first_name + '. You have no manuscripts.' in welcome_msg.text, welcome_msg.text
    # self.validate_application_h1_style(welcome_msg)
    return manuscript_count

  def validate_active_manuscript_section(self, username, active_manuscript_count):
    """
    Validates the display of the active manuscripts section of the dashboard. This may or may not be present.
    It consists of a title with a parenthetical count of active manuscripts and then a listing of each active
    manuscript ordered by submitted vs unsubmitted (with unsubmitted first) and display in descending order thereafter.
    :param username, active_manuscript_count: username, active_manuscript_count (int)
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
      assert active_section_title.text == 'Active ' + number + ' (' + str(active_manuscript_count) + ')'
      self.validate_manu_dynamic_content(username, 'active')
      assert self._get(self._dash_active_role_th).text == 'Role'
      assert self._get(self._dash_active_status_th).text == 'Status'
    else:
      print('No manuscripts are active for user.')

  def validate_inactive_manuscript_section(self, username):
    """
    Validates the display of the inactive manuscripts section of the dashboard. This may or may not be present.
    It consists of a title with a parenthetical count of inactive manuscripts (unsubmitted and rejected) and then a
    listing of each inactive manuscript ordered by role created_at in descending order thereafter.
    :param username: username
    :return: inactive_manuscript_count
    """
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    try:
      inactive_manuscripts = PgSQL().query('SELECT DISTINCT paper_roles.paper_id, papers.publishing_state '
                                           'FROM paper_roles INNER JOIN papers ON paper_roles.paper_id = papers.id '
                                           'WHERE paper_roles.user_id=%s '
                                           'AND papers.publishing_state IN (\'withdrawn\', \'rejected\');', (uid,))
    except:
      print('Could not retrieve inactive manuscripts from the database')
      return False
    inactive_manuscript_count = len(inactive_manuscripts)
    if inactive_manuscript_count <= 0:
      print('No manuscripts are inactive for user.')
    else:
      if len(inactive_manuscripts) == 1:
        number = 'Manuscript'
      else:
        number = 'Manuscripts'
      inactive_section_title = self._get(self._dash_inactive_section_title)
      assert inactive_section_title.text == 'Inactive ' + number + ' (' + str(inactive_manuscript_count) + ')'
      assert self._get(self._dash_inactive_role_th).text == 'Role'
      assert self._get(self._dash_inactive_status_th).text == 'Status'

      self.validate_manu_dynamic_content(username, 'inactive')
    return inactive_manuscript_count

  def validate_no_manus_info_msg(self):
    """
    If there are both no active and no inactive manuscripts, we should present an informational message.
    :return: None
    """
    info_text = self._get(self._dashboard_info_text)
    # https://www.pivotaltracker.com/story/show/105122790
    assert info_text.text == 'Your scientific paper submissions will\nappear here.'
    assert application_typeface in info_text.value_of_css_property('font-family')
    assert info_text.value_of_css_property('font-size') == '24px'
    assert info_text.value_of_css_property('font-style') == 'italic'
    assert info_text.value_of_css_property('line-height') == '24px'
    assert info_text.value_of_css_property('color') == 'rgba(128, 128, 128, 1)'

  def validate_manu_dynamic_content(self, username, list):
    """
    Validates the manuscript listings dynamic display based on assigned roles for papers. Papers should be ordered by
    paper_role.created_at DESC
    :param username, list: username, list
    :return: None
    """
    print('Starting validation of ' + list + ' papers for ' + username)
    uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
    # We MUST validate that manuscript_count is > 0 for list before calling this
    if list == 'inactive':
      paper_tuple_list = []
      papers = self._gets(self._dash_inactive_title)
      manu_ids = self._gets(self._dash_inactive_manu_id)
      roles = self._gets(self._dash_inactive_role)
      statuses = self._gets(self._dash_inactive_status)

      paper_tuple_list = PgSQL().query('SELECT paper_roles.paper_id, paper_roles.created_at, papers.publishing_state, '
                                       'papers.doi '
                                       'FROM paper_roles INNER JOIN papers ON paper_roles.paper_id = papers.id '
                                       'WHERE paper_roles.user_id=%s '
                                       'AND papers.publishing_state IN (\'withdrawn\', \'rejected\') '
                                       'ORDER BY paper_roles.created_at DESC;', (uid,)
                                       )
    else:
      paper_tuple_list = []
      papers = self._gets(self._dash_active_title)
      manu_ids = self._gets(self._dash_active_manu_id)
      roles = self._gets(self._dash_active_role)
      statuses = self._gets(self._dash_active_status)
      unsubmitted_paper_tuples = PgSQL().query(
                                   'SELECT paper_roles.paper_id, paper_roles.created_at, papers.publishing_state, '
                                   'papers.doi '
                                   'FROM paper_roles INNER JOIN papers ON paper_roles.paper_id = papers.id '
                                   'WHERE paper_roles.user_id=%s '
                                   'AND papers.publishing_state = \'unsubmitted\' '
                                   'ORDER BY paper_roles.created_at DESC;', (uid,)
                                  )
      for paper in unsubmitted_paper_tuples:
        paper_tuple_list.append(paper)
      other_paper_tuples = PgSQL().query(
                                   'SELECT paper_roles.paper_id, paper_roles.created_at, papers.publishing_state, '
                                   'papers.doi '
                                   'FROM paper_roles INNER JOIN papers ON paper_roles.paper_id = papers.id '
                                   'WHERE paper_roles.user_id=%s '
                                   'AND papers.publishing_state '
                                   'NOT IN (\'unsubmitted\', \'withdrawn\', \'rejected\') '
                                   'ORDER BY paper_roles.created_at DESC;', (uid,)
                                        )
      for paper in other_paper_tuples:
        paper_tuple_list.append(paper)
    db_papers_list = []
    for i in paper_tuple_list:
      current_paper = i[0]
      if current_paper not in db_papers_list:
        db_papers_list.append(current_paper)
    # Keeping this around but commented out as it is key to debugging issues with dirty paper data
    # print(db_papers_list)

    if len(db_papers_list) > 0:
      count = 0
      for paper in papers:  # List of papers for section from page
        # Validate paper title display and ordering
        # Get title of paper from db based on db ordered list of papers, then compare to papers ordered on page.
        title = PgSQL().query('SELECT title FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        title = self.strip_tags(title)
        if not title:
          print('Error: No title in db! Illogical, Illogical, Norman Coordinate: Invalid document')
          return False
        # The following two lines are very useful for debugging ordering issues, please leave in place
        # print(title)
        # print(paper.text)
        assert title == paper.text.encode('utf8'), 'DB: ' + title + ' is not equal to ' + paper.text + ', from page.'
        # Sort out paper role display
        paper_roles = PgSQL().query('SELECT role FROM paper_roles '
                                    'INNER JOIN papers ON papers.id = paper_roles.paper_id '
                                    'WHERE paper_roles.paper_id = %s AND '
                                    'paper_roles.user_id= %s '
                                    'ORDER BY paper_roles.created_at DESC;', (db_papers_list[count], uid))
        rolelist = []
        for role in paper_roles:
          rolelist.append(role[0])
        # print(db_papers_list[count])
        paper_owner = PgSQL().query('SELECT user_id FROM papers where id = %s;', (db_papers_list[count],))[0][0]
        if paper_owner == uid:
          rolelist.append('my paper')

        # This validates the role display in the tooltip hover
        page_derived_role_list = paper.get_attribute('data-original-title').lower().split(', ')
        for role in rolelist:
          assert role in page_derived_role_list

        # This validates the role display in the role column
        # per design, if my paper in roles, only display an 'Author' role
        if 'my paper' in rolelist:
          rolelist = ['Author']

        for role in rolelist:
          assert role.lower() in roles[count].text.lower()

        # Validate Status Display
        page_status = statuses[count].text
        dbstatus = PgSQL().query('SELECT publishing_state FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        if dbstatus == 'unsubmitted':
          dbstatus = 'draft'
        assert page_status.lower() == dbstatus.lower(), page_status.lower() + ' is not equal to: ' + dbstatus.lower()

        # Validate Manuscript ID display
        dbmanuid = PgSQL().query('SELECT doi FROM papers WHERE id = %s ;', (db_papers_list[count],))[0][0]
        if dbmanuid:
          dbmanuid = 'ID: ' + dbmanuid.split('/')[1]
        else:
          dbmanuid = 'ID:'
        manu_id = manu_ids[count].text
        assert dbmanuid == manu_id, dbmanuid + ' is not equal to: ' + manu_id

        # Finally increment counter
        count += 1

  def click_create_new_submission_button(self):
    """Click Create new submission button"""
    self._get(self._dashboard_create_new_submission_btn).click()
    return self

  #def click_create_document()

  def enter_title_field(self, title):
    """
    Enter title for the publication
    :param title: Title you wish to use for your paper
    :return:
    """
    title_field = self._get(self._cns_short_title_field)
    title_field.click()
    title_field.send_keys(title)

  def click_upload_button(self):
    """Click create button"""
    self._get(self._upload_btn).click()
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
    """
    Select a journal with its type
    jtitle: Title of the journal
    jtype: Journal type
    """
    div = self._get(self._cns_journal_chooser_dd)
    div.find_element_by_class_name('select-box-element').click()
    for item in self._gets((By.CLASS_NAME, 'select-box-item')):
      if item.text == jtitle:
        item.click()
        time.sleep(1)
        break
    div = self._get(self._cns_papertype_chooser_dd)
    div.find_element_by_class_name('select-box-element').click()
    for item in self._gets((By.CLASS_NAME, 'select-box-item')):
      if item.text == jtype:
        item.click()
        time.sleep(2)
        break

  def title_generator(self, prefix='', random_bit=True):
    """Creates a new unique title"""
    if not prefix:
      return str(uuid.uuid4())
    elif prefix and random_bit:
      return '%s %s'%(prefix, uuid.uuid4())
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
    assert application_typeface in modal_title.value_of_css_property('font-family')
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
    manuscript_title_field_label = self._get(self._cns_manuscript_title_label)
    assert manuscript_title_field_label.text == 'Give your paper a title'
    manuscript = self._get(self._cns_manuscript_title_field)
    assert manuscript.get_attribute('placeholder') == 'Crystalized Magnificence in the Modern World'
    # For the time being only validating the presence of these as they may be removed
    self._get(self._cns_manuscript_italic_icon)
    self._get(self._cns_manuscript_superscript_icon)
    self._get(self._cns_manuscript_subscript_icon)
    journal_chooser = self._get(self._cns_journal_chooser)
    assert journal_chooser.text == 'What journal are you submitting to?'
    paper_type_chooser = self._get(self._cns_paper_type_chooser)
    assert paper_type_chooser.text == "Choose the type of paper you're submitting"
    self._get(self._upload_btn)
    fn = '../assets/docs/sample.docx'
    self._driver.execute_script("$('#upload-files').fileupload('add', {files:['%s']})" % fn)
    time.sleep(1)
    # TODO: Check this when fixed bug #102130748
    # self.validate_secondary_big_green_button_style(create_btn)
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
    # Temporarily commented out per ticket APERTA-5413
    # assert 'Title can\'t be blank' in errors
    closer.click()
