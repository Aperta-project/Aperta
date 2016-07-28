#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Cards.basecard import BaseCard


__author__ = 'sbassi@plos.org'

class ReviewerReportCard(BaseCard):
  """
  Page Object Model for Reviewer Report Card
  This is a placeholder class since we are currently using this card as a task
  """
  def __init__(self, driver):
    super(ReviewerReportCard, self).__init__(driver)
    # Locators - Instance members

  # POM Actions
  def validate_card_elements_styles(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :return void function
    """
    self.validate_common_elements_styles(paper_id)

  def validate_reviewer_report(self):
    """
    Invites the reviewer that is passed as parameter, verifying the composed email. Makes
      function and style validations.
    :return void function
    """
