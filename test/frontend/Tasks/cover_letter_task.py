#!/usr/bin/env python2
# -*- coding: utf-8 -*-
from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'ivieira@plos.org'


class CoverLetterTask(BaseTask):
  """
  Page Object Model for Authors Task
  """
  def __init__(self, driver):
    super(CoverLetterTask, self).__init__(driver)

    # Locators - Instance members
    card_body_base_locator = '.cover-letter-task .task-disclosure-body .edit-cover-letter '
    self._instructions_text_first_p = (By.CSS_SELECTOR, card_body_base_locator + '> p:first-of-type')
    self._instructions_text_last_p = (By.CSS_SELECTOR, card_body_base_locator + '> p:last-of-type')
    self._instructions_text_questions_ul = (By.CSS_SELECTOR, card_body_base_locator + '> ul')
    self._form_textarea = (By.CLASS_NAME, 'cover-letter-field')
    self._form_attach_file_button = (By.CSS_SELECTOR, card_body_base_locator + '.attachment-manager .fileinput-button')
    self._task_done_button = (By.CSS_SELECTOR, card_body_base_locator + 'button.task-completed')

  def validate_cover_letter_task_styles(self):
    # Assert instructions text styling
    instructions_first_p = self._get(self._instructions_text_first_p)
    instructions_questions_ul = self._get(self._instructions_text_questions_ul)
    instructions_questions = instructions_questions_ul.find_elements_by_tag_name('li')
    instructions_last_p = self._get(self._instructions_text_last_p)

    assert instructions_first_p.text == 'To be of most use to editors, we suggest your letter could address the ' \
                                        'following questions:', instructions_first_p.text
    assert instructions_last_p.text == 'In your cover letter, please list any scientists whom you request be excluded ' \
                                       'from the assessment process along with a justification. You may also suggest ' \
                                       'experts appropriate to be considered as Academic Editors for your manuscript. ' \
                                       'Please be aware that your cover letter may be seen by members of the ' \
                                       'Editorial Board. For Research articles, if our initial assessment is ' \
                                       'positive, we will request further information, including Reviewer Candidates ' \
                                       'and Competing Interests. For other submission types, if the Reviewer ' \
                                       'Candidate and Competing Interests cards are already visible to you, ' \
                                       'please complete them now with the relevant information.', instructions_last_p.text

    self.validate_application_ptext(instructions_first_p)
    self.validate_application_ptext(instructions_last_p)

    expected_instructions_questions = [
      'What is the scientific question you are addressing?',
      'What is the key finding that answers this question?',
      'What is the nature of the evidence you provide in support of your conclusion?',
      'What are the three most recently published articles that are relevant to this question?',
      'What significance do your results have for the field?',
      'What significance do your results have for the broader community (of biologists and/or the public)?',
      'What other novel findings do you present?',
      'Is there additional information that we should take into account?'
    ]

    assert len(expected_instructions_questions) == len(instructions_questions), str(len(expected_instructions_questions))

    for i, question in enumerate(instructions_questions):
      assert question.text == expected_instructions_questions[i], question.text
      self.validate_application_ptext(question)

    # Assert form styling
    textarea = self._get(self._form_textarea)
    attach_file_button = self._get(self._form_attach_file_button)

    assert textarea.get_attribute('placeholder') == 'Please type or paste your cover letter into this text field, or attach a file below', textarea.placeholder
    # APERTA-8903
    # self.validate_textarea_style(textarea)

    assert attach_file_button.text == 'ATTACH FILE', attach_file_button.text
    self.validate_secondary_small_green_button_task_style(attach_file_button)

  def validate_styles(self):
    self.validate_cover_letter_task_styles()
    self.validate_common_elements_styles()
    return self
