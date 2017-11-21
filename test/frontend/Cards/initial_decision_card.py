#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the initial decision card
"""
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class InitialDecisionCard(BaseCard):
  """
  Page Object Model for the Initial Decision Card
  """
  def __init__(self, driver):
    super(InitialDecisionCard, self).__init__(driver)

    # Locators - Instance members
    self._card_title = (By.TAG_NAME, 'h1')
    self._intro_text = (By.CSS_SELECTOR, 'div.letter-template >p')
    self._reject_radio_button = (By.CSS_SELECTOR, 'div.decision-selections > label > input')
    self._invite_radio_button = (By.CSS_SELECTOR, 'div.decision-selections > label + label > input')
    self._register_decision_btn = (By.CSS_SELECTOR, 'button.send-email-action')
    self._decision_alert = (By.CLASS_NAME, 'rescind-decision-container')
    self._decision_verdict = (By.CLASS_NAME, 'rescind-decision-verdict')
    self._rescind_button = (By.CLASS_NAME, 'rescind-decision-button')

   # POM Actions
  def validate_styles(self):
    """
    Validate styles for the Initial Decision Card
    """
    card_title = self._get(self._card_title)
    assert card_title.text == 'Initial Decision'
    self.validate_overlay_card_title_style(card_title)
    invite_radio = self._get(self._invite_radio_button)
    # This is totally stupid, but the initial click is not actually always registering only when using Marionette.
    # Adding a repeat click seems to solidify this. Hacky but true.
    invite_radio.click()
    invite_radio.click()
    self._wait_for_element(self._get(self._intro_text))
    intro_text = self._get(self._intro_text)
    # APERTA-8902
    # self.validate_application_body_text(intro_text)
    assert intro_text.text == 'Please write your decision letter in the area below:', \
        intro_text.text
    self._get(self._reject_radio_button)
    self._get(self._invite_radio_button)
    reg_dcn_btn = self._get(self._register_decision_btn)
    # disabling due to APERTA-6224
    # self.validate_primary_big_disabled_button_style(reg_dcn_btn)

  def execute_decision(self, choice='random'):
    """
    Randomly renders an initial decision of reject or invite, populates the decision letter
    :param choice: indicates whether to generate a choice randomly or to reject, else invite
    :return: selected choice
    """
    choices = ['reject', 'invite']
    logging.info('Initial Decision Choice is: {0}'.format(choice))
    if choice == 'random':
      choice = random.choice(choices)
      logging.info('Since choice was random, new choice is {0}'.format(choice))
    time.sleep(2)
    if choice == 'reject':
      reject_input = self._get(self._reject_radio_button)
      reject_input.click()
      time.sleep(1)
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
          self.get_rich_text_editor_instance('decision-letter-field')
      logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, content='Rejected')
    else:
      invite_input = self._get(self._invite_radio_button)
      invite_input.click()
      time.sleep(1)
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
          self.get_rich_text_editor_instance('decision-letter-field')
      logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, content='Invited')
    # Gratuitous verification
    dec_letter_text = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
    logging.info('Decision Letter Text is: {0}'.format(dec_letter_text))
    # Time to allow the button to change to clickable state
    time.sleep(1)
    self._get(self._register_decision_btn).click()
    time.sleep(5)
    # look for alert info
    decision_msg = self._get(self._decision_alert)
    if choice != 'reject':
      assert "A decision of Invite full submission has been registered." in \
          decision_msg.text, decision_msg.text
    else:
      assert "A final decision of Reject has been registered." in decision_msg.text, \
          decision_msg.text
    self.validate_static_notification_style(decision_msg)
    self.click_close_button()
    return choice
