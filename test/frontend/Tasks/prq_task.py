#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class PRQTask(BaseCard):
  """
  Page Object Model for Invite Editor Card
  Publishing Related Questions
  """
  def __init__(self, driver, url_suffix='/'):
    super(PRQTask, self).__init__(driver)

    #Locators - Instance members
    self._questions = (By.CSS_SELECTOR, 'li.question')

    #self._invite_input = (By.ID, 's2id_autogen1_search')
    self._invite_input = (By.CLASS_NAME, 'select2-focused')
    self._drop_down = (By.CLASS_NAME, 'select2-drop-active')
    self._invite_editor_text = (By.CLASS_NAME, 'invite-editor-text')
    self._send_invitation_button = (By.CLASS_NAME, 'invite-editor-button')


   #POM Actions
  def complete_prq(self, data=None):
    """
    This method completes XXXXXX
    :data: A dictionary with the answers to



    """
    #import pdb
    if not data:
      # Just complete with blank
      completed = base_task.completed_cb_is_selected()
      if not completed:
        self._get(base_task._completed_cb).click()
      task.click()
      time.sleep(1)
    else:
      # complete with data
      questions = self._gets(self._questions)
      # q1
      questions[0].find_element_by_tag_name('input').click()
      import pdb; pdb.set_trace()




    selector = self._get(self._email_selector)

    # click on the selector to open input box
    selector.find_element_by_tag_name('a').click()
    self._get(self._invite_input).send_keys(user['email'] + Keys.ENTER)
    self._get(self._invite_input).send_keys(Keys.ENTER)
    time.sleep(1)
    self._get(self._drop_down).find_element_by_tag_name('li').click()
    #self._get(self._drop_down).find_element_by_tag_name('li').click()
    time.sleep(1)
    self._get(self._invite_editor_text).find_element_by_tag_name('button').click()
    time.sleep(1)
    self._get(self._send_invitation_button).click()
    #give some time to allow complete to check automatically,
    time.sleep(.5)
    self.click_completed_checkbox()
    self.click_close_button()
    return self
