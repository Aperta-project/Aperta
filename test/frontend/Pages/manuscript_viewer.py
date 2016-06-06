#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Editor Page. Validates global and dynamic elements and their styles
NOTE: This POM will be outdated when the Paper Editor is removed.
"""
import logging
import os
import random
import time
from datetime import datetime

from selenium.webdriver.common.by import By

from authenticated_page import AuthenticatedPage, application_typeface
from Base.Resources import affiliation, creator_login1, creator_login2, creator_login3, \
    creator_login4, creator_login5, staff_admin_login, pub_svcs_login, internal_editor_login, \
    super_admin_login
from Base.PDF_Util import PdfUtil
from Base.PostgreSQL import PgSQL
from frontend.Tasks.basetask import BaseTask
from frontend.Tasks.additional_information_task import AITask
from frontend.Tasks.authors_task import AuthorsTask
from frontend.Tasks.billing_task import BillingTask
from frontend.Tasks.revise_manuscript_task import ReviseManuscriptTask

__author__ = 'sbassi@plos.org'


class ManuscriptViewerPage(AuthenticatedPage):
  """
  Model an aperta paper viewer page
  """
  def __init__(self, driver, url_suffix='/'):
    super(ManuscriptViewerPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Main Viewer Div
    self._paper_title = (By.ID, 'control-bar-paper-title')
    self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
    self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
    self._card = (By.CLASS_NAME, 'card')
    self._submit_button = (By.ID, 'sidebar-submit-paper')
    self._withdraw_banner = (By.CLASS_NAME, 'withdrawal-banner')
    self._withdraw_banner_reactivate_button = (By.CSS_SELECTOR,
                                               'div.withdrawal-banner > div.button-secondary')
    # Sidebar Items
    self._task_headings = (By.CLASS_NAME, 'task-disclosure-heading')
    self._task_heading_status_icon = (By.CLASS_NAME, 'task-disclosure-completed-icon')
    self._task_heading_completed_icon = (By.CLASS_NAME, 'task-disclosure-completed-icon active')
    # Main Toolbar items
    self._tb_versions_link = (By.ID, 'nav-versions')
    self._tb_versions_diff_div = (By.CSS_SELECTOR, 'div.html-diff')
    self._tb_versions_closer = (By.CLASS_NAME, 'exit-versions')
    self._tb_collaborators_link = (By.ID, 'nav-collaborators')
    self._tb_add_collaborators_label = (By.CLASS_NAME, 'contributors-add')
    self._tb_collaborator_list_item = (By.CLASS_NAME, 'contributor')
    self._tb_downloads_link = (By.ID, 'nav-downloads')
    self._tb_dl_pdf_link = (By.XPATH, ".//div[contains(@class, 'manuscript-download-links')]/a[2]")
    self._tb_dl_docx_link = (By.CLASS_NAME, 'docx')
    self._tb_more_link = (By.CSS_SELECTOR, 'div#more-dropdown-menu > div > span')
    self._tb_more_appeal_link = (By.ID, 'nav-appeal')
    self._tb_more_withdraw_link = (By.ID, 'nav-withdraw-manuscript')
    self._tb_workflow_link = (By.ID, 'go-to-workflow')
    # Manage Collaborators Overlay
    self._add_collaborators_modal = (By.CLASS_NAME, 'show-collaborators-overlay')
    self._add_collaborators_modal_header = (By.CLASS_NAME, 'overlay-title-text')
    self._add_collaborators_modal_support_text = (By.CLASS_NAME, 'overlay-supporting-text')
    self._add_collaborators_modal_support_select = (By.CLASS_NAME, 'collaborator-select')
    self._add_collaborators_modal_input = (By.CLASS_NAME, 'select2-input')
    self._add_collaborators_modal_select = (By.CSS_SELECTOR, 'div.select2-container')

    self._add_collaborators_modal_cancel = (By.XPATH, "//div[@class='overlay-action-buttons']/a")
    self._add_collaborators_modal_save = (By.XPATH, "//div[@class='overlay-action-buttons']/button")
    # Withdraw Manuscript Overlay
    self._wm_modal = (By.CLASS_NAME, 'overlay--fullscreen')
    self._wm_exclamation_circle = (By.CLASS_NAME, 'fa-exclamation-circle')
    self._wm_modal_title = (By.CSS_SELECTOR, 'h1')
    self._wm_modal_text = (By.CSS_SELECTOR, 'div.overlay-body div p')
    self._wm_modal_textarea = (By.CSS_SELECTOR, 'div.paper-withdraw-wrapper > textarea')
    self._wm_modal_yes = (By.XPATH, '//div[@class="pull-right"]/button[1]')
    self._wm_modal_no = (By.XPATH, '//div[@class="pull-right"]/button[2]')
    # Submit Confirmation and Submit Congratulations Overlays (full and initial submit versions)
    # The overlay close X is universal and defined in
    # authenticated page (self._overlay_header_close)
    self._so_paper_submit_icon = (By.CLASS_NAME, 'paper-submit-icon')
    self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
    self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR,
                                                 'div.overlay-title-text-submit + h5')
    self._so_paper_title = (By.ID, 'paper-submit-title')
    self._so_submit_confirm = (By.CLASS_NAME, 'button-submit-paper')
    self._so_submit_cancel = (By.CSS_SELECTOR, 'div.submit-action-buttons button.button-link')
    self._so_close_after_submit = (By.CLASS_NAME, 'success-close')
    # Paper Sidebar and associated items
    self._paper_sidebar = (By.CLASS_NAME, 'paper-sidebar')
    self._paper_sidebar_info = (By.CLASS_NAME, 'paper-sidebar-info')
    self._paper_sidebar_assigned_tasks = (By.ID, 'paper-assigned-tasks')
    self._paper_sidebar_metadata_tasks = (By.ID, 'paper-metadata-tasks')
    # Sidebar Info Items
    self._paper_sidebar_submit_success_msg = (By.CLASS_NAME, 'task-list')
    self._paper_sidebar_state_information = (By.ID, 'submission-state-information')
    # Assigned Tasks
    self._billing_task = (By.CLASS_NAME, 'billing-task')
    self._cover_letter_task = (By.CLASS_NAME, 'cover-letter-task')
    self._cfa_task = (By.CLASS_NAME, 'changes-for-author-task')
    self._review_cands_task = (By.CLASS_NAME, 'reviewer-candidates-task')
    self._revise_task_task = (By.CLASS_NAME, 'revise-task')
    # Metadata Tasks
    self._addl_info_task = (By.CLASS_NAME, 'publishing-related-questions-task')
    self._authors_task = (By.CLASS_NAME, 'authors-task')
    self._competing_ints_task = (By.CLASS_NAME, 'competing-interests-task')
    self._data_avail_task = (By.CLASS_NAME, 'data-availability-task')
    self._ethics_statement_task = (By.CLASS_NAME, 'ethics-statement-task')
    self._figures_task = (By.CLASS_NAME, 'figure-task')
    self._fin_disclose_task = (By.CLASS_NAME, 'financial-disclosure-task')
    self._new_taxon_task = (By.CLASS_NAME, 'new-taxon-task')
    self._report_guide_task = (By.CLASS_NAME, 'reporting-guidelines-task')
    self._supporting_info_task = (By.CLASS_NAME, 'supporting-info-task')
    self._upload_manu_task = (By.CLASS_NAME, 'upload-manuscript-task')
    # infobox
    self._question_mark_icon = (By.ID, 'submission-process-toggle')
    # While IDs are normally king, for this element, we don't hide the element, we just change
    # its class to "hide" it
    self._infobox = (By.CSS_SELECTOR, 'div.show-process')
    self._manuscript_viewer_status_area = (By.ID, 'submission-state-information')
    self._status_info_initial_submit_todo = (By.CSS_SELECTOR,
                                             'div.gradual-engagement-presubmission-messaging')
    self._status_info_ready_to_submit = (By.CSS_SELECTOR, 'div.ready-to-submit')
    self._title = (By.ID, 'control-bar-paper-title')

  # POM Actions
  def validate_page_elements_styles_functions(self, useremail='', admin=''):
    """
    Main method to validate styles and basic functions for all elements
    in the page
    :param useremail: String with the email whom the page is rendered to
    :param admin: Boolean to indicate if the page is rendered for an admin user
    """
    if admin:
      self._get(self._tb_workflow_link)
    # Check application buttons
    self._check_version_btn_style()
    self._check_collaborator()
    self._check_download_btns()
    self._check_recent_activity()
    self._check_discussion(useremail)
    self._check_more_btn(useremail)

  def _check_version_btn_style(self):
    """
    Test version button. This test checks styles but not funtion
    """
    version_btn = self._get(self._tb_versions_link)
    version_btn.click()
    self._get(self._tb_versions_diff_div)
    bar_items = self._gets(self._bar_items)
    assert 'Now viewing:' in bar_items[1].text, bar_items[1].text
    assert 'Compare With:' in bar_items[2].text, bar_items[2].text
    self._get(self._tb_versions_closer).click()

  def get_manuscript_version(self):
    """
    Retrieves current manuscript version
    :return: String with manuscript version number
    """
    version_btn = self._get(self._tb_versions_link)
    version_btn.click()
    # allow time for components to attach to DOM
    time.sleep(1)
    bar_items = self._gets(self._bar_items)
    version_number = bar_items[1].text.split('\n')[1].split()[0]
    self._get(self._tb_versions_closer).click()
    return version_number

  def get_journal_id(self):
    """
    Retrieves journal id
    :return: Int with journal_id
    """
    paper_id = self.get_paper_db_id()
    print paper_id
    journal_id = PgSQL().query('SELECT papers.journal_id '
                               'FROM papers '
                               'WHERE id = %s;', (paper_id,))[0][0]
    return journal_id

  def _check_collaborator(self):
    """
    Test collaborator modal.
    """
    collaborator_btn = self._get(self._tb_collaborators_link)
    collaborator_btn.click()
    # APERTA-6840 - we disabled add collaborators temporarily
    # add_collaborators = self._get(self._tb_add_collaborators_label)
    # assert 'Add Collaborators' in add_collaborators.text
    # add_collaborators.click()
    # self._get(self._add_collaborators_modal)
    # add_collaborator_header = self._get(self._overlay_header_title)
    # assert "Who can collaborate on this manuscript?" == add_collaborator_header.text
    # # self.validate_modal_title_style(add_collaborator_header)
    # assert ("Select people to collaborate with on this paper. Collaborators can edit the "
    #         "paper, will be notified about edits on the paper, and can participate in the "
    #         "discussion about this paper." ==
    #         self._get(self._add_collaborators_modal_support_text).text)
    # self._get(self._add_collaborators_modal_support_select)
    # cancel = self._get(self._overlay_action_button_cancel)
    # self.validate_default_link_style(cancel)
    # save = self._get(self._overlay_action_button_save)
    # self.validate_primary_big_green_button_style(save)
    # close_icon_overlay = self._get(self._overlay_header_close)
    # # TODO: Change following line after bug #102078080 is solved
    # assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    # assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    # assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    # close_icon_overlay.click()
    # time.sleep(1)
    collaborator_btn.click()
    time.sleep(1)

  def _check_download_btns(self):
    """
    Check basic function and style of the downloads buttons.
    """
    downloads_link = self._get(self._tb_downloads_link)
    downloads_link.click()
    word_link = self._get(self._tb_dl_docx_link)
    assert 'WORD' in word_link.text, word_link.text
    assert '#' in self._get(self._tb_dl_docx_link).get_attribute('href')
    pdf_link = self._get(self._tb_dl_pdf_link)
    assert 'PDF' in pdf_link.text, pdf_link.text
    assert 'download.pdf' in pdf_link.get_attribute('href')
    time.sleep(1)
    downloads_link.click()
    time.sleep(1)

  def validate_download_btn_actions(self):
    """
    Initiates all supported download types, validates complete download and for pdf does
      some structural and metadata tests of the output.
    :return: void function
    """
    original_dir = os.getcwd()
    downloads_link = self._get(self._tb_downloads_link)
    downloads_link.click()
    word_link = self._get(self._tb_dl_docx_link)
    word_link.click()
    time.sleep(3)
    # Note that there is no validation of the doc or docx - we are not manipulating them at all
    #   Just returning the last stored version - so not doing anything beyond validating download
    #   completion.
    os.chdir('/tmp')
    files = filter(os.path.isfile, os.listdir('/tmp'))
    files = [os.path.join('/tmp', f) for f in files]  # add path to each file
    files.sort(key=lambda x: os.path.getmtime(x))
    newest_file = files[-1]
    logging.debug(newest_file)
    while newest_file.split('.')[-1] == 'part':
      time.sleep(5)
      files = filter(os.path.isfile, os.listdir('/tmp'))
      files = [os.path.join('/tmp', f) for f in files]  # add path to each file
      files.sort(key=lambda x: os.path.getmtime(x))
      newest_file = files[-1]
      logging.debug(newest_file.split('.')[-1])
    logging.debug(newest_file)
    os.remove(newest_file)
    # Tiny delay between download types to keep clean
    time.sleep(1)
    pdf_link = self._get(self._tb_dl_pdf_link)
    pdf_link.click()
    # This lengthy delay is here because the file must begin downloading before we can start
    #   to see if the download completes
    time.sleep(15)
    os.chdir('/tmp')
    files = filter(os.path.isfile, os.listdir('/tmp'))
    files = [os.path.join('/tmp', f) for f in files]  # add path to each file
    files.sort(key=lambda x: os.path.getmtime(x))
    newest_file = files[-1]
    logging.debug('Newest file is {0}'.format(newest_file.split('.')[-1]))
    while newest_file.split('.')[-1] == 'part':
      time.sleep(5)
      files = filter(os.path.isfile, os.listdir('/tmp'))
      files = [os.path.join('/tmp', f) for f in files]  # add path to each file
      files.sort(key=lambda x: os.path.getmtime(x))
      newest_file = files[-1]
      logging.debug(newest_file.split('.')[-1])
    logging.debug(newest_file)
    pdf_valid = PdfUtil.validate_pdf(newest_file)
    if not pdf_valid:
      logging.error('PDF file: {0} is invalid'.format(newest_file))
      raise ('Invalid PDF generated for {0}'.format(newest_file))
    os.remove(newest_file)
    os.chdir(original_dir)

  def validate_download_pdf_actions(self):
    """
    Initiates pdf download, validates complete download and does
      some structural and metadata tests of the output.
      Note that this is not actually called at present, but has been a useful function for
      doing ad-hoc tests around pdf generation about which we have had much pain.
    :return: void function
    """
    downloads_link = self._get(self._tb_downloads_link)
    downloads_link.click()
    pdf_link = self._get(self._tb_dl_pdf_link)
    pdf_link.click()
    time.sleep(3)
    os.chdir('/tmp')
    files = filter(os.path.isfile, os.listdir('/tmp'))
    files = [os.path.join('/tmp', f) for f in files]  # add path to each file
    files.sort(key=lambda x: os.path.getmtime(x))
    newest_file = files[-1]
    logging.debug('Newest file type is {0}'.format(newest_file.split('.')[-1]))
    while newest_file.split('.')[-1] == 'part':
      time.sleep(5)
      files = filter(os.path.isfile, os.listdir('/tmp'))
      files = [os.path.join('/tmp', f) for f in files]  # add path to each file
      files.sort(key=lambda x: os.path.getmtime(x))
      newest_file = files[-1]
      logging.debug('Newest file type is {0}'.format(newest_file.split('.')[-1]))
    logging.debug(newest_file)
    pdf_valid = PdfUtil.validate_pdf(newest_file)
    if not pdf_valid:
      logging.error('PDF file: {0} is invalid'.format(newest_file))
      raise('Invalid PDF generated for {0}'.format(newest_file))
    os.remove(newest_file)

  def _check_recent_activity(self):
    """
    Check recent activity modal styles
    """
    recent_activity = self._get(self._recent_activity)
    recent_activity.click()
    time.sleep(.5)
    self._get(self._recent_activity_modal)
    modal_title = self._get(self._overlay_header_title)
    self.validate_application_title_style(modal_title)
    close_icon_overlay = self._get(self._overlay_header_close)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()
    time.sleep(1)

  def _check_discussion(self, useremail=''):
    """
    Check discussion modal styles
    """
    logging.info('Checking Discussions toolbar for {0}'.format(useremail))
    discussion_link = self._get(self._discussion_link)
    discussion_link.click()
    self._get(self._discussion_container)
    discussion_container_title = self._get(self._discussion_container_title)
    # Note: The following method is parametrized since we don't have a guide for modals
    self.validate_modal_title_style(discussion_container_title, '36px', '500', '39.6px')
    assert 'Discussions' in discussion_container_title.text
    # Only Admins, Internal Editors and PubSvcs Staff can initiate a discussion APERTA-5627
    if useremail in [staff_admin_login['email'],
                     pub_svcs_login['email'],
                     internal_editor_login['email'],
                     super_admin_login['email'],
                     ]:
      discussion_create_new_btn = self._get(self._discussion_create_new_btn)
      # APERTA-6361 Styling incorrect
      # self.validate_secondary_big_green_button_style(discussion_create_new_btn)
      create_new_topic = self._get(self._create_new_topic)
      assert 'Create New Topic'.upper() in create_new_topic.text, create_new_topic.text
      discussion_create_new_btn.click()
      # TODO: Styles for cancel since is not in the style guide
      cancel = self._get(self._create_topic_cancel)
      assert application_typeface in cancel.value_of_css_property('font-family')
      assert cancel.value_of_css_property('font-size') == '14px'
      assert cancel.value_of_css_property('line-height') == '60px'
      assert cancel.value_of_css_property('background-color') == 'transparent'
      assert cancel.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
      assert cancel.value_of_css_property('font-weight') == '400'
      # TODO: Styles for create_new_topic since is not in the style guide
      titles = self._gets(self._topic_title)
      assert 'Topic Title' == titles[0].text
      assert 'Message' == titles[1].text
      create_topic_btn = self._get(self._create_topic_btn)
      #
      self.validate_primary_big_green_button_style(create_topic_btn)
    close_icon_overlay = self._get(self._sheet_close_x)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px', '42px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    close_icon_overlay.click()

  def _check_more_btn(self, useremail=''):
    """
    Check all options inside More button (Appeal and Withdraw).
    Note that Appeal is not implemented yet, so it is not tested.
    """
    logging.info('Checking More Toolbar menu for {0}'.format(useremail))
    more_btn = self._get(self._tb_more_link)
    more_btn.click()
    # For the time being, the appeals link is being removed for everybody.
    # self._get(self._tb_more_appeal_link)
    # Per APERTA-5371 only creators, admins, pub svcs and internal editors can see the withdraw item
    if useremail in [creator_login1['email'],
                     creator_login2['email'],
                     creator_login3['email'],
                     creator_login4['email'],
                     creator_login5['email'],
                     staff_admin_login['email'],
                     pub_svcs_login['email'],
                     internal_editor_login['email'],
                     super_admin_login['email'],
                     ]:
      withdraw_link = self._get(self._tb_more_withdraw_link)
      withdraw_link.click()
      self._get(self._wm_modal)
      self._get(self._wm_exclamation_circle)
      modal_title = self._get(self._wm_modal_title)
      assert 'Are you sure?' == modal_title.text
      # TODO: Style parametrized due to lack of styleguide for modals
      self.validate_modal_title_style(modal_title, '48px', line_height='52.8px',
                                      font_weight='500', color='rgba(119, 119, 119, 1)')
      withdraw_modal_text = self._get(self._wm_modal_text)
      # TODO: Leave comment out until solved. Pivotal bug#103864752
      # self.validate_application_ptext(withdraw_modal_text)
      assert ('Withdrawing your manuscript will withdraw it from consideration.\n'
              'Please provide your reason for withdrawing this manuscript.' in
              withdraw_modal_text.text)
      self._get(self._wm_modal_textarea)
      yes_btn = self._get(self._wm_modal_yes)
      assert 'YES, WITHDRAW' == yes_btn.text, yes_btn.text
      no_btn = self._get(self._wm_modal_no)
      assert "NO, I'M STILL WORKING" == no_btn.text, no_btn.text
      self.validate_link_big_grey_button_style(yes_btn)
      # TODO: Leave comment out until solved. Pivotal bug#103858114
      # self.validate_secondary_grey_small_button_modal_style(no_btn)
      close_icon_overlay = self._get(self._overlay_header_close)
      # TODO: Change following line after bug #102078080 is solved
      assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
      assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
      assert close_icon_overlay.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
      close_icon_overlay.click()

  def withdraw_manuscript(self):
    """
    Executes a withdraw action for a given manuscript
    :return: void function
    """
    more_btn = self._get(self._tb_more_link)
    more_btn.click()
    withdraw_link = self._get(self._tb_more_withdraw_link)
    withdraw_link.click()
    self._get(self._wm_modal_textarea).send_keys('I am so bored with all this...')
    self._get(self._wm_modal_yes).click()
    # Give a little time for the db transaction
    time.sleep(3)


  def validate_roles(self, user_buttons):
    """
    Given an amount of expected item, check if they are in the top menu.
    This can be expanded as needed.
    :param user_buttons: number of expected buttons
    """
    # Time needed to update page and get correct amount of items
    time.sleep(1)
    buttons = self._gets(self._control_bar_right_items)
    assert self._get(self._tb_workflow_link) if user_buttons == 8 else (len(buttons) == 7), \
        len(buttons)

  def is_task_present(self, task_name):
    """
    Check if a task is available in the task list
    :param task_name: The name of the task to validate
    return True if task is present and False otherwise
    """
    tasks = self._gets(self._task_headings)
    for task in tasks:
      if task.text == task_name:
        return True
    return False

  def complete_task(self, task_name, click_override=False, data=None):
    """
    On a given task, check complete and then close
    :param task_name: The name of the task to complete (str)
    :param click_override:
    :param data:
    """
    tasks = self._gets(self._task_headings)
    # if task is marked as complete, leave is at is.
    if not click_override:
      for task in tasks:
        task_div = task.find_element_by_xpath('..')
        if task.text == task_name and 'active' \
            not in task_div.find_element(*self._task_heading_status_icon).get_attribute('class'):
          manuscript_id_text = self._get(self._paper_sidebar_manuscript_id)
          self._actions.move_to_element(manuscript_id_text).perform()
          task.click()
          time.sleep(.5)
          break
        elif task.text == task_name and 'active' \
            in task_div.find_element(*self._task_heading_status_icon).get_attribute('class'):
          return None
      else:
        return None
    else:
      for task in tasks:
        if task.text == task_name:
          task.click()
          break
      else:
        return None
    base_task = BaseTask(self._driver)
    base_task.set_timeout(60)
    if task_name == 'Additional Information':
      ai_task = AITask(self._driver)
      # If the task is read only due to completion state, set read-write
      if base_task.completed_state():
        base_task.click_completion_button()
      ai_task.complete_ai()
      # complete_addl info task
      if not base_task.completed_state():
        base_task.click_completion_button()
      task.click()
      time.sleep(1)
    elif task_name == 'Billing':
      billing_task = BillingTask(self._driver)
      billing_task.complete(data)
      # complete_billing task
      task.click()
      """
      if not base_task.completed_state():
        base_task.click_completion_button()
        manuscript_id_text = self._get(self._paper_sidebar_manuscript_id)
        self._actions.move_to_element(manuscript_id_text).perform()
        task.click()
      """
      time.sleep(1)
    elif task_name == 'Revise Manuscript':
      revise_manuscript = ReviseManuscriptTask(self._driver)
      revise_manuscript.validate_styles()
      revise_manuscript.validate_empty_response()
      revise_manuscript.response_to_reviewers(data)
      # complete_billing task
      if not base_task.completed_state():
        base_task.click_completion_button()
        task.click()
      time.sleep(1)
    elif task_name in ('Cover Letter', 'Figures', 'Supporting Info', 'Upload Manuscript',
                       'Financial Disclosure'):
      # before checking that the complete is selected, in the accordion we need to
      # check if it is open
      if 'task-disclosure--open' not in task_div.get_attribute('class'):
        # accordion is close it, open it:
        logging.info('Accordion was closed, opening: {0}'.format(task.text))
        task.click()
      # Check completed_check status
      if not base_task.completed_state():
        base_task.click_completion_button()
      task.click()
      time.sleep(1)
    elif task_name == 'Authors':
      # Complete authors data before mark close
      logging.info('Completing Author Task')
      author_task = AuthorsTask(self._driver)
      author_task.edit_author(affiliation)
      task.click()
      time.sleep(1)
    elif 'Review by ' in task_name:
      logging.info('Completing {0}'.format(task_name))
      if not base_task.completed_state():
        base_task.click_completion_button()
      task.click()
    else:
      raise ValueError('No information on this task: {0}'.format(task_name))
    base_task.restore_timeout()

  def get_paper_title_from_page(self):
    """
    Returns the encoded paper title as it appears on the manuscript_viewer page
    :return: paper_title
    """
    paper_title = self._get(self._paper_title).text
    return paper_title

  def click_submit_btn(self):
    """Press the submit button"""
    # Must allow time for the overlay to animate
    time.sleep(.5)
    self._get(self._submit_button).click()

  def confirm_submit_btn(self):
    """Confirm paper submission"""
    # There is a lot going on under the covers in submittal - we need this pregnant delay
    confirm_btn = self._get(self._so_submit_confirm)
    confirm_btn.click()
    time.sleep(10)

  def confirm_submit_cancel(self):
    """Cancel on confirm paper submission"""
    self._get(self._so_submit_cancel).click()

  def close_submit_overlay(self):
    """Close the submit overlay after confirm paper submission"""
    closer = self._get(self._overlay_header_close)
    closer.click()

  def click_workflow_link(self):
    """Click workflow button"""
    self._get(self._tb_workflow_link).click()

  def click_question_mark(self):
    """Click on the question mark to open Infobox"""
    self._get(self._question_mark_icon).click()

  def click_dashboard_link(self):
    """Click on dashboard link"""
    self._get(self._nav_aperta_dashboard_link).click()

  def click_your_manuscript_link(self):
    """Click on Your Manuscripts link"""
    self._get(self._your_manuscripts_link).click()

  def go_to_dashboard(self, item=''):
    """
    Go to the dashboard
    :param item: string with the item where to click ('aperta' for Aperta Icon or
                 'your_manuscripts' for Your Manuscripts link)
    """
    dashboard = {'aperta': self._nav_aperta_dashboard_link,
                 'your_manuscripts': self._your_manuscripts_link}
    if item:
      self._get(dashboard[item]).click()
    else:
      dashboard_link = dashboard[random.choice(dashboard)]
      self._get(dashboard_link).click()

  def get_infobox(self):
    """Get the infobox element"""
    return self._get(self._infobox)

  def get_paper_doi_part(self):
    """
    Returns the local paper identifier part of the doi
    """
    doi_text = self._get(self._paper_sidebar_manuscript_id).text
    return doi_text.split(':')[1]

  def get_title(self):
    """
    Returns the title
    """
    return self._get(self._title).text

  def get_paper_db_id(self):
    """
    Returns the DB paper ID from URL
    """
    time.sleep(1)
    paper_url = self.get_current_url()
    logging.debug(paper_url)
    # Need to cover the first view case stripping the trailing garbage
    paper_id = int(paper_url.split('papers/')[1].split('?')[0])
    logging.info('The paper DB ID is: {0}'.format(paper_id))
    return paper_id

  def validate_so_overlay_elements_styles(self, type_, paper_title):
    """
    Validates styles and content on submit overlay
    :param type_: full_submit, initial_submit, initial_submit_full, congrats, congrats_is,
    congrats_is_full
    :param paper_title: Title of manuscript whose submit overlay you are validating
    :return:
    """
    self._get(self._overlay_header_close)
    self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
    self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR,
                                                 'div.overlay-title-text-submit + h5')
    main_head = self._get(self._so_paper_submit_title_text_submit)
    subhead = self._get(self._so_paper_submit_subhead_text_submit)
    if type_ == 'full_submit':
      assert 'Are you sure?' in main_head.text, main_head.text
      assert 'You are about to submit the paper' in subhead.text, subhead.text
    elif type_ == 'congrats':
      # assert 'Congratulations' in main_head.text, main_head.text
      self._get(self._so_paper_submit_icon)
      assert 'You\'ve successfully submitted your paper!' in subhead.text, subhead.text
      self._get(self._so_submit_cancel)
    elif type_ == 'congrats_is':
      assert 'You have successfully submitted your manuscript for initial review. If the initial ' \
             'review is favorable, we will invite you to add some information to facilitate peer ' \
             'review.' in subhead.text, subhead.text
    elif type_ == 'congrats_full':
      assert 'You have successfully submitted your manuscript. We will start the peer review ' \
             'process.' in subhead.text, subhead.text
    if type_ in ('full_submit', 'initial_submit', 'initial_submit_full'):
      title = self._get(self._so_paper_title)
      assert paper_title in title.text, '{0} vs {1}'.format(paper_title, title.text)
      self._get(self._so_submit_confirm)

  def validate_submit_success(self):
    """
    Ensure the successful submit message appears in the upper right corner of the manuscript
    viewer page
    """
    success_msg = self._get(self._paper_sidebar_state_information)
    assert 'This paper has been submitted.' in success_msg.text, success_msg.text

  def validate_initial_submit_success(self):
    """Ensure the final submit message does not appear on initial submit"""
    success_msg = self._get(self._paper_sidebar_state_information)
    assert 'This paper has been submitted.' not in success_msg.text, success_msg.text

  def add_collaborators(self, user):
    """
    Add a collaborator
    :param user: user
    :return: None
    """
    print(user['name'])
    self._get(self._tb_collaborators_link).click()
    self._get(self._tb_add_collaborators_label).click()
    time.sleep(2)
    select_div = self._get(self._add_collaborators_modal_select)
    select_div.find_element_by_tag_name('a').click()
    select_input = self._get(self._add_collaborators_modal_input)
    select_input.send_keys(user['name'][0:4])
    # Need time for list to populate dynamically
    time.sleep(2)
    select_items = (By.CSS_SELECTOR, 'ul.select2-results')
    items = self._get(select_items)
    for item in items.find_elements_by_tag_name('li'):
      if item.text == user['name']:
        item.click()
        time.sleep(.5)
        break
    else:
      raise Exception("User {0} not found".format(user['name']))
    time.sleep(1)
    self._get(self._add_collaborators_modal_save).click()

  def get_submission_status_initial_submission_todo(self):
    """
      Extract the submission status text from the page
      """
    return self._get(self._status_info_initial_submit_todo).text

  def get_submission_status_ready2submit_text(self):
    """
    Extract the submission status text from the page
    """
    return self._get(self._status_info_ready_to_submit).text

  def wait_for_viewer_page_population(self):
    """
    Purgatory, waiting for an update that sometimes takes forever, sigh
    :return:
    """
    logging.info(datetime.now())
    self.set_timeout(230)
    self._get(self._paper_sidebar_state_information)
    logging.info(datetime.now())
    self.restore_timeout()
