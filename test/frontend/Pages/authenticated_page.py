#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
A class to be inherited from every page for which one is authenticated and wants to access
the navigation menu also vital for ensuring style consistency across the application.
"""

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage

__author__ = 'jgray@plos.org'


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
    self._get(self._nav_toggle).click()

  def validate_nav_elements(self, permissions):
    """
    Validates the appearance of elements in the navigation menu for
    every logged in page
    :param permissions: username
    :return: None
    """
    elevated = ['jgray_flowmgr', 'jgray']
    self._get(self._nav_close)
    self._get(self._nav_title)
    self._get(self._nav_profile_link)
    self._get(self._nav_profile_img)
    self._get(self._nav_dashboard_link)
    self._get(self._nav_signout_link)
    self._get(self._nav_feedback_link)
    hamburger_icon = self._get(self._nav_hamburger_icon)
    assert hamburger_icon.get_attribute('d') == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.8'
      '96,6,2,6.896,2,8S2.896,10,4,10z M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0'
      '.896,2-2S29.104,14,28,14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2'
      '  S29.104,22,28,22z')
    nav_toogle = self._get(self._nav_toggle)
    assert nav_toogle.text == 'PLOS'
    assert nav_toogle.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert 'Cabin' in nav_toogle.value_of_css_property('font-family')
    assert nav_toogle.value_of_css_property('font-size') == '24px'
    assert nav_toogle.value_of_css_property('font-weight') == '700'
    assert nav_toogle.value_of_css_property('text-transform') == 'uppercase'
    
    # Must have flow mgr, admin or superadmin
    if permissions in elevated:
      self._get(self._nav_flowmgr_link)
      self._get(self._nav_paper_tracker_link)
    # Must have admin or superadmin
    if permissions == ('jgray_oa', 'jgray'):
      self._get(self._nav_admin_link)

  def click_nav_close_link(self):
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

  @staticmethod
  def validate_title_style(title, size='48', line='52.8'):
    """
    Ensure consistency in rendering page and overlay main headings across the application
    :param title: title to validate
    :return: None
    """
    assert 'helvetica' in title.value_of_css_property('font-family')
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
    assert 'helvetica' in title.value_of_css_property('font-family')
    assert title.value_of_css_property('font-size') == '14px'
    assert title.value_of_css_property('font-weight') == '500'
    assert title.value_of_css_property('line-height') == '15.4px'
    assert title.value_of_css_property('color') == 'rgba(153, 153, 153, 1)'
    return None
    
  @staticmethod
  def validate_green_backed_button_style(button):
    """
    Ensure consistency in rendering page and overlay green-backed, white text buttons across the application
    :param button: button to validate
    :return: None
    """
    assert 'helvetica' in button.value_of_css_property('font-family')
    assert button.value_of_css_property('font-size') == '14px'
    assert button.value_of_css_property('font-weight') == '400'
    assert button.value_of_css_property('line-height') == '20px'
    assert button.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert button.value_of_css_property('background-color') == 'rgba(57, 163, 41, 1)'
    assert button.value_of_css_property('text-align') == 'center'
    assert button.value_of_css_property('text-transform') == 'uppercase'
    return None

  @staticmethod
  def validate_table_heading_style(th):
    """
    Ensure consistency in rendering table headings across the application
    :param th: table heading to validate
    :return: None
    """
    assert 'helvetica' in th.value_of_css_property('font-family')
    assert th.value_of_css_property('font-size') == '14px'
    assert th.value_of_css_property('font-weight') == '700'
    assert th.value_of_css_property('line-height') == '20px'
    assert th.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert th.value_of_css_property('text-align') == 'left'
    assert th.value_of_css_property('vertical-align') == 'top'
    return None
