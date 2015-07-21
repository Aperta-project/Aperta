#! /usr/bin/env python2

from selenium.webdriver.common.by import By
from Base.PlosPage import PlosPage
import uuid
from selenium.webdriver.common.keys import Keys

__author__ = 'fcabrales'


# TODO: Move page objects definition to a dictionary

class CreateANewSubmissionPage(PlosPage):
  """
  Model an abstract base create new submission page
  """
  def __init__(self, driver):
    super(CreateANewSubmissionPage, self).__init__(driver, '/')

    # check if element is present
    # self.assertTrue(self._get(By.CSS_SELECTOR, 'html.overlay-open'))

    #Locators - Instance members
    self._create_modal = (By.CSS_SELECTOR, 'html.overlay-open')    
    self._title_text_field = (By.CSS_SELECTOR, '#paper-short-title')
    self._first_select = (By.XPATH, "//div[contains(@class, 'form-group')]/div[1]")
    self._second_select = (By.XPATH, "//div[contains(@class, 'form-group')]/div[3]")
    self._select_journal_from_dropdown = (By.XPATH,
      '//div[contains(@class, "form-group")]/div[1]/a')
    self._select_type_from_dropdown = (By.XPATH,'//div[contains(@class, "form-group")]/div[3]/a')
    self._cancel_button = (By.CSS_SELECTOR, 'button-link.button--green')
    self._create_button = (By.CSS_SELECTOR, 
      'div.inner-content div.overlay-action-buttons button.button-primary.button--green')

    self._get(self._create_modal)

  #POM Actions
  def enter_title_field(self, title):
    """Enter title for the publication"""
    self._get(self._title_text_field).clear()
    self._get(self._title_text_field).send_keys(title)
    return self

  def click_create_button(self):
    """Click create button"""
    self._get(self._create_button).click()
    return self

  def click_cancel_button(self):
    """Click cancel button"""
    self._get(self._create_button).click()
    return self

  def select_journal(self, jtitle='Assess', jtype='Research'):
    """Select a journal with its type"""
    self._get(self._first_select).click()
    self._get(self._select_journal_from_dropdown).send_keys(jtitle + Keys.ENTER)
    self._get(self._second_select).click()
    self._get(self._select_type_from_dropdown).send_keys(jtype + Keys.ENTER)
    return self

  def title_generator(self):
    """Creates a new unique title"""
    return 'Hendrik %s'%uuid.uuid4()
