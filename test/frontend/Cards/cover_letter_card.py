#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoAlertPresentException

from frontend.Cards.basecard import BaseCard
from Base.Resources import author

__author__ = 'sbassi@plos.org'

class CoverLetterCard(BaseCard):
  """
  Page Object Model for Authors Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(CoverLetterCard, self).__init__(driver)

   #POM Actions
  def click_task_completed_checkbox(self):
    """Click task completed checkbox"""
    self._get(self._click_task_completed).click()
    return self

  def click_close_button_bottom(self):
    """Click close button on bottom"""
    self._get(self._close_button_bottom).click()
    return self

  def validate_author_card_styles(self):
    pass

  def validate_author_card_action(self):
    pass

  def press_submit_btn(self):
    """Press sidebar submit button"""
    self._get(self._sidebar_submit).click()

  def confirm_submit_btn(self):
    """Press sidebar submit button"""
    self._get(self._submit_confirm).click()
