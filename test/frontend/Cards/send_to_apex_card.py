#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import hashlib
import json
import logging
import os
import shutil
import tempfile
import time
import zipfile

from ftplib import FTP
from selenium.webdriver.common.by import By

from Base.Resources import creator_login1, docs

from Base.Resources import creator_login1, APEX_FTP_USER, APEX_FTP_PASS, APEX_FTP_DOMAIN, \
    APEX_FTP_DIR

from frontend.Cards.basecard import BaseCard

__author__ = 'scadavid@plos.org'

class SendToApexCard(BaseCard):
  """
  Page Object Model for Send to APex Card
  """

  def __init__(self, driver):
    super(SendToApexCard, self).__init__(driver)

    # Locators - Instance members
    self._apex_button = (By.CLASS_NAME, 'send-to-apex-button')
    self._apex_message = (By.CLASS_NAME, 'apex-delivery-message')
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
    :param paper_id: The id of the manuscript
    :return: filename as str, directory_path as path
    """
    ftp = FTP(APEX_FTP_DOMAIN)
    ftp.login(APEX_FTP_USER, APEX_FTP_PASS)
    ftp.cwd(APEX_FTP_DIR)
    filename = '{0}.zip'.format(paper_id)
    directory_path = tempfile.mkdtemp()
    local_filename = os.path.join(r'{0}'.format(directory_path), filename)
    lf = open(local_filename, 'wb')
    # Time needed for the FTP to load the file and allow to grap it when running on TeamCity
    time.sleep(15)
    ftp.retrbinary('RETR ' + filename, lf.write, 8*1024)
    lf.close()

    return filename, directory_path

  def extract_zip_file_and_load_json(self, filename, directory_path):
    """
    This method extract the content of the retrieved file from FTP
    :param filename: The name of the file to extract
    :param directory_path: The path of the folder
    :return: json_data as dict
    """
    zip_ref = zipfile.ZipFile(r'{0}/{1}'.format(directory_path, filename))
    zip_ref.extractall(r'{0}'.format(directory_path))
    zip_ref.close()

    with open('{0}/metadata.json'.format(directory_path)) as json_file:
      json_data = json.load(json_file)

    return json_data

  def validate_json_information(self, json_data, short_doi, manuscript_title, manuscript_abstract,
                                directory_path):
    """
    This method validate the information within the extracted json
    :param json_data: Is the extracted json from the unziped metadata.json
    :param short_doi: Is the manuscript's ID
    :param manuscript_title: Is the manuscript's title
    :param manuscript_abstract: Is the manuscript's abstract
    :param directory_path: The location of the temp folder
    :return: None
    """
    author = json_data["metadata"]["authors"][0]["author"]
    competing_interests = json_data["metadata"]["competing_interests"]
    data_availability = json_data["metadata"]["data_availability"]
    financial_disclosure = json_data["metadata"]["financial_disclosure"]
    early_article_posting = json_data["metadata"]["early_article_posting"]
    journal_title = json_data["metadata"]["journal_title"]
    manuscript_id = json_data["metadata"]["manuscript_id"]
    paper_abstract = json_data["metadata"]["paper_abstract"]
    paper_title = json_data["metadata"]["paper_title"]
    paper_type = json_data["metadata"]["paper_type"]
    doi = json_data["metadata"]["doi"]

    asset_author = {"affiliation": creator_login1['affiliation-name'],
                    "contributions": "Conceptualization",
                    "corresponding": True,
                    "deceased": None,
                    "department": creator_login1['affiliation-dept'],
                    "email": creator_login1['email'],
                    "first_name": creator_login1["name"].split()[0],
                    "government_employee": False,
                    "last_name": creator_login1["name"].split()[1],
                    "middle_initial": None,
                    "orcid_authenticated": True,
                    "orcid_profile_url":
                        "http://sandbox.orcid.org/{0}".format(creator_login1["orcidid"]),
                    "secondary_affiliation": None,
                    "title": creator_login1['affiliation-title'],
                    "type": "author"}
    asset_competing_interests = {"competing_interests": None,
                                 "competing_interests_statement":
                                     "The authors have declared that no competing interests exist."}
    asset_data_availability = {"data_fully_available": None,
                               "data_location_statement": None}
    asset_financial_disclosure = {"author_received_funding": None,
                                  "funders": [],
                                  "funding_statement":
                                      "The author(s) received no specific funding for this work."}

    for key, value in author.iteritems():
      if key == "contributions":
        assert asset_author.get(key) in value, "Data point from json file: {0} does not match " \
            "to data point of the source manuscript " \
            "taken from the GUI: {1}".format(value, asset_author.get(key))
      else:
        assert value == asset_author.get(key), "Data point from json file: {0} does not match " \
            "to data point of the source manuscript " \
            "taken from the GUI: {1}".format(value, asset_author.get(key))

    for key, value in competing_interests.iteritems():
      assert value == asset_competing_interests.get(key), "Data point from json file: " \
          "{0} does not match to data point of the source manuscript taken " \
          "from the GUI: {1}".format(value, asset_author.get(key))

    for key, value in data_availability.iteritems():
      assert value == asset_data_availability.get(key), "Data point from json file: " \
          "{0} does not match to data point of the source manuscript taken " \
          "from the GUI: {1}".format(value, asset_author.get(key))

    for key, value in financial_disclosure.iteritems():
        assert value == asset_financial_disclosure.get(key), "Data point from json file: " \
          "{0} does not match to data point of the source manuscript taken " \
          "from the GUI: {1}".format(value, asset_author.get(key))

    assert early_article_posting == True, "Data point from json file: {0} does not match " \
        "to data point of the source manuscript taken " \
        "from the GUI: {1}".format(early_article_posting, True)
    assert journal_title == "PLOS Wombat", "Data point from json file: {0} does not match " \
        "to data point of the source manuscript taken " \
        "from the GUI: {1}".format(journal_title, "PLOS Wombat")
    assert manuscript_id == short_doi, "Data point from json file: {0} does not match " \
        "to data point of the source manuscript taken " \
        "from the GUI: {1}".format(manuscript_id, short_doi)
    assert paper_abstract == manuscript_abstract, "Data point from json file: {0} does not match " \
        "to data point of the source manuscript taken " \
        "from the GUI: {1}".format(paper_abstract, manuscript_abstract)
    assert paper_title == manuscript_title, "Data point from json file: {0} does not match " \
        "to data point of the source manuscript taken " \
        "from the GUI: {1}".format(paper_title, manuscript_title)
    assert paper_type == "generateCompleteApexData", "Data point from json file: " \
        "{0} does not match to data point of the source manuscript taken " \
        "from the GUI: {1}".format(paper_type, "generateCompleteApexData")
    assert "/journal.{0}".format(short_doi) in doi, "Data point from json file: " \
        "{0} does not match to data point of the source manuscript taken from " \
        "the GUI: {1}".format("/journal.{0}".format(short_doi), doi)

    shutil.rmtree(directory_path)

  def validate_source_file_in_zip(self, filename, directory_path, doc2upload, hash_file, short_doi):
    """
    This method compares the hash of the uploaded source file against the hash of the file
    contained in the zip retrieved from FTP
    :param filename: The name of the file to extract
    :param directory_path: The path of the folder
    :param doc2upload: The uploaded source file
    :param hash_file: Is the hash number of the uploaded source file
    :param short_doi: Is the manuscript ID
    :return: None
    """
    zip_ref = zipfile.ZipFile(r'{0}/{1}'.format(directory_path, filename))
    zip_ref.extractall(r'{0}'.format(directory_path))
    zip_ref.close()

    source_file_name = doc2upload.split("/")[3]
    file_ext = source_file_name.split(".")[1]
    extracted_source_file = os.path.join(directory_path, '{0}.{1}'.format(short_doi, file_ext))
    hash_file_extracted = hashlib.sha256(open(extracted_source_file, 'rb').read()).hexdigest()

    assert hash_file == hash_file_extracted, "The extracted document is not the same " \
        "that were uploaded as source file: " \
        "Uploaded hash {0} and extracted hash {1}".format(hash_file,hash_file_extracted) 

    shutil.rmtree(directory_path)