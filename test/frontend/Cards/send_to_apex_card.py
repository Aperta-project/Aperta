#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import time
import os
import zipfile
import json

from selenium.webdriver.common.by import By
from ftplib import FTP
from pprint import pprint

from frontend.Cards.basecard import BaseCard

__author__ = 'scadavid@plos.org'

class SendToApexCard(BaseCard):
  """
  Page Object Model for Send to APex Card
  """

  def __init__(self, driver):
    super(SendToApexCard, self).__init__(driver)

    # Locators - Instance members
    self._apex_button = (By.CSS_SELECTOR, '.animation-fade-in > div > .send-to-apex-button')
    self._apex_message = (By.CSS_SELECTOR, 
                          '.animation-fade-in > div > div > .apex-delivery-message')
    self._close_apex = (By.CSS_SELECTOR, '.overlay-footer > div + a')

  # POM Actions
  def validate_send_to_apex_message(self):
    """
    Validate the Send to Apex error messages
    :return: None
    """
    # Time needed for message to be ready
    time.sleep(3)
    apex_error, apex_succeed = self._gets(self._apex_message)
    if "530" in apex_succeed.text:
      assert apex_error.text == (
          "Apex Upload has failed. Paper has not been accepted"), apex_error
      assert apex_succeed.text == (
          "Apex Upload has failed. 530 Please login with USER and PASS"), apex_succeed
    else:
      assert apex_error.text == (
          "Apex Upload has failed. Paper has not been accepted"), apex_error
      assert apex_succeed.text == ("Apex Upload succeeded."), apex_succeed

  def click_send_to_apex_button(self):
    """
    Clicking Send to Apex button
    :return: None
    """
    apex_button = self._get(self._apex_button)
    apex_button.click()

  def click_close_apex(self):
    """
    Clicking Close Apex Card
    :return: None
    """
    close_apex = self._get(self._close_apex)
    close_apex.click()

  def validate_card_elements(self, paper_id):
    """
    This method validates the styles of the card elements including the common card elements
    :param paper_id: The id of the manuscript
    :return: None
    """
    apex_messages = self._gets(self._apex_message)
    apex_button = self._get(self._apex_button)
    self.validate_common_elements_styles(paper_id)
    self.validate_primary_big_green_button_style(apex_button)
    map(self.validate_textarea_style, apex_messages)

  def connect_to_aperta_ftp(self, paper_id):
    """
    This method allows to connect the ftp server and copy the file
    :param paper_id: The id of the manuscrip
    :return: filename
    """
    FTP_USER = 'aperta'
    FTP_PASS = 'flyskyfish'
    FTP_URL = 'delivery.plos.org'
    FTP_DIR = 'aperta2apextest'

    ftp = FTP(FTP_URL)
    ftp.login(FTP_USER, FTP_USER)
    ftp.cwd(FTP_DIR)
    filename = '{0}.zip'.format(paper_id)
    local_filename = os.path.join(r'/home/smurcia/Desktop', filename)
    lf = open(local_filename, 'wb')
    ftp.retrbinary('RETR' + filename, lf.write, 8*1024)
    lf.close()

    return filename

  def extract_zip_file_and_load_json(self, filename):
    """
    This method extract the content of the retrieved file from FTP
    :return: json_data
    """
    zip_ref = zipfile.ZipFile(r'/home/smurcia/Desktop/{0}'.format(filename))
    zip_ref.extractall(r'/home/smurcia/Desktop')
    zip_ref.close()

    with open('/home/smurcia/Desktop/metadata.json') as json_file:    
      json_data = json.load(json_file)

    return json_data