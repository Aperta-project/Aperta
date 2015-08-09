#!/usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage
from selenium.webdriver.common.keys import Keys
import time

__author__ = 'fcabrales'

class WorkflowPage(PlosPage):
  """
  Model workflow page
  """
  def __init__(self, driver):
    super(WorkflowPage, self).__init__(driver, '/')

    #Locators - Instance members
    self._click_editor_assignment_button = (By.XPATH, './/div[2]/div[2]/div/div[4]/div')
    # Reviewer Report button name = Reviewer Recommendation in the card's title
    self._reviewer_agreement_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Agreement')]")
    self._reviewer_recommendation_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Report')]")
    self._completed_review_button = (By.XPATH, 
      "//div[@class='column-content']/div/div//div[contains(., '[A] Completed Review')]")    
    self._assess_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Reviewer Report')]")
    self._editorial_decision_button = (By.XPATH, "//div[@class='column-content']/div/div//div[contains(., '[A] Editorial Decision')]")
    self._left_nav = (By.CSS_SELECTOR, 'div.navigation-toggle')
    self._hamburger_icon = (By.XPATH, 
      "//div[@class='navigation-toggle']/*[local-name() = 'svg']/*[local-name() = 'path']")
    self._left_nav_menu = (By.XPATH, ".//div/div/div[@class='navigation']")
    self._navigation_close = (By.XPATH, ".//div[@class='navigation']/div/span[@class='navigation-close']")
    self._navigation_title = (By.XPATH, ".//div[@class='navigation']/div")
    self._navigation_menu_line = (By.XPATH, ".//div[@class='navigation']/hr")
    self._editable_label = (By.XPATH, ".//div[@class='control-bar-inner-wrapper']/ul[2]/li/label")
    self._editable_checkbox = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li/label/input")
    self._recent_activity_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[2]/div/div/*[local-name() = 'svg']/*[local-name() = 'path']")
    self._recent_activity_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[2]/div/div[2]")
    self._discussions_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[3]/a/div/span[contains(@class, 'fa-comment')]")
    self._discussions_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[3]/a")
    self._manuscript_icon = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div/*[local-name() = 'svg']/*[local-name() = 'path']")
    self._manuscript_text = (By.XPATH, 
      ".//div[@class='control-bar-inner-wrapper']/ul[2]/li[4]/div/div[2]")
    self._column_header = (By.XPATH, 
      ".//div[contains(@class, 'column-header')]/div/h2")
    self._column_header_save = (By.XPATH, 
      ".//div[contains(@class, 'column-header')]/div/div/button[2]")
    self._column_header_cancel = (By.XPATH, 
      ".//div[contains(@class, 'column-header')]/div/div/button")
    self._add_card_button = (By.XPATH,
      ".//a[contains(@class, 'add-new-card-button')]")
    self._add_card_overlay = (By.XPATH,
      ".//div[@class='overlay-container']/div/div/h1")
    self._close_icon_overlay = (By.XPATH,
      ".//span[contains(@class, 'overlay-close-x')]")
    self._select_in_overlay = (By.XPATH,
      ".//div[contains(@class, 'select2-container')]/input")
    self._add_button_overlay = (By.XPATH,
      ".//div[@class='overlay-action-buttons']/button[1]")
    self._cancel_button_overlay = (By.XPATH,
      ".//div[@class='overlay-action-buttons']/button[2]")
    self._new_taks_overlay_cancel = (By.XPATH,
      ".//div[@class='overlay-main-work']/div/div/div[2]")
    self._new_taks_overlay_save = (By.XPATH,
      ".//div[@class='overlay-main-work']/div/div/div[1]")
    self._new_taks_overlay_plus = (By.XPATH,
      ".//span[@class='fa-plus']")
    self._new_taks_overlay_title = (By.XPATH,
      ".//header[@class='overlay-header']/h2/a")
    self._new_taks_overlay_close_top = (By.XPATH,
      ".//header[@class='overlay-header']/a")
    self._new_taks_overlay_discussion = (By.XPATH,
      ".//div[@class='overlay-discussion-board']/h2")
    self._new_taks_overlay_msg = (By.XPATH,
      ".//div[@class='overlay-discussion-board']/div/div/textarea")
    self._new_taks_overlay_msg_discussion_cancel = (By.XPATH,
      ".//div[@class='message-comment-buttons']/a")
    self._new_taks_overlay_msg_discussion_save = (By.XPATH,
      ".//div[@class='message-comment-buttons']/button")
    self._new_taks_overlay_following = (By.XPATH,
      ".//footer/div/div[2]/span")
    self._new_taks_overlay_comp_chkbx = (By.XPATH,
      ".//footer/div/div/div/input")
    self._new_taks_overlay_comp_chkbx_lbl = (By.XPATH,
      ".//footer/div/div/div/label")
    self._new_taks_overlay_close_bottom = (By.XPATH, ".//footer/div/a")

  #POM Actions

  def validate_initial_page_elements_styles(self):
    """ """
    # Validate menu elements (title and icon)
    hamburger_icon = self._get(self._hamburger_icon)
    assert hamburger_icon.get_attribute('d') == ('M4,10h24c1.104,0,2-0.896,2-2s-0.896-2-2-2H4C2.896,6,2,6.896,2,8S2.896,10,4,10z '
                'M28,14H4c-1.104,0-2,0.896-2,2  s0.896,2,2,2h24c1.104,0,2-0.896,2-2S29.104,14,28'
                ',14z M28,22H4c-1.104,0-2,0.896-2,2s0.896,2,2,2h24c1.104,0,2-0.896,2-2  S29.104,'
                '22,28,22z')
    left_nav = self._get(self._left_nav)
    assert left_nav.text == 'PLOS'
    assert left_nav.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert 'Cabin' in left_nav.value_of_css_property('font-family')
    assert left_nav.value_of_css_property('font-size') == '24px'
    assert left_nav.value_of_css_property('font-weight') == '700'
    assert left_nav.value_of_css_property('text-transform') == 'uppercase'
    left_nav_menu = self._get(self._left_nav_menu)
    assert left_nav_menu
    # 
    editable = self._get(self._editable_label)
    assert editable.text == 'EDITABLE'
    assert editable.value_of_css_property('font-size') == '10px'
    assert editable.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert editable.value_of_css_property('font-weight') == '700'
    assert 'Cabin' in editable.value_of_css_property('font-family')
    assert editable.value_of_css_property('text-transform') == 'uppercase'
    assert editable.value_of_css_property('line-height') == '20px'
    assert editable.value_of_css_property('text-align') == 'center'
    editable_checkbox = self._get(self._editable_checkbox)
    assert editable_checkbox.get_attribute('type') == 'checkbox'
    assert editable_checkbox.value_of_css_property('color') == 'rgba(60, 60, 60, 1)'
    assert editable_checkbox.value_of_css_property('font-size') == '10px'
    assert editable_checkbox.value_of_css_property('font-weight') == '700'
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
    assert 'Cabin' in recent_activity_text.value_of_css_property('font-family')
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
    column_header = self._get(self._column_header)
    assert column_header
    return self

  #def is_navigation_menu_visible(self):
  #  """ """
  #  self._get(self._click_editor_assignment_button)

  def click_editor_assignment_button(self):
    """Click editor assignment button"""
    self._get(self._click_editor_assignment_button).click()
    return self

  def get_assess_button(self):
    return self._get(self._assess_button)

  def click_reviewer_agreement_button(self):
    """Click reviewer agreement button"""
    self._get(self._reviewer_agreement_button).click()
    return self

  def click_completed_review_button(self):
    """Click completed review button"""
    self._get(self._completed_review_button).click()
    return self

  def click_reviewer_recommendation_button(self):
    """Click reviewer recommendation button"""
    self._get(self._reviewer_recommendation_button).click()
    return self

  def click_editorial_decision_button(self):
    """Click editorial decision button"""
    self._get(self._editorial_decision_button).click()
    return self

  def click_assess_button(self):
    """Click assess button"""
    self._get(self._assess_button).click()
    return self

  def click_left_nav(self):
    """Click left navigation"""
    self._get(self._left_nav).click()
    return self

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._sign_out_link).click()
    return self

  def click_close_navigation(self):
    """Click on the close icon to close left navigation bar"""
    self._get(self._navigation_close).click()
    return self

  #def get_column_header_(self):
  #  """ """
  #  return self._get(self._column_header).text

  def click_column_header(self):
    """Click on the first column header and returns the text"""
    column_header = self._get(self._column_header)
    column_header.click()
    return column_header.text

  def click_cancel_column_header(self):
    """ """
    self._get(self._column_header_cancel).click()
    return self

  def modify_column_header(self, title, blank=True):
    column_header = self._get(self._column_header)
    if blank:
      column_header.clear()
    column_header.send_keys(title)
    self._get(self._column_header_save).click()
    return self
  
  def click_add_new_card(self):
    """ """
    self._get(self._add_card_button).click()
    return self
  

  def check_overlay(self):
    """ """
    card_overlay = self._get(self._add_card_overlay)
    assert card_overlay.text == 'Pick the type of card to add'
    assert 'Cabin' in card_overlay.value_of_css_property('font-family')
    assert card_overlay.value_of_css_property('font-size') == '48px'
    assert card_overlay.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert card_overlay.value_of_css_property('font-weight') == '500'
    assert card_overlay.value_of_css_property('text-align') == 'center'
    close_icon_overlay = self._get(self._close_icon_overlay)
    assert close_icon_overlay.value_of_css_property('font-size') == '90px'
    assert 'Cabin' in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    select_task = self._get(self._select_in_overlay)
    assert 'Cabin' in select_task.value_of_css_property('font-family')
    assert select_task.value_of_css_property('font-size') == '14px'
    assert select_task.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    add_button_overlay = self._get(self._add_button_overlay)
    assert 'Cabin' in add_button_overlay.value_of_css_property('font-family')
    assert add_button_overlay.value_of_css_property('font-size') == '14px'
    assert add_button_overlay.value_of_css_property('color') == 'rgba(255, 255, 255, 1)'
    assert add_button_overlay.text == 'ADD'
    cancel_button_overlay = self._get(self._cancel_button_overlay)
    assert 'Cabin' in cancel_button_overlay.value_of_css_property('font-family')
    assert cancel_button_overlay.value_of_css_property('font-size') == '14px'
    assert cancel_button_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert cancel_button_overlay.value_of_css_property('text-align') == 'center'
    assert cancel_button_overlay.text == 'cancel'
    select_task.click()
    # NOTE: Must have at least one fixed item
    select_task.send_keys('Ad-hoc' + Keys.ENTER)
    self.click_add_new_card()
    time.sleep(10)
    # new page: isNewTask

    return self