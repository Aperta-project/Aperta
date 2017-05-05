#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""
import logging
import time
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import WebDriverException

from loremipsum import generate_paragraph

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import staff_admin_login, super_admin_login, \
    internal_editor_login, prod_staff_login, pub_svcs_login
from styles import StyledPage, APPLICATION_TYPEFACE, APERTA_GREEN, APERTA_GREY_DARK

__author__ = 'jgray@plos.org'


class AuthenticatedPage(StyledPage):
  """
  Model the common styles of elements of the authenticated pages to enforce consistency
  """

  def __init__(self, driver, url_suffix='/'):
    super(AuthenticatedPage, self).__init__(driver, url_suffix)

    # Locators - Instance members
    # Navigation toolbar Locators
    self._nav_toolbar = (By.CLASS_NAME, 'main-nav')
    self._nav_title = (By.CLASS_NAME, 'main-nav-item-app-name')
    self._nav_spacer = (By.CLASS_NAME, 'control-bar-item-spacer')
    # dashboard / your manuscripts Link
    self._nav_aperta_dashboard_link = (By.ID, 'nav-dashboard')
    self._nav_your_manuscripts_link = (By.ID, 'nav-manuscripts')
    self._nav_help_link = (By.ID, 'nav-help')
    self._nav_admin_link = (By.ID, 'nav-admin')
    self._nav_paper_tracker_link = (By.ID, 'nav-paper-tracker')
    self._nav_feedback_link = (By.ID, 'nav-give-feedback')
    self._nav_profile_menu_toggle = (By.ID, 'profile-dropdown-menu-trigger')
    self._nav_profile_img = (By.CSS_SELECTOR, 'div#profile-dropdown-menu-trigger > div > img')
    self._nav_profile_text = (By.CLASS_NAME, 'profile-dropdown-menu-text')
    self._nav_profile_link = (By.ID, 'nav-profile')
    self._nav_signout_link = (By.ID, 'nav-signout')
    # Global toolbar Icons
    self._toolbar_items = (By.CLASS_NAME, 'control-bar-button')
    self._editable_label = (By.ID, 'nav-paper-editable')
    self._editable_checkbox = (By.CSS_SELECTOR, 'label#nav-paper-editable > span > input')
    self._recent_activity = (By.ID, 'nav-recent-activity')
    self._discussion_link = (By.ID, 'nav-discussions')
    self._discussions_icon = (By.CSS_SELECTOR, 'a#nav-discussions > i')
    # TODO: Change this when APERTA-5531 is completed
    self._control_bar_right_items = (By.CLASS_NAME, 'control-bar-button')
    self._bar_items = (By.CSS_SELECTOR, 'div#versioning-bar label.bar-item')
    self._bar_item_selected_item = (By.CLASS_NAME, 'ember-power-select-selected-item')
    self._recent_activity_modal = (By.CLASS_NAME, 'activity-overlay')
    self._recent_activity_modal_title = (By.CSS_SELECTOR, 'h1.overlay-header-title')
    self._discussion_container = (By.CLASS_NAME, 'liquid-container')
    self._discussion_container_title = (By.CSS_SELECTOR, 'div.discussions-index-header h1')
    # Discussion related items
    self._discussion_create_new_btn = (By.CSS_SELECTOR, 'div.discussions-index-header a')
    self._create_new_topic = (By.CSS_SELECTOR, 'div.discussions-index-header a')
    self._topic_title_field = (By.ID, 'topic-title-field')
    self._create_topic = (By.CSS_SELECTOR, 'div.sheet-content button')
    self._add_participant_btn = (By.CLASS_NAME, 'add-participant-button')
    self._participant_field = (By.CLASS_NAME, 'ember-power-select-search-input')
    self._message_body_div = (By.CSS_SELECTOR, 'div.comment-board-form')
    self._message_body_field = (By.CSS_SELECTOR, 'textarea')
    self._post_message_btn = (By.CSS_SELECTOR, 'button')
    self._first_discussion_lnk = (By.CLASS_NAME, 'discussions-index-topic')
    self._topic_title = (By.CSS_SELECTOR, 'div.inset-form-control')
    self._create_topic_btn = (By.CSS_SELECTOR, 'div.discussions-show-content button')
    self._create_topic_cancel = (By.CSS_SELECTOR, 'span.sheet-toolbar-button')
    self._discussion_back_link = (By.CSS_SELECTOR, 'a.sheet-toolbar-button')
    self._sheet_close_x = (By.CLASS_NAME, 'sheet-close-x')
    # Discussion messages
    self._badge_red = (By.CSS_SELECTOR, 'span.badge--red')
    self._comment_sheet_badge_red = (By.CSS_SELECTOR, 'div.sheet-content span.badge--red')
    self._post_message_btn = (By.CSS_SELECTOR, 'div.editing button')
    self._comment_name = (By.CLASS_NAME, 'comment-name')
    self._comment_date = (By.CLASS_NAME, 'comment-date')
    self._comment_body = (By.CLASS_NAME, 'comment-body')
    self._mention = (By.CLASS_NAME, 'discussion-at-mention')
    # Withdraw Banner
    self._withdraw_banner = (By.CLASS_NAME, 'withdrawal-banner')
    # Flash Messages
    self._flash_success_msg = (By.CSS_SELECTOR,
                               'div.flash-message--success div.flash-message-content')
    self._flash_error_msg = (By.CSS_SELECTOR, 'div.flash-message--error div.flash-message-content')
    self._flash_closer = (By.CLASS_NAME, 'flash-message-remove')
    # Task list id needed in task and manuscript page
    self._paper_sidebar_state_information = (By.ID, 'submission-state-information')
    self._first_comment = (By.CLASS_NAME, 'discussion-topic-comment-field')
    self._paper_sidebar_manuscript_id = (By.CLASS_NAME, 'task-list-doi')
    # Cards - placeholder locators - these are over-ridden by definitions in the workflow and manuscript_viewer pages
    self._addl_info_card = None
    self._authors_card = None
    self._billing_card = None
    self._cfa_card = None
    self._competing_ints_card = None
    self._cover_letter_card = None
    self._data_avail_card = None
    self._early_article_posting_card = None
    self._ethics_statement_card = None
    self._figures_card = None
    self._fin_disclose_card = None
    self._new_taxon_card = None
    self._report_guide_card = None
    self._review_cands_card = None
    self._revise_task_card = None
    self._supporting_info_card = None
    self._upload_manu_card = None
    self._assign_admin_card = None
    self._assign_team_card = None
    self._editor_discussion_card = None
    self._final_tech_check_card = None
    self._initial_decision_card = None
    self._initial_tech_check_card = None
    self._invite_ae_card = None
    self._invite_reviewers_card = None
    self._production_metadata_card = None
    self._register_decision_card = None
    self._related_articles_card = None
    self._reviewer_report_card = None
    self._revision_tech_check_card = None
    self._send_to_apex_card = None
    self._title_abstract_card = None
    # Tasks - placeholder locators - these are over-ridden by definitions in the workflow and manuscript_viewer pages
    self._addl_info_task = None
    self._authors_task = None
    self._billing_task = None
    self._cfa_task = None
    self._competing_ints_task = None
    self._cover_letter_task = None
    self._early_article_posting_task = None
    self._data_avail_task = None
    self._ethics_statement_task = None
    self._figures_task = None
    self._fin_disclose_task = None
    self._new_taxon_task = None
    self._report_guide_task = None
    self._review_cands_task = None
    self._research_reviewer_report_task = None
    self._front_matter_reviewer_report_task = None
    self._revise_task = None
    self._supporting_info_task = None
    self._upload_manu_task = None
    # Global Overlay Locators
    self._overlay_header_title = (By.CLASS_NAME, 'overlay-header-title')
    self._overlay_header_close = (By.CLASS_NAME, 'overlay-close')
    self._overlay_action_button_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a.button-link')
    self._overlay_action_button_save = (By.CSS_SELECTOR, 'div.overlay-action-buttons button.button-primary')
    # Attachment component
    self._replace_attachment = (By.CSS_SELECTOR, 'span.replace-attachment')
    self._attachment_div = (By.CSS_SELECTOR, 'div.attachment-manager')
    self._att_item = (By.CSS_SELECTOR, 'div.attachment-item')
    self._file_attach_btn = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._file_attach_input = (By.CSS_SELECTOR, 'input.add-new-attachment')
    self._attachments = (By.CSS_SELECTOR, 'div.attachment-item')
    # Add participant
    self._discussion_panel = (By.CLASS_NAME, 'sheet--visible')
    self._add_participant_list = (By.CSS_SELECTOR, 'ember-power-select-options')
    # ORCID Elements - These are applicable to both the profile page and the author task/card
    self._profile_orcid_div = (By.CLASS_NAME, 'orcid-connect')
    self._profile_orcid_logo = (By.ID, 'orcid-id-logo')
    self._profile_orcid_unlinked_div = (By.CLASS_NAME, 'orcid-not-linked')
    self._profile_orcid_unlinked_button = (By.CSS_SELECTOR, 'div.orcid-not-linked > button')
    self._profile_orcid_unlinked_help_icon = (By.CLASS_NAME, 'what-is-orcid')

    self._profile_orcid_linked_div = (By.CLASS_NAME, 'orcid-linked')
    self._profile_orcid_linked_title = (By.CSS_SELECTOR, 'div.orcid-linked')
    self._profile_orcid_linked_id_link = (By.CSS_SELECTOR, 'div.orcid-linked > a')
    self._profile_orcid_linked_delete_icon = (By.CSS_SELECTOR, 'div.orcid-linked > i.fa-trash')
    # Recent Activity Overlay
    self._recent_activity_table = (By.CSS_SELECTOR, 'div.overlay-body table')
    self._recent_activity_table_row = (By.CSS_SELECTOR, 'div.overlay-body table tr')
    self._recent_activity_table_msg = (By.CSS_SELECTOR, 'td.activity-feed-overlay-message')
    self._recent_activity_table_user_full_name = (By.CSS_SELECTOR, 'td.activity-feed-overlay-user')
    self._recent_activity_table_user_avatar = (By.CSS_SELECTOR, 'td.activity-feed-overlay-user img')
    self._recent_activity_table_timestamp = (By.CSS_SELECTOR, 'td.activity-feed-overlay-timestamp')

  # POM Actions
  def attach_file(self, file_name):
    """
    Attach a file to the attach component that is located in Invite AE and other places
    :param file_name: File name with the full path
    :return: None
    """
    logging.info('Attach file called with {0}'.format(file_name))
    attach_button = self._get(self._file_attach_btn)
    # The following element is inside a hidden div so must use iget()
    attach_input = self._iget(self._file_attach_input)
    logging.info('Sending filename to input field')
    attach_input.send_keys(file_name)
    return None

  def get_paper_short_doi_from_url(self):
    """
    Returns the database paper short doi from URL
    """
    # Need to wait for url to update
    count = 0
    short_doi = self.get_current_url().split('/')[-1]
    while not short_doi:
      if count > 60:
        raise (StandardError, 'Short doi is not updated after a minute, aborting')
      time.sleep(1)
      short_doi = self.get_current_url().split('/')[-1]
      count += 1
    short_doi = short_doi.split('?')[0] if '?' in short_doi else short_doi
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    return short_doi

  def delete_attach_file(self, file_name):
    """
    Delete a file from the attach component that is located in Invite AE and other places
    :param file_name: File name with the full path
    :return: None
    """
    items = self._get(self._attachment_div).find_elements(*self._att_item)
    for item in items:
      if file_name.split('/')[-1] in item.text:
        item.find_element(*(By.CSS_SELECTOR, 'span.delete-attachment')).click()
        break
    return None

  def get_attached_file_names(self):
    """
    Return a list with the file names in the attachment section
    :return: A list with file names as displayed in the attachment section
    """
    attachments = [x.text.split(' ')[0] for x in self._gets(self._attachments)]
    return attachments

  def click_profile_nav(self):
    """
    Click profile navigation
    :return: None
    """
    profile_menu_toggle = self._get(self._nav_profile_menu_toggle)
    profile_menu_toggle.click()
    return None

  def get_flash_success_messages(self):
    """
    Get all flash sucess messages
    :return: A list with all flash sucess messages elements
    """
    return self._gets(self._flash_success_msg)

  def validate_nav_toolbar_elements(self, permissions):
    """
    Validates the appearance of elements in the navigation menu for
    every logged in page
    :param permissions: username
    """
    elevated = [staff_admin_login, super_admin_login]
    ptracker = elevated + [internal_editor_login, prod_staff_login, pub_svcs_login]
    self._get(self._nav_title)
    self._get(self._nav_profile_img)
    # APERTA-6761
    # assert 'Aperta' in self._get(self._nav_aperta_dashboard_link).text, \
    #   self._get(self._nav_aperta_dashboard_link).text
    assert 'Your Manuscripts' == self._get(self._nav_your_manuscripts_link).text, \
      self._get(self._nav_your_manuscripts_link).text
    help_link = self._get(self._nav_help_link)
    assert help_link.text =='Help', help_link.text
    assert help_link.get_attribute('target') == '_blank', help_link.get_attribute('target')
    assert help_link.get_attribute('href') == \
        'http://journals.plos.org/plosbiology/s/aperta-help', help_link.get_attribute('href')
    self._get(self._nav_feedback_link)
    self.click_profile_nav()
    self._get(self._nav_profile_link)
    self._get(self._nav_signout_link)
    # Closing menu we opened
    self.click_profile_nav()
    # Must have flow mgr, admin or superadmin
    if permissions in elevated:
      self._get(self._nav_admin_link)
    if permissions in ptracker:
      self._get(self._nav_paper_tracker_link)
    return None

  def validate_wf_top_elements(self):
    """Validate styles of elements that are in the top menu from workflow"""
    editable = self._get(self._editable_label)
    assert editable.text.lower() == 'editable', editable.text
    # The following block needs to be moved into a standardized style validation in authenticated_page.py
    # Further a bug should be filed to note the lack of any definition of these elements in a style_guide of any kind
    # assert editable.value_of_css_property('font-size') == '10px'
    # assert editable.value_of_css_property('color') == APERTA_GREEN
    # assert editable.value_of_css_property('font-weight') == '700'
    # assert APPLICATION_TYPEFACE in editable.value_of_css_property('font-family')
    # assert editable.value_of_css_property('text-transform') == 'uppercase'
    # assert editable.value_of_css_property('line-height') == '20px'
    # assert editable.value_of_css_property('text-align') == 'center'
    ec = self._get(self._editable_checkbox)
    assert ec.get_attribute('type') == 'checkbox'
    # assert ec.value_of_css_property('color') in ('rgba(49, 55, 57, 1)', 'rgba(60, 60, 60, 1)')
    # assert ec.value_of_css_property('font-size') == '10px'
    # assert ec.value_of_css_property('font-weight') == '700'
    # recent_activity_icon = self._get(self._recent_activity_icon)
    # assert recent_activity_icon.get_attribute('d') == ('M-171.3,403.5c-2.4,0-4.5,1.4-5.5,3.5c0,'
    #             '0-0.1,0-0.1,0h-9.9l-6.5-17.2  '
    #             'c-0.5-1.2-1.7-2-3-1.9c-1.3,0.1-2.4,1-2.7,2.3l-4.3,18.9l-4-43.4c-0.1-1'
    #             '.4-1.2-2.5-2.7-2.7c-1.4-0.1-2.7,0.7-3.2,2.1l-12.5,41.6  h-16.2c-1.6,0'
    #             '-3,1.3-3,3c0,1.6,1.3,3,3,3h18.4c1.3,0,2.5-0.9,2.9-2.1l8.7-29l4.3,46.8'
    #             'c0.1,1.5,1.3,2.6,2.8,2.7c0.1,0,0.1,0,0.2,0  c1.4,0,2.6-1,2.9-2.3l6.2-'
    #             '27.6l3.7,9.8c0.4,1.2,1.5,1.9,2.8,1.9h11.9c0.2,0,0.3-0.1,0.5-0.1c1.1,1'
    #             '.7,3,2.8,5.1,2.8  c3.4,0,6.1-2.7,6.1-6.1C-165.3,406.2-168,403.5-171.3,403.5z')
    # assert recent_activity_icon.value_of_css_property('color') == APERTA_GREEN
    recent_activity_text = self._get(self._recent_activity)
    assert recent_activity_text
    assert 'Recent Activity' in recent_activity_text.text, recent_activity_text.text
    # assert recent_activity_text.value_of_css_property('font-size') == '10px'
    # assert recent_activity_text.value_of_css_property('color') == APERTA_GREEN
    # assert recent_activity_text.value_of_css_property('font-weight') == '700'
    # assert APPLICATION_TYPEFACE in recent_activity_text.value_of_css_property('font-family')
    # assert recent_activity_text.value_of_css_property('text-transform') == 'uppercase'
    # assert recent_activity_text.value_of_css_property('line-height') == '20px'
    # assert recent_activity_text.value_of_css_property('text-align') == 'center'
    discussions_icon = self._get(self._discussions_icon)
    assert discussions_icon
    # assert discussions_icon.value_of_css_property('font-family') == 'FontAwesome'
    # assert discussions_icon.value_of_css_property('font-size') == '16px'
    # assert discussions_icon.value_of_css_property('color') == APERTA_GREEN
    # assert discussions_icon.value_of_css_property('font-weight') == '400'
    # assert discussions_icon.value_of_css_property('text-transform') == 'uppercase'
    # assert discussions_icon.value_of_css_property('font-style') == 'normal'
    discussions_label = self._get(self._discussion_link)
    assert discussions_label
    assert discussions_label.text.lower() == 'discussions', discussions_label.text

  @staticmethod
  def validate_delete_icon_grey(delete_icon):
    """
    Validate style of delete icon (trash bin)
    :return: None
    """
    assert delete_icon.value_of_css_property('font-family') == 'FontAwesome', \
        delete_icon.value_of_css_property('font-family')
    assert delete_icon.value_of_css_property('color') == APERTA_GREY_DARK, \
        delete_icon.value_of_css_property('color')
    assert delete_icon.value_of_css_property('font-size') in ('14px', '18px'), \
        delete_icon.value_of_css_property('font-size')

  @staticmethod
  def validate_delete_icon_green(delete_icon):
    """
    Validate style of delete icon when mouse over (trash bin)
    :return: None
    """
    assert delete_icon.value_of_css_property('font-family') == 'FontAwesome', \
        delete_icon.value_of_css_property('font-family')
    assert delete_icon.value_of_css_property('color') == APERTA_GREEN, \
        delete_icon.value_of_css_property('color')
    assert delete_icon.value_of_css_property('font-size') in ('14px', '18px'), \
        delete_icon.value_of_css_property('font-size')

  def click_recent_activity_link(self):
    """
    Open the Recent Activity Modal from the Workflow page
    :return: void function
    """
    recent_activity = self._get(self._recent_activity)
    recent_activity.click()
    # Time to allow the model to animate into place
    time.sleep(1)

  def click_profile_link(self):
    """Click nav toolbar profile link"""
    self.click_profile_nav()
    self._get(self._nav_profile_link).click()
    return self

  def click_dashboard_link(self):
    """Click nav toolbar dashboard link"""
    self._get(self._nav_dashboard_link).click()
    return self

  def click_paper_tracker_link(self):
    """Click nav toolbar paper tracker link"""
    self._get(self._nav_paper_tracker_link).click()
    return self

  def click_admin_link(self):
    """Click nav toolbar admin link"""
    self._get(self._nav_admin_link).click()
    return self

  def click_sign_out_link(self):
    """Click nav toolbar sign out link"""
    self.click_profile_nav()
    self._get(self._nav_signout_link).click()
    return self

  def click_feedback_link(self):
    """Click nav toolbar feedback link"""
    self._get(self._nav_feedback_link).click()
    return self

  def logout(self):
    """Logout from any page"""
    url = self._driver.current_url
    signout_url = url.split('/')[0] + '//' + url.split('/')[2] + '/users/sign_out'
    self._driver.get(signout_url)

  def close_sheet(self):
    """
    Close overlaping sheet by clicking the upper right X
    """
    self._get(self._sheet_close_x).click()

  def go_to_manuscript(self, short_doi):
    """
    Navigate to the manuscript viewer page of the provided short doi
    :param short_doi: papers.short_doi of the requested paper
    :return: void function
    """
    time.sleep(5)
    url = self._driver.current_url
    url = url.split('/')[0] + '//' + url.split('/')[2] + '/papers/' + short_doi
    self._driver.get(url)

  def validate_ihat_conversions_success(self, timeout=104, fail_on_missing=False):
    """
    Validate ihat conversion success, or display of failure message or no message at all
    :param timeout: alternate timeout (optional)
    :param fail_on_missing: boolean, defaults to False. If True error on no or fail msg display,
       else warn only.
    :return: void function
    """
    # This needs to be an extraordinary timeout value to cover the case of iHat
    #  going out to lunch. 103+ seconds is the longest I've seen it take and still
    #  succeed:
    # 934edb97-2a49-4028-9523-25f1d31f7dcc
    # 2016-04-07T00:35:52Z   2016-04-07T00:35:53Z   11 of 11   103.04s completed
    self.set_timeout(timeout)
    success_msg = ''
    failure_msg = ''
    if not fail_on_missing:
      try:
        success_msg = self._get(self._flash_success_msg)
      except ElementDoesNotExistAssertionError:
        logging.warning('No successful conversion result message displayed')
        self.set_timeout(1)
        try:
          failure_msg = self._get(self._flash_error_msg)
          logging.warning(u'Conversion failure result message displayed: '
                          '{0}'.format(failure_msg.text))
        except ElementDoesNotExistAssertionError:
          logging.warning('No conversion result message displayed at all')
    else:
      success_msg = self._get(self._flash_success_msg)
      assert 'Finished loading Word file.' or 'Finished loading PDF file.' in success_msg.text, \
          success_msg.text
    if success_msg or failure_msg:
      try:
        self.close_flash_message()
      except WebDriverException:
        logging.warning('Flash message closer is inaccessible - probably under the toolbar')
    self.restore_timeout()

  def validate_ihat_conversions_failure(self):
    """
    Validate ihat conversion failure
    """
    self.set_timeout(30)
    ihat_msg = self._get(self._flash_error_msg)
    self.restore_timeout()
    assert 'There was an error loading your Word file.' in ihat_msg.text, ihat_msg.text

  def check_for_flash_error(self):
    """
    Check that any process (submit, save, send, etc) did not trigger a flash error
    :return: void function
    """
    error_msg = ''
    self.set_timeout(3)
    try:
      # no need to include the closer character in message
      error_msg = self._get(self._flash_error_msg).text.strip(u'\xd7')
    except ElementDoesNotExistAssertionError:
      self.restore_timeout()
    if isinstance(error_msg, unicode):
      error_msg_string = error_msg.encode()
    else:
      error_msg_string = error_msg
    if error_msg:
      # For the time being, capturing the error message and continuing rather than failing
      #   and stopping the test is of greater importance. At some point we may want to enforce
      #   this failure, so leaving it in place.
      # raise ElementExistsAssertionError('Error Message found: {0}'.format(error_msg_string))
      logging.error('Error Message found: {0}'.format(error_msg_string))

  def check_for_flash_success(self, timeout=15):
    """
    Check that any process (submit, save, send, etc) triggered a flash success message
    use where we are supposed to explicitly put up a success message - though not for
    new manuscript creation - there is a custom method for that.
    :param timeout: a time in seconds to wait for the success message (optional, default 15s)
    :return: text of flash success message
    """
    self.set_timeout(timeout)
    success_msg = self._get(self._flash_success_msg)
    time.sleep(.5)
    return success_msg.text

  def close_flash_message(self):
    """
    Close any type of flash message: error, info or success
    :return: void function
    """
    self.set_timeout(15)
    self._get(self._flash_closer).click()
    self.restore_timeout()

  def close_modal(self):
    """
    Close any type of modal
    :return: None
    """
    self._wait_for_element(self._get(self._overlay_header_close))
    self._get(self._overlay_header_close).click()

  def get_short_doi(self):
    """
    A method to extract the short doi from the current page url
    :return: short doi, a string
    """
    count = 0
    short_doi = self.get_current_url().split('/')[-1]
    while not short_doi:
      if count > 60:
        raise (StandardError, 'Short doi is not updated after a minute, aborting')
      time.sleep(1)
      short_doi = self.get_current_url().split('/')[-1]
      count += 1
    short_doi = short_doi.split('?')[0] if '?' in short_doi else short_doi
    logging.info("Assigned paper short doi: {0}".format(short_doi))
    return short_doi

  @staticmethod
  def get_journal_name_from_short_doi(short_doi):
    """
    A method to return the paper id from the database via a query on the short_doi
    :param short_doi: The short doi available from the URL of a paper and also the short_url in db
    :return: paper.id from db, an integer
    """
    journal_id = PgSQL().query('SELECT journal_id '
                               'FROM papers WHERE short_doi = %s;', (short_doi,))[0][0]
    return PgSQL().query('SELECT name FROM journals WHERE id = %s;', (journal_id,))[0][0]

  @staticmethod
  def get_paper_id_from_short_doi(short_doi):
    """
    A method to return the paper id from the database via a query on the short_doi
    :param short_doi: The short doi available from the URL of a paper and also the short_url in db
    :return: paper.id from db, an integer
    """
    paper_id = PgSQL().query('select id from papers where short_doi = %s;', (short_doi,))[0][0]
    return paper_id

  @staticmethod
  def get_db_submission_data(short_doi):
    """
    Provided a manuscript ID, queries the database for current publishing_state, gradual_engagement
      state, and any submitted_at date/time object if present
    :param short_doi: short_doi of paper to query
    :return: a tuple of (publishing_state, gradual_engagement (boolean), submitted_at (date/time))
    """
    submission_data = PgSQL().query('SELECT publishing_state, gradual_engagement, submitted_at '
                                    'FROM papers '
                                    'WHERE short_doi = %s;', (short_doi,))
    return submission_data

  def click_card(self, cardname, title=''):
    """
    Passed a card name, opens the relevant card
    :param cardname: any one of: addl_info, authors, billing, changes_for_author,
      competing_interests, cover_letter, data_availability, ethics_statement, figures,
      financial_disclosure, new_taxon, reporting_guidelines, reviewer_candidates, revise_task,
      supporting_info, upload_manuscript, assign_admin, assign_team, editor_discussion,
      final_tech_check, initial_decision, invite_academic_editor, invite_reviewers,
      production_metadata, register_decision, reviewer_report, revision_tech_check or send_to_apex
    :param title: String with card title to rule out when there are cards with the same name
    NOTE: this does not cover the ad hoc card
    NOTE also that the locators for these are specifically defined within the scope of the
        manuscript_viewer or workflow page
    NOTE: Note this method is bifurcated into click_card() and click_task() to support both the
        manuscript view and workflow contexts.

    :return: True or False, if cardname is unknown.
    """
    # Must give cards time to load/attach to DOM
    self.set_timeout(15)
    # 'Author-type' cards
    if cardname.lower() == 'addl_info':
      card_title = self._get(self._addl_info_card)
    elif cardname.lower() == 'authors':
      card_title = self._get(self._authors_card)
    elif cardname.lower() == 'billing':
      card_title = self._get(self._billing_card)
    elif cardname.lower() == 'changes_for_author':
      card_title = self._get(self._cfa_card)
    elif cardname.lower() == 'competing_interests':
      card_title = self._get(self._competing_ints_card)
    elif cardname.lower() == 'cover_letter':
      card_title = self._get(self._cover_letter_card)
    elif cardname.lower() == 'data_availability':
      card_title = self._get(self._data_avail_card)
    elif cardname.lower() == 'early_article_posting':
      card_title = self._get(self._early_article_posting_card)
    elif cardname.lower() == 'ethics_statement':
      card_title = self._get(self._ethics_statement_card)
    elif cardname.lower() == 'figures':
      card_title = self._get(self._figures_card)
    elif cardname.lower() == 'financial_disclosure':
      card_title = self._get(self._fin_disclose_card)
    elif cardname.lower() == 'new_taxon':
      card_title = self._get(self._new_taxon_card)
    elif cardname.lower() == 'reporting_guidelines':
      card_title = self._get(self._report_guide_card)
    elif cardname.lower() == 'review_by' and title:
      cards = self._gets(self._reviewed_by_card)
      for card in cards:
        if title == card.text:
          card_title = card
          break
      else:
        logging.info('Reviewer card not found')
        self.restore_timeout()
        return False
    elif cardname.lower() == 'reviewer_candidates':
      card_title = self._get(self._review_cands_card)
    elif cardname.lower() == 'revise_task':
      card_title = self._get(self._revise_task_card)
    elif cardname.lower() == 'supporting_info':
      card_title = self._get(self._supporting_info_card)
    elif cardname.lower() == 'upload_manuscript':
      card_title = self._get(self._upload_manu_card)
    # 'staff/editorial-type cards
    elif cardname.lower() == 'assign_admin':
      card_title = self._get(self._assign_admin_card)
    elif cardname.lower() == 'assign_team':
      card_title = self._get(self._assign_team_card)
    elif cardname.lower() == 'editor_discussion':
      card_title = self._get(self._editor_discussion_card)
    elif cardname.lower() == 'final_tech_check':
      card_title = self._get(self._final_tech_check_card)
    elif cardname.lower() == 'initial_decision':
      card_title = self._get(self._initial_decision_card)
    elif cardname.lower() == 'invite_academic_editor':
      card_title = self._get(self._invite_ae_card)
    elif cardname.lower() == 'invite_reviewers':
      card_title = self._get(self._invite_reviewers_card)
    elif cardname.lower() == 'production_metadata':
      card_title = self._get(self._production_metadata_card)
    elif cardname.lower() == 'register_decision':
      card_title = self._get(self._register_decision_card)
    elif cardname.lower() == 'reviewer_report':
      card_title = self._get(self._reviewer_report_card)
    elif cardname.lower() == 'revision_tech_check':
      card_title = self._get(self._revision_tech_check_card)
    elif cardname.lower() == 'send_to_apex':
      card_title = self._get(self._send_to_apex_card)
    elif cardname.lower() == 'title_and_abstract':
      card_title = self._get(self._title_abstract_card)
    else:
      logging.info('Unknown Card')
      self.restore_timeout()
      return False
    card_title.find_element_by_xpath('.//ancestor::a').click()
    self.restore_timeout()
    return True

  def click_discussion_link(self):
    """
    Click on discussion link
    :return: None
    """
    self._get(self._discussion_link).click()
    return None

  def post_new_discussion(self, topic='', msg='', mention='', participants=''):
    """
    Post a message on a new discussion
    :param topic: Topic to post. If empty, will post a random text.
    :param msg: Message to post. If empty, will post a random text.
    :param mention: User to mention. A string with the username.
    :param participants: List of participants to add, each element in the list is
    a user object.
    :return: None.
    """
    participants = participants or []
    self.click_discussion_link()
    self._get(self._create_new_topic).click()
    time.sleep(1)
    topic_title = self._get(self._topic_title_field)
    if topic:
      topic_title.send_keys(topic)
    else:
      topic_title.send_keys(generate_paragraph()[2][15])
    msg_body = self._get(self._message_body_field)
    if msg:
      msg_body.send_keys(msg + ' ')
    else:
      msg_body.send_keys(generate_paragraph()[2] + ' ')
    if mention:
      # Note: At this stage only Staff users can be mentioned.
      msg_body.send_keys('@' + mention)
      time.sleep(1)
      msg_body.send_keys(Keys.ARROW_DOWN + Keys.ENTER)
    time.sleep(1)
    self._get(self._create_topic).click()
    time.sleep(1)
    if participants:
      for participant in participants:
        user_search_string = random.choice(['name',
                                            #'email', APERTA-8243
                                            'user'])
        logging.info('Participant key to retrieve user: {0}'.format(user_search_string))
        logging.info('Participant to add: {0}'.format(participant))
        try:
          self._get(self._add_participant_btn).click()
        except ElementDoesNotExistAssertionError:
          raise(ElementDoesNotExistAssertionError, 'This may fail when the user names has '
            'less than 3 character, we don\'t expect this to happend with current dataset.'
            ' Reported in APERTA-7862')
        time.sleep(.5)
        participant_field = self._get(self._participant_field)
        participant_field.send_keys(participant[user_search_string])
        time.sleep(.5)
        participant_field.send_keys(Keys.ENTER)
    return None

  def post_discussion(self, msg='', mention=''):
    """
    Post a message on an ongoing discussion
    :param msg: Message to post. If empty, will post a random text.
    :param mention: User to mention. A string with the username.
    :return: None.
    """
    try:
      self._wait_for_element(self._get(self._first_discussion_lnk))
    except ElementDoesNotExistAssertionError:
      raise(ElementDoesNotExistAssertionError, 'This may be caused by APERTA-7902')
    first_disc_link = self._get(self._first_discussion_lnk)
    first_disc_link.click()
    time.sleep(.5)
    # This shouldn't make baby Jesus cry, since there is good reason for this:
    # make textarea visible. Selenium won't do it because running JS is not
    # part of a regular user interaction. Inserting JS is a valid hack when
    # there is no other way to make this work. Ticket for this: APERTA-8344
    js_cmd = "document.getElementsByClassName('comment-board-form')[0].className += ' editing'"
    self._driver.execute_script(js_cmd);
    time.sleep(2)
    msg_body = self._get(self._message_body_field)
    msg_body.send_keys(msg + ' ')
    time.sleep(1)
    if mention:
      msg_body.send_keys('@' + mention)
      time.sleep(1)
      msg_body.send_keys(Keys.ARROW_DOWN + Keys.ENTER)
    post_message_btn = (By.CSS_SELECTOR, 'div.editing button')
    try:
      self._get(post_message_btn).click()
    except ElementDoesNotExistAssertionError:
      raise(ElementDoesNotExistAssertionError, 'This may be caused due to dynamic buttons '
        'not always showing up for selenium. Reported in APERTA-8344')
    return None

  def get_mention(self, user):
    """
    Get the object of a mention
    :param user: String with username
    :return: object of a mention
    """
    comment_body = self._get(self._comment_body)
    mentions = comment_body.find_elements(*self._mention)
    for mention in mentions:
      if mention.text[1:] == user:
        return mention
    raise Exception(u'{0} not found'.format(user))

  def validate_withdraw_banner(self, journal):
    """
    A method to validate the withdraw banner. Only valid in the context of either the paper_viewer
      or the workflow page.
    :param journal: The name of the journal from which the manuscript was withdrawn. A string.
    :return: void function
    """
    withdraw_banner = self._get(self._withdraw_banner)
    assert 'This paper has been withdrawn from {0} and is in View Only mode'.format(journal) in \
          withdraw_banner.text, 'Banner text is not correct: {0}'.format(withdraw_banner.text)
    assert withdraw_banner.value_of_css_property('background-color') == 'rgba(135, 135, 135, 1)', \
        withdraw_banner.value_of_css_property('background-color')
    assert withdraw_banner.value_of_css_property('color') == 'rgba(255, 255, 255, 1)', \
        withdraw_banner.value_of_css_property('color')
    assert APPLICATION_TYPEFACE in withdraw_banner.value_of_css_property('font-family'), \
        withdraw_banner.value_of_css_property('font-family')

  def scroll_element_into_view_below_toolbar(self, element):
    """
    Because the Manuscript toolbar obscures content, we need a method specifically to scroll an
      element to the top and then down below the toolbar.
    :param element: webelement to scroll to
    :return: void function
    """
    self._driver.execute_script("javascript:arguments[0].scrollIntoView()", element)
    # This delay seems to be needed for the second call to succeed
    time.sleep(1)
    # using 2x the height of the toolbar as for items like images, the positioning can "receded"
    self._driver.execute_script("javascript:scrollBy(0,-120)")
    time.sleep(1)

  def click_covered_element(self, element):
    """
    Because the Manuscript toolbar obscures content, we need a method specifically to click
    on element without click on that is on top. This breaks Selenium prevision on not
    clicking in elements that a regular user will not be able to click, so use it only for
    non core test component. Consider this a Konami like cheatcode for development purposes.
    :param element: webelement to receive the click
    :return: None
    """
    logging.debug('{0} is covered by the toolbar...'.format(element))
    self._driver.execute_script("javascript:arguments[0].click()", element)
    return None

  def scroll_by_pixels(self, pixels):
    """
    A generic method to scroll by x pixels (positive - down) or (negative - up)
    :return: void function
    """
    self._driver.execute_script('javascript:scrollBy(0,{0})'.format(pixels))
    time.sleep(1)

  def validate_recent_activity_entry(self, msg, full_name=''):
    """
    Confirms that msg is present in the workflow recent activity feed, executed by full name
    :param msg: The recent activity message you wish to validate
    :param full_name: the full name of the executing user. If not present, only validate message.
    :return: boolean, true if found
    """
    msg_match = False
    name_match = False
    ra_entries = self._gets(self._recent_activity_table_row)
    for ra_entry in ra_entries:
      try:
        assert msg in self._get(self._recent_activity_table_msg).text
        logging.info('Workflow RA message '
                     'match found: {0}'.format(self._get(self._recent_activity_table_msg).text))
        msg_match = True
        if full_name:
          try:
            assert full_name in self._get(self._recent_activity_table_user_full_name).text
            logging.info('Workflow RA name match found: {0}'.format(
                self._get(self._recent_activity_table_user_full_name).text))
            return True
          except AssertionError:
            continue
      except AssertionError:
        continue
    if not full_name:
      if msg_match:
        return True
      else:
        return False

  def close_overlay(self):
    """
    Close the overlay modals
    :return: void function
    """
    close_btn = self._get(self._overlay_header_close)
    close_btn.click()
    # time to allow the modal to animate away
    time.sleep(1)
