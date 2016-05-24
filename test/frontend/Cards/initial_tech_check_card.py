#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class ITCCard(BaseCard):
  """
  Page Object Model for the Initial Tech Check Card
  """
  def __init__(self, driver):
    super(ITCCard, self).__init__(driver)

    # Locators - Instance members
    #self._card_title = (By.TAG_NAME, 'h1')
    #self._intro_text = (By.TAG_NAME, 'p')
    self._h2_titles = (By.CSS_SELECTOR, 'div.checklist h2')
    self._h3_titles = (By.CSS_SELECTOR, 'div.checklist h3')
    self._send_changes = (By.CSS_SELECTOR, 'div.tech-check-email h3')
    self._send_changes_button = (By.CSS_SELECTOR, 'div.tech-check-email button')
    self._reject_radio_button = (By.XPATH, '//input[@value=\'reject\']')
    self._invite_radio_button = (By.XPATH, '//input[@value=\'invite_full_submission\']')
    self._decision_letter_textarea = (By.TAG_NAME, 'textarea')
    self._register_decision_btn = (By.XPATH, '//textarea/following-sibling::button')
    # TODO: Find out why class_name and tag_name locator not working here
    # self._register_decision_btn = (By.CLASS_NAME, 'button-primary')
    self._alert_info = (By.CLASS_NAME, 'alert-info')
    self._autogenerate_email = (By.ID, 'autogenerate-email')

    self._field_title = (By.CSS_SELECTOR, 'span.text-field-title')

    self._checkboxes = (By.CSS_SELECTOR, 'label.question-checkbox input')

   # POM Actions
  def validate_styles(self):
    """
    Validate styles for the Initial Tech Check Card
    :return: None
    """
    self.validate_common_elements_styles()
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Initial Tech Check'
    self.validate_application_title_style(card_title)
    time.sleep(1)
    # Check all h2 titles
    h2_titles = self._gets(self._h2_titles)
    h2 = [h2.text for h2 in h2_titles]
    assert h2 == [u'Submission Cards', u'Figures/Supporting Information',
        u'Open Rejects (previously rejected papers treated as new submissions)'], h2
    # get style
    for h2 in h2_titles:
        self.validate_application_h2_style(h2)
    h3_titles = self._gets(self._h3_titles)
    h3 = [h3.text for h3 in h3_titles]
    assert h3 == [u'Ethics Statement', u'Data Policy', u'Author List',
        u'Author Email Addresses', u'Authors Added/Removed', u'Competing Interests',
        u'Financial Disclosure Statement', u'Collections', u'Figures', u'Figure Captions',
        u'Cited Files Present', u'Response to Reviewers for Open Rejects'], h3
    for h3 in h3_titles:
        self.validate_application_h3_style(h3)
    send_changes = self._get(self._send_changes)
    assert send_changes.text == u'If there are issues the author needs to address, click '\
        'below to send changes to the author.', send_changes.text
    self.validate_application_h3_style(send_changes)
    send_changes_button = self._get(self._send_changes_button)
    assert send_changes_button.text == 'SEND CHANGES TO AUTHOR', send_changes_button.text
    #assert self.validate_green_on_green_button_style(send_changes_button)
    self.validate_primary_big_green_button_style(send_changes_button)

  def complete_card(self, data=None):
    """
    Complete the Production Metadata card using custom or random data
    :data: List with data to complete the card. If empty,
      will generate random data.
    :return: data used to complete the card
    """
    # Input data, close, open and check if it is saved 05/04/2016
    if not data:
      # generate random data
      data = []
      for x in range(16):
        data.append(random.choice([True, False]))
    print data
    for order, checkbox in enumerate(self._gets(self._checkboxes)):
      if data[order]:
        checkbox.click()
    send_changes_button = self._get(self._send_changes_button)
    send_changes_button.click()
    time.sleep(1)
    field_title = self._get(self._field_title)
    assert field_title.text == 'List all changes the author needs to make:', field_title.text
    # Dissabled due to APERTA-6954
    #self.validate_field_title_style(field_title)

    import pdb; pdb.set_trace()

    #print len(self._gets(self._checkboxes))


    publication_date = self._get(self._publication_date)

    send_changes_button.click()

    time.sleep(2)
    # autogenerate-email
    import pdb; pdb.set_trace()
    self._get(self._autogenerate_email).click()







    # Check all h3 titles
    intro_text = self._get(self._intro_text)
    self.validate_application_ptext(intro_text)
    assert intro_text.text == 'Please write your decision letter in the area below', intro_text.text
    self._get(self._reject_radio_button)
    self._get(self._invite_radio_button)
    self._get(self._decision_letter_textarea)
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
    decision_letter_input = self._get(self._decision_letter_textarea)
    logging.info('Initial Decision Choice is: {0}'.format(choice))
    if choice == 'random':
      choice = random.choice(choices)
      logging.info('Since choice was random, new choice is {0}'.format(choice))
    if choice == 'reject':
      reject_input = self._get(self._reject_radio_button)
      reject_input.click()
      time.sleep(1)
      decision_letter_input.send_keys('Rejected')
    else:
      invite_input = self._get(self._invite_radio_button)
      invite_input.click()
      time.sleep(1)
      decision_letter_input.send_keys('Invited')
    # Time to allow the button to change to clickable state
    time.sleep(1)
    self._get(self._register_decision_btn).click()
    time.sleep(5)
    # look for alert info
    alert_msg = self._get(self._alert_info)
    if choice != 'reject':
      assert "An initial decision of 'Invite full submission' decision has been made." in \
          alert_msg.text, alert_msg.text
    else:
      assert "An initial decision of 'Reject' decision has been made." in alert_msg.text, alert_msg.text
    self.click_close_button()
    time.sleep(.5)
    return choice
