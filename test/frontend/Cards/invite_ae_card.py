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
    self._card_title = (By.TAG_NAME, 'h1')
    self._invite_text = (By.CSS_SELECTOR, 'div.invite-editors label')
    self._invite_box = (By.ID, 'invitation-recipient')
    self._compose_invite_button = (By.CLASS_NAME,'compose-invite-button')


   #POM Actions
  def invite_ae(self, user):
    """
    This method invites the user that is passed as parameter
    :user: User to send the invitation
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

  def check_style(self, user):
    """
    Style check for the card
    :user: User to send the invitation
    """
    self.validate_common_elements_styles()
    card_title = self._get(self._card_title)
    assert card_title.text == 'Invite Academic Editor'
    self.validate_application_title_style(card_title)
    invite_text = self._get(self._invite_text)
    assert invite_text.text == 'Academic Editor'
    self.validate_label_style(invite_text)
    ae_input = self._get(self._invite_box)
    assert ae_input.get_attribute('placeholder') == 'Invite Academic Editor by name or email' ,\
        ae_input.get_attribute('placeholder')
    # Button
    btn = self._get(self._compose_invite_button)
    assert btn.text == 'COMPOSE INVITE'
    # Check disabled button
    # Style validation on disabled button is commented out due to APERTA-6768
    # self.validate_primary_big_disabled_button_style(btn)
    # Enable button to check style
    ae_input.send_keys(user['email'] + Keys.ENTER)
    ae_input.send_keys(Keys.ENTER)
    time.sleep(.5)
    self.validate_primary_big_green_button_style(btn)
    ae_input.clear()
    return None
