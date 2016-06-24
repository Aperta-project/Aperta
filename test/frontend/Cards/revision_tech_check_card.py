#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class RTCCard(BaseCard):
  """
  Page Object Model for the Revision Tech Check Card
  """
  def __init__(self, driver):
    super(RTCCard, self).__init__(driver)

    # Locators - Instance members
    self._h2_titles = (By.CSS_SELECTOR, 'div.checklist h2')
    self._h3_titles = (By.CSS_SELECTOR, 'ul.list-unstyled h3')
    self._h4_titles = (By.CSS_SELECTOR, 'ul.list-unstyled h4')
    self._send_changes = (By.CSS_SELECTOR, 'h3.change-instructions')
    self._send_changes_button = (By.CSS_SELECTOR, 'div.task-main-content button.button-primary')
    self._reject_radio_button = (By.XPATH, '//input[@value=\'reject\']')
    self._invite_radio_button = (By.XPATH, '//input[@value=\'invite_full_submission\']')
    self._decision_letter_textarea = (By.TAG_NAME, 'textarea')
    self._register_decision_btn = (By.XPATH, '//textarea/following-sibling::button')
    self._alert_info = (By.CLASS_NAME, 'alert-info')
    self._autogenerate_text = (By.XPATH,
        '//div[contains(@class, \'form-group\')]/following-sibling::button')
    self._text_area = (By.CSS_SELECTOR, 'textarea.ember-text-area')
    self._field_title = (By.CSS_SELECTOR, 'span.text-field-title')
    self._checkboxes = (By.CSS_SELECTOR, 'label.question-checkbox input')
    self._check_items = (By.CSS_SELECTOR, 'p.model-question')
    self._check_items_text = ['Make sure the ethics statement looks complete. If the authors '
        'have responded Yes to any question, but have not provided approval information, please'
        ' request this from them.',
        'In the Data Availability card, if the answer to Q1 is \'No\' or if the answer to Q2 is'
        ' \'Data are from the XXX study whose authors may be contacted at XXX\' or \'Data are '
        'available from the XXX Institutional Data Access/ Ethics Committee for researchers who'
        ' meet the criteria for access to confidential data\', start a \'MetaData\' discussion '
        'and ping the handling editor.',
        'In the Data Availability card, if the authors have not selected one of the reasons '
        'listed in Q2 and pasted it into the text box, please request that they complete this '
        'section.',
        'In the Data Availability card, if the authors have mentioned data submitted to Dryad, '
        'check that the author has provided the Dryad reviewer URL and if not, request it from'
        ' them.',
        'Compare the author list between the manuscript file and the Authors card. If the author'
        ' list does not match, request the authors to update whichever section is missing '
        'information. Ignore omissions of middle initials.',
        'If the author list has changed (author(s) being added or removed), flag it to the '
        'editor/initiate our COPE process if an author was removed.',
        'If any competing interests are listed, please add a manuscript note. ex: \'Initials '
        'Date: Note to Editor - COI statement present, please see COI field.\'',
        'Check that the Financial Disclosure card has been filled out correctly. Ensure the '
        'authors have provided a description of the roles of the funder, if they responded Yes'
        ' to our standard statement.',
        'If the Financial Disclosure Statement includes any companies from the Tobacco Industry,'
        ' start a \'MetaData\' discussion and ping the handling editor. See this list.',
        'For any resubmissions that have previously gone through review, ensure the authors have'
        ' responded to the reviewer comments in the Revision Details box of the Revise '
        'Manuscript card. If this information is not present, request it from author.',
        'If the authors mention submitting their paper to a collection in the cover letter or '
        'Additional Information card, alert Jenni Horsley by pinging her through the discussion '
        'of the ITC card.',
        'Make sure you can view and download all files uploaded to your Figures card. Check '
        'against figure citations in the manuscript to ensure there are no missing figures.',
        'If main figures or supporting information captions are only available in the file '
        'itself (and not in the manuscript), request that the author remove the captions from '
        'the file and instead place them in the manuscript file.',
        'If main figures or supporting information captions are missing entirely, ask the '
        'author to provide them in the manuscript file.',
        'If any files or figures are cited in the manuscript but not included in the Figures or'
        ' Supporting Information cards, ask the author to provide the missing information. '
        '(Search Fig, Table, Text, Movie and check that they are in the file inventory).',
        ]
    self.email_text = {0: 'In the Ethics statement card, you have selected Yes to one of the questions.'
          ' In the box provided, please include the appropriate approval information, as well as any'
          ' additional requirements listed.',
                    1: '',
                    2: 'In the Data Availability card, you have selected Yes in response to Question'
          ' 1, but you have not fill in the text box under Question 2 explaining how your data can '
          'be accessed. Please choose the most appropriate option from the list and paste into the '
          'text box.',
                    3: 'In the Data Availability card, you have mentioned your data has been '
          'submitted to the Dryad repository. Please provide the reviewer URL in the text box under '
          'question 2 so that your submitted data can be reviewed.',
                    4: 'The list of authors in your manuscript file does not match the list of '
          'authors in the Authors card. Please ensure these are consistent.',
                    5: '',
                    6: 'In the Competing Interests card, you have selected Yes, but not provided an '
          'explanation in the box provided. Please take this opportunity to include all relevant '
          'information.',
                    7: 'Please complete the Financial Disclosure card. This section should describe '
          'sources of funding that have supported the work. Please include relevant grant numbers '
          'and the URL of any funder\'s Web site. If the funders had a role in the manuscript, '
          'please include a description in the box provided.',
                    8: '',
                    9: 'Please respond to all reviewer comments point-by-point in the Revision '
          'Details section of your Revise Manuscript card.',
                    10: '',
                    11: 'We are unable to preview or download Figure [X]. Please upload a higher '
          'quality version, preferably in TIF or EPS format and ensure the uploaded version can be '
          'previewed and downloaded before resubmitting your manuscript.',
                    12: 'Please remove captions from figure or supporting information files and ensure'
          ' each file has a caption present in the manuscript.',
                    13: 'Please provide a caption for [file name] in the manuscript file.',
                    14: 'Please note you have cited a file, [file name], in your manuscript that has '
          'not been included with your submission. Please upload this file, or if this file was cited '
          'in error, please remove the corresponding citation from your manuscript.'
                    }

   # POM Actions
  def validate_styles(self, paper_id):
    """
    Validate styles for the Revision Tech Check Card
    :param paper_id: passed through for validate_common_elements_styles - needed for card header
    :return: None
    """
    self.validate_common_elements_styles(paper_id)
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Revision Tech Check', card_title.text
    self.validate_application_title_style(card_title)
    time.sleep(1)
    # Check all h2 titles
    h2_titles = self._gets(self._h2_titles)
    h2 = [h2.text for h2 in h2_titles]
    assert h2 == [u'Submission Cards', u'Figures/Supporting Information'], h2
    # get style
    for h2 in h2_titles:
        self.validate_application_h2_style(h2)
    h3_titles = self._gets(self._h3_titles)
    h3 = [h3.text for h3 in h3_titles]
    assert h3 == [u'Ethics Statement', u'Data Policy', u'Author List', u'Authors Added/Removed',
        u'Competing Interests', u'Financial Disclosure Statement', u'Response to Reviewers',
        u'Collections', u'Figures', u'Figure Captions', u'Cited Files Present'], h3
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
    :return: Text in the text area of RTC
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
    Complete the Final Tech Check card using custom or random data
    :data: List with data to complete the card. If empty,
      will generate random data.
    :return: list with data used to complete the card
    """
    if not data:
      # generate random data
      data = []
      for x in range(15):
        data.append(random.choice([True, False]))
    logging.info('Data: {0}'.format(data))
    for order, checkbox in enumerate(self._gets(self._checkboxes)):
      if data[order]:
        checkbox.click()
    send_changes_button = self._get(self._send_changes_button)
    send_changes_button.click()
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
      assert 'An initial decision of \'Invite full submission\' decision has been made.' in \
          alert_msg.text, alert_msg.text
    else:
      assert 'An initial decision of \'Reject\' decision has been made.' in alert_msg.text, \
          alert_msg.text
    self.click_close_button()
    time.sleep(.5)
    return choice
