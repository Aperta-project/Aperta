#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time
import pdb

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class PRQTask(BaseTask):
  """
  Page Object Model for Published Related Questions
  Note: This will be replaced by the Additional Information
  """

  data = {'q1':'No', 'q2':'No', 'q3': [0,0,0,0], 'q4':'', 'q5':''}

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
  def complete_prq(self, data=data):
    """
    This method completes the task Publishing Related Data
    :data: A dictionary with the answers to all questions
    """
    #import pdb
    completed = self.completed_cb_is_selected()
    if not data:
      # Just complete with blank
      if not completed:
        self._get(self._completed_cb).click()
      #task.click()
      time.sleep(1)
    else:
      # complete with data
      questions = self._gets(self._questions)
      # q1
      if data['q1'] == 'Yes':
        # wait for the element to be attached to the DOM
        time.sleep(2)
        questions[0].find_elements_by_tag_name('input')[0].click()
      else:
        time.sleep(1)
        questions[0].find_elements_by_tag_name('input')[1].click()
      if data['q2'] == 'Yes':
        # wait for the element to be attached to the DOM
        time.sleep(2)
        questions[1].find_element_by_tag_name('input').click()
      else:
        time.sleep(2)
        questions[1].find_elements_by_tag_name('input')[1].click()
      if data['q3'] != [0,0,0,0]:
        # wait for the element to be attached to the DOM
        time.sleep(2)
        checkboxes = questions[2].find_elements_by_tag_name('input')
        for order, cbx in enumerate(data['q3']):
          if cbx == 1:
            checkboxes[order].click()
      if data['q4']:
        time.sleep(1)
        questions[3].find_element_by_tag_name('input').send_keys(data['q4'])
      if data['q5']:
        time.sleep(1)
        questions[4].find_element_by_class_name('format-input-field').send_keys(data['q5'])
      if not self.completed_cb_is_selected():
        self._get(self._completed_cb).click()
    return self
