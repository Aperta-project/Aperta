#!/usr/bin/env python
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
    self._question1_file_input = (By.CLASS_NAME, 'add-new-attachment')
    self._question1_upload_button = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._uploaded_file = (By.CSS_SELECTOR, 'div.attachment-item')
    self._uploaded_file_link = (By.CSS_SELECTOR, 'a.file-link')
    self._uploaded_file_description = (By.NAME, 'attachment-caption')
    self._q1_data_editor = 'publishing_related_questions--published_elsewhere--taken_from_manuscripts'
    #2
    self._q2_title_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_title')
    self._q2_corresponding_author_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_author')
    self._q2_journal_input = (
        By.NAME, 'publishing_related_questions--submitted_in_conjunction--corresponding_journal')
    self._q2_handle_together_cb = (
         By.ID, 'check-box-publishing_related_questions--submitted_in_conjunction--handled_together')
    self._q2_data_editor = 'publishing_related_questions--submitted_in_conjunction--corresponding_title'
   #3
    self._q3_previous_interactions_cb = (
        By.ID, 'check-box-publishing_related_questions--previous_interactions_with_this_manuscript')
    self._q3_presubmission_cb = (
        By.ID, 'check-box-publishing_related_questions--presubmission_inquiry')
    self._q3_other_journal_cb = (
        By.ID, 'check-box-publishing_related_questions--other_journal_submission')
    self._q3_previous_editor_cb = (
        By.ID, 'check-box-publishing_related_questions--author_was_previous_journal_editor')
    #5
    self._q5_data_editor = 'publishing_related_questions--short_title'
    # Version difference
    self._diff_removed = (By.CSS_SELECTOR, 'span.ember-view.text-diff .removed')
    self._diff_added = (By.CSS_SELECTOR, 'span.ember-view.text-diff .added')


  # POM Actions
  def complete_ai(self, data=None):
    """
    This method completes the task Additional Information
    :data: A dictionary with the answers to all questions
    """

    if not data:
      data = self.create_data()

    self.set_timeout(120)
    questions = self._gets(self._questions)
    question_1 = questions[0]
    question_2 = questions[1]
    question_3 = questions[2]
    question_4 = questions[3]

    q1ans = data['q1']
    logging.debug('The answer to question 1 is {0}'.format(q1ans))
    if q1ans == 'Yes':
      self._wait_for_element(questions[0].find_element_by_tag_name('input'))
      questions[0].find_elements_by_tag_name('input')[0].click()

      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance(self._q1_data_editor)
      self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, data['q1_child_answer'])

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

    # Question #2
    self.scroll_element_into_view_below_toolbar(question_1)
    q2ans = data['q2']
    logging.debug('The answer to question 2 is {0}'.format(q2ans))
    if q2ans == 'Yes':
      self._wait_for_element(questions[1].find_element_by_tag_name('input')) # radio button
      questions[1].find_element_by_tag_name('input').click()
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance(self._q2_data_editor)
      logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
      self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, data['q2_child1_answer'])

      # there are no specific attributes for simple text field, using relative locator
      # having tag name 'input' and class 'form-control'
      self._wait_for_element(question_2.find_element_by_css_selector('input.form-control'))

      input_fields = question_2.find_elements_by_css_selector('input.form-control')
      if data['q2_child2_answer']:
        self.send_content_to_text_field(input_fields[0], data['q2_child2_answer'])
      if data['q2_child3_answer']:
        self.send_content_to_text_field(input_fields[1], data['q2_child3_answer'])

      # question 2 -> child 4: check box
      q2_handle_together = self._get(self._q2_handle_together_cb)
      q2c4ans = data['q2_child4_answer']
      logging.debug('The answer to question 2, child 4 is {0}'.format(q2c4ans))
      self.select_new_checkbox_value(q2_handle_together, q2c4ans)

    else:
      self._wait_for_element(questions[1].find_elements_by_tag_name('input')[1])
      questions[1].find_elements_by_tag_name('input')[1].click()

    # Question #3
    self.scroll_element_into_view_below_toolbar(question_2)
    q3ans = data['q3']
    logging.info('The answers to question 3 are {0}'.format(q3ans))
    if q3ans != [0, 0, 0, 0]:
      # check boxes parents to find input field
      checkboxes_parents = question_3.find_elements_by_css_selector('.card-content-check-box')
      # check boxes
      checkboxes = question_3.find_elements_by_css_selector('.card-content-check-box .checkbox input')
      self.set_timeout(5)
      for order, cbx in enumerate(q3ans):
        self.select_new_checkbox_value(checkboxes[order], cbx)
        if order != 3 and (cbx == 1) and 'q3_child_answer' in data:
          self._wait_for_element(checkboxes_parents[order].find_element_by_css_selector('input.form-control'))
          try:
            self.send_content_to_text_field(
                    checkboxes_parents[order].find_element_by_css_selector('input.form-control'),
                    data['q3_child_answer'][order])
          except IndexError:
            continue
      self.restore_timeout()
    self.scroll_element_into_view_below_toolbar(question_3)

    # Question #4
    q4ans = data['q4']
    logging.debug('The answers to question 4 is {0}'.format(q4ans))
    if q4ans:
      self.send_content_to_text_field(question_4.find_element_by_css_selector('input.form-control'), q4ans)

    # Question #5
    self.scroll_element_into_view_below_toolbar(question_4)
    q5ans = data['q5']
    logging.debug('The answers to question 5 is {0}'.format(q5ans))
    if q5ans:
      tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
        self.get_rich_text_editor_instance(self._q5_data_editor)
      self.tmce_clear_rich_text(tinymce_editor_instance_iframe)
      self.tmce_set_rich_text(tinymce_editor_instance_iframe, q5ans)
      logging.info('Add\'l Info Q5 answer is: {0}'.format(q5ans))

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
     q1_child_file = ('frontend/assets/imgs/plos.gif', 'Picture')  # file name, description
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

  def is_task_editable(self):
    """
    Check if Additional information task is editable
    :return: True if task is ready to edit and False if it is not
    """
    questions = self._gets(self._questions)
    self._wait_for_element(questions[0].find_element_by_tag_name('input'))
    first_input = questions[0].find_element_by_tag_name('input')
    return first_input.is_enabled()

  def send_content_to_text_field(self, input_field, text2send):
    """
    Sending content to text field
    :param nainput_field: text field, webElement
    :param text2send: text to send
    :return: None
    """
    self._wait_for_element(input_field)
    input_field.clear()
    input_field.send_keys(text2send)

  def select_new_checkbox_value(self, checkbox_element, new_value):
    """
    This method clicks on checkbox if new value is different from the old one
    :param checkbox_element: check box webElement
    :param new_value: new value for checkbox: 0, 1, '0', '1'
    :return: None
    """
    if (int(new_value) != checkbox_element.is_selected()):
      try:
        checkbox_element.click()
      except WebDriverException:
        self.click_covered_element(checkbox_element)
