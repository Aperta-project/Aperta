#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Admin Page, Workflow Tab. Validates elements and their styles,
and functions.
also includes
Page Object Model for the MMT (workflow) definition overlay. This should probably be moved to its
  own POM file in the future.
"""
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.expected_conditions import alert_is_present

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from .styles import APERTA_BLUE
from .base_admin import BaseAdminPage
from .sim_check_settings import SimCheckSettings

__author__ = 'jgray@plos.org'


class AdminWorkflowsPage(BaseAdminPage):
  """
  Model the Admin page, Workflow Tab elements and their functions; and the MMT (workflow) definition
    overlay elements/styles/functions
  Provides:
    page_ready()
    validate_workflow_tab()
    _validate_mmt_definition_overlay_items()
    add_new_mmt_template()
    delete_new_mmt_template()
    is_mmt_present()
    add_card_to_mmt()
  """
  def __init__(self, driver):
    super(AdminWorkflowsPage, self).__init__(driver)

    # Locators - Instance members
    self._admin_workflow_progress_spinner = (By.CSS_SELECTOR, 'div.progress-spinner')
    self._admin_workflow_pane_title = (By.CSS_SELECTOR, 'div.admin-workflow-catalogue > h2')
    self._admin_workflow_add_mmt_btn = (
      By.CSS_SELECTOR, 'div.admin-workflow-catalogue > a.button-primary.button--blue')
    self._admin_workflow_catalogue = (By.CLASS_NAME, 'admin-workflow-catalogue')
    self._admin_workflow_mmt_thumbnail = (By.CLASS_NAME, 'admin-catalogue-item')
    # Manuscript manager thumbnail details
    self._admin_workflow_mmt_title = (By.CLASS_NAME, 'admin-workflow-thumbnail-name')
    self._admin_workflow_mmt_journal = (By.CLASS_NAME, 'admin-workflow-thumbnail-journal')
    self._admin_workflow_mmt_last_update_label_date = (By.CLASS_NAME,
                                                       'admin-workflow-thumbnail-updated')
    self._admin_workflow_mmt_number_of_ms_and_label = (
        By.CLASS_NAME, 'admin-workflow-thumbnail-active-manuscripts')
    self._mmt_template_name_field = (By.CLASS_NAME, 'edit-paper-type-field')
    self._mmt_template_error_msg = (By.CLASS_NAME, 'mmt-edit-error-message')
    self._mmt_template_save_button = (By.CSS_SELECTOR,
                                      'a.paper-type-save-button')
    self._mmt_template_cancel_link = (By.CSS_SELECTOR,
                                      'a.paper-type-cancel-button')
    self._mmt_template_back_link = (By.CSS_SELECTOR,
                                    'a#control-bar-journal-back-button')
    self._mmt_template_resrev_checkbox = (By.CSS_SELECTOR,
                                          'div.uses-research-article-reviewer-report input')
    self._mmt_template_preprint_checkbox = (By.CSS_SELECTOR, 'div.preprint-eligible input')
    self._mmt_template_resrev_label = (By.CSS_SELECTOR,
                                       'label.uses-research-article-reviewer-report')
    self._mmt_template_add_phase_icons = (By.CSS_SELECTOR, 'i.fa-plus-square-o')
    self._mmt_template_columns = (By.CSS_SELECTOR, 'div.ember-view.column')
    self._mmt_template_column_title = (By.CSS_SELECTOR, 'div.column-header div h2')
    self._mmt_template_column_no_cards_card = (By.CSS_SELECTOR, 'div.sortable-no-cards')
    self._mmt_template_column_add_new_card_btn = (By.CSS_SELECTOR, 'a.button-secondary')
    self._mmt_template_column_content = (By.CLASS_NAME, 'column-content')
    self._mmt_template_card_title = (By.CLASS_NAME, 'card-title')
    self._mmt_template_edit = (By.CSS_SELECTOR, 'i.fa-pencil')
    # borrowed locators from the add_new_cards overlay definition in workflow_page
    self._card_types = (By.CSS_SELECTOR, 'div.row label')
    self._div_buttons = (By.CSS_SELECTOR, 'div.overlay-action-buttons')
    # relative locators
    self._card_columns = (By.CSS_SELECTOR, 'div.row')
    self._card_titles = (By.CSS_SELECTOR, 'label')
    self._add_button = (By.CLASS_NAME, 'button-primary')
    self._overlay_drop_zone = (By.CSS_SELECTOR, 'div.ember-view>div#overlay-drop-zone>*')
    self._div = (By.TAG_NAME, 'div')
    self._control_bar = (By.ID, 'control-bar')
    self._overlay_body = (By.CSS_SELECTOR, 'div.ember-view .overlay-body')
    self._check_divs = (By.CSS_SELECTOR, 'div.ember-view>div.ember-view')
    # locators for card settings overlay
    self._similarity_check_card = (By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]")
    self._sim_check_card_settings = (By.XPATH, "//a[./span[contains(text(),'Similarity Check')]]//i")


  # POM Actions
  def page_ready(self):
    """"Ensure the page is ready to test"""
    self._wait_for_element(self._get(self._admin_workflow_catalogue))

  def page_ready_post_journal_selection(self):
    """
    We are exceedingly slow updating the page on journal selection. Need a new method to indicate the page is updated
    post-selection or we get a StaleElementReferenceException.
    :return: void function
    """
    self._wait_for_not_element(self._admin_workflow_progress_spinner, 1)
    time.sleep(1)

  def validate_workflow_pane(self, selected_jrnl):
    """
    Assert the existence and function of the elements of the Workflows pane.
    Validate Add new template, edit/delete existing templates, validate presentation.
    :param selected_jrnl: The name of the selected journal for which to validate the workflow pane
    :return: void function
    """
    # Time to fully populate MMT for selected journal
    time.sleep(1)
    all_journals = False
    dbmmts = []
    dbids = []
    mmts = []
    workflow_pane_title = self._get(self._admin_workflow_pane_title)
    self.validate_application_h2_style(workflow_pane_title)
    assert 'Workflow Catalogue' in workflow_pane_title.text, workflow_pane_title.text
    # Ostorozhna: The All My Journals selection is a special case. There is no add workflow button
    # and there will be no defined jid
    logging.info('Validating workflow display for {0}.'.format(selected_jrnl))
    # only validate add new mmt button if not all my journals
    if selected_jrnl not in ('All My Journals', 'All'):
      add_mmt_btn = self._get(self._admin_workflow_add_mmt_btn)
      assert 'ADD NEW WORKFLOW' in add_mmt_btn.text, add_mmt_btn.text
    # Now a guard to ensure we are in a reasonable data state
    try:
      mmts = self._gets(self._admin_workflow_mmt_thumbnail)
    # I know this looks weird, but I want an explicit error string for this failure if it occurs
    except ElementDoesNotExistAssertionError:
      raise ElementDoesNotExistAssertionError('No extant MMT found for Journal. '
                                              'This should never happen.')
    try:
      jid = self._driver.current_url.split('=')[1]
    except IndexError:
      logging.info("We are on the All journals selection, have to roll up all mmt")
      all_journals = True
    if not all_journals:
      db_mmts = PgSQL().query('SELECT paper_type, id '
                              'FROM manuscript_manager_templates '
                              'WHERE journal_id = %s;', (jid,))
    else:
      db_mmts = PgSQL().query('SELECT paper_type, id '
                              'FROM manuscript_manager_templates;')
    logging.info(db_mmts)
    for dbmmt in db_mmts:
      logging.debug('Appending {0} to dbmmts'.format(dbmmt[0]))
      dbmmts.append(dbmmt[0])
      dbids.append(dbmmt[1])
    logging.info(dbids)
    if mmts:
      count = 0
      for mmt in mmts:
        name = mmt.find_element(*self._admin_workflow_mmt_title)
        logging.info('Examining MMT: {0}'.format(name.text))
        assert name.text in dbmmts, name.text
        journal = mmt.find_element(*self._admin_workflow_mmt_journal)
        logging.info('Validating MMT for journal: {0}'.format(journal.text))
        if all_journals:
          jid = PgSQL().query('SELECT id '
                              'FROM journals '
                              'WHERE LOWER(name) = %s;', (journal.text.lower(),))[0][0]
          logging.info(jid)
          jid = int(jid)
          logging.info('JID is {0}'.format(jid))
        mmt_id = PgSQL().query('SELECT id '
                               'FROM manuscript_manager_templates '
                               'WHERE journal_id = %s '
                               'AND paper_type = %s;', (jid, name.text))
        assert mmt_id, 'No workflow named "{0}" in journal: {1}'.format(name.text, journal.text)
        # TODO: validate Last Update label and date stamp
        # PSQL: last_update = select latest updated_at from phase_templates where manuscript_
        # manager_template_id=mmt_id (This doesn't seem correct - ask a dev)
        db_mmt_active_paper_count = PgSQL().query('SELECT count(*) '
                                                  'FROM papers '
                                                  'WHERE journal_id = %s '
                                                  'AND paper_type = %s '
                                                  'AND active = %s;', (jid,
                                                                       name.text,
                                                                       'true'))[0][0]
        db_mmt_active_paper_count = int(db_mmt_active_paper_count)
        page_mmt_active_paper_count = \
            int(mmt.find_element(*self._admin_workflow_mmt_number_of_ms_and_label).text.split(' Active')[0])
        assert page_mmt_active_paper_count == db_mmt_active_paper_count, \
            'Page MMT Active MS Count: {0}, is not equal to DB MMT ' \
            'Active MS Count: {1} for mmt: {2}'.format(page_mmt_active_paper_count,
                                                       db_mmt_active_paper_count,
                                                       name.text)
        assert mmt.value_of_css_property('background-color') == APERTA_BLUE, \
          mmt.value_of_css_property('background-color')
        # Validate Color shift on hover
        self._actions.move_to_element_with_offset(mmt, 5, 5).perform()
        # The hover color of the mmt thumbnails is not present in the approved palette in the
        #   style guide. Currently only a question in APERTA-8989.
        # assert mmt.value_of_css_property('background-color') == APERTA_BLUE_DARK, \
        #   mmt.value_of_css_property('background-color')
    if not all_journals:
      add_mmt_btn.click()
      self._validate_mmt_definition_overlay_items()

  def _validate_mmt_definition_overlay_items(self):
    """
    Validate the elements of the manuscript manager template (aka paper type)
    :return: void function
    """
    self._wait_for_element(self._get(self._mmt_template_name_field))
    template_field = self._get(self._mmt_template_name_field)
    # The default name should be Research
    assert 'Research' in template_field.get_attribute('value'), \
        template_field.get_attribute('value')
    self._get(self._mmt_template_save_button)
    template_cancel = self._get(self._mmt_template_cancel_link)
    self._gets(self._mmt_template_add_phase_icons)
    self._wait_for_element(self._get(self._mmt_template_columns))
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

  def add_new_mmt_template(self, commit=False, mmt_name='',
                           user_tasks=('upload_manuscript',),
                           staff_tasks=('assign_team', 'editor_discussion', 'final_tech_check',
                                        'initial_tech_check', 'invite_academic_editor',
                                        'invite_reviewers', 'production_metadata',
                                        'register_decision', 'related_articles',
                                        'revision_tech_check', 'send_to_apex',
                                        'title_and_abstract'),
                           uses_resrev_report=True,
                           preprint_eligible=False,
                           settings=None):
    """
    A function to add a new mmt (paper type) template to a journal
    :param commit: boolean, whether to commit the named mmt to the journal, defaults to False.
      All other params are ignored if False
    :param mmt_name: optional name for the new mmt
    :param user_tasks: list of user facing tasks to add to the mmt
    :param staff_tasks: list of staff facing tasks to add to the mmt
    :param uses_resrev_report: boolean, default true, specifies mmt type as research for
      the purposes of reviewer report selection
    :param preprint_eligible: bool, Whether the mmt supports preprint functions, including export
    :param settings: tuple of dictionaries: card_name, setting name and value
    :return: void function
    """
    if not commit:
      logging.info('Add New Template called')
      add_mmt_btn = self._get(self._admin_workflow_add_mmt_btn)
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
      # time to execute the save, then given the above comment, set timeout temporarily low since
      #  the error pops immediately in in that data condition
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
      logging.info('Adding {0} MMT with user tasks: {1}, staff tasks {2}, and that uses the research reviewer '
                   'report: {3}, with a preprint eligible setting: {4}, automation setting for the '
                   'similar check card: {5}'.format(mmt_name,
                                                    user_tasks,
                                                    staff_tasks,
                                                    uses_resrev_report,
                                                    preprint_eligible,
                                                    settings))
      add_mmt_btn = self._get(self._admin_workflow_add_mmt_btn)
      add_mmt_btn.click()
      self._wait_for_element(self._get(self._mmt_template_name_field))
      if uses_resrev_report:
        self._get(self._mmt_template_resrev_checkbox).click()
      if preprint_eligible:
        self._get(self._mmt_template_preprint_checkbox).click()
      template_field = self._get(self._mmt_template_name_field)
      save_template_button = self._get(self._mmt_template_save_button)
      template_field.click()
      template_field.send_keys(Keys.ARROW_DOWN + (Keys.BACKSPACE * 8) + mmt_name + Keys.ENTER)
      self._wait_for_element(save_template_button)
      save_template_button.click()
      # time.sleep(1)
      #
      active_queries = self._driver.execute_script("return jQuery.active")
      seconds_to_wait = max(5, int(int(active_queries) / 4))
      logging.info('Saving mmt: {0}, active queries: {1}, max_wait: {2}'.format(mmt_name, str(active_queries),
                                                                                str(seconds_to_wait)))
      self._wait_on_lambda(lambda:
                           self._driver.execute_script("return jQuery.active") == 0, max_wait=seconds_to_wait)
      #

      phases = self._gets(self._mmt_template_column_add_new_card_btn)
      phase1 = phases[0]
      if user_tasks:
        phase1.click()
        # wait for custom cards loading
        self._wait_for_text_be_present_in_element(self._card_columns,'Reporting Guidelines')
        for card_name in user_tasks:
          self.add_card_to_mmt(card_name)
        div_buttons = self._get(self._div_buttons)
        check_divs_before = len(self._gets(self._check_divs))
        div_buttons.find_element(*self._add_button).click()
        self._wait_on_lambda(lambda: self._driver.execute_script("return jQuery.active") == 0, max_wait=10)
        self._wait_on_lambda(lambda: len(self._driver.find_elements(*self._check_divs))
                                     ==(check_divs_before+len(user_tasks)-2), max_wait=5)
        #time.sleep(1)
      phase2 = phases[1]
      if staff_tasks:
        phase2.click()
        # wait for custom cards loading
        self._wait_for_text_be_present_in_element(self._card_columns,'Reporting Guidelines')
        for card_name in staff_tasks:
          self.add_card_to_mmt(card_name)
        div_buttons = self._get(self._div_buttons)
        check_divs_before = len(self._gets(self._check_divs))
        div_buttons.find_element(*self._add_button).click()
        self._wait_on_lambda(lambda: self._driver.execute_script("return jQuery.active") == 0, max_wait=10)
        self._wait_on_lambda(lambda: len(self._driver.find_elements(*self._check_divs))
                                     ==(check_divs_before+len(staff_tasks)-2), max_wait=5)

        self._scroll_into_view(self._get(self._mmt_template_save_button))
        save_template_button = self._get(self._mmt_template_save_button)
        save_template_button.click()
        #
        active_queries = self._driver.execute_script("return jQuery.active")
        seconds_to_wait = max(5, int(int(active_queries)/4))
        logging.info('Saving mmt: {0}, active queries: {1}, max_wait: {2}'.format(mmt_name, str(active_queries),
                                                                                  str(seconds_to_wait)))
        self._wait_on_lambda(lambda:
                             self._driver.execute_script("return jQuery.active") == 0, max_wait=seconds_to_wait)
        self._wait_for_element(self._get(self._mmt_template_back_link))
        #
      #time.sleep(1)
      if settings:
        for setting in settings:
          self.set_settings(setting)
          self._wait_for_not_element(self._div_buttons, 0.1)
        time.sleep(1)
      self._wait_for_element(self._get(self._mmt_template_back_link))
      back_btn = self._get(self._mmt_template_back_link)
      #self._scroll_into_view(self._get(self._mmt_template_save_button))
      back_btn.click()
      self._wait_on_lambda(lambda: 'workflows' in self._driver.current_url)

  def delete_new_mmt_template(self):
    """
    A function to delete a newly added mmt (paper type) template to a journal
    :return: void function
    """
    logging.info('Delete New Template called')
    mmts = self._gets(self._admin_workflow_mmt_thumbnail)
    if mmts:
      count = 0
      for mmt in mmts:
        name = mmt.find_element(*self._admin_workflow_mmt_title)
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
    mmts = self._gets(self._admin_workflow_mmt_thumbnail)
    if mmts:
      for mmt in mmts:
        name = mmt.find_element(*self._admin_workflow_mmt_title)
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
      raise ElementDoesNotExistAssertionError('No such card: {0}'.format(card_title))

  def validate_journal_block_display(self, username):
    """
    Provided a privileged username, validates the display of journal blocks and their elements
    :param username: a privileged username for determining which journal blocks should be displayed
    per the db
    :return: void function
    """
    logging.info(username)
    if username == 'asuperadm':
      logging.info('Validating journal blocks for Site Admin user')
      # Validate the presentation of journal blocks
      # Site Admin gets all journals
      db_journals = PgSQL().query('SELECT journals.name '
                                  'FROM journals;')
      db_journals.append('All My Journals')
    else:
      # Staff Admin role is assigned on a per journal basis
      logging.info('Validating admin page elements for Staff Admin user')
      uid = PgSQL().query('SELECT id FROM users WHERE username = %s;', (username,))[0][0]
      db_journals = []
      db_journals.append(PgSQL().query('SELECT journals.name '
                                       'FROM journals '
                                       'JOIN assignments '
                                       'ON journals.id = assignments.assigned_to_id '      
                                       'WHERE user_id = %s AND assigned_to_type=\'Journal\';',
                                       (uid,))[0][0])
      if len(db_journals) > 1:
        db_journals.append('All My Journals')
    journal_blocks = self._gets(self._admin_workflow_mmt_thumbnail)
    for journal_block in journal_blocks:
      logging.info('Testing for presence of {0}'.format(journal_block))
      journal_title = self._get(self._base_admin_journal_links)
      assert journal_title.text in db_journals, '{0} not found in \n{1}'.format(journal_title.text,
                                                                                db_journals)

  def close_mmt(self):
    """
    Close manuscript template page by clicking on Back button
    """
    self._wait_for_element(self._get(self._mmt_template_back_link))
    back_btn = self._get(self._mmt_template_back_link)
    back_btn.click()
    self._wait_for_element(self._get(self._admin_workflow_pane_title))

  def open_mmt(self, mmt_name):
    """
    A function to open existing mmt
    :param mmt_name: optional name for the new mmt
    :return: void function
    """
    self._wait_for_element(self._get(self._admin_workflow_pane_title))
    mmts = self._gets(self._admin_workflow_mmt_thumbnail)
    for mmt in mmts:
      name = mmt.find_element(*self._admin_workflow_mmt_title)
      if name.text == mmt_name:
        logging.info('Opening {0} template'.format(name.text))
        self._scroll_into_view(name)
        name.click()
        break

  def click_on_card_settings(self, card_settings_locator):
    """
    A function to open card settings
    :param card_settings_locator: locator to find the gear icon
    :return: void function
    """
    self._wait_for_element(self._get(card_settings_locator))
    settings_icon = self._get(card_settings_locator)
    # Hover color of the Similarity Check settings cog should be Admin blue
    self._scroll_into_view(settings_icon)
    color_before = settings_icon.value_of_css_property('color')
    logging.info('Icon color before moving to it: '.format(color_before))
    #self._actions.move_to_element(settings_icon).perform()
    logging.info('Moving to settings gear icon')
    self._actions.move_to_element_with_offset(settings_icon, 1, 1).perform()
    logging.info('Icon color is: '.format(settings_icon.value_of_css_property('color')))
    self._wait_on_lambda(lambda: settings_icon.value_of_css_property('color') != color_before)
    # time.sleep(1)
    assert settings_icon.value_of_css_property('color') == APERTA_BLUE, \
      settings_icon.value_of_css_property('color')
    settings_icon.click()

  def set_settings(self, setting):
    """
    A function to set card setting
    :param setting: dictionary with card name, seetting name and setting value
    :return: void function
    """
    if setting['card_name'] == 'Similarity Check':
      self.click_on_card_settings(self._sim_check_card_settings)
      sim_check_settings = SimCheckSettings(self._driver)
      sim_check_settings.set_ithenticate(setting['value'])
      sim_check_settings.click_save_settings()

  def wait_for_not_active_jqueries(self, mmt_name):
    #
    active_queries = self._driver.execute_script("return jQuery.active")
    seconds_to_wait = max(5, int(int(active_queries) / 4))
    logging.info('Saving mmt: {0}, active queries: {1}, max_wait: {2}'.format(mmt_name, str(active_queries),
                                                                              str(seconds_to_wait)))
    self._wait_on_lambda(lambda:
                         self._driver.execute_script("return jQuery.active") == 0, max_wait=seconds_to_wait)
    #
