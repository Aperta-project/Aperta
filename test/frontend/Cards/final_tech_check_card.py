#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import logging
import random
import time

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class FTCCard(BaseCard):
  """
  Page Object Model for the Final Tech Check Card
  """
  def __init__(self, driver):
    super(FTCCard, self).__init__(driver)

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
    self._check_items_text = [u'Check Section Headings of all new submissions (including Open '
        'Rejects). Should broadly follow: Title, Authors, Affiliations, Abstract, Introduction,'
        ' Results, Discussion, Materials and Methods, References, Acknowledgements, and Figure '
        'Legends.',
        'Check the ethics statement - does it mention Human Participants? If so, flag this with'
        ' the editor in the discussion below.',
        'Check if there are any obvious ethical flags (mentions of animal/human work in the '
        'title/abstract), check that there\'s an ethics statement. If not, ask the authors about'
        ' this.',
        'Is the data available? If not, or it\'s only available by contacting an author or the '
        'institution, make a note in the discussion below.',
        'If author indicates the data is available in Supporting Information, check to make sure'
        ' there are Supporting Information files in the submission (don\'t need to check for '
        'specifics at this stage).',
        'If the author has mentioned Dryad in their Data statement, check that they\'ve included'
        ' the Dryad reviewer URL. If not, make a note in the discussion below.',
        'If Financial Disclosure Statement is not complete (they\'ve written N/A or something '
        'similar), message author.',
        'If the Financial Disclosure Statement includes any companies from the Tobacco Industry,'
        ' make a note in the discussion below.',
        'If any figures are completely illegible, contact the author.',
        'If any files or figures are cited but not included in the submission, message the '
        'author.',
        'Have the authors asked any questions in the cover letter? If yes, contact the '
        'editor/journal team.',
        'Have the authors mentioned any billing information in the cover letter? If yes, contact'
        ' the editor/journal team.',
        'If an Ethics Statement is present, make a note in the discussion below.',
        ]
    self.email_text = {0: '',
                    1: 'Please ensure that all of the following sections are present and '
          'appear in your manuscript file in the following order: Title, Authors, '
          'Affiliations, Abstract, Introduction, Results, Discussion, Materials and '
          'Methods, References, Acknowledgments, and Figure Legends. More detailed '
          'guidelines can be found on our website: '
          'http://journals.plos.org/plosbiology/s/submission-guidelines#loc-manuscript-'
          'organization.',
                    2: '',
                    3: '',
                    4: '',
                    5: '',
                    6: 'Please complete the Financial Disclosure Statement field of the '
          'online submission form.',
                    7: 'This section should describe sources of funding that have '
          'supported the work. Please include relevant grant numbers and the URL of any '
          'funder\'s Web site.',
                    8: 'Your Figure is not easily legible. Please provide a higher '
          'quality version of this Figure while ensuring the file size remains below '
          '10MB. We recommend saving your figures as TIFF files using LZW compression.'
          ' More detailed guidelines can be found on our website: '
          'http://journals.plos.org/plosbiology/s/figures.',
                    9: 'Please note you have cited a file in your manuscript that has not'
          ' been included with your submission. Please upload this file, or if this file '
          'was cited in error, please remove the corresponding citation from your '
          'manuscript.',
                    10: '',
                    11: 'Please note that our policy requires the removal of any mention '
          'of billing information from the cover letter. I have forwarded your query to '
          'our Billing Team (authorbilling@plos.org). Further infromation about Publication'
          ' Fees can be found here: http://www.plos.org/publications/publication-fees/. '
          'Thank you, PLOS Biology',
                    12: '',
                    }

   # POM Actions
  def validate_styles(self, paper_id):
    """
    Validate styles for the Final Tech Check Card
    :param paper_id: passed through for validate_common_elements_styles - needed for card header
    :return: None
    """
    self.validate_common_elements_styles(paper_id)
    card_title = self._get(self._card_heading)
    assert card_title.text == 'Final Tech Check', card_title.text
    self.validate_overlay_card_title_style(card_title)
    time.sleep(1)
    # Check all h2 titles
    h3_titles = self._gets(self._h3_titles)
    h3 = [h3.text for h3 in h3_titles]
    assert h3 == [u'Submission tasks', u'Figures and Supporting Information'], h3
    # get style
    # TODO: Following check disabled due to APERTA-7087
    """
    for h2 in h2_titles:
        self.validate_application_h2_style(h2)
    """
    h4_titles = self._gets(self._h4_titles)
    h4 = [h4.text for h4 in h4_titles]
    assert h4 == [u'Ethics Statement', u'Financial Disclosure Statement'], h4
    # TODO: Following check disabled due to APERTA-7087
    """
    for h3 in h3_titles:
        self.validate_application_h3_style(h3)
    """
    check_items = self._gets(self._check_items)
    for item in [item.text for item in check_items]:
      assert item in self._check_items_text, '{0}\n not in\n {1}'.format(item,
                                                                         self._check_items_text)
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
    Complete the Final Tech Check card using custom or random data
    :data: List with data to complete the card. If empty,
      will generate random data.
    :return: list with data used to complete the card
    """
    if not data:
      # generate random data
      data = []
      for x in range(13):
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
