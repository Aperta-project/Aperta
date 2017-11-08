#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the early version card
"""
from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'jgray@plos.org'


class EarlyVersionCard(BaseCard):
  """
  Page Object Model for the Early Version Card
  """
  def __init__(self, driver):
    super(EarlyVersionCard, self).__init__(driver)

    # Locators - Instance members
    self._intro_text = (By.CSS_SELECTOR, 'div.card-content.card-content-view-text.ember-view > p')
    self._accman_consent_checkbox = (By.ID, 'check-box-early-posting--consent')
    self._accman_consent_label = (By.CSS_SELECTOR, '#check-box-early-posting--consent + span')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in the Early Version Card
    :return: void function
    """
    completed = self.completed_state()
    if completed:
      self.click_completion_button()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Early Version', card_title.text
    self.validate_overlay_card_title_style(card_title)
    intro_text = self._get(self._intro_text)
    self.validate_application_body_text(intro_text)
    assert intro_text.text == 'A copy of your uncorrected proof will be published online ahead ' \
                              'of the final version of your manuscript, should your manuscript ' \
                              'be accepted. If you do NOT consent to having an early version of ' \
                              'your paper published online, please uncheck the box below. Please ' \
                              'note, if you change your mind, you may choose to opt out up until ' \
                              'final acceptance.', intro_text.text
    opt_in_checkbox = self._get(self._accman_consent_checkbox)
    # APERTA-8500
    # self.validate_checkbox(opt_in_checkbox)
    assert opt_in_checkbox.is_selected(), 'Default value for EV should be selected, it isn\'t'
    opt_in_label = self._get(self._accman_consent_label)
    self.validate_checkbox_label(opt_in_label)

  def validate_state(self, selection_state=''):
    """
    Validate the Selection state in card view matches what is expected
    :param selection_state: The expected state of the card
    :return: void function
    """
    opt_in_checkbox = self._get(self._accman_consent_checkbox)
    assert selection_state in (True, False), 'Selection state can only be True or False. ' \
                                             'Supplied: {0}'.format(selection_state)
    if selection_state:
      try:
        opt_in_checkbox.is_selected()
      except:
        raise(ValueError, 'EV opt-in state expected to be True, '
                          'actual state: {0}'.format(not selection_state))
      return
    else:
      opt_in_checkbox.is_selected()
      try:
        assert opt_in_checkbox.is_selected()
      except AssertionError:
        return
      raise (ValueError, 'EV opt-in state expected to be False, '
                         'actual state: {0}'.format(not selection_state))