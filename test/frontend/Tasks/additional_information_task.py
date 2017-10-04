#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time
import os

from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask
from Base.Resources import figures

__author__ = 'sbassi@plos.org'


class AITask(BaseTask):
  """
  Page Object Model for Additional Information
  """

  def __init__(self, driver):
    super(AITask, self).__init__(driver)

    # Locators - Instance members
    self._questions = (By.CSS_SELECTOR, 'li.question')
    self._question1_child = (
        By.NAME, 'publishing_related_questions--published_elsewhere--taken_from_manuscripts')
    self._question1_file_input = (By.CLASS_NAME, 'add-new-attachment')
    self._question1_upload_button = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._uploaded_file = (By.CSS_SELECTOR, 'div.attachment-item')
    self._uploaded_file_link = (By.CSS_SELECTOR, 'a.file-link')
    self._uploaded_file_description = (By.NAME, 'attachment-caption')
    #2
    self._q2_title_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_title')
    self._q2_corresponding_author_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_author')
    self._q2_journal_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_journal')
    self._q2_handle_together_cb = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--handled_together')
   #3
    self._q3_previous_interactions_cb = (
        By.NAME, 'publishing_related_questions--previous_interactions_with_this_manuscript')
    self._q3_previous_interactions_input = (
        By.NAME, 'publishing_related_questions--previous_interactions_with_this_manuscript--submission_details')
    self._q3_presubmission_cb = (
        By.NAME, 'publishing_related_questions--presubmission_inquiry')
    self._q3_presubmission_input = (
        By.NAME, 'publishing_related_questions--presubmission_inquiry--submission_details')
    self._q3_other_journal_cb = (
        By.NAME, 'publishing_related_questions--other_journal_submission')
    self._q3_other_journal_input = (
        By.NAME, 'publishing_related_questions--other_journal_submission--submission_details')
    self._q3_previous_editor_cb = (
        By.NAME, 'publishing_related_questions--author_was_previous_journal_editor')
    #4
    self._q4_collection_name_input = (
      By.NAME, 'publishing_related_questions--intended_collection')
    # Version difference
    self._diff_removed = (By.CSS_SELECTOR, 'span.ember-view.text-diff .removed')
    self._diff_added = (By.CSS_SELECTOR, 'span.ember-view.text-diff .added')


  # POM Actions
  def complete_ai(self, data=None):
    """
    This method completes the task Additional Information
    :data: A dictionary with the answers to all questions
    """
    completed = self.completed_state()
    if completed:
      if data:  # must be in editable state to update data
        self.click_completion_button()
        time.sleep(.5)
      else:
        logging.info('Additional Information card is in completed state, aborting...')
        return None

    if not data:
      data = self.create_data()

    self.set_timeout(120)
    questions = self._gets(self._questions)
    question_1 = questions[0]
    question_2 = questions[1]
    question_3 = questions[2]
    question_4 = questions[3]

    q1ans = data['q1'] #random.choice(q1_answers)
    logging.debug('The answer to question 1 is {0}'.format(q1ans))
    if q1ans == 'Yes':
      # wait for the element to be attached to the DOM
      self._wait_for_element(questions[0].find_elements_by_tag_name('input')[0])
      questions[0].find_elements_by_tag_name('input')[0].click()
      q1ans_text = self._get(self._question1_child)
      q1ans_text.clear()
      q1ans_text.send_keys(data['q1_child_answer'])
      # Handles specifying an upload file
      q1_file_name = data['q1_child_file'][0]
      q1_file_description = data['q1_child_file'][1]
      if q1_file_name:
        uploaded_file_name = self.upload_file(file2upload=q1_file_name)
        time.sleep(3)
        logging.info(uploaded_file_name)
        self._wait_for_element(self._get(self._uploaded_file_link))
        time.sleep(.5)
        if q1_file_description:
          description_text_field = self._get(self._uploaded_file_description)
          description_text_field.send_keys(q1_file_description)
          time.sleep(.5)
    else:
      self._wait_for_element(questions[0].find_elements_by_tag_name('input')[1])
      questions[0].find_elements_by_tag_name('input')[1].click()

    self.scroll_element_into_view_below_toolbar(question_1)
    q2ans = data['q2']
    logging.debug('The answer to question 2 is {0}'.format(q2ans))
    if q2ans == 'Yes':
      # wait for the element to be attached to the DOM
      self._wait_for_element(questions[1].find_element_by_tag_name('input'))
      questions[1].find_element_by_tag_name('input').click()
      self._wait_for_element(self._get(self._q2_title_input))
      q2titleinput = self._get(self._q2_title_input)
      q2titleinput.send_keys(data['q2_child1_answer'])
      q2corrauthinput = self._get(self._q2_corresponding_author_input)
      q2corrauthinput.send_keys(data['q2_child2_answer'])
      q2journalinput = self._get(self._q2_journal_input)
      q2journalinput.send_keys(data['q2_child3_answer'])
      q2c4ans = data['q2_child4_answer']
      logging.debug('The answer to question 2, child 4 is {0}'.format(q2c4ans))
      if q2c4ans == '1':
        q2handletogether = self._get(self._q2_handle_together_cb)
        q2handletogether.click()
    else:
      self._wait_for_element(questions[1].find_elements_by_tag_name('input')[1])
      questions[1].find_elements_by_tag_name('input')[1].click()

    self.scroll_element_into_view_below_toolbar(question_2)
    q3ans = data['q3']
    logging.info('The answers to question 3 are {0}'.format(q3ans))
    if q3ans != [0, 0, 0, 0]:
      # wait for the element to be attached to the DOM
      time.sleep(2)
      checkboxes = questions[2].find_elements_by_tag_name('input')
      q3_inputs = []
      q3_inputs.append(self._q3_previous_interactions_input)
      q3_inputs.append(self._q3_presubmission_input)
      q3_inputs.append(self._q3_other_journal_input)
      self.set_timeout(5)
      for order, cbx in enumerate(q3ans):
        if (cbx == 1 and (not checkboxes[order].is_selected())\
                or (cbx == 0 and checkboxes[order].is_selected())):
          #time.sleep(2)
          try:
            checkboxes[order].click()
            #time.sleep(2)
          except WebDriverException:
            self.click_covered_element(checkboxes[order])
          time.sleep(2)
          if order!=3 and (cbx == 1) and 'q3_child_answer' in data:
            self._wait_for_element(self._get(q3_inputs[order]))
            try:
              q3cans = data['q3_child_answer'][order]
              collection_name = self._get(q3_inputs[order])
              collection_name.clear()
              collection_name.send_keys(q3cans)
            except IndexError:
              continue
      self.restore_timeout()
    self.scroll_element_into_view_below_toolbar(question_3)
    q4ans = data['q4']
    logging.debug('The answers to question 4 is {0}'.format(q4ans))
    if q4ans:
        collection_name = self._get(self._q4_collection_name_input)
        collection_name.clear()
        collection_name.send_keys(q4ans)

    self.scroll_element_into_view_below_toolbar(question_4)
    q5ans = data['q5']
    logging.debug('The answers to question 5 is {0}'.format(q5ans))
    if q5ans:
      time.sleep(1)
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
          self.get_rich_text_editor_instance('publishing_related_questions--short_title')
      logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
      self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q5ans)
      # Gratuitous verification
      q5_answer = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
      logging.info('Add\'l Info Q5 answer is: {0}'.format(q5_answer))

    manuscript_id = self._get(self._paper_sidebar_state_information)
    self.scroll_element_into_view_below_toolbar(manuscript_id)
    if not self.completed_state():
      self.click_completion_button()

    self.restore_timeout()

  def create_data(self):
     """
     This method creates data for the task Additional Information
     :data: A dictionary with the answers to all questions
     """
     data = {}
     q1_answers = ('Yes', 'No')
     q1_child_answer = 'Figure 1.2 - contains new data points'
     #q1_child_file = "os.path.join(os.getcwd(), 'frontend/assets/imgs/plos.gif'"
     q1_child_file = ('frontend/assets/imgs/plos.gif', '')  # file name, description
     q2_answers = ('Yes', 'No')
     q2_child1_answer = 'Submission Title'
     q2_child2_answer = 'Corresponding Author Name'
     q2_child3_answer = 'Journal Name'
     q2_child4_answers = (0, 1)
     q3_answers = ([0, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0], [0, 0, 1, 1],
                   [0, 1, 0, 0], [0, 1, 0, 1], [0, 1, 1, 0], [0, 1, 1, 1],
                   [1, 0, 0, 0], [1, 0, 0, 1], [1, 0, 1, 0], [1, 0, 1, 1],
                   [1, 1, 0, 0], [1, 1, 0, 1], [1, 1, 1, 0], [1, 1, 1, 1])
     q3_child1_answers = ('Manuscript Number #1 and Editor Name #1', '')
     q3_child2_answers = ('Manuscript Number #2 and Editor Name #2', '')
     q3_child3_answers = ('Manuscript Number #3 and Editor Name #3', '')
     q4_answers = ('CollectionName', '')
     q5_answers = ('ShortTitle',
                   'Alternate Short Title',
                   'A super long running head for this brilliant manuscript')
     data['q1'] = random.choice(q1_answers)
     data['q1_child_answer'] = q1_child_answer
     data['q2'] = random.choice(q2_answers)
     data['q2_child1_answer'] = q2_child1_answer
     data['q1_child_file'] = q1_child_file
     data['q2_child2_answer'] = q2_child2_answer
     data['q2_child3_answer'] = q2_child3_answer
     data['q2_child4_answer'] = random.choice(q2_child4_answers)
     data['q3'] = random.choice(q3_answers)
     data['q3_child_answer'] =[]
     data['q3_child_answer'].append(random.choice(q3_child1_answers))
     data['q3_child_answer'].append(random.choice(q3_child2_answers))
     data['q3_child_answer'].append(random.choice(q3_child3_answers))
     data['q4'] = random.choice(q4_answers)
     data['q5'] = random.choice(q5_answers)

     return data

  def upload_file(self, file2upload='random'):
    """
    Function to upload file for question # 1
    :param file2upload: The full path and filename to upload. A string.
    :return: filename of the uploaded file
    """
    current_path = os.getcwd()
    if file2upload == 'random':
      chosen_file = random.choice(figures)
      fn = os.path.join(current_path, chosen_file)
    else:
      chosen_file = file2upload
      fn = os.path.join(current_path, chosen_file)
    logging.info('Sending file for question # 1: {0}'.format(fn))
    time.sleep(1)
    input_selector = self._iget(self._question1_file_input)
    input_selector.send_keys(fn)
    file_name = fn.split('/')[-1]
    add_new_file2upload_btn = self._get(self._question1_upload_button)
    self.scroll_element_into_view_below_toolbar(add_new_file2upload_btn)
    # Wait until the uploaded file be loaded
    self._wait_for_element(self._get(self._uploaded_file))
    # Wait until the uploaded file link have the file name
    self._wait_for_text_be_present_in_element(
      self._uploaded_file_link, file_name)
    return file_name
