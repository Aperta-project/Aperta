#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import hashlib
import os
import urllib

import time
from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'ivieira@plos.org'


class CoverLetterCard(BaseCard):
  """
  Page Object Model for Cover Letter Card
  """

  def __init__(self, driver, url_suffix='/'):
    super(CoverLetterCard, self).__init__(driver)
    self._title = (By.CLASS_NAME, 'overlay-body-title')
    self._instructions_text_first_p = (
    By.CSS_SELECTOR, '.edit-cover-letter > p:first-of-type')
    self._instructions_text_last_p = (
    By.CSS_SELECTOR, '.edit-cover-letter > p:last-of-type')
    self._instructions_text_questions_ul = (
    By.CSS_SELECTOR, '.edit-cover-letter > ul')
    self._cover_letter_textarea = (By.CLASS_NAME, 'cover-letter-field')
    self._uploaded_attachment_item_link = (By.CSS_SELECTOR,
                                           '.edit-cover-letter .attachment-manager .attachment-item a.file-link')

  def validate_styles(self):
    """
    validate_styles: Validates the elements, styles and texts for the cover letter card
    :return: void function
    """
    # Assert card title style
    card_title = self._get(self._title)
    expected_card_title = 'Cover Letter'

    assert card_title.text == expected_card_title, 'The card title: {0} is not the expected: {1}'.format(
      card_title.text, expected_card_title)
    self.validate_application_title_style(card_title)

    # Assert instructions text styling
    instructions_first_p = self._get(self._instructions_text_first_p)
    instructions_questions_ul = self._get(self._instructions_text_questions_ul)
    instructions_questions = instructions_questions_ul.find_elements_by_tag_name(
      'li')
    instructions_last_p = self._get(self._instructions_text_last_p)

    expected_instructions_first_p = 'To be of most use to editors, we suggest your letter could address the following questions:'
    assert instructions_first_p.text == expected_instructions_first_p, 'The instructions text first paragraph: {0} is not the expected: {1}'.format(
      instructions_first_p.text, expected_instructions_first_p)

    expected_instructions_last_p = 'In your cover letter, please list any scientists whom you request be excluded ' \
                                   'from the assessment process along with a justification. You may also suggest ' \
                                   'experts appropriate to be considered as Academic Editors for your manuscript. ' \
                                   'Please be aware that your cover letter may be seen by members of the ' \
                                   'Editorial Board. For Research articles, if our initial assessment is ' \
                                   'positive, we will request further information, including Reviewer Candidates ' \
                                   'and Competing Interests. For other submission types, if the Reviewer ' \
                                   'Candidate and Competing Interests cards are already visible to you, ' \
                                   'please complete them now with the relevant information.'
    assert instructions_last_p.text == expected_instructions_last_p, 'The instructions text last paragraph: {0} is not the expected: {1}'.format(
      instructions_last_p.text, expected_instructions_last_p)

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

    for i, question in enumerate(instructions_questions):
      assert question.text == expected_instructions_questions[
        i], 'The instructions question {0}: {1} is not the expected: {2}'.format(
        i, question.text,
        expected_instructions_questions[i])
      self.validate_application_ptext(question)

    # Validate textarea state
    textarea = self._get(self._cover_letter_textarea)

    expected_textarea_placeholder = 'Please type or paste your cover letter into this text field, or attach a file below'
    assert textarea.get_attribute(
      'placeholder') == expected_textarea_placeholder, 'The textarea placeholder: {0} is not the expected: {1}'.format(
      textarea.get_attribute('placeholder'), expected_textarea_placeholder)
    # APERTA-8903
    # self.validate_textarea_style(textarea)

  def validate_textarea_submitted_text(self, submitted_text):
    """
    validate_textarea_submitted_text: Validates display of the submitted cover letter text
    :param submitted_text: The submitted cover letter text. A string.
    :return: void function
    """

    textarea = self._get(self._cover_letter_textarea)

    assert textarea.get_attribute(
      'value') == submitted_text, "The textarea text: {0} do not match the submitted: {1}".format(
      textarea.get_attribute('value'), submitted_text)

  def validate_textarea_text_editing(self):
    """
    validate_textarea_text_editing: Validates the editing of the cover letter text
    :return: void function
    """

    if self.completed_state():
      self.click_completion_button()

    textarea = self._get(self._cover_letter_textarea)
    textarea_edited_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec iaculis, nisl volutpat ' \
                           'dignissim tempus, urna risus semper lectus, non fermentum quam neque sed magna. Morbi in ' \
                           'velit ac arcu scelerisque lobortis nec et mauris. Vestibulum nec mauris sapien. Aenean ac '

    assert textarea.is_enabled(), 'The textarea is not enabled when it ' \
                                  'should be'

    textarea.clear()

    textarea.send_keys(textarea_edited_text)

    self.click_completion_button()

    assert textarea.get_attribute(
      'value') == textarea_edited_text, 'The edited text: {0} is not the expected: {1}'.format(
      textarea.get_attribute('value'), textarea_edited_text)

  def validate_uploaded_file_download(self, uploaded_file):
    """
    validate_uploaded_file_download: Validates the display of the uploaded file and check if is the same uploaded
    :param uploaded_file: The uploaded file path. A string.
    :return: void function
    """

    if self.completed_state():
      self.click_completion_button()

    download_button = self._get(self._uploaded_attachment_item_link)
    formatted_file_name = urllib.quote_plus(uploaded_file.split("/")[-1])
    original_working_dir = os.getcwd()

    assert download_button.text == formatted_file_name, 'The formatted file name: {0} is not the expected: {1}'.format(
      download_button.text, formatted_file_name)

    download_button.click()

    # Add a sleep to wait the file to download, as the resource files are
    # small, 10 seconds are enough.
    time.sleep(10)

    # Get the newest file downloaded
    os.chdir('/tmp')

    # Do operation inside try to avoid errors, preventing the chdir to don't return to the original one
    try:
      files = filter(os.path.isfile, os.listdir('/tmp'))
      files = [os.path.join('/tmp', f) for f in files]  # add path to each file
      files.sort(key=lambda x: os.path.getmtime(x))
      newest_file = files[-1]
    except IndexError:
      newest_file = None
    finally:
      # Move the working directory back to the original one
      os.chdir(original_working_dir)

    # Generate MD5 hashes for original and downloaded file to compare if is the same
    uploaded_file_md5 = hashlib.md5(
      open(uploaded_file, 'rb').read()).hexdigest()
    downloaded_file_md5 = hashlib.md5(
      open(newest_file, 'rb').read()).hexdigest()

    assert uploaded_file_md5 == downloaded_file_md5, 'The downloaded file ({0}) ' \
                                                     'MD5 hash (Hash: {1}) ' \
                                                     'does not match the ' \
                                                     'uploaded file ({2}) ' \
                                                     'MD5 hash (Hash: {3})'.format(
      newest_file, downloaded_file_md5, uploaded_file, uploaded_file_md5)

    self.click_completion_button()
