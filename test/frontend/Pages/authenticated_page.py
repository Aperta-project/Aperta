#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import WebDriverException

from loremipsum import generate_paragraph

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PlosPage import PlosPage
from Base.PostgreSQL import PgSQL
from Base.Resources import staff_admin_login, super_admin_login, \
    internal_editor_login, prod_staff_login, pub_svcs_login

__author__ = 'jgray@plos.org'

# Variable definitions

# typefaces
application_typeface = 'source-sans-pro'
manuscript_typeface = 'lora'
# colors
aperta_green = 'rgba(57, 163, 41, 1)'
aperta_green_light = 'rgba(142, 203, 135, 1)'
aperta_green_dark = 'rgba(15, 116, 0, 1)'
aperta_blue = 'rgba(45, 133, 222, 1)'
aperta_blue_light = 'rgba(148, 184, 224, 1)'
aperta_blue_dark = 'rgba(32, 94, 156, 1)'
aperta_grey_xlight = 'rgba(245, 245, 245, 1)'
aperta_grey_medlight = 'rgba(228, 228, 228, 1)'
aperta_grey_light = 'rgba(213, 213, 213, 1)'
aperta_grey_dark = 'rgba(135, 135, 135, 1)'
aperta_black = 'rgba(51, 51, 51, 1)'
aperta_error = 'rgba(206, 11, 36, 1)'
white = 'rgba(255, 255, 255, 1)'
aperta_flash_error = 'rgba(122, 51, 78, 1)'
aperta_flash_error_bkgrnd = 'rgba(230, 221, 210, 1)'
aperta_flash_success = aperta_green
aperta_flash_success_bkgrnd = 'rgba(234, 253, 231, 1)'
aperta_flash_info = 'rgba(146, 139, 113, 1)'
aperta_flash_info_bkgrnd = 'rgba(242, 242, 213, 1)'


