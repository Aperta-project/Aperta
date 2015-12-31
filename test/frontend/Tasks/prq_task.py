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
  Page Object Model for Invite Editor Card
  Publishing Related Questions
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
    This method completes XXXXXX
    :data: A dictionary with the answers to all questions
    """
    #import pdb
    completed = self.completed_cb_is_selected()
    if not data:
      print 44
      # Just complete with blank
      if not completed:
        self._get(self._completed_cb).click()
      #task.click()
      time.sleep(1)
    else:
      print 51
      pdb.set_trace()
      # complete with data
      questions = self._gets(self._questions)
      # q1
      if data['q1'] == 'Yes':
        questions[0].find_element_by_tag_name('input').click()
      if data['q2'] == 'Yes':
        questions[1].find_element_by_tag_name('input').click()
      if data['q3'] != [0,0,0,0]:
        # not implemented
        pass
      if data['q4']:
        # Not implemented
        pass
        #questions[1].find_element_by_tag_name('input').click()
        #questions[1].find_element_by_tag_name('input').click()
      if data['q5']:
        # Not implemented
        pass
        #questions[1].find_element_by_tag_name('input').click()
      completed = self.completed_cb_is_selected()
      self._get(self._completed_cb).click()
      #task.click()

    return self
