#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class InviteAECard(BaseCard):
  """
  Page Object Model for Invite AE Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(InviteAECard, self).__init__(driver)

    #Locators - Instance members
    self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
    self._send_invitation_button = (By.CLASS_NAME, 'invite-editor-button')
    self._ae_input = (By.ID, 'invitation-recipient')


   #POM Actions
  def invite_ae(self, user):
    """
    This method invites the user that is passed as parameter
    :decision: User to send the invitation
    """
    time.sleep(.5)
    self._get(self._ae_input).send_keys(user['email'] + Keys.ENTER)
    self._get(self._ae_input).send_keys(Keys.ENTER)
    time.sleep(2)
    self._get(self._invite_editor_text).find_element_by_tag_name('button').click()
    time.sleep(2)
    self._get(self._send_invitation_button).click()
    #give some time to allow complete to check automatically,
    time.sleep(.5)
    self.click_completion_button()
    self.click_close_button()