class AuthenticatedPage(PlosPage):
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
    self._nav_profile_menu_toggle = (By.ID, 'profile-dropdown-menu')
    self._nav_profile_img = (By.CSS_SELECTOR, 'span.main-nav-item img')
    self._nav_profile_text = (By.CLASS_NAME, 'profile-dropdown-menu-text')
    self._nav_profile_link = (By.ID, 'nav-profile')
    self._nav_signout_link = (By.ID, 'nav-signout')
    # Global toolbar Icons
    self._toolbar_items = (By.CLASS_NAME, 'control-bar-inner-wrapper')
    self._editable_label = (By.CSS_SELECTOR, 'label.control-bar-item')
    self._editable_checkbox = (By.ID, 'nav-paper-editable')
    self._recent_activity = (By.ID, 'nav-recent-activity')
    self._recent_activity_label = (By.CSS_SELECTOR, 'div.control-bar-link')
    self._discussion_link = (By.ID, 'nav-discussions')
    self._discussions_icon = (By.CSS_SELECTOR, 'a.control-bar-item--last div')
    self._discussions_label = (By.CSS_SELECTOR, 'div.control-bar-item + a.control-bar-item')
    # TODO: Change this when APERTA-5531 is completed
    self._control_bar_right_items = (By.CLASS_NAME, 'control-bar-item')
    self._bar_items = (By.CSS_SELECTOR, 'div#versioning-bar.toot div.bar-item')
    self._recent_activity_modal = (By.CLASS_NAME, 'activity-overlay')
    self._recent_activity_modal_title = (By.CSS_SELECTOR, 'h1.overlay-header-title')
    self._discussion_container = (By.CLASS_NAME, 'liquid-container')
    self._discussion_container_title = (By.CSS_SELECTOR, 'div.discussions-index-header h1')
    # Discussion related items
    self._discussion_create_new_btn = (By.CSS_SELECTOR, 'div.discussions-index-header a')
    self._create_new_topic = (By.CSS_SELECTOR, 'div.discussions-index-header a')
    self._topic_title_field = (By.CSS_SELECTOR, 'input')
    self._create_topic = (By.CSS_SELECTOR, 'div.sheet-content button')
    self._add_participant_btn = (By.CLASS_NAME, 'add-participant-button')
    self._participant_field = (By.CSS_SELECTOR, 'input.active')
    self._message_body_div = (By.CSS_SELECTOR, 'div.comment-board-form')
    self._message_body_field = (By.CSS_SELECTOR, 'textarea')
    self._post_message_btn = (By.CSS_SELECTOR, 'button')
    self._first_discussion_lnk = (By.CLASS_NAME, 'discussions-index-topic')
    self._topic_title = (By.CSS_SELECTOR, 'div.inset-form-control')
    self._create_topic_btn = (By.CSS_SELECTOR, 'div.discussions-show-content button')
    self._create_topic_cancel = (By.CSS_SELECTOR, 'span.sheet-toolbar-button')
    self._sheet_close_x = (By.CLASS_NAME, 'sheet-close-x')
    # Discussion messages
    self._badge_red = (By.CSS_SELECTOR, 'span.badge--red')
    self._comment_sheet_badge_red = (By.CSS_SELECTOR, 'div.sheet-content span.badge--red')
    # Flash Messages
    self._flash_success_msg = (By.CSS_SELECTOR, 'div.flash-message--success div.flash-message-content')
    self._flash_error_msg = (By.CSS_SELECTOR, 'div.flash-message--error div.flash-message-content')
    self._flash_closer = (By.CLASS_NAME, 'flash-message-remove')
    # Task list id needed in task and manuscript page
    self._paper_sidebar_manuscript_id = (By.CLASS_NAME, 'task-list-doi')
    # Cards - placeholder locators - these are over-ridden by definitions in the workflow and manuscript_viewer pages
    self._addl_info_card = None
    self._authors_card = None
    self._billing_card = None
    self._cfa_card = None
    self._competing_ints_card = None
    self._cover_letter_card = None
    self._data_avail_card = None
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
    self._invite_academic_editors_card = None
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
    self._data_avail_task = None
    self._ethics_statement_task = None
    self._figures_task = None
    self._fin_disclose_task = None
    self._new_taxon_task = None
    self._report_guide_task = None
    self._review_cands_task = None
    self._revise_task = None
    self._supporting_info_task = None
    self._upload_manu_task = None
    # Global Overlay Locators
    self._overlay_header_title = (By.CLASS_NAME, 'overlay-header-title')
    self._overlay_header_close = (By.CLASS_NAME, 'overlay-close')
    self._overlay_action_button_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a.button-link')
    self._overlay_action_button_save = (By.CSS_SELECTOR, 'div.overlay-action-buttons button.button-primary')

  # POM Actions
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
    # assert editable.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    # assert editable.value_of_css_property('font-weight') == '700'
    # assert application_typeface in editable.value_of_css_property('font-family')
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
    # assert recent_activity_icon.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    recent_activity_text = self._get(self._recent_activity_label)
    assert recent_activity_text
    assert 'Recent Activity' in recent_activity_text.text, recent_activity_text.text
    # assert recent_activity_text.value_of_css_property('font-size') == '10px'
    # assert recent_activity_text.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    # assert recent_activity_text.value_of_css_property('font-weight') == '700'
    # assert application_typeface in recent_activity_text.value_of_css_property('font-family')
    # assert recent_activity_text.value_of_css_property('text-transform') == 'uppercase'
    # assert recent_activity_text.value_of_css_property('line-height') == '20px'
    # assert recent_activity_text.value_of_css_property('text-align') == 'center'
    discussions_icon = self._get(self._discussions_icon)
    assert discussions_icon
    # assert discussions_icon.value_of_css_property('font-family') == 'FontAwesome'
    # assert discussions_icon.value_of_css_property('font-size') == '16px'
    # assert discussions_icon.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    # assert discussions_icon.value_of_css_property('font-weight') == '400'
    # assert discussions_icon.value_of_css_property('text-transform') == 'uppercase'
    # assert discussions_icon.value_of_css_property('font-style') == 'normal'
    discussions_label = self._get(self._discussions_label)
    assert discussions_label
    assert discussions_label.text.lower() == 'discussions', discussions_label.text

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

  def go_to_manuscript(self, manuscript_id):
    """
    Navigate to the manuscript viewer page of the provided paper id
    :param manuscript_id: papers.id of the requested paper
    :return: void function
    """
    time.sleep(5)
    url = self._driver.current_url
    id_url = url.split('/')[0] + '//' + url.split('/')[2] + '/papers/' + str(manuscript_id)
    self._driver.get(id_url)

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
          logging.warning('Conversion failure result message displayed: '
                          '{0}'.format(failure_msg.text))
        except ElementDoesNotExistAssertionError:
          logging.warning('No conversion result message displayed at all')
    else:
      success_msg = self._get(self._flash_success_msg)
      assert 'Finished loading Word file.' in success_msg.text, success_msg.text
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
    self.set_timeout(15)
    try:
      error_msg = self._get(self._flash_error_msg)
    except ElementDoesNotExistAssertionError:
      self.restore_timeout()
    if isinstance(error_msg, unicode):
      error_msg_string = error_msg.decode('utf-8')
    else:
      error_msg_string = error_msg
    if error_msg:
      raise ElementExistsAssertionError('Error Message found: {0}'.format(error_msg_string))

  def check_for_flash_success(self):
    """
    Check that any process (submit, save, send, etc) triggered a flash success message
    use where we are supposed to explicitly put up a success message - though not for
    new manuscript creation - there is a custom method for that. Closes message, if found.
    :return: text of flash success message
    """
    self.set_timeout(15)
    success_msg = self._get(self._flash_success_msg)
    self.close_flash_message()
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
    self._get(self._overlay_header_close).click()

  @staticmethod
  def get_db_submission_data(manu_id):
    """
    Provided a manuscript ID, queries the database for current publishing_state, gradual_engagement
      state, and any submitted_at date/time object if present
    :param manu_id: ID of paper to query
    :return: a tuple of (publishing_state, gradual_engagement (boolean), submitted_at (date/time))
    """
    submission_data = PgSQL().query('SELECT publishing_state, gradual_engagement, submitted_at '
                                    'FROM papers '
                                    'WHERE id = %s;', (manu_id,))
    return submission_data

  def click_card(self, cardname):
    """
    Passed a card name, opens the relevant card
    :param cardname: any one of: addl_info, authors, billing, changes_for_author,
      competing_interests, cover_letter, data_availability, ethics_statement, figures,
      financial_disclosure, new_taxon, reporting_guidelines, reviewer_candidates, revise_task,
      supporting_info, upload_manuscript, assign_admin, assign_team, editor_discussion,
      final_tech_check, initial_decision, invite_academic_editor, invite_reviewers,
      production_metadata, register_decision, reviewer_report, revision_tech_check or send_to_apex
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
      card_title = self._get(self._cover_letter_card)
    elif cardname.lower() == 'changes_for_author':
      card_title = self._get(self._cfa_card)
    elif cardname.lower() == 'competing_interests':
      card_title = self._get(self._competing_ints_card)
    elif cardname.lower() == 'cover_letter':
      card_title = self._get(self._billing_card)
    elif cardname.lower() == 'data_availability':
      card_title = self._get(self._data_avail_card)
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
      card_title = self._get(self._invite_academic_editors_card)
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
      print('Unknown Card')
      self.restore_timeout()
      return False
    card_title.find_element_by_xpath('.//ancestor::a').click()
    self.restore_timeout()
    return True

  def click_task(self, taskname):
    """
    Passed a task name, opens the relevant task
    :param taskname: any one of: cover_letter, billing, figures, authors, supporting_info, upload_manuscript, addl_info,
        reviewer_candidates, revise_task, competing_interests, data_availability, ethics_statement, financial_disclosure,
        new_taxon, reporting_guidelines, changes_for_author
    NOTE: this covers only the author facing tasks, with the exception of initial_decision
    NOTE also that the locators for these are specifically defined within the scope of the manuscript_viewer or
        workflow page
    NOTE: Note this method is temporarily bifurcated into click_card() and click_task() to support both the manuscript
        and workflow contexts while we transition.

    :return: True or False, if taskname is unknown.
    """
    if taskname.lower() == 'addl_info':
      task_title = self._get(self._addl_info_task)
    elif taskname.lower() == 'billing':
      task_title = self._get(self._billing_task)
    elif taskname.lower() == 'cover_letter':
      task_title = self._get(self._cover_letter_task)
    elif taskname.lower() == 'figures':
      task_title = self._get(self._figures_task)
    elif taskname.lower() == 'authors':
      task_title = self._get(self._authors_task)
    elif taskname.lower() == 'supporting_info':
      task_title = self._get(self._supporting_info_task)
    elif taskname.lower() == 'upload_manuscript':
      task_title = self._get(self._upload_manu_task)
    elif taskname.lower() == 'review_candidates':
      task_title = self._get(self._review_cands_task)
    elif taskname.lower() == 'revise_task':
      task_title = self._get(self._revise_task)
    elif taskname.lower() == 'competing_interests':
      task_title = self._get(self._competing_ints_task)
    elif taskname.lower() == 'data_availability':
      task_title = self._get(self._data_avail_task)
    elif taskname.lower() == 'ethics_statement':
      task_title = self._get(self._ethics_statement_task)
    elif taskname.lower() == 'financial_disclosure':
      task_title = self._get(self._fin_disclose_task)
    elif taskname.lower() == 'new_taxon':
      task_title = self._get(self._new_taxon_task)
    elif taskname.lower() == 'reporting_guidelines':
      task_title = self._get(self._report_guide_task)
    elif taskname.lower() == 'changes_for_author':
      task_title = self._get(self._cfa_task)
    elif taskname.lower() == 'initial_decision':
      task_title = self._get(self._initial_decision_card)
    else:
      print('Unknown Task')
      return False
    # For whatever reason, selenium can't grok a simple click() here
    self._actions.click_and_hold(task_title).release().perform()
    return True

  def post_new_discussion(self, topic='', msg='', participants=None):
    """
    Post a message on a new discussion
    :param topic: Topic to post. If empty, will post a random text.
    :param msg: Message to post. If empty, will post a random text.
    :param participants: List of participants to add
    :return: None.
    """
    participants = participants or []
    self._get(self._discussion_link).click()
    self._get(self._create_new_topic).click()
    time.sleep(.5)
    if topic:
      self._get(self._topic_title_field).send_keys(topic)
    else:
      self._get(self._topic_title_field).send_keys(generate_paragraph()[2][15])
    # create topic btn
    time.sleep(.5)
    self._get(self._create_topic).click()
    # add paper creator to the discussion
    if participants:
      # the_creator (tm)
      for participant in participants:
        self._get(self._add_participant_btn).click()
        time.sleep(.5)
        self._get(self._participant_field).send_keys(participant + Keys.ENTER)
        time.sleep(5)
        self._get(self._participant_field).send_keys(Keys.ARROW_DOWN + Keys.ENTER)
    time.sleep(.5)
    js_cmd = "document.getElementsByClassName('comment-board-form')[0].className += ' editing'"
    self._driver.execute_script(js_cmd)
    time.sleep(.5)
    msg_body = self._get(self._message_body_field)
    if msg:
      msg_body.send_keys(msg)
    else:
      msg_body.send_keys(generate_paragraph()[2])
    time.sleep(1)
    post_message_btn = (By.CSS_SELECTOR, 'div.editing button')
    self._get(post_message_btn).click()
    return None

  def post_discussion(self, msg=''):
    """
    Post a message on an ongoing discussion
    :param msg: Message to post. If empty, will post a random text.
    :return: None.
    """
    self._get(self._discussion_link).click()
    # click on first discussion
    self._get(self._first_discussion_lnk).click()
    time.sleep(.5)
    # This shouldn't make baby Jesus cry, since there is good reason for this:
    # make textarea visible. Selenium won't do it because running JS is not
    # part of a regular user interaction. Inserting JS is a valid hack when
    # there is no other way to make this work
    js_cmd = "document.getElementsByClassName('comment-board-form')[0].className += ' editing'"
    self._driver.execute_script(js_cmd);
    time.sleep(.5)
    msg_body = self._get(self._message_body_field)
    msg_body.send_keys(msg)
    time.sleep(1)
    post_message_btn = (By.CSS_SELECTOR, 'div.editing button')
    self._get(post_message_btn).click()
    return None

  # Style Validations
  # Divider and Border Styles ===========================
  @staticmethod
  def validate_light_background_border(border):
    """
    This border style is used against the $color-light variants only
    :param border: border
    :return: Void function
    """
    # This color is not represented in the tahi palette
    assert border.value_of_css_property('color') == 'rgba(128, 128, 128, 1)', border.value_of_css_property('color')
    assert border.value_of_css_property('background-color') in (aperta_green_light, aperta_blue_light, aperta_grey_light), \
        border.value_of_css_property('background-color')

  @staticmethod
  def validate_standard_border(border):
    """
    This border style is used against all but the light color variants.
    :param border: border
    :return: Void function
    """
    # This color is not represented in the tahi palette
    assert border.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', border.value_of_css_property('color')

  # Heading Styles ===========================
  @staticmethod
  def validate_application_title_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    Not used for the Manuscript Title!
    :param title: title to validate
    Updated for new style guide: https://app.zeplin.io/project.html
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '48px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '52.8px', title.value_of_css_property('line-height')
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_application_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '33px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_application_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '26.4px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_application_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '19.8px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_h1_style(title):
    """
    Ensure consistency in rendering page and overlay main headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '36px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '39.6px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings within the manuscript
    :param title: Title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '33px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '26.4px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  @staticmethod
  def validate_label_style(label):
    """
    Ensure consistency in rendering label style in cards
    :param title: title to validate
    """
    assert application_typeface in label.value_of_css_property('font-family'), \
        label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '18px', label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', label.value_of_css_property('font-weight')
    assert label.value_of_css_property('line-height') == '25.7167px', label.value_of_css_property('line-height')
    assert label.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', label.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '19.8px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  # This seems out of bounds - this should conform to one of the above styles - report as a bug
  @staticmethod
  def validate_profile_title_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: Void Function
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '15.4px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert title.value_of_css_property('color') == 'rgba(153, 153, 153, 1)', title.value_of_css_property('color')

  # This method is out of bounds and should not be here
  @staticmethod
  def validate_modal_title_style(title, font_size='14px', font_weight='400',
                                 line_height='20px', color='rgba(51, 51, 51, 1)'):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :param font_size
    :param font_weight
    :param line_height
    :param color
    :return: None
    TODO: APERTA-7212
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == font_size
    assert title.value_of_css_property('font-weight') == font_weight
    assert title.value_of_css_property('line-height') == line_height
    assert title.value_of_css_property('color') == color


  @staticmethod
  def validate_field_title_style(title):
    """
    Ensure consistency in rendering field titles across the application
    :param title: title to validate
    :return: None
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px', \
        title.value_of_css_property('font-size')
    assert title.value_of_css_property('line-height') == '20px', \
        title.value_of_css_property('line-height')
    assert title.value_of_css_property('font-weight') == '400', \
        title.value_of_css_property('font-weight')
    assert title.value_of_css_property('color') == 'rgba(135, 135, 135, 1)', \
        title.value_of_css_property('color')

  @staticmethod
  def validate_accordion_task_title(title):
    """
    Ensure consistency in rendering accordion headings across the application
    :param title: title to validate
    Updated for new style guide: https://app.zeplin.io/project.html
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('line-height') == '40px', title.value_of_css_property('line-height')
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', title.value_of_css_property('color')

  # Ordinary Text Styles ============================
  @staticmethod
  def validate_application_ptext(paragraph):
    """
    Ensure consistency in rendering application ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert application_typeface in paragraph.value_of_css_property('font-family'), \
        paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px', paragraph.value_of_css_property('font-size')
    assert paragraph.value_of_css_property('font-weight') == '400', paragraph.value_of_css_property('font-weight')
    assert paragraph.value_of_css_property('line-height') == '20px', paragraph.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert paragraph.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', paragraph.value_of_css_property('color')

  @staticmethod
  def validate_manuscript_ptext(paragraph):
    """
    Ensure consistency in rendering manuscript ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert manuscript_typeface in paragraph.value_of_css_property('font-family'), \
        paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px', paragraph.value_of_css_property('font-size')
    assert paragraph.value_of_css_property('font-weight') == '400', paragraph.value_of_css_property('font-weight')
    assert paragraph.value_of_css_property('line-height') == '20px', paragraph.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert paragraph.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', paragraph.value_of_css_property('color')

  # Link Styles ==============================
  @staticmethod
  def validate_default_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == aperta_green, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_profile_link_style(link):
    """
    Links valid in profile page
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == aperta_green, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '700', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_default_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == aperta_green, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')
    assert link.value_of_css_property('text-decoration') == 'underline', link.value_of_css_property('text-decoration')

  @staticmethod
  def validate_admin_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == aperta_blue, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  @staticmethod
  def validate_admin_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    assert link.value_of_css_property('color') == aperta_blue, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')
    assert link.value_of_css_property('text-decoration') == 'underline', link.value_of_css_property('text-decoration')

  @staticmethod
  def validate_disabled_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family'), link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px', link.value_of_css_property('font-size')
    assert link.value_of_css_property('line-height') == '20px', link.value_of_css_property('line-height')
    assert link.value_of_css_property('background-color') == 'transparent', \
        link.value_of_css_property('background-color')
    # This color is not represented in the tahi palette
    assert link.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

  # List Styles ==============================
  @staticmethod
  def validate_application_list_style(olul):
    """
    Ensure consistency in list presentation across the application
    :param olul: ol or ul
    :return: Void function
    """
    assert application_typeface in olul.value_of_css_property('font-family'), olul.value_of_css_property('font-family')
    assert olul.value_of_css_property('font-size') == '14px', olul.value_of_css_property('font-size')
    assert olul.value_of_css_property('line-height') == '20px', olul.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert olul.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', olul.value_of_css_property('color')

  # Button Styles ============================
  @staticmethod
  def validate_primary_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay large green-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_green, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay big white-backed, green text buttons across
      the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', \
        button.value_of_css_property('font-size')
    # APERTA-6498
    # assert button.value_of_css_property('line-height') == '18px', \
    #     button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_green, \
        button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', \
        button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', \
        button.value_of_css_property('text-transform')
    # APERTA-6498
    # assert button.value_of_css_property('padding-top') == '8px', \
    #     button.value_of_css_property('padding-top')
    # assert button.value_of_css_property('padding-bottom') == '8px', \
    #     button.value_of_css_property('padding-bottom')
    # assert button.value_of_css_property('padding-left') == '14px', \
    #     button.value_of_css_property('padding-left')
    # assert button.value_of_css_property('padding-right') == '14px', \
    #     button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_green, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small green-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_green, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, green text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('color') == aperta_green, button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_green, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '5px'
    assert button.value_of_css_property('padding-left') == '1px'
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, lighter grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_grey_light, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(238, 238, 238, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_grey_light, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_grey_light, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_green_on_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay light green-backed, dark green text buttons across the application.
    These buttons should be used against a standard aperta_green background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_green_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_green_light, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, white text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 119, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small grey-backed, white text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 19, 1)', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, grey text link-buttons across the
    application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_grey_on_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay light grey-backed, dark-grey text buttons across the application
    These should be used on a standard tahi_grey background only.
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_grey_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_grey_light, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_blue, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_blue, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_link_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_blue, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_primary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == white, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_blue, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_secondary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('color') == aperta_blue, button.value_of_css_property('color')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')

  @staticmethod
  def validate_link_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, blue text link-buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_blue, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == 'transparent', \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('text-align') == 'center', button.value_of_css_property('text-align')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('padding-top') == '1px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-left') == '5px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-bottom') == '1px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-right') == '5px', button.value_of_css_property('padding-right')

  @staticmethod
  def validate_blue_on_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay light blue-backed, dark-blue text buttons across the application
    These should only be used against a standard aperta_blue background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == aperta_blue_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == aperta_blue_light, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  # Form Styles ==============================
  @staticmethod
  def validate_input_field_inside_label_style(label):
    """
    Ensure consistency in rendering page, card and overlay input field labels across the application
    :param label: label to validate
    """
    assert application_typeface in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', \
        label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', \
        label.value_of_css_property('font-weight')
    # This color is not represented in the tahi palette
    assert label.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', \
        label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', \
        label.value_of_css_property('line-height')

  @staticmethod
  def validate_input_field_style(field):
    """
    Ensure consistency in rendering page, card and overlay input fields across the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', \
        field.value_of_css_property('font-weight')
    assert field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')

  @staticmethod
  def validate_single_select_dropdown_style(field):
    """
    Ensure consistency in rendering page, card and overlay single select drop down fields across
      the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', \
        field.value_of_css_property('font-weight')
    assert field.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '18px', \
        field.value_of_css_property('line-height')
    assert field.value_of_css_property('padding-top') == '6px', \
        field.value_of_css_property('padding-top')
    assert field.value_of_css_property('padding-bottom') == '6px', \
        field.value_of_css_property('padding-bottom')
    assert field.value_of_css_property('padding-left') == '11px', \
        field.value_of_css_property('padding-left')
    assert field.value_of_css_property('padding-right') == '12px',\
        field.value_of_css_property('padding-left')

  @staticmethod
  def validate_multi_select_dropdown_style(field):
    """
    Ensure consistency in rendering page, card and overlay multi-select drop down fields across the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', field.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert field.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', field.value_of_css_property('line-height')
    assert field.value_of_css_property('text-overflow') == 'ellipsis', field.value_of_css_property('text-overflow')
    assert field.value_of_css_property('margin-right') == '26px', field.value_of_css_property('margin-right')

  @staticmethod
  def validate_textarea_style(field):
    """
    Ensure consistency in rendering page, card and overlay textarea fields across the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', field.value_of_css_property('font-weight')
    assert field.value_of_css_property('font-style') == 'normal', field.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', field.value_of_css_property('line-height')
    assert field.value_of_css_property('background-color') == white, field.value_of_css_property('background-color')
    assert field.value_of_css_property('padding-top') == '6px', field.value_of_css_property('padding-top')
    assert field.value_of_css_property('padding-right') == '12px', field.value_of_css_property('padding-right')
    assert field.value_of_css_property('padding-bottom') == '6px', field.value_of_css_property('padding-bottom')
    assert field.value_of_css_property('padding-left') == '12px', field.value_of_css_property('padding-left')

  @staticmethod
  def validate_radio_button(button):
    """
    Ensure consistency in rendering page, card and overlay radio buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('font-style') == 'normal', button.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert button.value_of_css_property('color') == aperta_black, button.value_of_css_property('color')
    assert button.value_of_css_property('line-height') == '18px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('margin-top') == '4px', button.value_of_css_property('margin-top')

  @staticmethod
  def validate_radio_button_label(label):
    """
    Ensure consistency in rendering page, card and overlay radio button labels across the application
    :param label: label to validate
    """
    assert application_typeface in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', label.value_of_css_property('font-weight')
    assert label.value_of_css_property('font-style') == 'normal', label.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert label.value_of_css_property('color') == aperta_black, label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', label.value_of_css_property('line-height')


  @staticmethod
  def validate_checkbox(checkbox):
    """
    Ensure consistency in rendering page, card and overlay checkboxes across the application
    :param checkbox: checkbox to validate
    """
    assert application_typeface in checkbox.value_of_css_property('font-family')
    assert checkbox.value_of_css_property('font-size') == '14px', checkbox.value_of_css_property('font-size')
    assert checkbox.value_of_css_property('font-weight') == '400', checkbox.value_of_css_property('font-weight')
    assert checkbox.value_of_css_property('font-style') == 'normal', checkbox.value_of_css_property('font-style')
    # This color is not represented in the style guide
    assert checkbox.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', checkbox.value_of_css_property('color')
    assert checkbox.value_of_css_property('line-height') == '20px', checkbox.value_of_css_property('line-height')
    assert checkbox.value_of_css_property('margin-right') == '20px', checkbox.value_of_css_property('margin-right')
    assert checkbox.value_of_css_property('margin-bottom') == '5px', checkbox.value_of_css_property('margin-bottom')

  @staticmethod
  def validate_checkbox_label(label):
    """
    Ensure consistency in rendering page, card and overlay checkbox labels across the application
    :param label: label to validate
    """
    assert application_typeface in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', label.value_of_css_property('font-weight')
    assert label.value_of_css_property('vertical-align') == 'middle', label.value_of_css_property('vertical-align')
    # This color is not represented in the style guide
    assert label.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', label.value_of_css_property('line-height')
    assert label.value_of_css_property('margin-right') == '20px', label.value_of_css_property('margin-right')

  # Navigation Styles ========================
  # There are currently no defined navigation styles in the style guide

  # Error Styles =============================
  @staticmethod
  def validate_flash_info_style(msg):
    """
    Ensure consistency in rendering informational alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the tahi palette
    assert msg.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', msg.value_of_css_property('color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_error_style(msg):
    """
    Ensure consistency in rendering error alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    # assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide as a color and is not the color of the actual implementation
    # assert msg.value_of_css_property('color') == 'rgba(122, 51, 78, 1)', msg.value_of_css_property('color')
    # This color is not represented in the style guide
    # assert msg.value_of_css_property('background-color') == 'rgba(247, 239, 233, 1)', \
    #    msg.value_of_css_property('background-color')
    # assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    # assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    # assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    # assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_success_style(msg):
    """
    Ensure consistency in rendering success alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    assert msg.value_of_css_property('color') == aperta_green, msg.value_of_css_property('color')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)', \
        msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_warn_style(msg):
    """
    Ensure consistency in rendering warning alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('color') == 'rgba(146, 139, 113, 1)', msg.value_of_css_property('color')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == 'rgba(242, 242, 213, 1)', \
        msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_error_field_style(field):
    """
    Ensure consistency in rendering warning alerts across the application
    :field: field to validate
    """
    assert field.value_of_css_property('border-top-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-top-color')
    assert field.value_of_css_property('border-left-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-left-color')
    assert field.value_of_css_property('border-right-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-right-color')
    assert field.value_of_css_property('border-bottom-color') == 'rgba(206, 11, 37, 1)', \
        field.value_of_css_property('border-bottom-color')
    assert field.value_of_css_property('border-style') == 'solid', \
        field.value_of_css_property('border-style')
    assert field.value_of_css_property('border-radius') == '3px', \
        field.value_of_css_property('border-radius')

  @staticmethod
  def validate_error_msg_field_style(field):
    """
    Ensure consistency in rendering warning alerts across the application
    :field: field to validate
    """
    import pdb; pdb.set_trace()
    assert field.value_of_css_property('color')  == 'rgba(208, 2, 27, 1)', \
        field.value_of_css_property('color')
    assert field.value_of_css_property('font-size') == '14px', \
        field.value_of_css_property('font-size')
    assert field.value_of_css_property('line-height') == '20px', \
        field.value_of_css_property('line-height')

  # Avatar Styles =============================
  @staticmethod
  def validate_large_avatar_style(avatar):
    """
    Ensure consistency in rendering large avatars across the application
    :param avatar: avatar to validate
    """
    assert application_typeface in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '160px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '160px', avatar.value_of_css_property('height')

  @staticmethod
  def validate_large_avatar_hover_style(avatar):
    """
    Ensure consistency in rendering large avatar hover states across the application
    :param avatar: avatar to validate
    """
    assert application_typeface in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert avatar.value_of_css_property('color') == 'rgba(15, 116, 0, 1)', avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('background-color') == 'rgba(142, 203, 135, 1)', \
        avatar.value_of_css_property('background-color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')

  @staticmethod
  def validate_thumbnail_avatar_style(avatar):
    """
    Ensure consistency in rendering thumbnail avatars across the application
    :param avatar: avatar to validate
    """
    assert application_typeface in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '32px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '32px', avatar.value_of_css_property('height')

  @staticmethod
  def validate_small_thumbnail_avatar_style(avatar):
    """
    Ensure consistency in rendering thumbnail avatars across the application
    :param avatar: avatar to validate
    """
    assert application_typeface in avatar.value_of_css_property('font-family'), \
        avatar.value_of_css_property('font-family')
    assert avatar.value_of_css_property('font-size') == '14px', avatar.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert avatar.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', avatar.value_of_css_property('color')
    assert avatar.value_of_css_property('line-height') == '20px', avatar.value_of_css_property('line-height')
    assert avatar.value_of_css_property('vertical-align') == 'middle', avatar.value_of_css_property('vertical-align')
    assert avatar.value_of_css_property('width') == '25px', avatar.value_of_css_property('width')
    assert avatar.value_of_css_property('height') == '25px', avatar.value_of_css_property('height')

  # Activity Overlay Styles ==================
  # Why does this one overlay get it's own styles?
  @staticmethod
  def validate_activity_message_style(msg):
    """
    Ensure consistency in rendering activity list messages
    :param msg: activity message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-size'), msg.value_of_css_property('font-size')
    assert msg.value_of_css_property('font-size') == '17px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert msg.value_of_css_property('line-height') == 'rgba(51, 51, 51, 1)', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('line-height') == '24.2833px', msg.value_of_css_property('line-height')
    assert msg.value_of_css_property('padding-top') == '0px', msg.value_of_css_property('padding-top')
    assert msg.value_of_css_property('padding-right') == '15px', msg.value_of_css_property('padding-right')
    assert msg.value_of_css_property('padding-bottom') == '25px', msg.value_of_css_property('padding-bottom')
    assert msg.value_of_css_property('padding-left') == '0px', msg.value_of_css_property('padding-left')

  @staticmethod
  def validate_activity_timestamp_style(timestamp):
    """
    Ensure consistency in rendering activity list timestamps
    :param timestamp: timestamp to validate
    """
    assert application_typeface in timestamp.value_of_css_property('font-size'), \
        timestamp.value_of_css_property('font-size')
    assert timestamp.value_of_css_property('font-size') == '14px', timestamp.value_of_css_property('font-size')
    # This color is not represented in the style guide
    assert timestamp.value_of_css_property('line-height') == 'rgba(51, 51, 51, 1)', \
        timestamp.value_of_css_property('line-height')
    assert timestamp.value_of_css_property('line-height') == '20px', timestamp.value_of_css_property('line-height')
    assert timestamp.value_of_css_property('padding-top') == '0px', timestamp.value_of_css_property('padding-top')
    assert timestamp.value_of_css_property('padding-right') == '15px', timestamp.value_of_css_property('padding-right')
    assert timestamp.value_of_css_property('padding-bottom') == '25px', \
        timestamp.value_of_css_property('padding-bottom')
    assert timestamp.value_of_css_property('padding-left') == '0px', timestamp.value_of_css_property('padding-left')

  # Progress Styles ==========================
  @staticmethod
  def validate_progress_spinner_style(spinner):
    """
    Ensure consistency in rendering progress spinners across the application
    :param spinner: spinner to validate
    """
    assert application_typeface in spinner.value_of_css_property('font-family'), \
        spinner.value_of_css_property('font-family')
    assert spinner.value_of_css_property('font-size') == '14px', spinner.value_of_css_property('font-size')
    # These colors are not represented in the style guide
    assert spinner.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', spinner.value_of_css_property('color')
    assert spinner.value_of_css_property('line-height') == '20px', spinner.value_of_css_property('line-height')
    assert spinner.value_of_css_property('width') == '50px', spinner.value_of_css_property('width')
    assert spinner.value_of_css_property('height') == '50px', spinner.value_of_css_property('height')

  # Table Styles =============================
  # None of these are currently represented in the style guide and there is a lot of variance in the app
  @staticmethod
  def validate_table_heading_style(th):
    """
    Ensure consistency in rendering table headings across the application
    :param th: table heading to validate
    """
    assert application_typeface in th.value_of_css_property('font-family'), th.value_of_css_property('font-family')
    assert th.value_of_css_property('font-size') == '14px', th.value_of_css_property('font-size')
    assert th.value_of_css_property('font-weight') == '700', th.value_of_css_property('font-weight')
    assert th.value_of_css_property('line-height') == '20px', th.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
    assert th.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', th.value_of_css_property('color')
    assert th.value_of_css_property('text-align') == 'left', th.value_of_css_property('text-align')
    assert th.value_of_css_property('vertical-align') == 'top', th.value_of_css_property('vertical-align')
