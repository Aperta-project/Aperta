#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""

__author__ = 'jgray@plos.org'

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage
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
    self._nav_hamburger_icon = (By.XPATH,
                                "//div[@class='navigation-toggle']/*[local-name() = 'svg']/*[local-name() = 'path']")
    # Icons on the top right
    self._nav_menu = (By.CLASS_NAME, 'navigation')
    self._version_link = (By.CLASS_NAME, 'versions-link')
    self._collaborators_link = (By.CLASS_NAME, 'contributors-link')
    self._downloads_link = (By.XPATH, ".//div[contains(@class, 'downloads-link')]/div")
    self._recent_activity = (By.CLASS_NAME, 'activity-link')
    self._discussion_link = (By.CLASS_NAME, 'discussions-link')
    self._workflow_link = (By.CLASS_NAME, 'workflow-link')
    self._more_link = (By.CLASS_NAME, 'more-link')
    self._control_bar_right_items = (By.XPATH, "//div[@class='control-bar-inner-wrapper']/ul[2]/li")

    self._bar_items = (By.CLASS_NAME, 'bar-item')
    self._add_collaborators_label = (By.CLASS_NAME, 'contributors-add')
    self._add_collaborators_modal = (By.CLASS_NAME, 'show-collaborators-overlay')
    self._add_collaborators_modal_header = (By.CLASS_NAME, 'overlay-title-text')
    self._add_collaborators_modal_support_text =  (By.CLASS_NAME, 'overlay-supporting-text')
    self._add_collaborators_modal_support_select = (By.CLASS_NAME, 'collaborator-select')
    self._add_collaborators_modal_cancel = (By.XPATH, "//div[@class='overlay-action-buttons']/a")
    self._add_collaborators_modal_save = (By.XPATH, "//div[@class='overlay-action-buttons']/button")
    self._modal_close = (By.CLASS_NAME, 'overlay-close-x')
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
    # Inside more button
    self._appeal_link = (By.CLASS_NAME, 'appeal-link')
    self._withdraw_link = (By.CLASS_NAME, 'withdraw-link')
    self._withdraw_modal = (By.CLASS_NAME, 'overlay--fullscreen')
    self._exclamation_circle = (By.CLASS_NAME, 'fa-exclamation-circle')
    self._withdraw_modal_title = (By.CSS_SELECTOR, 'h1')
    self._withdraw_modal_text = (By.CSS_SELECTOR, 'div.paper-withdraw-wrapper p')
    self._withdraw_modal_yes = (By.XPATH, '//div[@class="pull-right"]/button[1]')
    self._withdraw_modal_no = (By.XPATH, '//div[@class="pull-right"]/button[2]')

        # active

  # POM Actions
  def click_left_nav(self):
    """Click left navigation"""
    hamburger_icon = self._get(self._nav_hamburger_icon)
    assert hamburger_icon.get_attribute('d') == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.8'
      '96,6,2,6.896,2,8S2.896,10,4,10z M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0'
      '.896,2-2S29.104,14,28,14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2'
      '  S29.104,22,28,22z')
    self._get(self._nav_toggle).click()

  def validate_closed_lef_nav(self):
    """Validate left navigation element in its rest state"""
    left_nav = self._get(self._nav_toggle)
    assert left_nav.text == 'PLOS', left_nav.text
    assert left_nav.value_of_css_property('color') == 'rgba(57, 163, 41, 1)', \
      left_nav.value_of_css_property('color')
    assert application_typeface in left_nav.value_of_css_property('font-family'), \
      application_typeface
    assert left_nav.value_of_css_property('font-size') == '24px', \
      left_nav.value_of_css_property('font-size')
    assert left_nav.value_of_css_property('font-weight') == '700', \
      left_nav.value_of_css_property('font-weight')
    assert left_nav.value_of_css_property('text-transform') == 'uppercase', \
      left_nav.value_of_css_property('text-transform')



  def validate_nav_elements(self, permissions):
    """
    Validates the appearance of elements in the navigation menu for
    every logged in page
    :param permissions: username
    """
    elevated = [fm_login, sa_login]
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
    if permissions == (oa_login, sa_login):
      self._get(self._nav_admin_link)
    return None

  def validate_wf_top_elements(self):
    """Validate styles of elements that are in the top menu from workflow"""
    editable = self._get(self._editable_label)
    assert editable.text == 'EDITABLE'
    assert editable.value_of_css_property('font-size') == '10px'
    assert editable.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert editable.value_of_css_property('font-weight') == '700'
    assert application_typeface in editable.value_of_css_property('font-family')
    assert editable.value_of_css_property('text-transform') == 'uppercase'
    assert editable.value_of_css_property('line-height') == '20px'
    assert editable.value_of_css_property('text-align') == 'center'
    ec = self._get(self._editable_checkbox)
    assert ec.get_attribute('type') == 'checkbox'
    #assert ec.value_of_css_property('color') in ('rgba(49, 55, 57, 1)', 'rgba(60, 60, 60, 1)')
    assert ec.value_of_css_property('font-size') == '10px'
    assert ec.value_of_css_property('font-weight') == '700'
    recent_activity_icon = self._get(self._recent_activity_icon)
    assert recent_activity_icon.get_attribute('d') == ('M-171.3,403.5c-2.4,0-4.5,1.4-5.5,3.5c0,'
                '0-0.1,0-0.1,0h-9.9l-6.5-17.2  '
                'c-0.5-1.2-1.7-2-3-1.9c-1.3,0.1-2.4,1-2.7,2.3l-4.3,18.9l-4-43.4c-0.1-1'
                '.4-1.2-2.5-2.7-2.7c-1.4-0.1-2.7,0.7-3.2,2.1l-12.5,41.6  h-16.2c-1.6,0'
                '-3,1.3-3,3c0,1.6,1.3,3,3,3h18.4c1.3,0,2.5-0.9,2.9-2.1l8.7-29l4.3,46.8'
                'c0.1,1.5,1.3,2.6,2.8,2.7c0.1,0,0.1,0,0.2,0  c1.4,0,2.6-1,2.9-2.3l6.2-'
                '27.6l3.7,9.8c0.4,1.2,1.5,1.9,2.8,1.9h11.9c0.2,0,0.3-0.1,0.5-0.1c1.1,1'
                '.7,3,2.8,5.1,2.8  c3.4,0,6.1-2.7,6.1-6.1C-165.3,406.2-168,403.5-171.3,403.5z')
    assert recent_activity_icon.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    recent_activity_text = self._get(self._recent_activity_text)
    assert recent_activity_text
    assert recent_activity_text.text, 'Recent Activity'
    assert recent_activity_text.value_of_css_property('font-size') == '10px'
    assert recent_activity_text.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert recent_activity_text.value_of_css_property('font-weight') == '700'
    assert application_typeface in recent_activity_text.value_of_css_property('font-family')
    assert recent_activity_text.value_of_css_property('text-transform') == 'uppercase'
    assert recent_activity_text.value_of_css_property('line-height') == '20px'
    assert recent_activity_text.value_of_css_property('text-align') == 'center'
    discussions_icon = self._get(self._discussions_icon)
    assert discussions_icon
    assert discussions_icon.value_of_css_property('font-family') == 'FontAwesome'
    assert discussions_icon.value_of_css_property('font-size') == '16px'
    assert discussions_icon.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert discussions_icon.value_of_css_property('font-weight') == '400'
    assert discussions_icon.value_of_css_property('text-transform') == 'uppercase'
    assert discussions_icon.value_of_css_property('font-style') == 'normal'
    discussions_text = self._get(self._discussions_text)
    assert discussions_text
    assert discussions_text.text == 'DISCUSSIONS'


  def click_nav_close(self):
    """Click sign out link"""
    self._get(self._nav_close).click()
    return self

  def click_profile_link(self):
    """Click sign out link"""
    self._get(self._nav_profile_link).click()
    return self

  def click_dashboard_link(self):
    """Click sign out link"""
    self._get(self._nav_dashboard_link).click()
    return self

  def click_flow_mgr_link(self):
    """Click sign out link"""
    self._get(self._nav_flowmgr_link).click()
    return self

  def click_paper_tracker_link(self):
    """Click sign out link"""
    self._get(self._nav_paper_tracker_link).click()
    return self

  def click_admin_link(self):
    """Click sign out link"""
    self._get(self._nav_admin_link).click()
    return self

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._nav_signout_link).click()
    return self

  def click_feedback_link(self):
    """Click sign out link"""
    self._get(self._nav_feedback_link).click()
    return self

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
