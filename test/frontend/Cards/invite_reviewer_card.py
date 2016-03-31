#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError, ErrorAlertThrownException
from frontend.Cards.basecard import BaseCard


__author__ = 'jgray@plos.org'

class InviteReviewerCard(BaseCard):
  """
  Page Object Model for Invite Reviewer Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(InviteEditorCard, self).__init__(driver)

    #Locators - Instance members
    self._field_label = (By.CSS_SELECTOR, 'div.invite-reviewers label')
    self._recipient_field = (By.ID, 'invitation-recipient')
    self._reviewer_suggester = (By.CSS_SELECTOR, 'div.auto-suggest')
    self._reviewer_suggestion_listing = (By.CSS_SELECTOR, 'div.auto-suggest-item')
    self._send_invitation_button = (By.CLASS_NAME, 'compose-invite-button')

    self._edit_invite_div = (By.CSS_SELECTOR, 'div.invite-reviewer-edit-invite')
    self._edit_invite_heading = (By.CSS_SELECTOR, 'h3.invite-to')
    self._edit_invite_textarea = (By.CSS_SELECTOR, 'div.taller-textarea')
    self._edit_invite_text_cancel = (By.CSS_SELECTOR, 'button.cancel')
    self._edit_invite_text_send_invite_button = (By.CSS_SELECTOR, 'button.invite-reviewer-button')

  # POM Actions
  def invite_reviewer(self, user):
    """
    This method invites the user that is passed as parameter
    :param user: user to invite specified as email, or, if in system, name, or username
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
