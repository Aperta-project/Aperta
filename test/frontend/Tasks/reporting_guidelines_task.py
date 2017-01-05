#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import os
import random
import time

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'achoe@plos.org'


class ReportingGuidelinesTask(BaseTask):
  """
  Page Object for the Reporting Guidelines task
  """

  def __init__(self, driver):
    super(ReportingGuidelinesTask, self).__init__(driver)

    # Locators - Instance members
    self._question_text = (By.CLASS_NAME, 'question-text')
    self._select_instruction = (By.CLASS_NAME, 'help')
    self._selection_list = (By.CLASS_NAME, 'list-unstyled')
    self._prisma_upload_button = (By.CLASS_NAME, 'fileinput-button')
    self._prisma_uploaded_file_link = (By.CLASS_NAME, 'file-link')
    self._file_replace = (By.CLASS_NAME, 'replace-attachment')
    self._file_delete = (By.CLASS_NAME, 'delete-attachment')
    self._file_attach_input = (By.CSS_SELECTOR, 'input.s3-file-uploader')

  # POM Actions
  def validate_styles(self):
    """
    Validates styles in the Reporting Guidelines Task
    :return: None
    """
    question_text = self._get(self._question_text)
    assert question_text.text == 'Authors should check the EQUATOR Network site for any reporting' \
                                 ' guidelines that apply to their study design, and ensure that any' \
                                 ' required Supporting Information (checklists, protocols, flowcharts,' \
                                 ' etc.) be included in the article submission.', question_text.text
    select_instruction = self._get(self._select_instruction)
    self.validate_application_ptext(select_instruction)
    selection_list = self._get(self._selection_list)
    self.validate_application_ptext(selection_list)
    selection_list_items = selection_list.find_elements_by_css_selector('li.item')
    # All checkboxes should be unchecked by default:
    for item in selection_list_items:
      assert item.find_element_by_tag_name('input').is_selected() is False, 'Item {0} is ' \
                                                                            'checked by default'.format(item.text)
    self.validate_common_elements_styles()

  def make_selections(self, prisma=True):
    """
    Selects checkboxes in the Reporting Guidelines task.
    :param prisma: If set to true, will select one of the two checkboxes that allows up upload of a PRISMA checklist
    :return: selected_checkboxes - a list of indices that correspond with the checkboxes that were selected
    """
    selection_list = self._get(self._selection_list)
    selection_list_items = selection_list.find_elements_by_css_selector('li.item')
    selected_checkboxes = []
    # Select checkboxes for either "Systematic Reviews" or "Meta-analyses" - for testing PRISMA checklist uploads
    if prisma:
      choice = random.choice([1,2])
      selected_checkboxes.append(choice)
      selection_list_items[choice].find_element_by_tag_name('input').click()
    # Select another checkbox at random
    choice = random.choice([0, 3, 4, 5])
    selected_checkboxes.append(choice)
    selection_list_items[choice].find_element_by_tag_name('input').click()
    return selected_checkboxes


  def upload_prisma_review_checklist(self):
    """
    Uploads one of the two PRISMA checklist files
    :return: file - The PRISMA checklist file that was uploaded
    """
    prisma_files = ['frontend/assets/PRISMA_2009_checklist.doc', 'frontend/assets/PRISMA_2009_checklist.pdf']
    current_path = os.getcwd()

    file_ = random.choice(prisma_files)
    logging.info('PRISMA file: {0}'.format(file_))
    file_name = os.path.join(current_path, file_)
    logging.info('Sending file: {0}'.format(file_name))
    self._driver.find_element_by_class_name('add-new-attachment').send_keys(file_name)
    link_to_uploaded_file = self._get(self._prisma_uploaded_file_link)
    assert link_to_uploaded_file.text == os.path.basename(file_), 'File {0} is not displayed' \
                                                              ' on Reporting Guidelines task'.format(file_name)
    return file_

  def download_prisma_checklist(self):
    """
    Downloads a prisma checklist file by clicking on the uploaded file link
    :return: None
    """
    uploaded_prisma_file = self._get(self._prisma_uploaded_file_link)
    uploaded_prisma_file.click()
    # Added sleep here to prevent this method from
    # trying to get the downloaded file before the download has completed
    time.sleep(2)
    current_path = os.getcwd()
    os.chdir('/tmp')
    files = filter(os.path.isfile, os.listdir('/tmp'))
    files = [os.path.join('/tmp', f) for f in files]
    files.sort(key=lambda x: os.path.getmtime(x))
    try:
      newest_file = files[-1]
    except IndexError:
      os.chdir(current_path)
      logging.warning('Another process may deleted files from /tmp. While rare, '
                              'this should not be considered a failure.')
      return
    newest_file = os.path.basename(newest_file)
    os.remove(newest_file)
    os.chdir(current_path)
    assert uploaded_prisma_file.text == os.path.basename(newest_file), \
      'Uploaded file: {0} | Downloaded file: {1}'.format(uploaded_prisma_file.text, newest_file)

  def replace_prisma_checklist(self):
    """
    Replaces a prisma checklist file
    :return: None
    """
    current_path = os.getcwd()
    uploaded_prisma_file = self._get(self._prisma_uploaded_file_link)
    if uploaded_prisma_file.text == 'PRISMA_2009_checklist.doc':
      replacement_file = 'frontend/assets/PRISMA_2009_checklist.pdf'
    else:
      replacement_file = 'frontend/assets/PRISMA_2009_checklist.doc'
    file_name = os.path.join(current_path, replacement_file)
    logging.info('Replacing {0} with {1}'.format(uploaded_prisma_file.text, file_name))
    # TODO: Remove driver.execute_script once APERTA-8644 has been addressed
    self._driver.execute_script("document.getElementsByClassName('s3-file-uploader')[0].style.display='block';")
    self._driver.find_element_by_class_name('s3-file-uploader').send_keys(file_name)
    time.sleep(2)
    uploaded_prisma_file = self._get(self._prisma_uploaded_file_link)
    assert uploaded_prisma_file.text == os.path.basename(replacement_file), \
      'Uploaded file: {0} | Replacement file: {1}'.format(uploaded_prisma_file.text, os.path.basename(replacement_file))

  def delete_prisma_checklist(self):
    """
    Deletes a prisma checklist file
    :return: None
    """
    delete_link = self._get(self._file_delete)
    delete_link.click()
    upload_button = self._get(self._prisma_upload_button)
    assert upload_button.text in ['UPLOAD REVIEW CHECKLIST', 'UPLOAD PRISMA CHECKLIST'], upload_button.text
