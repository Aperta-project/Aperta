#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By

from .authenticated_page import AuthenticatedPage, APPLICATION_TYPEFACE
from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Cards.basecard import BaseCard
from frontend.Cards.initial_decision_card import InitialDecisionCard
from frontend.Cards.register_decision_card import RegisterDecisionCard

__author__ = 'achoe@plos.org'


class CorrespondenceHistory(AuthenticatedPage):
  """
  Model correspondence history page
  """
  def __init__(self, driver):
    super(CorrespondenceHistory, self).__init__(driver, '/')

    # Locators - instance members
    self._correspondence_table = (By.CSS_SELECTOR, '#correspondence-history table.table-hover')
    self._correspondence_item_row = (By.CSS_SELECTOR, '#correspondence-history table.table-hover tbody tr')

    # Individual Correspondence Record modal
    self._correspondence_modal_date_sent = (By.CLASS_NAME, 'correspondence-date')
    self._correspondence_modal_from = (By.CLASS_NAME, 'correspondence-sender')
    self._correspondence_modal_to = (By.CLASS_NAME, 'correspondence-recipient')
    self._correspondence_modal_subject = (By.CLASS_NAME, 'correspondence-subject')
    self._correspondence_modal_email_body = (By.TAG_NAME, 'iframe')

    # Co-author confirmation specific elements
    self._authorship_list = (By.ID, 'author-list')
    self._authorship_confirm_button = (By.CSS_SELECTOR, 'table.btn table')
    self._authorship_refute_link = (By.CSS_SELECTOR, '#author-list ~ p')



  # POM Actions
  def page_ready(self):
    """
    A simple method to validate the complete load of the correspondence history page prior to starting
    testing of that page.
    return: Void function
    """
    self._wait_for_element(self._get(self._correspondence_table))

  def validate_co_author_confirmation_email(self):
    """
    Validates the metadata and contents of the co-author confirmation email
    return: Void function
    """
    correspondence_items = self._gets(self._correspondence_item_row)
    # At the point in which this method is called, the co-author confirmation email
    # should be the first item in the correspondence history, since it will be the
    # most recent email sent for this paper from Aperta.
    co_author_confirmation_correspondence = correspondence_items[0]
    correspondence_link = co_author_confirmation_correspondence.find_element_by_tag_name('a')
    assert correspondence_link.text.strip() == 'Authorship Confirmation of Manuscript Submitted to PLOS Biology', correspondence_link.text

    correspondence_link.click()
    correspondence_subject = self._get(self._correspondence_modal_subject)
    assert correspondence_subject.text == correspondence_link.text.strip(), '{0} != {1}'.format(correspondence_subject.text, correspondence_link.text.strip())

    # Validates that the email has confirm authorship and refute authorship buttons
    iframe = self._get(self._correspondence_modal_email_body)
    self.traverse_to_frame(iframe)
    confirm_authorship_btn = self._get(self._authorship_confirm_button)
    assert 'Confirm Authorship' in confirm_authorship_btn.text

    refute_link = self._get(self._authorship_refute_link)
    assert 'Reply to this email to refute authorship' in refute_link.text
