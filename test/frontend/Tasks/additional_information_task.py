#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'


class AITask(BaseTask):
  """
  Page Object Model for Additional Information
  Note: This will be replaced by the Additional Information
  """

  def __init__(self, driver):
    super(AITask, self).__init__(driver)

    # Locators - Instance members
    self._questions = (By.CSS_SELECTOR, 'li.question')
    self._question1_child = (
        By.NAME, 'publishing_related_questions--published_elsewhere--taken_from_manuscripts')
    self._question1_file_input = (By.ID, 'add-new-attachment')
    self._question1_upload_button = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._q2_title_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_title')
    self._q2_corresponding_author_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_author')
    self._q2_journal_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_journal')
    self._q2_handle_together_cb = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--handled_together')

  # POM Actions
  def complete_ai(self):
    """
    This method completes the task Additional Information
    :data: A dictionary with the answers to all questions
    """
    data = {'q1':'No', 'q2':'No', 'q3': [0,0,0,0], 'q4':'', 'q5':''}
    q1_answers = ('Yes', 'No')
    q1_child_answer = 'Figure 1.2 - contains new data points'
    q1_child_file = "os.path.join(os.getcwd(), 'frontend/assets/imgs/plos.gif'"
    q2_answers = ('Yes', 'No')
    q2_child1_answer = 'Submission Title'
    q2_child2_answer = 'Corresponding Author Name'
    q2_child3_answer = 'Journal Name'
    q2_child4_answer = (0, 1)
    q3_answers = ([0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 0, 1, 1],
                  [0, 1, 0, 0], [0, 1, 0, 1], [0, 1, 1, 0], [0, 1, 1, 1],
                  [1, 0, 0, 0], [1, 0, 0, 1], [1, 0, 1, 0], [1, 0, 1, 1],
                  [1, 1, 0, 0], [1, 1, 0, 1], [1, 1, 1, 0], [1, 1, 1, 1])
    q3_child_answer = ('Manuscript Name and Editor Name', '')
    q4_answers = ('CollectionName', '')
    q5_answers = ('ShortTitle',
                  'Alternate Short Title',
                  'A super long running head for this brilliant manuscript')

    self.set_timeout(120)
    questions = self._gets(self._questions)
    question_2 = questions[1]
    question_3 = questions[2]
    question_4 = questions[3]
    q1ans = random.choice(q1_answers)
    logging.debug('The answer to question 1 is {0}'.format(q1ans))
    if q1ans == 'Yes':
      # wait for the element to be attached to the DOM
      time.sleep(2)
      questions[0].find_elements_by_tag_name('input')[0].click()
      time.sleep(2)
      questions[0].find_elements_by_tag_name('input')[2].send_keys(q1_child_answer)
      # TODO: Handles specifying an upload file
    else:
      time.sleep(1)
      questions[0].find_elements_by_tag_name('input')[1].click()

    q2ans = random.choice(q2_answers)
    logging.debug('The answer to question 2 is {0}'.format(q2ans))
    if q2ans == 'Yes':
      # wait for the element to be attached to the DOM
      time.sleep(2)
      questions[1].find_element_by_tag_name('input').click()
      time.sleep(2)
      q2titleinput = self._get(self._q2_title_input)
      q2titleinput.send_keys(q2_child1_answer)
      q2corrauthinput = self._get(self._q2_corresponding_author_input)
      q2corrauthinput.send_keys(q2_child2_answer)
      q2journalinput = self._get(self._q2_journal_input)
      q2journalinput.send_keys(q2_child3_answer)
      q2c4ans = random.choice(q2_child4_answer)
      logging.debug('The answer to question 2, child 4 is {0}'.format(q2c4ans))
      if q2c4ans == '1':
        q2handletogether = self._get(self._q2_handle_together_cb)
        q2handletogether.click()
    else:
      time.sleep(2)
      questions[1].find_elements_by_tag_name('input')[1].click()

    self.scroll_element_into_view_below_toolbar(question_2)
    q3ans = random.choice(q3_answers)
    logging.info('The answers to question 3 are {0}'.format(q3ans))
    if q3ans != [0, 0, 0, 0]:
      # wait for the element to be attached to the DOM
      time.sleep(2)
      checkboxes = questions[2].find_elements_by_tag_name('input')
      for order, cbx in enumerate(q3ans):
        if cbx == 1:
          checkboxes[order].click()
          q3cans = random.choice(q3_child_answer)
          try:
            # This is a rather brute force method, but, I don't have time for filigree here
            for i in range(order, 0, -1):
              questions[2].find_elements_by_tag_name('textarea')[i].send_keys(q3cans)
          except IndexError:
            continue

    self.scroll_element_into_view_below_toolbar(question_3)
    q4ans = random.choice(q4_answers)
    logging.debug('The answers to question 4 is {0}'.format(q4ans))
    if q4ans:
        time.sleep(1)
        questions[3].find_element_by_tag_name('input').send_keys(q4ans)

    self.scroll_element_into_view_below_toolbar(question_4)
    q5ans = random.choice(q5_answers)
    logging.debug('The answers to question 5 is {0}'.format(q5ans))
    if q5ans:
      time.sleep(1)
      questions[4].find_element_by_class_name('format-input-field').send_keys(q5ans)

    manuscript_id = self._get(self._paper_sidebar_state_information)
    self.scroll_element_into_view_below_toolbar(manuscript_id)
    if not self.completed_state():
      self.click_completion_button()

    self.restore_timeout()
