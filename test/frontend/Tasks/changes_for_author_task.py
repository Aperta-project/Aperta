#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
POM for the dynamically generated Changes for Author Card
"""
import time

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class ChangesForAuthorTask(BaseTask):
  """
  Page Object Model for Changes For Author task
  """

  def __init__(self, driver, url_suffix='/'):
    super(ChangesForAuthorTask, self).__init__(driver)

    #Locators - Instance members
    self._card_heading = (By.CSS_SELECTOR, 'div.task-main-content > h3')
    self._changes_requested_detail = (By.CSS_SELECTOR, 'p.preserve-line-breaks')
    self._these_changes_have_been_made_btn = (By.ID, 'submit-tech-fix')

  # POM Actions
  def validate_styles(self):
    """
    Validate styles in the Changes For Author Task
    """
    heading_text = self._get(self._card_heading)
    self.validate_application_h3_style(heading_text)
    assert heading_text.text == ('Please address the following changes so we can process your '
                                 'manuscript:'), heading_text.text
    changes_detail_p = self._get(self._changes_requested_detail)
    self.validate_application_ptext(changes_detail_p)

    changes_made_btn = self._get(self._these_changes_have_been_made_btn)
    assert changes_made_btn.text == "THESE CHANGES HAVE BEEN MADE"
    self.validate_primary_big_green_button_style(changes_made_btn)

  def complete_cfa_card(self):
    """
    Mark the changes for author card as having been addressed
    :return: void function
    """
    change_detail = self._get(self._changes_requested_detail)
    self._actions.move_to_element(change_detail).perform()
    changes_made_btn = self._get(self._these_changes_have_been_made_btn)
    changes_made_btn.click()
    time.sleep(1)

