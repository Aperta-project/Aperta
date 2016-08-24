#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
import random
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from Base.CustomException import ElementDoesNotExistAssertionError
from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'

expected_reject_selections = ['Editor Decision - Reject After Review',
                              'Editor Decision - Reject After Review CJs',
                              'Editor Decision - Reject After Review ONE',
                              'Reject After Review ONE',
                              'Reject After Revision and Re-review ONE'
                              ]


class RegisterDecisionCard(BaseCard):
  """
  Page Object Model for Register Decision Card
  """
  def __init__(self, driver, url_suffix='/'):
    super(RegisterDecisionCard, self).__init__(driver)

    # Locators - Instance members
    self._decision_alert = (By.CLASS_NAME, 'rescind-decision-container')
    self._decision_verdict = (By.CLASS_NAME, 'rescind-decision-verdict')
    self._rescind_button = (By.CLASS_NAME, 'rescind-decision-button')
    self._decision_labels = (By.CLASS_NAME, 'decision-label')

    self._register_decision_button = (By.CLASS_NAME, 'send-email-action')
    self._decision_history_heading = (By.CSS_SELECTOR, 'div.task-main-content > h3')
    self._previous_decision_history_item = (By.CSS_SELECTOR,
                                            'div.previous-decisions > div.decision_bar')
    self._decision_bar_verdict = (By.CSS_SELECTOR, 'h4.decision-bar-verdict')
    self._decision_bar_version = (By.CSS_SELECTOR, 'div.decision-bar-revision-number')
    self._decision_bar_rescinded_flag = (By.CSS_SELECTOR, 'div.decision-bar-rescinded')
    self._decision_bar_contents_preamble = (By.CSS_SELECTOR, 'div.decision-bar-contents > h4')
    self._decision_bar_contents_letter = (By.CSS_SELECTOR, 'div.decision-bar-contents > div')
    # Form Elements for selected decision
    self._letter_template_placeholder_div = (By.CSS_SELECTOR, 'div.letter-template-paceholder')
    self._letter_template_placeholder_paragraph = (By.CSS_SELECTOR,
                                                   'div.letter-template-placeholder > p')
    self._letter_template_reject_selector = (By.CSS_SELECTOR,
                                             'div.task-main-content div.select2-container')
    self._letter_template_reject_search_input = (By.CSS_SELECTOR,
                                                 'div.select2-search input.select2-input')
    self._letter_template_reject_selection = (By.CSS_SELECTOR, 'li > div.select2-result-label')
    self._letter_template_reject_selected = (By.CSS_SELECTOR, 'span.select2-chosen')

    self._letter_template_to_field_label = (By.CSS_SELECTOR, 'div.email-header')
    self._letter_template_to_display_field = (By.CSS_SELECTOR, 'input.to-field')
    self._letter_template_subject_field_label = (
        By.CSS_SELECTOR, 'div.input-group + div.input-group > div.email-header')
    self._letter_template_subject_display_field = (By.CSS_SELECTOR, 'input.subject-field')
    self._letter_template_decision_letter_field = (By.CSS_SELECTOR,
                                                   'textarea.decision-letter-field')

    # POM Actions
  def validate_styles(self):
    """
    Validate the elements and styles of the Register Decision card
    :return: void function
    """
    decision_div = False
    decision_history_head = False
    title = self._get(self._card_heading)
    assert title.text == 'Register Decision', title.text
    self.validate_application_title_style(title)
    # This div will be present if the paper in question is an initial decision paper, it will not be
    #   present for full decision papers.
    self.set_timeout(5)
    try:
      decision_div = self._get(self._decision_alert)
    except ElementDoesNotExistAssertionError:
      logging.info('No pre-existing decision registered for paper')
    self.restore_timeout()
    if decision_div:
      current_verdict = self._get(self._decision_verdict)
      self.validate_rescind_decision_success_style(current_verdict)
    expected_labels = ('Reject', 'Major revision', 'Minor revision', 'Accept')
    decision_labels = self._gets(self._decision_labels)
    for label in decision_labels:
      assert label.text in expected_labels, label.text
    letter_template = self._get(self._letter_template_placeholder_paragraph)
    # Initial state
    assert 'No decision has been registered.' in letter_template.text, letter_template.text
    self.validate_application_ptext(letter_template)
    # The decision history elements are conditional on their being a decision history
    self.set_timeout(1)
    try:
      decision_history_head = self._get(self._decision_history_heading)
    except ElementDoesNotExistAssertionError:
      logging.info('No decision history for paper.')
    self.restore_timeout()
    if decision_history_head:
      assert 'Decision History' in decision_history_head.text, decision_history_head.text
      self.validate_manuscript_h3_style(decision_history_head)
      previous_decisions = self._gets(self._previous_decision_history_item)
      for previous_decision in previous_decisions:
        verdict = self._get(self._decision_bar_verdict)
        self.validate_rescind_decision_info_style(verdict)
        revision = self._get(self._decision_bar_version)
        self.validate_rescind_decision_info_revision_style(revision)
        try:
          rescinded = self._get(self._decision_bar_rescinded_flag)
        except ElementDoesNotExistAssertionError:
          logging.info('Current Decision {0}, is not a rescinded decision.'.format(verdict.text))
        if rescinded:
          assert 'Rescinded' in rescinded.text, rescinded.text
          self.validate_rescind_decision_info_rescinded_flag(rescinded)
        # Expand the decision and check contents
        previous_decision.click()
        decision_preamble = previous_decision.find_element(*self._decision_bar_contents_preamble)
        assert 'Letter sent to Author:' in decision_preamble.text, decision_preamble.text
        self.validate_manuscript_h4_style(decision_preamble)
        decision_letter = previous_decision.find_element(*self._decision_bar_contents_letter)
        self.validate_application_ptext(decision_letter)
        previous_decision.click()
    decision, reject_selection = self.register_decision(decision=False, commit=False)
    if decision == 'Reject':
      letter_template = self._get(self._letter_template_placeholder_paragraph)
      assert 'Please select the template letter and then edit further.' in letter_template.text, \
          letter_template.text
    to_label = self._get(self._letter_template_to_field_label)
    assert 'To:' in to_label.text, to_label.text
    self._letter_template_to_display_field = (By.CSS_SELECTOR, 'input.to-field')
    subject_label = self._get(self._letter_template_subject_field_label)
    assert 'Subject:' in subject_label.text, subject_label.text
    subject = self._get(self._letter_template_subject_display_field)
    subject_text = subject.get_attribute('value')
    assert 'Your PLOS Wombat submission' in subject_text, subject_text
    letter = self._get(self._letter_template_decision_letter_field)
    letter_text = letter.get_attribute('value')
    template_letters = {'Reject-ED-RAR': 'In this case, your article was also assessed by an '
                                         'Academic Editor with relevant expertise and several '
                                         'independent reviewers. Based on the reviews, I regret '
                                         'that we will not be able to accept this manuscript for '
                                         'publication in the journal.',
                        'Reject-ED-RAR-CJ': 'In this case, your article was also assessed by an '
                                            'Academic Editor with relevant expertise and several '
                                            'independent reviewers. Based on the reviews, I regret '
                                            'that we will not be able to accept this manuscript '
                                            'for publication in the journal.',
                        'Reject-ED-RAR-ONE': 'While we cannot consider your manuscript further for '
                                             'publication in PLOS Wombat, we very much appreciate '
                                             'your wish to present your work in an Open Access '
                                             'publication and so suggest, as an alternative, '
                                             'submitting to PLOS ONE (www.plosone.org).',
                        'Reject-RAR-ONE': 'While we cannot consider your manuscript further for '
                                          'publication in PLOS Wombat, we very much appreciate '
                                          'your wish to present your work in an Open Access '
                                          'publication and so suggest, as an alternative, '
                                          'submitting to PLOS ONE (www.plosone.org).',
                        'Reject-RARAR-ONE': 'In this case, your article was also assessed by the '
                                            'Academic Editor who saw the original version and by '
                                            'several independent reviewers. Based on the reviews, '
                                            'I regret that we will not be able to accept this '
                                            'manuscript for publication in the journal. As you '
                                            'will see, the reviewers continue to have concerns '
                                            'about [...EDIT HERE....]. These seem to us '
                                            'sufficiently serious that we cannot encourage you to '
                                            'revise the manuscript further.',
                        'MajorRev': "In light of the reviews, we will not be able to accept the "
                                    "current version of the manuscript, but we would welcome "
                                    "resubmission of a much-revised version that takes into "
                                    "account the reviewers' comments.",
                        'MinorRev': 'Based on the reviews, we will probably accept this manuscript '
                                    'for publication, assuming that you are willing and able to '
                                    'modify the manuscript to address the remaining concerns '
                                    'raised by the reviewers.',
                        'Accept': "On behalf of my colleagues and the Academic Editor, [*INSERT "
                                  "AE'S NAME*], I am pleased to inform you that we will be "
                                  "delighted to publish your manuscript in PLOS Biology."}
    if decision == 'Accept':
      assert template_letters['Accept'] in letter_text, letter_text
    elif decision == 'Minor Revision':
      assert template_letters['MinorRev'] in letter_text, letter_text
    elif decision == 'Major Revision':
      assert template_letters['MajorRev'] in letter_text, letter_text
    else:
      if reject_selection == 'Editor Decision - Reject After Review':
        assert template_letters['Reject-ED-RAR'] in letter_text, letter_text
      elif reject_selection == 'Editor Decision - Reject After Review CJs':
        assert template_letters['Reject-ED-RAR-CJ'] in letter_text, letter_text
      elif reject_selection == 'Editor Decision - Reject After Review ONE':
        assert template_letters['Reject-ED-RAR-ONE'] in letter_text, letter_text
      elif reject_selection == 'Reject After Review ONE':
        assert template_letters['Reject-RAR-ONE'] in letter_text, letter_text
      else:
        assert template_letters['Reject-RARAR-ONE'] in letter_text, letter_text

  def register_decision(self, decision='', reject_template='', commit=True):
    """
    Register decision on publishing manuscript
    :param commit: boolean, default to True - determines whether to commit the decision by emailing
      the author, if false, just selects a draft.
    :param decision: decision to mark, accepted values:
    'Accept', 'Reject', 'Major Revision' and 'Minor Revision' if no decision, will be generated
    returns: decision (For the case where a random decision was specified) and reject_selection
        (if decision == 'Reject')
    :param reject_template: if you would like to specify an explicit template, pass it here.
      Valid selections are: 'Editor Decision - Reject After Review',
                            'Editor Decision - Reject After Review CJs',
                            'Editor Decision - Reject After Review ONE',
                            'Reject After Review ONE',
                            'Reject After Revision and Re-review ONE'
    """
    reject_selection = ''
    # APERTA-7502 This alert no longer exists, but it should
    # try:
    #   alert = self._get(self._status_alert)
    #   if 'A decision cannot be registered at this time. ' \
    #      'The manuscript is not in a submitted state.' in alert.text:
    #     raise ValueError('Manuscript is in unexpected state: {0}'.format(alert.text))
    # except ElementDoesNotExistAssertionError:
    #   logging.info('Manuscript is in submitted state.')
    if not decision:
      decision = self._make_a_decision()
    logging.info('Decision is {0}.'.format(decision))
    decision_d = {'Reject': 0, 'Major Revision': 1, 'Minor Revision': 2, 'Accept': 3}
    decision_labels = self._gets(self._decision_labels)
    # There needs to be a delay on load of the card, or the selection will not trigger the
    #   drawing of the form elements.
    time.sleep(1)
    decision_labels[decision_d[decision]].click()
    # Apparently there is some background work here that can put a spinner in the way
    # adding sleep to give it time
    time.sleep(3)
    if decision == 'Reject':
      default_selection = self._get(self._letter_template_reject_selected)
      assert 'Editor Decision - Reject After Review' in default_selection.text, \
          default_selection.text
      if not reject_template:
        reject_selection = random.choice(expected_reject_selections)
      else:
        reject_selection = reject_template
      logging.info('Rejection template selection is {0}'.format(reject_selection))
      template_selector = self._get(self._letter_template_reject_selector)
      template_selector.click()
      reject_selections = self._gets(self._letter_template_reject_selection)
      for selection in reject_selections:
          assert selection.text in expected_reject_selections, selection.text
      template_selector_input = self._get(self._letter_template_reject_search_input)
      template_selector_input.send_keys(reject_selection + Keys.ENTER)
    if commit:
      # click on register decision and email the author
      self._get(self._register_decision_button).click()
      # give some time to allow complete to check automatically
      time.sleep(2)
      self.click_close_button()
    return decision, reject_selection

  @staticmethod
  def _make_a_decision():
    """
    Return a random publishing decision
    :return: decision - one of Reject, Major Revision, Minor Revision or Accept - weighted equally
    """
    decisions = ['Reject',
                 'Major Revision',
                 'Minor Revision',
                 'Accept'
                 ]
    decision = random.choice(decisions)
    return decision
