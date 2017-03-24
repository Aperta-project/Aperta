#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class ITCCard(BaseCard):
  """
  Page Object Model for the Initial Tech Check Card
  """
  def __init__(self, driver):
    super(ITCCard, self).__init__(driver)

    # Locators - Instance members
    self._h2_titles = (By.CSS_SELECTOR, 'div.checklist h2')
    self._h3_titles = (By.CSS_SELECTOR, 'div.checklist h3')
    self._send_changes = (By.CSS_SELECTOR, 'div.tech-check-email h3')
    self._send_changes_button = (By.CSS_SELECTOR, 'div.tech-check-email button.button--green')
    self._reject_radio_button = (By.XPATH, '//input[@value=\'reject\']')
    self._invite_radio_button = (By.XPATH, '//input[@value=\'invite_full_submission\']')
    self._decision_letter_textarea = (By.TAG_NAME, 'textarea')
    self._register_decision_btn = (By.XPATH, '//textarea/following-sibling::button')
    self._alert_info = (By.CLASS_NAME, 'alert-info')
    self._autogenerate_text = (By.ID, 'autogenerate-email')
    self._text_area = (By.CSS_SELECTOR, 'textarea.ember-text-area')
    self._field_title = (By.CSS_SELECTOR, 'span.text-field-title')
    self._checkboxes = (By.CSS_SELECTOR, 'label.question-checkbox input')
    self._check_items = (By.CSS_SELECTOR, 'p.model-question')
    self._check_items_text = [u'Make sure the ethics statement looks complete. If the authors '
        'have responded Yes to any question, but have not provided approval information, '
        'please request this from them.',
        u"In the Data Availability card, if the answer to Q1 is 'No' or if the answer to Q2 is "
        "'Data are from the XXX study whose authors may be contacted at XXX' or 'Data are "
        "available from the XXX Institutional Data Access/ Ethics Committee for researchers who"
        " meet the criteria for access to confidential data', start a 'MetaData' discussion and"
        " ping the handling editor.",
        u'In the Data Availability card, if the authors have not selected one of the reasons '
        'listed in Q2 and pasted it into the text box, please request that they complete this '
        'section.',
        u'In the Data Availability card, if the authors have mentioned data submitted to Dryad, '
        'check that the author has provided the Dryad reviewer URL and if not, request it from '
        'them.',
        u'Compare the author list between the manuscript file and the Authors card. If the '
        'author list does not match, request the authors to update whichever section is missing '
        'information. Ignore omissions of middle initials.',
        u"If we don't have unique email addresses for all authors, send it back.",
        u'If the author list has changed between initial and full submission, pass it through if'
        ' an author was added and flag it to the editor/initiate our COPE process if an author '
        'was removed.',
        u'Check that the Competing Interest card has been filled out correctly. If the authors '
        'have selected Yes and not provided an explanation, send it back.',
        u'Check that the Financial Disclosure card has been filled out correctly. Ensure the '
        'authors have provided a description of the roles of the funder, if they responded Yes '
        'to our standard statement.',
        u"If the Financial Disclosure Statement includes any companies from the Tobacco "
        "Industry, start a 'MetaData' discussion and ping the handling editor. See this list.",
        u'If the authors mention submitting their paper to a collection in the cover letter or '
        'Additional Information card, alert Jenni Horsley by pinging her through the discussion'
        ' of the ITC card.',
        u'Make sure you can view and download all files uploaded to your Figures card. Check '
        'against figure citations in the manuscript to ensure there are no missing figures.',
        u'If main figures or supporting information captions are only available in the file '
        'itself (and not in the manuscript), request that the author remove the captions from '
        'the file and instead place them in the manuscript file.',
        u'If main figures or supporting information captions are missing entirely, ask the '
        'author to provide them in the manuscript file.',
        u'If any files or figures are cited in the manuscript but not included in the Figures '
        'or Supporting Information cards, ask the author to provide the missing information. '
        '(Search Fig, Table, Text, Movie and check that they are in the file inventory).',
        u"For any resubmissions after an Open Reject decision, ensure the authors have uploaded "
        "A 'Response to Reviewer's document. If this information is provided in the cover letter"
        " or another part of the submission, ask the authors to upload it as a new file and if "
        "this information is not present, request the file from author."
        ]
    self.email_text = {0: 'In the Ethics statement card, you have selected Yes to one of the '
          'questions. In the box provided, please include the appropriate approval information, '
          'as well as any additional requirements listed.',
                    1: '',
                    2: 'In the Data Availability card, you have selected Yes in response to '
          'Question 1, but you have not fill in the text box under Question 2 explaining how '
          'your data can be accessed. Please choose the most appropriate option from the list '
          'and paste into the text box.',
                    3: 'In the Data Availability card, you have mentioned your data has been '
          'submitted to the Dryad repository. Please provide the reviewer URL in the text box '
          'under question 2 so that your submitted data can be reviewed.',
                    4: 'The list of authors in your manuscript file does not match the list of '
          'authors in the Authors card. Please ensure these are consistent.',
                    5: 'Please provide a unique and current email address for each contributing '
          'author. It is important that you provide a working email address as we will contact '
          'each author to confirm authorship.',
                    6: '',
                    7: 'In the Competing Interests card, you have selected Yes, but not provided '
          'an explanation in the box provided. Please take this opportunity to include all '
          'relevant information.',
                    8: 'Please complete the Financial Disclosure card. This section should '
          'describe sources of funding that have supported the work. Please include relevant '
          'grant numbers and the URL of any funder\'s Web site. If the funders had a role in the '
          'manuscript, please include a description in the box provided.',
                    9: '',
                    10: '',
                    11: 'We are unable to preview or download Figure [X]. Please upload a higher '
          'quality version, preferably in TIF or EPS format and ensure the uploaded version can '
          'be previewed and downloaded before resubmitting your manuscript.',
                    12: 'Please remove captions from figure or supporting information files and '
          'ensure each file has a caption present in the manuscript.',
                    13: 'Please provide a caption for [file name] in the manuscript file.',
                    14: 'Please note you have cited a file, [file name], in your manuscript that '
          'has not been included with your submission. Please upload this file, or if this file '
          'was cited in error, please remove the corresponding citation from your manuscript.',
                    15: 'Please upload a \'Response to Reviewers\' Word document in the Supporting'
          ' Information card. This file should address all reviewer comments from the original '
          'submission point-by-point.',
                    }

   # POM Actions
  def validate_styles(self, paper_id):
    """
    Validate styles for the Initial Tech Check Card
    :return: None
    """
    self.validate_common_elements_styles(paper_id)
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Initial Tech Check', card_title.text
    self.validate_card_title_style(card_title)
    time.sleep(1)
    # Check all h2 titles
    h2_titles = self._gets(self._h2_titles)
    h2 = [h2.text for h2 in h2_titles]
    assert h2 == [u'Submission Cards', u'Figures/Supporting Information',
        u'Open Rejects (previously rejected papers treated as new submissions)'], h2
    # get style
    for h2 in h2_titles:
        self.validate_application_h2_style(h2)
    h3_titles = self._gets(self._h3_titles)
    h3 = [h3.text for h3 in h3_titles]
    assert h3 == [u'Ethics Statement', u'Data Policy', u'Author List',
        u'Author Email Addresses', u'Authors Added/Removed', u'Competing Interests',
        u'Financial Disclosure Statement', u'Collections', u'Figures', u'Figure Captions',
        u'Cited Files Present', u'Response to Reviewers for Open Rejects'], h3
    for h3 in h3_titles:
        self.validate_application_h3_style(h3)
    check_items = self._gets(self._check_items)
    for item in [item.text for item in check_items]:
      assert item in self._check_items_text, '{0} not in {1}'.format(item, self._check_items_text)
    send_changes = self._get(self._send_changes)
    assert send_changes.text == u'If there are issues the author needs to address, click '\
        'below to send changes to the author.', send_changes.text
    self.validate_application_h3_style(send_changes)
    send_changes_button = self._get(self._send_changes_button)
    assert send_changes_button.text == 'SEND CHANGES TO AUTHOR', send_changes_button.text
    self.validate_primary_big_green_button_style(send_changes_button)
    return None

  def click_autogenerate_btn(self):
    """
    Click autogenerate button
    :return: None
    """
    autogenerate_text_btn = self._get(self._autogenerate_text)
    autogenerate_text_btn.click()
    return None

  def get_issues_text(self):
    """
    Get the contents of the issues to address in the text area
    :return: Text in the text area of ITC
    """
    return self._get(self._text_area).get_attribute('value')

  def click_send_changes_btn(self):
    """
    Click send changes button
    :return None:
    """
    self._get(self._send_changes_button).click()
    return None

  def complete_card(self, data=None):
    """
    Complete the Initial Tech Check card using custom or random data
    :data: List with data to complete the card. If empty,
      will generate random data.
    :return: list with data used to complete the card
    """
    if not data:
      # generate random data
      data = []
      for x in range(16):
        data.append(random.choice([True, False]))
    logging.info('Data: {0}'.format(data))
    for order, checkbox in enumerate(self._gets(self._checkboxes)):
      if data[order]:
        checkbox.click()
    send_changes_button = self._get(self._send_changes_button)
    send_changes_button.click()
    #import pdb; pdb.set_trace()
    time.sleep(1)
    field_title = self._get(self._field_title)
    assert field_title.text == 'List all changes the author needs to make:', field_title.text
    # Dissabled due to APERTA-6954
    #self.validate_field_title_style(field_title)
    # Disabled due to APERTA-6964
    #self.validate_secondary_big_grey_button_style(autogenerate_email_btn)
    return data

  def execute_decision(self, choice='random'):
    """
    Randomly renders an initial decision of reject or invite, populates the decision letter
    :param choice: indicates whether to generate a choice randomly or to reject, else invite
    :return: selected choice
    """
    choices = ['reject', 'invite']
    decision_letter_input = self._get(self._decision_letter_textarea)
    logging.info('Initial Decision Choice is: {0}'.format(choice))
    if choice == 'random':
      choice = random.choice(choices)
      logging.info('Since choice was random, new choice is {0}'.format(choice))
    if choice == 'reject':
      reject_input = self._get(self._reject_radio_button)
      reject_input.click()
      time.sleep(1)
      decision_letter_input.send_keys('Rejected')
    else:
      invite_input = self._get(self._invite_radio_button)
      invite_input.click()
      time.sleep(1)
      decision_letter_input.send_keys('Invited')
    # Time to allow the button to change to clickable state
    time.sleep(1)
    self._get(self._register_decision_btn).click()
    time.sleep(5)
    # look for alert info
    alert_msg = self._get(self._alert_info)
    if choice != 'reject':
      assert "An initial decision of 'Invite full submission' decision has been made." in \
          alert_msg.text, alert_msg.text
    else:
      assert "An initial decision of 'Reject' decision has been made." in alert_msg.text, alert_msg.text
    self.click_close_button()
    time.sleep(.5)
    return choice
