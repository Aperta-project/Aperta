#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import hashlib
import os
import random
import logging
import time
import re
import urllib

from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC

from frontend.Tasks.basetask import BaseTask
from Base.Resources import cover_letters

__author__ = 'ivieira@plos.org'


class CoverLetterTask(BaseTask):
  """
  Page Object Model for Cover Letter Task
  """

  def __init__(self, driver):
    super(CoverLetterTask, self).__init__(driver)

    # Locators - Instance members

    # The base CSS locator to the task body
    self._task_body_base_locator = '.cover-letter-task .task-disclosure-body .edit-cover-letter '
    self._instructions_text_first_p = (
    By.CSS_SELECTOR, self._task_body_base_locator + '> p:first-of-type')
    self._instructions_text_last_p = (
    By.CSS_SELECTOR, self._task_body_base_locator + '> p:last-of-type')
    self._instructions_text_questions_ul = (
    By.CSS_SELECTOR, self._task_body_base_locator + '> ul')
    self._cover_letter_textarea = (By.CLASS_NAME, 'cover-letter-field')
    self._upload_cover_letter_button = (By.CSS_SELECTOR,
                                        self._task_body_base_locator + '.attachment-manager .fileinput-button')
    self._upload_cover_letter_input_selector = self._task_body_base_locator + '.attachment-manager input.add-new-attachment'
    self._uploaded_attachment_item = (By.CSS_SELECTOR,
                                      self._task_body_base_locator + '.attachment-manager .attachment-item')
    self._uploaded_attachment_item_link = (By.CSS_SELECTOR,
                                           self._task_body_base_locator + '.attachment-manager .attachment-item a.file-link')
    self._task_done_button = (
    By.CSS_SELECTOR, self._task_body_base_locator + 'button.task-completed')

    self._last_uploaded_letter_file = None
    self._textarea_sample_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec iaculis, nisl volutpat ' \
                                 'dignissim tempus, urna risus semper lectus, non fermentum quam neque sed magna. Morbi in ' \
                                 'velit ac arcu scelerisque lobortis nec et mauris. Vestibulum nec mauris sapien. Aenean ac ' \
                                 'massa facilisis, pulvinar quam nec, volutpat enim. Sed at sem risus. Sed hendrerit, odio ' \
                                 'vitae lobortis dapibus, turpis ipsum tristique elit, et bibendum urna magna in elit. ' \
                                 'Aliquam in lacus diam. Aenean tellus lectus, commodo eget leo et, interdum hendrerit lectus.'

  def validate_cover_letter_task_styles(self):
    """
    validate_cover_letter_task_styles: Validates the elements, styles and texts for the cover letter task
    :return: void function
    """
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
        i, question.text, expected_instructions_questions[i])
      self.validate_application_ptext(question)

    # Assert form styling
    textarea = self._get(self._cover_letter_textarea)
    upload_cover_letter_button = self._get(self._upload_cover_letter_button)

    expected_textarea_placeholder = 'Please type or paste your cover letter into this text field, or attach a file below'
    assert textarea.get_attribute(
      'placeholder') == expected_textarea_placeholder, 'The textarea placeholder: {0} is not the expected: {1}'.format(
      textarea.get_attribute('placeholder'), expected_textarea_placeholder)
    # APERTA-8903
    # self.validate_textarea_style(textarea)

    expected_upload_button_text = 'ATTACH FILE'
    assert upload_cover_letter_button.text == expected_upload_button_text, 'The upload button text: {0} is not the expected: {0}'.format(
      upload_cover_letter_button.text, expected_upload_button_text)
    self.validate_secondary_small_green_button_task_style(
      upload_cover_letter_button)

  def validate_styles(self):
    """
    validate_styles: Validates the elements, styles and texts for the cover letter task and the common elements styles
    :return: void function
    """
    self.validate_cover_letter_task_styles()
    self.validate_common_elements_styles()
    return self

  def get_textarea_sample_text(self):
    """
    get_textarea_sample_text: Get the text used to fill the textarea
    :return: String
    """
    return self._textarea_sample_text

  def validate_letter_textarea(self):
    """
    validate_letter_textarea: Validate the textarea filling and mark task as completed
    :return: void function
    """
    textarea = self._get(self._cover_letter_textarea)
    sample_text = self.get_textarea_sample_text()

    textarea.send_keys(sample_text)

    self.click_completion_button()

  def upload_letter(self, letter='random'):
    """
    upload_letter: Upload the cover letter file
    :param letter: The full path and filename of the letter to upload. A string.
    :return: void function
    """
    if letter == 'random':
      letter2upload = random.choice(cover_letters)
      fn = os.path.join(os.getcwd(), letter2upload)
    else:
      fn = os.path.join(os.getcwd(), letter)

    logging.info('Sending cover letter: {0}'.format(fn))
    self._driver.find_element_by_css_selector(
      self._upload_cover_letter_input_selector).send_keys(fn)
    self._last_uploaded_letter_file = fn
    formatted_file_name = urllib.quote_plus(fn.split("/")[-1])

    # Wait until the uploaded item be loaded
    self._wait_for_element(self._get(self._uploaded_attachment_item))
    # Wait until the uploaded item link have the formatted name
    self._wait_for_text_be_present_in_element(
      self._uploaded_attachment_item_link, formatted_file_name)

  def _get_uploaded_item_element(self):
    """
    _get_uploaded_item_element: Get the current uploaded file element
    :return: WebElement
    """

    uploaded_item = self._get(self._uploaded_attachment_item)

    return uploaded_item

  def get_last_uploaded_letter_file(self):
    """
    _get_uploaded_item_element: Get the last uploaded file path
    :return: String
    """
    return self._last_uploaded_letter_file

  def replace_letter(self, letter='random'):
    """
    upload_letter: Replaces an uploaded cover letter file by another new one
    :param letter: The new file full path and filename. A string.
    :return: void function
    """
    uploaded_item = self._get_uploaded_item_element()

    if letter == 'random':
      letter2upload = random.choice(cover_letters)
      fn = os.path.join(os.getcwd(), letter2upload)
    else:
      fn = os.path.join(os.getcwd(), letter)

    logging.info('Replacing cover letter by: {0}'.format(fn))

    # Making file input visible, using JavaScript, to Selenium be able to interact with this.
    # A ticket to front end fix is was filed: APERTA-8960
    js_cmd = "$('<style>{0}.attachment-manager .s3-file-uploader {{ display:block !important; }}</style>').appendTo('body');".format(
      self._task_body_base_locator)
    self._driver.execute_script(js_cmd)
    replace_file_input = uploaded_item.find_element_by_class_name(
      's3-file-uploader')
    replace_file_input.send_keys(fn)
    formatted_file_name = urllib.quote_plus(fn.split("/")[-1])

    # Wait until the uploaded item link have the formatted name
    self._wait_for_text_be_present_in_element(
      self._uploaded_attachment_item_link, formatted_file_name)

    uploaded_file_name = self._get(self._uploaded_attachment_item_link).text

    assert formatted_file_name == uploaded_file_name, "The uploaded file name: {0} is not the expected: {1}".format(
      formatted_file_name, uploaded_file_name)

  def remove_letter(self):
    """
    remove_letter: Removes an uploaded cover letter file
    :return: void function
    """
    uploaded_item = self._get_uploaded_item_element()
    remove_button = uploaded_item.find_element_by_class_name(
      'delete-attachment')

    remove_button.click()

    self._wait_for_not_element(self._uploaded_attachment_item, 2)

  def download_letter(self):
    """
    remove_letter: Downloads an uploaded cover letter file and check if is the expected
    :return: void function
    """
    uploaded_item = self._get_uploaded_item_element()
    download_button = uploaded_item.find_element_by_class_name('file-link')
    original_working_dir = os.getcwd()

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

    # Get the last uploaded file, if available, or find the original file in resource list
    if self.get_last_uploaded_letter_file():
      original_file_path = self.get_last_uploaded_letter_file()
    else:
      # Find the original resource file name
      original_file_name = newest_file.split('/')[-1]
      # Remove the version number in case of duplicated file
      pattern = "\([^\d]*(\d+)[^\d]*\)"
      original_file_name = re.sub(pattern, '', original_file_name)
      # Replace + by space, as the backend does
      original_file_name = original_file_name.replace("+", " ")

      # Filter the resource list to find a path with the file name
      original_file_path = filter(lambda x: original_file_name in x,
                                  cover_letters)
      original_file_path = os.path.join(original_working_dir,
                                        original_file_path[0])

    # Generate MD5 hashes for original and downloaded file to compare if is the same
    original_file_md5 = hashlib.md5(
      open(original_file_path, 'rb').read()).hexdigest()
    downloaded_file_md5 = hashlib.md5(
      open(newest_file, 'rb').read()).hexdigest()

    assert original_file_md5 == downloaded_file_md5, 'The downloaded file MD5 hash ({0}) do not match the uploaded ({1})'.format(
      downloaded_file_md5, original_file_md5)
