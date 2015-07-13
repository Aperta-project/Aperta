#! /usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage
import re

__author__ = 'fcabrales'

class HomePage(PlosPage):
  """
  Model an abstract base homepage page
  """
  def __init__(self, driver):
    super(HomePage, self).__init__(driver, '/')


    self.driver = driver
    #Locators - Instance members
    self._create_new_submission_button = (By.CSS_SELECTOR, 'button.button-primary.button--green')
    self._check_for_one_invite = (By.CSS_SELECTOR, 'h2.welcome-message')
    self._click_view_invitations_button = (By.XPATH, './/div[2]/div[5]/section[1]/button')
    self._click_yes_to_invitations_button = (By.XPATH, './/div[3]/div/div/ul/li/button[1]')
    self._click_no_to_invitations_button = (By.XPATH, './/div[3]/div/div/ul/li/button[2]')
    self._click_left_nav = (By.CSS_SELECTOR, 'div.navigation-toggle')
    self._click_sign_out_link = (By.XPATH, './/div/div[1]/a')
    self._check_for_one_invite_home = (By.XPATH, './/div[2]/div[5]/section[2]/h2')
    self._check_for_no_invites_home = (By.XPATH, './/div[2]/div[5]/section[2]/h2')
    self._check_error_assertion_failed = (By.CSS_SELECTOR, 'div.flash-message-content')

  #POM Actions
  def click_create_new_submision_button(self):
    """Click Create new submission button"""
    self._get(self._create_new_submission_button).click()
    return self

  def click_on_existing_manuscript_link(self, title):
    """Click on existing manuscript link"""
    self._click_existing_manuscript = (By.LINK_TEXT,title)
    self._get(self._click_existing_manuscript).click()
    return self

  def click_on_existing_manuscript_link_partial_title(self, partial_title):
    """Click on existing manuscript link using partial title"""
    self.driver.find_element_by_partial_link_text(partial_title).click()
    return self  

  def verify_editor_invites(self):
    """Verify invites for editor"""
    editorInvitation = '1'
    #Starting validation of editor invitation count...
    actualText = self._get(self._check_for_one_invite).text
    actualInvitationText = (re.search(r'\d+',actualText).group())
    self._validate_individual_text(actualInvitationText, editorInvitation)

  def verify_editor_invites_at_home(self):
    """Verify invites for editor at homepage"""
    editorInvitation = 'Hi, Hendrik W.. You have 1 manuscript.'
    #Starting validation of editor invitation count in homepage...
    actualText = self._get(self._check_for_one_invite_home).text
    self._validate_individual_text(actualText, editorInvitation)

  def verify_editor_no_invites_at_home(self):
    editorInvitation = 'Hi, Hendrik W.. You have no manuscripts.'
    print ('Starting validating editor has no invitation in homepage...')
    actualText = self._get(self._check_for_no_invites_home).text
    self._validate_individual_text(actualText, editorInvitation)

  def verify_error_assertion_failed_at_home(self):
    errorAssertFail = 'Error: Assertion Failed: calling set on destroyed object'
    print ('Starting validating error assertion failed at homepage...')
    actualText = self._get(self._check_error_assertion_failed).text
    self._validate_individual_text(actualText, errorAssertFail)

  def click_view_invitations_button(self):
    """Click on invitation button"""
    self._get(self._click_view_invitations_button).click()
    return self

  def click_yes_to_invitations(self):
    """Click yes button"""
    self._get(self._click_yes_to_invitations_button).click()
    return self

  def click_no_to_invitations(self):
    """Click no button"""
    self._get(self._click_no_to_invitations_button).click()
    return self

  def click_left_nav(self):
    """Click left navigation"""
    self._get(self._click_left_nav).click()
    return self

  def click_sign_out_link(self):
    """Click sign out link"""
    self._get(self._click_sign_out_link).click()
    return self

  def _validate_individual_text(self, actualText, expectedText):
    # Why a validation method in a PO?
    print ('Verifying text "%s":' % actualText,)
    assert actualText == expectedText
    print ('PRESENT',)


