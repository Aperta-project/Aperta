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
# application_typeface = 'source-sans-pro'
application_typeface = 'helvetica'
# manuscript_typeface = 'lora'
manuscript_typeface = 'times'

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

  # Heading Styles ===========================
  @staticmethod
  def validate_application_h1_style(title, size='48', line='52.8'):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    Not used for the Manuscript Title!
    :param title: title to validate
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '%spx'%size
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '%spx'%line
    assert title.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    return None

  @staticmethod
  def validate_profile_title_style(title):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: None
    """
    assert application_typeface in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '15.4px'
    assert title.value_of_css_property('color') == 'rgba(153, 153, 153, 1)'
    return None
    
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

  # Button Styles ============================
  @staticmethod
  def validate_green_backed_button_style(button):
    """
    Ensure consistency in rendering page and overlay green-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(57, 163, 41, 1)'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_green_on_green_button_style(button):
    """
    Ensure consistency in rendering page and overlay light green-backed, green text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(15, 116, 0, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(142, 203, 135, 1)'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_small_green_backed_button_style(button):
    """
    Ensure consistency in rendering page and overlay small green-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(57, 163, 41, 1)'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_blue_backed_button_style(button):
    """
    Ensure consistency in rendering page and overlay blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(45, 133, 222, 1)'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_blue_on_blue_button_style(button):
    """
    Ensure consistency in rendering page and overlay light blue-backed, blue text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(32, 94, 156, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(148, 184, 224, 1)'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '6px'
    assert button.value_of_css_property('padding-bottom') == '6px'
    assert button.value_of_css_property('padding-left') == '12px'
    assert button.value_of_css_property('padding-right') == '12px'

  @staticmethod
  def validate_small_blue_backed_button_style(button):
    """
    Ensure consistency in rendering page and overlay small blue-backed, white text buttons across the application
    :param button: button to validate
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(45, 133, 222, 1)'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('vertical-align') == 'middle'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    assert button.value_of_css_property('padding-top') == '1px'
    assert button.value_of_css_property('padding-bottom') == '1px'
    assert button.value_of_css_property('padding-left') == '5px'
    assert button.value_of_css_property('padding-right') == '5px'

  @staticmethod
  def validate_secondary_button_style(button, color='rgba(255, 255, 255, 1)',
                                      transform='uppercase', font_size='14px',
                                      line_height='20px', background_color='rgba(255, 255, 255, 1)',
                                      text_align='center'):
    """
    Ensure consistency in rendering page and overlay text buttons across the application
    :param button: button to validate
    :return: None
    TODO: Find out why I see the commented values in the browser
    """
    assert application_typeface in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == font_size
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == line_height
    assert button.value_of_css_property('color') == color
    # Reset button color according to browser: 'rgba(57, 163, 41, 1)'
    assert button.value_of_css_property('background-color') == background_color
    assert button.value_of_css_property('text-align') == text_align
    assert button.value_of_css_property('text-transform') == transform
    return None

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
    :return: None
    """
    assert application_typeface in input_.value_of_css_property('font-family')
    assert input_.value_of_css_property('font-size') == '14px'
    assert input_.value_of_css_property('font-weight') == '400'
    assert input_.value_of_css_property('line-height') == '20px'
    assert input_.value_of_css_property('color') == color
    assert input_.value_of_css_property('text-align') == 'start'
    return None
