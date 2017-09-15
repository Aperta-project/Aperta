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
    self._task_body_base_locator = 'div.task-main-content.custom-card-task '  #'div.edit-cover-letter '
    self._instructions_text_first_p = (
        By.CSS_SELECTOR, self._task_body_base_locator + 'p:first-of-type')
    self._instructions_text_last_p = (
        By.CSS_SELECTOR, 'label.content-text')
    self._instructions_text_questions_ul = (
        By.CSS_SELECTOR, self._task_body_base_locator + 'ul')
    self._cover_letter_textarea =  (By.CSS_SELECTOR, '.ember-view.rich-text-editor')
    #(By.CLASS_NAME, 'cover-letter-field')
    self._upload_cover_letter_button = (By.CSS_SELECTOR, 'div.fileinput-button')
    self._upload_cover_letter_filename_input = (
        By. CSS_SELECTOR, 'div.fileinput-button > div > input.add-new-attachment')
    #attachment-caption
    self._uploaded_attachment_item = (By.CSS_SELECTOR, 'div.attachment-item')
    self._uploaded_attachment_item_link = (By.CSS_SELECTOR, 'div.attachment-item > a.file-link')
    self._uploaded_attachment_item_replace_file_input = (By.CSS_SELECTOR, 'input.s3-file-uploader')
    self._last_uploaded_letter_file = None
    self._textarea_sample_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ' \
                                 'iaculis, nisl volutpat dignissim tempus, urna risus semper ' \
                                 'lectus, non fermentum quam neque sed magna. Morbi in velit ac ' \
                                 'arcu scelerisque lobortis nec et mauris. Vestibulum nec mauris ' \
                                 'sapien. Aenean ac massa facilisis, pulvinar quam nec, volutpat ' \
                                 'enim. Sed at sem risus. Sed hendrerit, odio vitae lobortis ' \
                                 'dapibus, turpis ipsum tristique elit, et bibendum urna magna ' \
                                 'in elit. Aliquam in lacus diam. Aenean tellus lectus, commodo ' \
                                 'eget leo et, interdum hendrerit lectus.'
    self._description = (By.CSS_SELECTOR, 'div.ember-view.card-content-view-text')
    self._paper_sidebar_state_information = (By.ID, 'submission-state-information')

  def validate_cover_letter_task_styles(self):
    """
    validate_cover_letter_task_styles: Validates the elements, styles and texts for the cover
    letter task
    :return: void function
    """
    # Assert instructions text styling
    instructions_first_p = self._get(self._instructions_text_first_p)
    instructions_questions_ul = self._get(self._instructions_text_questions_ul)
    instructions_questions = instructions_questions_ul.find_elements_by_tag_name(
      'li')
    instructions_last_p = self._get(self._instructions_text_last_p)

    expected_instructions_first_p = 'To be of most use to editors, we suggest your letter could ' \
                                    'address the following questions:'
    assert instructions_first_p.text == expected_instructions_first_p, \
        'The instructions text first paragraph: {0} is not ' \
        'the expected: {1}'.format(instructions_first_p.text, expected_instructions_first_p)

    expected_instructions_last_p = 'In your cover letter, please list any scientists whom you ' \
                                   'request be excluded from the assessment process along with a ' \
                                   'justification. You may also suggest experts appropriate to ' \
                                   'be considered as Academic Editors for your manuscript. ' \
                                   'Please be aware that your cover letter may be seen by ' \
                                   'members of the Editorial Board. For Research articles, if ' \
                                   'our initial assessment is positive, we will request further ' \
                                   'information, including Reviewer Candidates and Competing ' \
                                   'Interests. For other submission types, if the Reviewer ' \
                                   'Candidate and Competing Interests cards are already visible ' \
                                   'to you, please complete them now with the relevant information.'
    assert instructions_last_p.text == expected_instructions_last_p, \
        'The instructions text last paragraph: {0} is not ' \
        'the expected: {1}'.format(instructions_last_p.text, expected_instructions_last_p)

    self.validate_application_body_text(instructions_first_p)
    self.validate_application_body_text(instructions_last_p)

    expected_instructions_questions = [
      'What is the scientific question you are addressing?',
      'What is the key finding that answers this question?',
      'What is the nature of the evidence you provide in support of your conclusion?',
      'What are the three most recently published articles that are relevant to this question?',
      'What significance do your results have for the field?',
      'What significance do your results have for the broader community (of biologists and/or '
      'the public)?',
      'What other novel findings do you present?',
      'Is there additional information that we should take into account?'
      ]

    for i, question in enumerate(instructions_questions):
      assert question.text == expected_instructions_questions[i], \
          'The instructions question {0}: {1} is not the expected: ' \
          '{2}'.format(i, question.text, expected_instructions_questions[i])
      self.validate_application_body_text(question)

    # Assert form styling
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
      self.get_rich_text_editor_instance()  # self.get_rich_text_editor_instance('cover_letter--text')
    logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
    assert tinymce_editor_instance_id and tinymce_editor_instance_iframe, 'Cover letter text area '\
                                                                          'is not present in the ' \
                                                                          'task!'
    upload_cover_letter_button = self._get(self._upload_cover_letter_button)

    expected_upload_button_text = 'ATTACH FILE'
    assert upload_cover_letter_button.text == expected_upload_button_text, \
        'The upload button text: {0} is not the expected: ' \
        '{0}'.format(upload_cover_letter_button.text, expected_upload_button_text)
    self.validate_secondary_small_green_button_task_style(
      upload_cover_letter_button)

  def validate_styles(self):
    """
    validate_styles: Validates the elements, styles and texts for the cover letter task and the
      common elements styles
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

  def fill_and_complete_letter_textarea(self):
    """
    fill_and_complete_letter_textarea: Enter sample text to cover letter rich text editor, then
      mark task completed
    :return: void function
    """
    sample_text = self.get_textarea_sample_text()
    tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
      self.get_rich_text_editor_instance()  # self.get_rich_text_editor_instance('cover_letter--text')
    assert tinymce_editor_instance_id and tinymce_editor_instance_iframe, 'No Cover Letter editor '\
                                                                          'text entry area present.'
    logging.info('Editor instance is: {0}'.format(tinymce_editor_instance_id))
    self._driver.execute_script("javascript:arguments[0].scrollIntoView()", tinymce_editor_instance_iframe)
    self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=sample_text)
    time.sleep(2)
    self._cover_text_label = (By.CSS_SELECTOR, '.content-text')
    self._get(self._cover_text_label).click()
    # Gratuitous verification
    cvr_ltr_txt = self.tmce_get_rich_text(tinymce_editor_instance_iframe)
    logging.info('Temporary Paper Title is: {0}'.format(cvr_ltr_txt))
    time.sleep(1) #sleep added to give tinymce more time
    #manuscript_id = self._get(self._paper_sidebar_state_information)
    #self.scroll_element_into_view_below_toolbar(manuscript_id)
    self.click_covered_element(self._get(self._completion_button))
    #self.click_completion_button()

  def upload_letter(self, letter='random'):
    """
    upload_letter: Upload the cover letter file
    :param letter: The full path and filename of the letter to upload. A string.
    :return: the relative path/filename of the uploaded letter (Matches format of the cover_letters
      list in Base/Resources)
    """
    if letter == 'random':
      letter = random.choice(cover_letters)
    fn = os.path.join(os.getcwd(), letter)
    logging.info('Sending cover letter: {0}'.format(fn))
    input_selector = self._iget(self._upload_cover_letter_filename_input)
    input_selector.send_keys(fn)
    self._last_uploaded_letter_file = fn
    formatted_file_name = urllib.parse.quote_plus(fn.split("/")[-1])

    # Wait until the uploaded item be loaded
    self._wait_for_element(self._get(self._uploaded_attachment_item))
    # Wait until the uploaded item link have the formatted name
    self._wait_for_text_be_present_in_element(
      self._uploaded_attachment_item_link, formatted_file_name)
    return letter

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
    letter_attachment = self._get(self._uploaded_attachment_item_link)
    return letter_attachment.text

  def replace_letter(self, letter='random', exclude=''):
    """
    upload_letter: Replaces an uploaded cover letter file by another new one
    :param letter: The new file full path and filename. A string.
    :param exclude: The path/filename to exclude from the list so we don't replace a file
      with itself
    :return: the path/filename of the letter that replaced the original file - formatted as per
      the cover_letters list in Base/Resources
    """
    if exclude:
      cover_letters.remove(exclude)
    uploaded_item = self._get_uploaded_item_element()

    if letter == 'random':
      letter = random.choice(cover_letters)
    fn = os.path.join(os.getcwd(), letter)

    logging.info('Replacing cover letter with: {0}'.format(fn))
    replace_file_input = self._iget(self._uploaded_attachment_item_replace_file_input)

    # # Making file input visible, using JavaScript, to Selenium be able to interact with this.
    # # A ticket to front end fix is was filed: APERTA-8960
    js_cmd = "$('<style>{0}.attachment-manager " \
             ".s3-file-uploader {{ display:block !important; }}</style>').appendTo('body');"\
        .format(self._task_body_base_locator)
    self._driver.execute_script(js_cmd)
    # replace_file_input = uploaded_item.find_element_by_class_name(
    #   's3-file-uploader')
    replace_file_input.send_keys(fn)
    time.sleep(3) #This sleep is to allow a file upload to process.
    expected_file_name = fn.split("/")[-1]
    return letter

  def remove_letter(self):
    """
    remove_letter: Removes an uploaded cover letter file
    :return: void function
    """
    uploaded_item = self._get_uploaded_item_element()
    remove_button = uploaded_item.find_element_by_class_name(
      'delete-attachment')

    remove_button.click()

    self._wait_for_not_element(self._uploaded_attachment_item, .1)

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

    # Do operation inside try to avoid errors, preventing the chdir to don't return to the
    # original one
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
      open(os.path.join(original_working_dir + '/frontend/assets/coverletters/'
                        + urllib.parse.unquote_plus(original_file_path)), 'rb').read()).hexdigest()
    downloaded_file_md5 = hashlib.md5(
      open(newest_file, 'rb').read()).hexdigest()

    assert original_file_md5 == downloaded_file_md5, \
        'The downloaded file ({0}) MD5 hash (Hash: {1}) does not match the ' \
        'uploaded file ({2}) MD5 hash (Hash: {3})'.format(newest_file,
                                                          downloaded_file_md5,
                                                          original_file_path,
                                                          original_file_md5)
