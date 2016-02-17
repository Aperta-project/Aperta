#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""

__author__ = 'jgray@plos.org'

import time

from selenium.webdriver.common.by import By
from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PlosPage import PlosPage
from Base.PostgreSQL import PgSQL
from Base.Resources import fm_login, oa_login, sa_login


# Variable definitions
# We are in process of migrating fonts in the interface, until this is deployed to lean, we can
#    only enforce the fallback font and have it work in both environments. Source-Sans-Pro and Lora are what we are
#    moving to when the next push to lean happens we can correct the following entries.
# typefaces
application_typeface = 'source-sans-pro'
manuscript_typeface = 'lora'
# colors
tahi_green = 'rgba(57, 163, 41, 1)'
tahi_green_light = 'rgba(142, 203, 135, 1)'
tahi_green_dark = 'rgba(15, 116, 0, 1)'
tahi_blue = 'rgba(45, 133, 222, 1)'
tahi_blue_light = 'rgba(148, 184, 224, 1)'
tahi_blue_dark = 'rgba(32, 94, 156, 1)'
tahi_grey = 'rgba(242, 242, 242, 1)'
tahi_grey_xlight = 'rgba(245, 245, 245, 1)'
tahi_grey_light = 'rgba(213, 213, 213, 1)'
tahi_grey_dark = 'rgba(135, 135, 135, 1)'
tahi_black = 'rgba(0, 0, 0, 1)'
white = 'rgba(255, 255, 255, 1)'


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
    self._nav_dashboard_link = (By.ID, 'nav-dashboard')
    self._nav_admin_link = (By.ID, 'nav-admin')
    self._nav_flowmgr_link = (By.ID, 'nav-flow-manager')
    self._nav_paper_tracker_link = (By.ID, 'nav-paper-tracker')
    self._nav_profile_menu_toggle = (By.ID, 'profile-dropdown-menu')
    self._nav_profile_img = (By.CSS_SELECTOR, 'span.main-nav-item img')
    self._nav_profile_text = (By.CLASS_NAME, 'profile-dropdown-menu-text')
    self._nav_profile_link = (By.ID, 'nav-profile')
    self._nav_signout_link = (By.ID, 'nav-signout')
    self._nav_feedback_link = (By.ID, 'nav-give-feedback')
    self._nav_hamburger_icon = (By.CLASS_NAME,'fa-list-ul')
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
    self._recent_activity_modal_title = (By.CSS_SELECTOR, 'h1.feedback-overlay-thanks')
    self._discussion_container = (By.CLASS_NAME, 'liquid-container')
    self._discussion_container_title = (By.CSS_SELECTOR, 'div.discussions-index-header h1')
    self._discussion_create_new_btn = (By.CSS_SELECTOR, 'div.discussions-index-header a')
    self._create_new_topic = (By.CSS_SELECTOR, 'h1.discussions-show-title')
    self._topic_title = (By.CSS_SELECTOR, 'div.inset-form-control')
    self._create_topic_btn = (By.CSS_SELECTOR, 'div.discussions-show-content button')
    self._create_topic_cancel = (By.CSS_SELECTOR, 'span.sheet-toolbar-button')
    self._sheet_close_x = (By.CLASS_NAME, 'sheet-close-x')
    # Flash Messages
    self._flash_success_msg = (By.CSS_SELECTOR, 'div.flash-message--success div.flash-message-content')
    self._flash_error_msg = (By.CSS_SELECTOR, 'div.flash-message--error div.flash-message-content')

    self._flash_closer = (By.CLASS_NAME, 'flash-message-remove')
    # Cards - placeholder locators - these are over-ridden by definitions in the workflow and manuscript_viewer pages
    self._billing_card = None
    self._cover_letter_card = None
    self._review_cands_card = None
    self._revise_task_card = None
    self._cfa_card = None
    self._authors_card = None
    self._competing_ints_card = None
    self._data_avail_card = None
    self._ethics_statement_card = None
    self._figures_card = None
    self._fin_disclose_card = None
    self._new_taxon_card = None
    self._report_guide_card = None
    self._supporting_info_card = None
    self._upload_manu_card = None
    self._prq_card = None
    self._initial_decision_card = None
    # Tasks - placeholder locators - these are over-ridden by definitions in the workflow and manuscript_viewer pages
    self._billing_task = None
    self._cover_letter_task = None
    self._review_cands_task = None
    self._revise_task = None
    self._cfa_task = None
    self._authors_task = None
    self._competing_ints_task = None
    self._data_avail_task = None
    self._ethics_statement_task = None
    self._figures_task = None
    self._fin_disclose_task = None
    self._new_taxon_task = None
    self._report_guide_task = None
    self._supporting_info_task = None
    self._upload_manu_task = None
    self._prq_task = None
    self._initial_decision_task = None
    # Global Overlay Locators
    self._overlay_header_title = (By.CLASS_NAME, 'overlay-header-title')
    self._overlay_header_close = (By.CLASS_NAME, 'overlay-close')
    self._overlay_action_button_cancel = (By.CSS_SELECTOR, 'div.overlay-action-buttons a.button-link')
    self._overlay_action_button_save = (By.CSS_SELECTOR, 'div.overlay-action-buttons button.button-primary')

  # POM Actions
  def click_profile_nav(self):
    """Click profile navigation"""
    profile_menu_toggle = self._get(self._nav_profile_menu_toggle)
    profile_menu_toggle.click()

  def validate_nav_toolbar_elements(self, permissions):
    """
    Validates the appearance of elements in the navigation menu for
    every logged in page
    :param permissions: username
    """
    elevated = [fm_login, sa_login]
    self._get(self._nav_title)
    self._get(self._nav_profile_img)
    self._get(self._nav_dashboard_link)
    self.click_profile_nav()
    self._get(self._nav_profile_link)
    self._get(self._nav_signout_link)
    self._get(self._nav_feedback_link)
    # Must have flow mgr, admin or superadmin
    if permissions in elevated:
      self._get(self._nav_flowmgr_link)
      self._get(self._nav_paper_tracker_link)
    # Must have admin or superadmin
    if permissions == (oa_login, sa_login):
      self._get(self._nav_admin_link)
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
    #assert ec.value_of_css_property('color') in ('rgba(49, 55, 57, 1)', 'rgba(60, 60, 60, 1)')
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

  def click_flow_mgr_link(self):
    """Click nav toolbar flow manager link"""
    self._get(self._nav_flowmgr_link).click()
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
    self.click_profile_nav()
    self._get(self._nav_feedback_link).click()
    return self

  def logout(self):
    """Logout from any page"""
    url = self._driver.current_url
    signout_url = url.split('/')[0]+'//'+url.split('/')[2]+'/users/sign_out'
    self._driver.get(signout_url)

  def go_to_manuscript(self, manuscript_id):
    """
    """
    url = self._driver.current_url
    id_url = url.split('/')[0]+'//'+url.split('/')[2]+'/papers/'+str(manuscript_id)
    self._driver.get(id_url)

  def validate_ihat_conversions_success(self):
    """
    Validate ihat conversion success
    """
    self.set_timeout(30)
    try:
      ihat_msg = self._get(self._flash_success_msg)
    except Exception as e:
      self.restore_timeout()
      return e
    self.restore_timeout()
    assert 'Finished loading Word file.' in ihat_msg.text, ihat_msg.text

  def validate_ihat_conversions_failure(self):
    """
    Validate ihat conversion failure
    """
    self.set_timeout(30)
    ihat_msg = self._get(self._flash_error_msg)
    self.restore_timeout()
    assert 'There was an error loading your Word file.' in ihat_msg.text, ihat_msg.text

  def close_flash_message(self):
    """
    Close any type of flash message: error, info or success
    :return: void function
    """
    self._get(self._flash_closer).click()

  def close_modal(self):
    """
    Close any type of modal
    :return: None
    """
    self._get(self._overlay_header_close).click()



  @staticmethod
  def get_db_submission_data(manu_id):
    """
    Provided a manuscript ID, queries the database for current publishing_state, gradual_engagement state, and any
      submitted_at date/time object if present
    :param manu_id: ID of paper to query
    :return: a tuple
    """
    submission_data = PgSQL().query('SELECT publishing_state, gradual_engagement, submitted_at '
                                    'FROM papers '
                                    'WHERE id = %s;', (manu_id,))
    return submission_data

  def click_card(self, cardname):
    """
    Passed a card name, opens the relevant card
    :param cardname: any one of: cover_letter, billing, figures, authors, supporting_info, upload_manuscript, prq,
        review_candidates, revise_task, competing_interests, data_availability, ethics_statement, financial_disclosure,
        new_taxon, reporting_guidelines, changes_for_author
    NOTE: this covers only the author facing cards, with the exception of initial_decision
    NOTE also that the locators for these are specifically defined within the scope of the manuscript_viewer or
        workflow page
    NOTE: Note this method is temporarily bifurcated into click_card() and click_task() to support both the manuscript
        and workflow contexts while we transition.

    :return: True or False, if cardname is unknown.
    """
    self.set_timeout(1)
    if cardname.lower() == 'cover_letter':
      card_title = self._get(self._billing_card)
    elif cardname.lower() == 'billing':
      card_title = self._get(self._cover_letter_card)
    elif cardname.lower() == 'figures':
      card_title = self._get(self._figures_card)
    elif cardname.lower() == 'authors':
      card_title = self._get(self._authors_card)
    elif cardname.lower() == 'supporting_info':
      card_title = self._get(self._supporting_info_card)
    elif cardname.lower() == 'upload_manuscript':
      card_title = self._get(self._upload_manu_card)
    elif cardname.lower() == 'prq':
      card_title = self._get(self._prq_card)
    elif cardname.lower() == 'review_candidates':
      card_title = self._get(self._review_cands_card)
    elif cardname.lower() == 'revise_task':
      card_title = self._get(self._revise_task_card)
    elif cardname.lower() == 'competing_interests':
      card_title = self._get(self._competing_ints_card)
    elif cardname.lower() == 'data_availability':
      card_title = self._get(self._data_avail_card)
    elif cardname.lower() == 'ethics_statement':
      card_title = self._get(self._ethics_statement_card)
    elif cardname.lower() == 'financial_disclosure':
      card_title = self._get(self._fin_disclose_card)
    elif cardname.lower() == 'new_taxon':
      card_title = self._get(self._new_taxon_card)
    elif cardname.lower() == 'reporting_guidelines':
      card_title = self._get(self._report_guide_card)
    elif cardname.lower() == 'changes_for_author':
      card_title = self._get(self._cfa_card)
    elif cardname.lower() == 'initial_decision':
      card_title = self._get(self._initial_decision_card)
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
    :param taskname: any one of: cover_letter, billing, figures, authors, supporting_info, upload_manuscript, prq,
        review_candidates, revise_task, competing_interests, data_availability, ethics_statement, financial_disclosure,
        new_taxon, reporting_guidelines, changes_for_author
    NOTE: this covers only the author facing tasks, with the exception of initial_decision
    NOTE also that the locators for these are specifically defined within the scope of the manuscript_viewer or
        workflow page
    NOTE: Note this method is temporarily bifurcated into click_card() and click_task() to support both the manuscript
        and workflow contexts while we transition.

    :return: True or False, if taskname is unknown.
    """
    self.set_timeout(5)
    if taskname.lower() == 'billing':
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
    elif taskname.lower() == 'prq':
      task_title = self._get(self._prq_task)
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
      self.restore_timeout()
      return False
    # For whatever reason, selenium can't grok a simple click() here
    self._actions.click_and_hold(task_title).release().perform()
    self.restore_timeout()
    return True

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
    assert border.value_of_css_property('background-color') in (tahi_green_light, tahi_blue_light, tahi_grey_light), \
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
  def validate_application_h1_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    Not used for the Manuscript Title!
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family'), \
        title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '36px', title.value_of_css_property('font-size')
    assert title.value_of_css_property('font-weight') == '500', title.value_of_css_property('font-weight')
    assert title.value_of_css_property('line-height') == '39.6px', title.value_of_css_property('line-height')
    # This color is not represented in the tahi palette
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
    :return: None
    TODO: Leave this method with parameters until fixed lack of styleguide for this
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == font_size
    assert title.value_of_css_property('font-weight') == font_weight
    assert title.value_of_css_property('line-height') == line_height
    assert title.value_of_css_property('color') == color

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
    assert link.value_of_css_property('color') == tahi_green, link.value_of_css_property('color')
    assert link.value_of_css_property('font-weight') == '400', link.value_of_css_property('font-weight')

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
    assert link.value_of_css_property('color') == tahi_green, link.value_of_css_property('color')
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
    assert link.value_of_css_property('color') == tahi_blue, link.value_of_css_property('color')
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
    assert link.value_of_css_property('color') == tahi_blue, link.value_of_css_property('color')
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
    assert button.value_of_css_property('background-color') == tahi_green, \
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
    Ensure consistency in rendering page and overlay big white-backed, green text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == tahi_green, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == white, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

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
    assert button.value_of_css_property('color') == tahi_green, button.value_of_css_property('color')
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
    assert button.value_of_css_property('background-color') == tahi_green, \
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
    assert button.value_of_css_property('color') == tahi_green, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_green, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_grey_light, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_grey_light, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_grey_light, button.value_of_css_property('color')
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
    These buttons should be used against a standard tahi_green background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == tahi_green_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == tahi_green_light, \
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
    assert button.value_of_css_property('color') == tahi_grey_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == tahi_grey_light, \
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
    assert button.value_of_css_property('background-color') == tahi_blue, \
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
    assert button.value_of_css_property('color') == tahi_blue, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_blue, button.value_of_css_property('color')
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
    assert button.value_of_css_property('background-color') == tahi_blue, \
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
    assert button.value_of_css_property('color') == tahi_blue, button.value_of_css_property('color')
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
    assert button.value_of_css_property('color') == tahi_blue, button.value_of_css_property('color')
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
    These should only be used against a standard tahi_blue background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family'), \
        button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px', button.value_of_css_property('font-size')
    assert button.value_of_css_property('font-weight') == '400', button.value_of_css_property('font-weight')
    assert button.value_of_css_property('line-height') == '20px', button.value_of_css_property('line-height')
    assert button.value_of_css_property('color') == tahi_blue_dark, button.value_of_css_property('color')
    assert button.value_of_css_property('background-color') == tahi_blue_light, \
        button.value_of_css_property('background-color')
    assert button.value_of_css_property('vertical-align') == 'middle', button.value_of_css_property('vertical-align')
    assert button.value_of_css_property('text-transform') == 'uppercase', button.value_of_css_property('text-transform')
    assert button.value_of_css_property('padding-top') == '6px', button.value_of_css_property('padding-top')
    assert button.value_of_css_property('padding-bottom') == '6px', button.value_of_css_property('padding-bottom')
    assert button.value_of_css_property('padding-left') == '12px', button.value_of_css_property('padding-left')
    assert button.value_of_css_property('padding-right') == '12px', button.value_of_css_property('padding-right')

  # Form Styles ==============================
  @staticmethod
  def validate_input_field_label_style(label):
    """
    Ensure consistency in rendering page, card and overlay input field labels across the application
    :param label: label to validate
    """
    assert application_typeface in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px', label.value_of_css_property('font-size')
    assert label.value_of_css_property('font-weight') == '400', label.value_of_css_property('font-weight')
    # This color is not represented in the tahi palette
    assert label.value_of_css_property('color') == 'rgba(119, 119, 119, 1)', label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', label.value_of_css_property('line-height')

  @staticmethod
  def validate_input_field_style(field):
    """
    Ensure consistency in rendering page, card and overlay input fields across the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', field.value_of_css_property('font-weight')
    # This color is not represented in the tahi palette
    assert field.value_of_css_property('color') == 'rgba(85, 85, 85, 1)', field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '20px', field.value_of_css_property('line-height')
    assert field.value_of_css_property('padding-top') == '26px', field.value_of_css_property('padding-top')
    assert field.value_of_css_property('padding-right') == '12px', field.value_of_css_property('padding-right')
    assert field.value_of_css_property('padding-bottom') == '6px', field.value_of_css_property('padding-bottom')
    assert field.value_of_css_property('padding-left') == '12px', field.value_of_css_property('padding-left')

  @staticmethod
  def validate_single_select_dropdown_style(field):
    """
    Ensure consistency in rendering page, card and overlay single select drop down fields across the application
    :param field: field to validate
    """
    assert application_typeface in field.value_of_css_property('font-family')
    assert field.value_of_css_property('font-size') == '14px', field.value_of_css_property('font-size')
    assert field.value_of_css_property('font-weight') == '400', field.value_of_css_property('font-weight')
    # This color is not represented in the style guide
    assert field.value_of_css_property('color') == 'rgba(68, 68, 68, 1)', field.value_of_css_property('color')
    assert field.value_of_css_property('line-height') == '26px', field.value_of_css_property('line-height')
    assert field.value_of_css_property('text-overflow') == 'ellipsis', field.value_of_css_property('text-overflow')
    assert field.value_of_css_property('margin-right') == '26px', field.value_of_css_property('margin-right')

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
    assert button.value_of_css_property('color') == tahi_black, button.value_of_css_property('color')
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
    assert label.value_of_css_property('color') == 'rgba(51, 51, 51, 1)', label.value_of_css_property('color')
    assert label.value_of_css_property('line-height') == '20px', label.value_of_css_property('line-height')
    assert label.value_of_css_property('margin-right') == '20px', label.value_of_css_property('margin-right')
    assert label.value_of_css_property('margin-bottom') == '5px', label.value_of_css_property('margin-bottom')

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
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide as a color and is not the color of the actual implementation
    # assert msg.value_of_css_property('color') == 'rgba(122, 51, 78, 1)', msg.value_of_css_property('color')
    # This color is not represented in the style guide
    # assert msg.value_of_css_property('background-color') == 'rgba(247, 239, 233, 1)', \
    #    msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
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
    assert msg.value_of_css_property('color') == tahi_green, msg.value_of_css_property('color')
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
