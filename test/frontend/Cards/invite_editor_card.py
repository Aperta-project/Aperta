#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class InviteEditorCard(BaseCard):
  """
  Page Object Model for Invite Editor Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(InviteEditorCard, self).__init__(driver)

    #Locators - Instance members
    self._email_selector = (By.CLASS_NAME, 'select2-container')
    #self._invite_input = (By.CLASS_NAME, 'select2-focused')
    self._invite_input = (By.CLASS_NAME, 'select2-search')
    self._drop_down = (By.CLASS_NAME, 'select2-drop-active')
    self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
    self._send_invitation_button = (By.CLASS_NAME, 'invite-editor-button')


   #POM Actions
  def invite_editor(self, user):
    """
    This method invites the user that is passed as parameter
    :decision: User to send the invitation
    """
    time.sleep(.5)
    selector = self._get(self._email_selector)
    # click on the selector to open input box
    selector.find_element_by_tag_name('a').click()
    time.sleep(2)
    self._get(self._invite_input).send_keys(user['email'] + Keys.ENTER)
    self._get(self._invite_input).send_keys(Keys.ENTER)
    time.sleep(2)
    self._get(self._drop_down).find_element_by_tag_name('li').click()
    time.sleep(2)
    self._get(self._invite_editor_text).find_element_by_tag_name('button').click()
    time.sleep(2)
    self._get(self._send_invitation_button).click()
    #give some time to allow complete to check automatically,
    time.sleep(.5)
    self.click_completed_checkbox()
    self.click_close_button()

    #self._get((By.CLASS_NAME, 'select2-search'))
