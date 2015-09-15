#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""

__author__ = 'jgray@plos.org'

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage
from Base.Resources import au_login, rv_login, ae_login, he_login, fm_login, oa_login, sa_login

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
tahi_blue_dark =  'rgba(32, 94, 156, 1)'
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
    self._nav_menu = (By.CLASS_NAME, 'navigation')

  # POM Actions
  def click_left_nav(self):
    """Click left navigation"""
    hamburger_icon = self._get(self._nav_hamburger_icon)
    assert hamburger_icon.get_attribute('d') == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.8'
      '96,6,2,6.896,2,8S2.896,10,4,10z M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0'
      '.896,2-2S29.104,14,28,14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2'
      '  S29.104,22,28,22z')
    self._get(self._nav_toggle).click()

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
    assert border.value_of_css_property('color') == 'rgba(128, 128, 128, 1)'
    assert border.value_of_css_property('background-color') in (tahi_green_light, tahi_blue_light, tahi_grey_light)

  @staticmethod
  def validate_standard_border(border):
    """
    This border style is used against all but the light color variants.
    :param border: border
    :return: Void function
    """
    assert border.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  # Heading Styles ===========================
  @staticmethod
  def validate_application_h1_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    Not used for the Manuscript Title!
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '36px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '39.6px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_application_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '33px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_application_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '26.4px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_application_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings across the application
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '19.8px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_manuscript_h1_style(title):
    """
    Ensure consistency in rendering page and overlay main headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '36px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '39.6px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_manuscript_h2_style(title):
    """
    Ensure consistency in rendering page and overlay h2 section headings within the manuscript
    """
    assert manuscript_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '30px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '33px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_manuscript_h3_style(title):
    """
    Ensure consistency in rendering page and overlay h3 section headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '24px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '26.4px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_manuscript_h4_style(title):
    """
    Ensure consistency in rendering page and overlay h4 section headings within the manuscript
    :param title: title to validate
    """
    assert manuscript_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '18px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '19.8px'
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  # This seems out of bounds - this should conform to one of the above styles - report as a bug
  @staticmethod
  def validate_profile_title_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: Void Function
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '15.4px'
    assert title.value_of_css_property('color') == 'rgba(153, 153, 153, 1)'

  # Ordinary Text Styles ============================
  @staticmethod
  def validate_application_ptext(paragraph):
    """
    Ensure consistency in rendering application ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert application_typeface in paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px'
    assert paragraph.value_of_css_property('font-weight') == '500'
    assert paragraph.value_of_css_property('line-height') == '20px'
    assert paragraph.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  @staticmethod
  def validate_manuscript_ptext(paragraph):
    """
    Ensure consistency in rendering manuscript ordinary text and paragraph text across the application
    :param paragraph: paragraph to validate
    :return: Void Function
    """
    assert manuscript_typeface in paragraph.value_of_css_property('font-family')
    assert paragraph.value_of_css_property('font-size') == '14px'
    assert paragraph.value_of_css_property('font-weight') == '500'
    assert paragraph.value_of_css_property('line-height') == '20px'
    assert paragraph.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

  # Link Styles ==============================
  @staticmethod
  def validate_default_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px'
    assert link.value_of_css_property('line-height') == '20px'
    assert link.value_of_css_property('background-color') == 'transparent'
    assert link.value_of_css_property('color') == tahi_green
    assert link.value_of_css_property('font-weight') == '400'

  @staticmethod
  def validate_default_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px'
    assert link.value_of_css_property('line-height') == '20px'
    assert link.value_of_css_property('background-color') == 'transparent'
    assert link.value_of_css_property('color') == tahi_green
    assert link.value_of_css_property('font-weight') == '400'
    assert link.value_of_css_property('text-decoration') == 'underline'

  @staticmethod
  def validate_admin_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px'
    assert link.value_of_css_property('line-height') == '20px'
    assert link.value_of_css_property('background-color') == 'transparent'
    assert link.value_of_css_property('color') == tahi_blue
    assert link.value_of_css_property('font-weight') == '400'

  @staticmethod
  def validate_admin_link_hover_style(link):
    """
    Ensure consistency in rendering link hover across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px'
    assert link.value_of_css_property('line-height') == '20px'
    assert link.value_of_css_property('background-color') == 'transparent'
    assert link.value_of_css_property('color') == tahi_blue
    assert link.value_of_css_property('font-weight') == '400'
    assert link.value_of_css_property('text-decoration') == 'underline'

  @staticmethod
  def validate_disabled_link_style(link):
    """
    Ensure consistency in rendering links across the application
    :param link: link to validate
    """
    assert application_typeface in link.value_of_css_property('font-family')
    assert link.value_of_css_property('font-size') == '14px'
    assert link.value_of_css_property('line-height') == '20px'
    assert link.value_of_css_property('background-color') == 'transparent'
    assert link.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert link.value_of_css_property('font-weight') == '400'

  # List Styles ==============================
  @staticmethod
  def validate_application_list_style(olul):
    """
    Ensure consistency in list presentation across the application
    :param ulol: ol or ul
    :return: Void function
    """
    assert application_typeface in olul.value_of_css_property('font-family')
    assert olul.value_of_css_property('font-size') == '14px'
    assert olul.value_of_css_property('line-height') == '20px'
    assert olul.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'

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
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_green
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_link_big_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_green
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_primary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small green-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == white
    assert button.value_of_css_property('background-color') == tahi_green
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_secondary_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, green text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('color') == tahi_green
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'

  @staticmethod
  def validate_link_small_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay transparent-backed, green text link-buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_green
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '5px'
    assert button.value_of_css_property('padding-left') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_primary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, lighter grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_grey_light
    assert button.value_of_css_property('background-color') == 'rgba(238, 238, 238, 1)'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_secondary_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_grey_light
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_link_big_disabled_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, grey text disabled buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_grey_light
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_green_on_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay light green-backed, dark green text buttons across the application.
    These buttons should be used against a standard tahi_green background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_green_dark
    assert button.value_of_css_property('background-color') == tahi_green_light
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_primary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large grey-backed, white text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == white
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 119, 1)'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_secondary_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_link_big_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay large tansparent-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_primary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small grey-backed, white text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == white
    assert button.value_of_css_property('background-color') == 'rgba(119, 119, 19, 1)'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_secondary_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, grey text buttons across the application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'

  @staticmethod
  def validate_link_small_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, grey text link-buttons across the
    application
    TODO: Find out what the use case is for this design as it seems duplicative with the defined disabled buttons
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '5px'
    assert button.value_of_css_property('padding-left') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_grey_on_grey_button_style(button):
    """
    Ensure consistency in rendering page and overlay light grey-backed, dark-grey text buttons across the application
    These should be used on a standard tahi_grey background only.
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_grey_dark
    assert button.value_of_css_property('background-color') == tahi_grey_light
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_primary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == white
    assert button.value_of_css_property('background-color') == tahi_blue
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_secondary_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large white-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_blue
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_link_big_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay large transparent-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_blue
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_primary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == white
    assert button.value_of_css_property('background-color') == tahi_blue
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_secondary_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small white-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('color') == tahi_blue
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('background-color') == white
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'

  @staticmethod
  def validate_link_small_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay small transparent-backed, blue text link-buttons across the
    application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_blue
    assert button.value_of_css_property('background-color') == 'transparent'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '5px'
    assert button.value_of_css_property('padding-left') == '1px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_blue_on_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay light blue-backed, dark-blue text buttons across the application
    These should only be used against a standard tahi_blue background
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == tahi_blue_dark
    assert button.value_of_css_property('background-color') == tahi_blue_light
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  # Form Styles ==============================
  @staticmethod
  def validate_input_field_label_style(label):
    """
    Ensure consistency in rendering page, card and overlay input field labels across the application
    :param label: label to validate
    """
    # NOTE THAT THIS DOES NOT CURRENTLY MATCH THE STYLEGUIDE
    assert application_typeface in label.value_of_css_property('font-family')
    assert label.value_of_css_property('font-size') == '14px'
    assert label.value_of_css_property('font-weight') == '400'
    assert label.value_of_css_property('color') == 'rgba(119, 119, 119, 1)'
    assert label.value_of_css_property('line-height') == '20px'
    assert label.value_of_css_property('padding-left') == '12px'
    assert label.value_of_css_property('margin-bottom') == '5px'

  # Error Styles =============================
  @staticmethod
  def validate_flash_info_style(msg):
    """
    Ensure consistency in rendering informational alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px'
    assert msg.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert msg.value_of_css_property('line-height') == '20px'
    assert msg.value_of_css_property('text-align') == 'center'
    assert msg.value_of_css_property('position') == 'relative'
    assert msg.value_of_css_property('display') == 'inline-block'

  @staticmethod
  def validate_flash_error_style(msg):
    """
    Ensure consistency in rendering error alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family'), msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px', msg.value_of_css_property('font-size')
    # This color is not represented in the style guide as a color and is not the color of the actual implementation
    #assert msg.value_of_css_property('color') == 'rgba(122, 51, 78, 1)', msg.value_of_css_property('color')
    # This color is not represented in the style guide
    #assert msg.value_of_css_property('background-color') == 'rgba(247, 239, 233, 1)', \
    #    msg.value_of_css_property('background-color')
    assert msg.value_of_css_property('line-height') == '20px', msg.value_of_css_property('line-height')
    #assert msg.value_of_css_property('text-align') == 'center', msg.value_of_css_property('text-align')
    #assert msg.value_of_css_property('position') == 'relative', msg.value_of_css_property('position')
    #assert msg.value_of_css_property('display') == 'inline-block', msg.value_of_css_property('display')

  @staticmethod
  def validate_flash_success_style(msg):
    """
    Ensure consistency in rendering success alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px'
    assert msg.value_of_css_property('color') == tahi_green
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == 'rgba(234, 253, 231, 1)'
    assert msg.value_of_css_property('line-height') == '20px'
    assert msg.value_of_css_property('text-align') == 'center'
    assert msg.value_of_css_property('position') == 'relative'
    assert msg.value_of_css_property('display') == 'inline-block'

  @staticmethod
  def validate_flash_warn_style(msg):
    """
    Ensure consistency in rendering warning alerts across the application
    :param msg: alert message to validate
    """
    assert application_typeface in msg.value_of_css_property('font-family')
    assert msg.value_of_css_property('font-size') == '14px'
    # This color is not represented in the style guide
    assert msg.value_of_css_property('color') == 'rgba(146,​ 139,​ 113, 1)'
    # This color is not represented in the style guide
    assert msg.value_of_css_property('background-color') == 'rgba(242,​ 242,​ 213, 1)'
    assert msg.value_of_css_property('line-height') == '20px'
    assert msg.value_of_css_property('text-align') == 'center'
    assert msg.value_of_css_property('position') == 'relative'
    assert msg.value_of_css_property('display') == 'inline-block'

  # Table Styles =============================
  @staticmethod
  def validate_table_heading_style(th):
    """
    Ensure consistency in rendering table headings across the application
    :param th: table heading to validate
    """
    assert application_typeface in th.value_of_css_property('font-family')
    assert th.value_of_css_property('font-size') == '14px'
    assert th.value_of_css_property('font-weight') == '700'
    assert th.value_of_css_property('line-height') == '20px'
    assert th.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert th.value_of_css_property('text-align') == 'left'
    assert th.value_of_css_property('vertical-align') == 'top'

  @staticmethod
  def validate_input_form_style(input_, color='rgba(85, 85, 85, 1)'):
    """
    Ensure consistency in rendering input in forms across the application
    :return: Void Function
    """
    assert application_typeface in input_.value_of_css_property('font-family')
    assert input_.value_of_css_property('font-size') == '14px'
    assert input_.value_of_css_property('font-weight') == '400'
    assert input_.value_of_css_property('line-height') == '20px'
    assert input_.value_of_css_property('color') == color
    assert input_.value_of_css_property('text-align') == 'start'
    return None
