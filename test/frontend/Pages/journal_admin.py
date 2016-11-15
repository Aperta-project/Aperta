#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Journal specific Admin Page. Validates global and dynamic elements and
  their styles. This is really a shell of a test.
"""

import logging
import time

from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import task_names, yeti_task_names
from admin import AdminPage

__author__ = 'jgray@plos.org'


class JournalAdminPage(AdminPage):
  """
  Model an aperta Journal specific Admin page
  """
  def __init__(self, driver, url_suffix='/'):
    super(JournalAdminPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Journals Admin Page
    # User Search widget and result table
    self._journal_admin_users_title = (By.CLASS_NAME, 'admin-section-title')
    self._journal_admin_user_search_field = (By.NAME, 'Admin Search Input')
    self._journal_admin_user_search_button = (By.CSS_SELECTOR, 'div.admin-search > button')
    self._journal_admin_user_search_default_state_text = (By.CLASS_NAME,
                                                          'admin-user-search-default-state-text')
    self._journal_admin_user_search_results_table = (By.CLASS_NAME, 'admin-users')
    self._journal_admin_user_search_results_table_uname_header = (By.XPATH, '//table[1]/tr/th[1]')
    self._journal_admin_user_search_results_table_fname_header = (By.XPATH, '//table[1]/tr/th[2]')
    self._journal_admin_user_search_results_table_lname_header = (By.XPATH, '//table[1]/tr/th[3]')
    self._journal_admin_user_search_results_table_rname_header = (By.XPATH, '//table[1]/tr/th[4]')
    self._journal_admin_user_search_results_row = (By.CLASS_NAME, 'user-row')

    self._journal_admin_user_row_username = (By.CSS_SELECTOR, 'tr.user-row td')
    self._journal_admin_user_row_fname = (By.CSS_SELECTOR, 'tr.user-row td + td')
    self._journal_admin_user_row_lname = (By.CSS_SELECTOR, 'tr.user-row td + td + td')
    self._journal_admin_user_row_roles = (By.CSS_SELECTOR,
                                          'tr.user-row td div ul.select2-choices li div')
    self._journal_admin_user_row_role_delete = (By.CSS_SELECTOR,
                                                'tr.user-row td div ul.select2-choices li a')
    self._journal_admin_user_row_role_add = (By.CSS_SELECTOR,
                                             'tr.user-row td div span.assign-role-button')
    self._journal_admin_user_row_role_add_field = (
        By.CSS_SELECTOR, 'tr.user-row td div div ul li.select2-search-field input')
    self._journal_admin_user_row_role_search_result_item = (By. CSS_SELECTOR,
                                                            'ul.select2-results li div')

    # User Role Management Section
    self._journal_admin_roles_role_table = (By.CLASS_NAME, 'admin-users')
    self._journal_admin_roles_rt_first_name_heading = (By.CSS_SELECTOR,
                                                       'table.admin-users > tr > th')
    self._journal_admin_roles_rt_last_name_heading = (By.CSS_SELECTOR,
                                                      'table.admin-users > tr > th + th')
    self._journal_admin_roles_rt_username_heading = (By.CSS_SELECTOR,
                                                     'table.admin-users > tr > th + th + th')
    self._journal_admin_roles_rt_roles_heading = (By.CSS_SELECTOR,
                                                  'table.admin-users > tr > th + th + th')

    self._journal_admin_roles_rt_listing_row = (By.CSS_SELECTOR, 'table.admin-users > tr.user-role')

    # Generic
    self._journal_admin_non_user_section = (By.XPATH, '//div[@class="admin-section"][1]')
    # Manuscript manager Management Section
    self._journal_admin_manu_mgr_templates_title = (By.XPATH, '//div[@class="admin-section"][1]/h2')
    self._journal_admin_manu_mgr_templates_button = (By.XPATH,
                                                     '//div[@class="admin-section"][1]/button')
    self._journal_admin_manu_mgr_thumbnail = (By.CLASS_NAME, 'mmt-thumbnail')
    self._journal_admin_manu_mgr_thumb_title = (By.CSS_SELECTOR, 'h3.mmt-thumbnail-title')
    self._journal_admin_manu_mgr_thumb_phases = (By.TAG_NAME, 'span')

    # Style Settings Section
    self._journal_admin_style_settings_title = (By.XPATH, '//div[@class="admin-section"][2]/h2')
    self._journal_admin_edit_pdf_css_btn = (By.ID, 'edit-pdf-css')
    self._journal_admin_edit_ms_css_btn = (By.ID, 'edit-manuscript-css')

    self._journal_styles_css_overlay_field_label = (By.CSS_SELECTOR, 'div.overlay-header + p')
    self._journal_styles_css_overlay_field = (By.CSS_SELECTOR, 'div.overlay-header + p + textarea')
    self._journal_styles_css_overlay_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a')
    self._journal_styles_css_overlay_save = (By.CSS_SELECTOR,
                                             'div.overlay-action-buttons a + button')

    self._mmt_template_name_field = (By.CSS_SELECTOR, 'input.edit-paper-type-field')
    self._mmt_template_error_msg = (By.CSS_SELECTOR, 'div.mmt-edit-error-message')
    self._mmt_template_save_button = (By.CSS_SELECTOR,
                                      'a.paper-type-save-button')
    self._mmt_template_cancel_link = (By.CSS_SELECTOR,
                                      'a.paper-type-cancel-button')
    self._mmt_template_back_link = (By.CSS_SELECTOR,
                                    'a#control-bar-journal-back-button')
    self._mmt_template_resrev_checkbox = (By.CSS_SELECTOR,
                                          'div.uses-research-article-reviewer-report input')
    self._mmt_template_resrev_label = (By.CSS_SELECTOR,
                                       'label.uses-research-article-reviewer-report')
    self._mmt_template_add_phase_icons = (By.CSS_SELECTOR, 'i.fa-plus-square-o')
    self._mmt_template_columns = (By.CSS_SELECTOR, 'div.ember-view.column')
    self._mmt_template_column_title = (By.CSS_SELECTOR, 'div.column-header div h2')
    self._mmt_template_column_no_cards_card = (By.CSS_SELECTOR, 'div.sortable-no-cards')
    self._mmt_template_column_add_new_card_btn = (By.CSS_SELECTOR, 'a.button-secondary')
    # borrowed locators from the add_new_cards overlay definition in workflow_page
    self._card_types = (By.CSS_SELECTOR, 'div.row label')
    self._div_buttons = (By.CSS_SELECTOR, 'div.overlay-action-buttons')

  # POM Actions
  def validate_users_section(self, journal):
    """
    Validate the elements and functions of the User search and role assignment areas of the page
    :param journal: journal to which to validate this section
    :return: void function
    """
    users_title = self._get(self._journal_admin_users_title)
    self.validate_application_h2_style(users_title)
    journal_id = PgSQL().query('SELECT id FROM journals WHERE name = %s;', (journal,))[0][0]
    logging.debug(journal_id)
    journal_roles = PgSQL().query('SELECT id from roles WHERE journal_id = %s AND name in '
                                  '(\'Staff Admin\', \'Internal Editor\', \'Production Staff\','
                                  '\'Publishing Services\', \'Freelance Editors\');',
                                  (journal_id,))
    journal_roles = tuple([x[0] for x in journal_roles])
    users_db = PgSQL().query('SELECT user_id from assignments WHERE role_id in %s AND '
                             'assigned_to_id = %s AND assigned_to_type=\'Journal\';',
                             (journal_roles, journal_id))
    users_db = set([x[0] for x in users_db])
    self._get(self._journal_admin_user_search_field)
    self._get(self._journal_admin_user_search_button)
    if users_db:
      self._get(self._journal_admin_user_search_results_table_uname_header)
      self._get(self._journal_admin_user_search_results_table_fname_header)
      self._get(self._journal_admin_user_search_results_table_lname_header)
      self._get(self._journal_admin_user_search_results_table_rname_header)
      self._get(self._journal_admin_user_search_results_table)
      self._gets(self._journal_admin_user_search_results_row)
    else:
      logging.info('No users assigned roles in journal: {0}, so will add one...'.format(journal))
      self._add_user_with_role('atest author3', 'Staff Admin')
      logging.info('Verifying added user')
      self._validate_user_with_role('atest author3', 'Staff Admin')
      logging.info('Deleting newly added user')
      self._delete_user_with_role()
      time.sleep(3)

  def _add_user_with_role(self, user, role):
    """
    For user and role names, add to current journal
    :param user: existing user
    :param role: existing role
    :return: void function
    """
    user_title = self._get(self._journal_admin_users_title)
    self._actions.move_to_element(user_title).perform()
    user_input = self._get(self._journal_admin_user_search_field)
    search_btn = self._get(self._journal_admin_user_search_button)
    user_input.clear()
    self._actions.send_keys_to_element(user_input, user).perform()
    search_btn.click()
    self._get(self._journal_admin_user_row_role_add).click()
    role_search_field = self._get(self._journal_admin_user_row_role_add_field)
    self._actions.send_keys_to_element(role_search_field, role + Keys.RETURN).perform()

  def _validate_user_with_role(self, user, role):
    """
    For named user and role, ensure this exists for current journal
    :param user: user to validate
    :param role: role to validate
    :return: void function
    """
    page_user_list = self._gets(self._journal_admin_user_search_results_row)
    for row in page_user_list:
      assert user in row.text, row.text
      assert role in row.text, row.text

  def _delete_user_with_role(self):
    """
    Delete user role
    :return: void function
    """
    user_role_pill = self._get(self._journal_admin_user_row_roles)
    # For whatever reason, using action chains move_to_element() is failing here
    # so doing a simple click
    user_role_pill.click()
    delete_role = self._get(self._journal_admin_user_row_role_delete)
    delete_role.click()

  def validate_roles_section(self, journal):
    """
    Validate the elements and function of the Roles section of the journal admin page
    :return: void function
    """
    roles_table = self._get(self._journal_admin_roles_role_table)
    self._actions.move_to_element(roles_table).perform()
    journal_id = PgSQL().query('SELECT id FROM journals WHERE name = %s;',
                               (journal,))[0][0]
    # Get list of roles that should be displayed
    journal_roles = PgSQL().query('SELECT id from roles WHERE journal_id = %s AND name in '
                                  '(\'Staff Admin\', \'Internal Editor\', \'Production Staff\','
                                  '\'Publishing Services\', \'Freelance Editor\','
                                  ' \'Billing Staff\');',
                                  (journal_id,))
    journal_roles = tuple([x[0] for x in journal_roles])
    users_db = PgSQL().query('SELECT user_id from assignments WHERE role_id in %s AND '
                             'assigned_to_id = %s AND assigned_to_type=\'Journal\';',
                             (journal_roles, journal_id))
    users_db = set([x[0] for x in users_db])
    users_db = tuple(users_db)
    # Check if there are users with journal roles
    usernames_db = PgSQL().query('SELECT username FROM users WHERE id in %s;', (users_db,))
    usernames_db = [x[0] for x in usernames_db]
    # For each user, get first and last name
    lastnames_db = []
    for username in usernames_db:
      lastnames_db.append(PgSQL().query(
                         'SELECT last_name FROM users WHERE username = %s;', (username,)
                         )[0][0])
    self.set_timeout(3)
    if users_db:
      role_rows = self._gets(self._journal_admin_user_search_results_row)
      usernames = []
      for counter, row in enumerate(role_rows):
        logging.info(row.text)
        if counter > 0:
          old_last_name = last_name
        row_elements = row.find_elements(*(By.TAG_NAME, 'td'))
        last_name, first_name, username, roles = row_elements
        last_name = last_name.text
        username = username.text
        usernames.append(username)
        # This username should be in the list of user names from the DB
        assert username in usernames_db, (username, usernames_db)
        if counter > 0:
          assert last_name.lower() >= old_last_name.lower(), 'Not in alphabetical order {0} is'\
              ' showed before {1}'.format(last_name.lower(), old_last_name.lower())
        roles = roles.find_elements(*(By.CSS_SELECTOR, 'li.select2-search-choice'))
        roles = [x.text for x in roles]
        # search for roles in DB
        uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
        try:
          roles_id = PgSQL().query('SELECT role_id FROM assignments '
                                   'WHERE user_id = %s AND assigned_to_type=\'Journal\' '
                                   'AND assigned_to_id = %s;', (uid, journal_id))
          roles_id = tuple([x[0] for x in roles_id])
          named_db_roles = PgSQL().query('SELECT name FROM roles WHERE id in %s;', (roles_id,))
          named_db_roles = set([x[0] for x in named_db_roles])
          assert set(roles).issuperset(set(named_db_roles)), (roles, named_db_roles)
        except IndexError:
          logging.warning('No permissions found for user {0}'.format(username))
          assert not roles, roles
      assert set(usernames) == set(usernames_db)
    else:
      # If there is no users in the DB, there should not be in the UI
      self.set_timeout(3)
      try:
        role_rows = self._gets(self._journal_admin_user_search_results_row)
        users = [row.find_elements(*(By.TAG_NAME, 'td')) for row in role_rows]
        raise ValueError('There are users in the site that are not in the DB: {0}', users)
      except ElementDoesNotExistAssertionError:
        assert True
    self.restore_timeout()

  def validate_mmt_section(self):
    """
    Assert the existence and function of the elements of the Manuscript Manager Templates section.
    Validate Add new template, edit existing templates, validate presentation of staging.
    :return: void function
    """
    time.sleep(1)
    dbmmts = []
    dbids = []
    mmts = []
    manu_mgr_title = self._get(self._journal_admin_manu_mgr_templates_title)
    self.validate_application_h2_style(manu_mgr_title)
    assert 'Manuscript Manager Templates' in manu_mgr_title.text, manu_mgr_title.text
    add_mmt_btn = self._get(self._journal_admin_manu_mgr_templates_button)
    assert 'ADD NEW TEMPLATE' in add_mmt_btn.text, add_mmt_btn.text
    try:
      mmts = self._gets(self._journal_admin_manu_mgr_thumbnail)
    except ElementDoesNotExistAssertionError:
      logging.error('No extant MMT found for Journal. This should never happen.')
    curr_journal_id = self._driver.current_url.split('/')[-1]
    logging.info(curr_journal_id)
    db_mmts = PgSQL().query('SELECT paper_type, id '
                            'FROM manuscript_manager_templates '
                            'WHERE journal_id = %s;', (curr_journal_id,))
    for dbmmt in db_mmts:
      logging.debug('Appending {0} to dbmmts'.format(dbmmt[0]))
      dbmmts.append(dbmmt[0])
      dbids.append(dbmmt[1])
    logging.info(dbids)
    if mmts:
      count = 0
      for mmt in mmts:
        logging.debug(mmt)
        name = mmt.find_element(*self._journal_admin_manu_mgr_thumb_title)
        logging.info(name.text)
        assert name.text in dbmmts, name.text
        phases = mmt.find_element(*self._journal_admin_manu_mgr_thumb_phases)
        db_phase_count = PgSQL().query('SELECT count(*) '
                                       'FROM phase_templates '
                                       'WHERE manuscript_manager_template_id = %s;',
                                       (dbids[count],))[0][0]
        assert phases.text == str(db_phase_count), phases.text + ' != ' + str(db_phase_count)
        self._actions.move_to_element(mmt).perform()
        self._journal_admin_manu_mgr_thumb_edit = (By.CSS_SELECTOR, 'a.fa-pencil')
        mmt.find_element(*self._journal_admin_manu_mgr_thumb_edit)
        # Journals must have at least one MMT, so if only one, no delete icon is present
        if len(mmts) > 1:
          self._journal_admin_manu_mgr_thumb_delete = (By.CSS_SELECTOR,
                                                       'span.fa.fa-trash.animation-scale-in')
          mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
        count += 1
    # Need to ensure the Add New Template button is not under the top toolbar
    admin_sections = self._get(self._journal_admin_non_user_section)
    self._actions.move_to_element(admin_sections).perform()
    add_mmt_btn.click()
    time.sleep(2)
    self._validate_mmt_template_items()

  def validate_style_settings_section(self):
    """
    Validate the Roles section elements and permission assignment functions of the
    journal admin page
    :return: void function
    """
    styles_title = self._get(self._journal_admin_style_settings_title)
    self.validate_application_h2_style(styles_title)
    assert 'Style Settings' in styles_title.text, styles_title.text
    edit_pdf_css_btn = self._get(self._journal_admin_edit_pdf_css_btn)
    assert edit_pdf_css_btn.text == 'EDIT PDF CSS', edit_pdf_css_btn.text
    edit_pdf_css_btn.click()
    time.sleep(.5)
    self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'PDF CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the PDF output for this '\
        'journal\'s papers.', label.text
    self._get(self._journal_styles_css_overlay_field)
    cancel = self._get(self._journal_styles_css_overlay_cancel)
    self._get(self._journal_styles_css_overlay_save)
    cancel.click()
    time.sleep(.5)
    edit_ms_css_btn = self._get(self._journal_admin_edit_ms_css_btn)
    assert edit_ms_css_btn.text == 'EDIT MANUSCRIPT CSS', edit_ms_css_btn.text
    edit_ms_css_btn.click()
    time.sleep(.5)
    self._get(self._overlay_header_close)
    title = self._get(self._overlay_header_title)
    assert 'Manuscript CSS' in title.text, title.text
    label = self._get(self._journal_styles_css_overlay_field_label)
    assert label.text == 'Enter or edit CSS to format the manuscript editor and output for '\
        'this journal.', label.text
    self._get(self._journal_styles_css_overlay_field)
    self._get(self._journal_styles_css_overlay_cancel)
    save = self._get(self._journal_styles_css_overlay_save)
    save.click()

  def _validate_mmt_template_items(self):
    """
    Validate the elements of the manuscript manager template (aka paper type)
    :return: void function
    """
    template_field = self._get(self._mmt_template_name_field)
    # The default name should be Research
    assert 'Research' in template_field.get_attribute('value'), \
        template_field.get_attribute('value')
    self._get(self._mmt_template_save_button)
    template_cancel = self._get(self._mmt_template_cancel_link)
    self._gets(self._mmt_template_add_phase_icons)
    time.sleep(3)
    columns = self._gets(self._mmt_template_columns)
    # For each column, validate its widgets
    for column in columns:
      col_title = column.find_element(*self._mmt_template_column_title)
      time.sleep(1)
      # For a reason I can't fathom, the first click is not always registered, second is always.
      col_title.click()
      col_title.click()
      # The click should pull up some column editing widgets.
      # We sometimes have a delayed drawing of these items
      time.sleep(1)
      self._mmt_template_column_delete = (By.CSS_SELECTOR, 'span.remove-icon')
      column.find_element(*self._mmt_template_column_delete)
      self._mmt_template_column_title_edit_cancel_btn = (By.CSS_SELECTOR,
                                                         'button.column-header-update-cancel')
      self._mmt_template_column_title_edit_save_btn = (By.CSS_SELECTOR,
                                                       'button.column-header-update-save')
      col_cancel = column.find_element(*self._mmt_template_column_title_edit_cancel_btn)
      column.find_element(*self._mmt_template_column_title_edit_save_btn)
      # Commenting out until APERTA-6407 is resolved
      # col_cancel.click()
      column.find_element(*self._mmt_template_column_no_cards_card)
      column.find_element(*self._mmt_template_column_add_new_card_btn)
    template_cancel.click()
    # Time to clear the overlay
    time.sleep(2)

  def add_new_mmt_template(self, commit=False, mmt_name='', user_tasks=('upload_manuscript'),
                           staff_tasks=('assign_team', 'editor_discussion', 'final_tech_check',
                                        'initial_tech_check', 'invite_academic_editor',
                                        'invite_reviewers', 'production_metadata',
                                        'register_decision', 'related_articles',
                                        'revision_tech_check', 'send_to_apex',
                                        'title_and_abstract'), uses_resrev_report=True):
    """
    A function to add a new mmt (paper type) template to a journal
    :param commit: boolean, whether to commit the named mmt to the journal, defaults to False.
      All other params are ignored if False
    :param mmt_name: optional name for the new mmt
    :param user_tasks: list of user facing tasks to add to the mmt
    :param staff_tasks: list of staff facing tasks to add to the mmt
    :param uses_resrev_report: boolean, default true, specifies mmt type as research for
      the purposes of reviewer report selection
    :return: void function
    """
    if not commit:
      logging.info('Add New Template called')
      # Need to ensure the Add New Template button is not under the top toolbar
      admin_sections = self._get(self._journal_admin_non_user_section)
      self._actions.move_to_element(admin_sections).perform()
      add_mmt_btn = self._get(self._journal_admin_manu_mgr_templates_button)
      add_mmt_btn.click()
      self._wait_for_element(self._get(self._mmt_template_name_field))
      template_field = self._get(self._mmt_template_name_field)
      save_template_button = self._get(self._mmt_template_save_button)
      template_field.click()
      template_field.send_keys(Keys.ARROW_DOWN + '<-False')
      self._wait_for_element(save_template_button)
      # If this mmt template already exists, this save should return an error and the name link
      # won't exist
      save_template_button.click()
      time.sleep(1)
      self.set_timeout(2)
      try:
        logging.info('The following message will only be found if there is a particular data '
                     'state, it is not an error.')
        msg = self._get(self._mmt_template_error_msg)
      except ElementDoesNotExistAssertionError:
        self._mmt_template_name_link = (By.CSS_SELECTOR, 'div.paper-type-name')
        self._get(self._mmt_template_name_link)
        self._journal_admin_manu_mgr_back_link = (By.CSS_SELECTOR,
                                                  'a#control-bar-journal-back-button')
        back_btn = self._get(self._journal_admin_manu_mgr_back_link)
        back_btn.click()
        self.restore_timeout()
        return
      assert 'Has already been taken' in msg.text, msg.text
      cancel = self._get(self._mmt_template_cancel_link)
      cancel.click()
      time.sleep(1)
    else:
      logging.info('Adding {0} MMT with user tasks: {1}, staff tasks {2} and that uses the '
                   'research reviewer report: {3}'.format(mmt_name,
                                                          user_tasks,
                                                          staff_tasks,
                                                          uses_resrev_report))
      # Need to ensure the Add New Template button is not under the top toolbar
      admin_sections = self._get(self._journal_admin_non_user_section)
      self._actions.move_to_element(admin_sections).perform()
      add_mmt_btn = self._get(self._journal_admin_manu_mgr_templates_button)
      add_mmt_btn.click()
      self._wait_for_element(self._get(self._mmt_template_name_field))
      template_field = self._get(self._mmt_template_name_field)
      save_template_button = self._get(self._mmt_template_save_button)
      template_field.click()
      template_field.send_keys(Keys.ARROW_DOWN + (Keys.BACKSPACE * 8) + mmt_name + Keys.ENTER)
      self._wait_for_element(save_template_button)
      save_template_button.click()
      time.sleep(1)
      phases = self._gets(self._mmt_template_column_add_new_card_btn)
      phase1 = phases[0]
      phase1.click()
      for card_name in user_tasks:
        self.add_card_to_mmt(card_name)
      div_buttons = self._get(self._div_buttons)
      div_buttons.find_element_by_class_name('button-primary').click()
      time.sleep(1)
      phase3 = phases[2]
      phase3.click()
      for card_name in staff_tasks:
        self.add_card_to_mmt(card_name)
      div_buttons = self._get(self._div_buttons)
      div_buttons.find_element_by_class_name('button-primary').click()
      time.sleep(1)
      # working around a stale element reference
      new_save_template_button = self._get(self._mmt_template_save_button)
      new_save_template_button.click()
      time.sleep(1)
      if uses_resrev_report:
        self._get(self._mmt_template_resrev_checkbox).click()
      time.sleep(1)
      back_btn = self._get(self._mmt_template_back_link)
      back_btn.click()

  def delete_new_mmt_template(self):
    """
    A function to delete a newly added mmt (paper type) template to a journal
    :return: void function
    """
    logging.info('Delete New Template called')
    mmts = self._gets(self._journal_admin_manu_mgr_thumbnail)
    if mmts:
      count = 0
      for mmt in mmts:
        name = mmt.find_element(*self._journal_admin_manu_mgr_thumb_title)
        logging.info(name.text)
        self._actions.move_to_element(mmt).perform()
        self._journal_admin_manu_mgr_thumb_edit = (By.CSS_SELECTOR, 'a.fa-pencil')
        mmt.find_element(*self._journal_admin_manu_mgr_thumb_edit)
        # Journals must have at least one MMT, so if only one, no delete icon is present
        if len(mmts) > 1:
          self._journal_admin_manu_mgr_thumb_delete = (By.CSS_SELECTOR,
                                                       'span.fa.fa-trash.animation-scale-in')
          if name.text == 'Research<-False':
            logging.info('Found MMT to delete - moving to trash icon')
            time.sleep(1)
            delete_mmt = mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
            logging.info('Clicking on MMT trash icon')
            delete_mmt.click()
            time.sleep(1)
            self._journal_admin_manu_mgr_delete_confirm_paragraph = (
                By.CSS_SELECTOR, 'div.mmt-thumbnail-overlay-confirm-destroy p')
            confirm_text = self._get(self._journal_admin_manu_mgr_delete_confirm_paragraph)
            assert 'This will permanently delete your template. Are you sure?' in \
                confirm_text.text, confirm_text.text
            self._journal_admin_manu_mgr_thumb_delete_cancel = (
                By.CSS_SELECTOR, 'div.mmt-thumbnail-overlay-confirm-destroy p + button')
            self._journal_admin_manu_mgr_thumb_delete_confirm = (
                By.CSS_SELECTOR, 'button.mmt-thumbnail-delete-button')
            time.sleep(1)
            # cancel mmt delete should be present
            self._get(self._journal_admin_manu_mgr_thumb_delete_cancel)
            confirm_delete = self._get(self._journal_admin_manu_mgr_thumb_delete_confirm)
            confirm_delete.click()
            # If this mmt is found before the end of the list of mmt, the DOM will be stale so
            break
          else:
            mmt.find_element(*self._journal_admin_manu_mgr_thumb_delete)
        count += 1

  def is_mmt_present(self, mmt_name):
    """
    A function to check if a named mmt exists for journal under test
    :return: boolean indicating if named mmt was found on journal admin page
    """
    logging.info('Checking for MMT {0}'.format(mmt_name))
    mmts = self._gets(self._journal_admin_manu_mgr_thumbnail)
    if mmts:
      for mmt in mmts:
        name = mmt.find_element(*self._journal_admin_manu_mgr_thumb_title)
        logging.info('Found {0}'.format(name.text))
        if name.text == mmt_name:
          return True
    return False

  def add_card_to_mmt(self, card_title):
    """
    An abbreviated method that merely checks the appropriate checkbox of the edit mmt overlay.
    :param card_title: The Actual Card title verbatim that you wish to check
    :return: void function
    """
    card_types = self._gets(self._card_types)
    for card in card_types:
      if card.text == card_title:
        card.click()
        break
    else:
      raise ElementDoesNotExistAssertionError('No such card')
