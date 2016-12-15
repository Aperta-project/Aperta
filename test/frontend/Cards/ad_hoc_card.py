#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import re
import time
import os
import random

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from Base.CustomException import ElementDoesNotExistAssertionError, ElementExistsAssertionError
from Base.PostgreSQL import PgSQL
from Base.Resources import docs, supporting_info_files, figures, pdfs
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

class AHCard(BaseCard):
  """
  Abstract class for Page Object Model of all types of Ad-Hoc Cards
  """
  def __init__(self, driver):
    super(AHCard, self).__init__(driver)

    # Locators - Instance members
    self._send_invitation_button = (By.CLASS_NAME, 'invitation-item-action-send')
    self._rescind_button = (By.CSS_SELECTOR, 'span.invite-rescind')
    self._recipient_field = (By.ID, 'invitation-recipient')
    self._compose_invitation_button = (By.CLASS_NAME, 'invitation-email-entry-button')
    self._edit_invite_heading = (By.CLASS_NAME, 'invitation-item-full-name')


  # POM Actions
  def invite(self, user):
    """
    This method invites the user that is passed as parameter
    :user: User to send the invitation
    :return: None
    """
    self._wait_for_element(self._get(self._recipient_field))
    self._get(self._recipient_field).send_keys(user['email'] + Keys.ENTER)
    self._get(self._compose_invitation_button).click()
    self._wait_for_element(self._get(self._edit_add_to_queue_btn))
    self._get(self._edit_add_to_queue_btn).click()
    self._wait_for_element(self._get(self._invite_send_invite_button))
    self._get(self._invite_send_invite_button).click()
    # The problem with this next item is that it requires the button to be clickable
    # when after send, the whole invite element is in a readonly state.
    try:
      self.check_for_flash_error()
    except NoSuchElementException:
      logging.error('Error fired on send invite.')
    self.click_close_button()

  def validate_response(self, invitee, response, reason='N/A', suggestions='N/A'):
    """
    This method invites the invitee that is passed as parameter, verifying
      the composed email. It then checks the table of invited users.
    :param invitee: user to invite specified as email, or, if in system, name,
        or username
    :param response: The response to the invitation
    :return void function
    """
    self._wait_for_element(self._get(self._invitee_listing))
    invitee_element = self._get(self._invitee_listing)
    pagefullname = False
    count = 0
    while not pagefullname:
      pagefullname = invitee_element.find_element(*self._invitee_full_name)
      count += 1
      time.sleep(.5)
      if count > 60:
        raise(StandardError, 'Full name not present, aborting')
    assert invitee['name'] in pagefullname.text
    status = invitee_element.find_element(*self._invitee_state)
    assert response in ['Accept', 'Decline'], response
    if response == 'Accept':
      assert 'Accepted' in status.text, status.text
    elif response == 'Decline':
      # Need to extend box to display text
      assert 'Decline' in status.text, status.text
      status.click()
      reason_suggestions = self._get(self._reason_suggestions).text
      reason_suggestions = self.normalize_spaces(reason_suggestions)
      assert reason in reason_suggestions, u'{0} not in {1}'.format(reason, reason_suggestions)
      assert suggestions in reason_suggestions, u'{0} not in {1}'.format(reason,
                                                                         reason_suggestions)

  def validate_card_elements_styles(self, user, short_doi):
    """
    Style check for the card
    :param user: User (AE or Reviewer) to send the invitation
    :param short_doi: Used to pass through to validate_common_elements_styles
    :return None
    """
    self.validate_common_elements_styles(short_doi)

    return None
