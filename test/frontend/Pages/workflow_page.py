#!/usr/bin/env python2

import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from authenticated_page import AuthenticatedPage, application_typeface


__author__ = 'sbassi@plos.org'


class WorkflowPage(AuthenticatedPage):
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
    self._first_column = (By.XPATH,
      ".//div[@class='column-content']/div")
    self._first_column_cards = (By.CSS_SELECTOR, 'div.card')
    # Note: Not used due to not reaching this menu from automation
    self._remove_confirmation_title = (By.XPATH,
        ".//div[contains(@class, 'delete-card-title')]/h1")
    self._remove_confirmation_subtitle = (By.XPATH,
        ".//div[contains(@class, 'delete-card-title')]/h2")
    self._remove_yes_button = (By.XPATH,
        ".//div[contains(@class, 'delete-card-action-buttons')]/div/button")
    self._remove_cancel_button = (By.XPATH,
        ".//div[contains(@class, 'delete-card-action-buttons')]/div[2]/button")
    # End of not used elements

  #POM Actions


  def validate_initial_page_elements_styles(self):
    """ """
    # Validate menu elements (title and icon)
    # https://www.pivotaltracker.com/story/show/103343910
    # https://www.pivotaltracker.com/story/show/104018188
    self.validate_closed_lef_nav()
    assert self._get(self._nav_menu)
    # Right menu items
    # https://www.pivotaltracker.com/story/show/103343910
    # https://www.pivotaltracker.com/story/show/104018188
    self.validate_wf_top_elements()
    assert self._get(self._column_header)

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

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._sign_out_link).click()
    return self

  def click_close_navigation(self):
    """Click on the close icon to close left navigation bar"""
    self._get(self._nav_close).click()
    return self

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
    """Click on the add new card button"""
    self._get(self._add_card_button).click()
    return self


  def check_overlay(self):
    """Check CSS properties of the overlay that appears when the user click on add new card"""
    card_overlay = self._get(self._add_card_overlay)
    assert card_overlay.text == 'Pick the type of card to add'
    #self.validate_application_h1_style(card_overlay)
    assert card_overlay.value_of_css_property('text-align') == 'center'
    close_icon_overlay = self._get(self._close_icon_overlay)
    # TODO: Change following line after bug #102078080 is solved
    assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
    assert application_typeface in close_icon_overlay.value_of_css_property('font-family')
    assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    select_task = self._get(self._select_in_overlay)
    assert application_typeface in select_task.value_of_css_property('font-family')
    assert select_task.value_of_css_property('font-size') == '14px'
    assert select_task.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    add_button_overlay = self._get(self._add_button_overlay)
    self.validate_primary_big_green_button_style(add_button_overlay)
    assert add_button_overlay.text == 'ADD'
    cancel_button_overlay = self._get(self._cancel_button_overlay)
    assert application_typeface in cancel_button_overlay.value_of_css_property('font-family')
    assert cancel_button_overlay.value_of_css_property('font-size') == '14px'
    assert cancel_button_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert cancel_button_overlay.value_of_css_property('text-align') == 'center'
    assert cancel_button_overlay.text == 'cancel'
    return self

  def check_new_tasks_overlay(self):
    """On the add new task overlay, select a card"""
    select_task = self._get(self._select_in_overlay)
    select_task.click()
    # NOTE: Must have at least one fixed item
    select_task.send_keys('Ad-hoc' + Keys.ENTER)
    self._get(self._add_button_overlay).click()
    time.sleep(2)
    return self

  def count_cards_first_column(self):
    """Count the cards in the first column"""
    return len(self._gets(self._first_column_cards))

  def remove_last_task(self):
    """
    Remove the last task from the first column
    This test the removal process and is used for housekeeping
    """
    cards = self._gets(self._first_column_cards)
    last_card = cards[-1]
    # TODO: Find how to reach delete screen
    remove = last_card.find_element_by_xpath('//div/span')
    remove.click()
    time.sleep(10)
    return self

  def validate_confirm_delete_styles(self):
    """
    Styles validation for delete card
    This is not used until finding a way to automate reaching this place
    """
    remove_title = self._get(self._remove_confirmation_title)
    assert remove_title.text == "You're about to delete this card forever."
    self.validate_application_h1_style(remove_title)
    remove_subtitle = self._get(self._remove_confirmation_subtitle)
    assert remove_subtitle.text == "Are you sure?"
    assert remove_subtitle.value_of_css_property('color') == 'rgba(51, 51, 51, 1)'
    assert application_typeface in remove_subtitle.value_of_css_property('font-family')
    assert remove_subtitle.value_of_css_property('font-size') == '30px'
    assert remove_subtitle.value_of_css_property('font-weight') == '500'
    remove_yes = self._get(self._remove_confirmation_title)
    self.validate_green_backed_button_style(remove_yes)
    assert remove_yes.text == "Yes, Delete this Card"
    remove_cancel = self._get(self._remove_confirmation_subtitle)
    assert remove_cancel.text == "cancel"
    assert remove_cancel.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
    assert application_typeface in remove_cancel.value_of_css_property('font-family')
    assert remove_cancel.value_of_css_property('font-size') == '14px'
    return self
