#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import time

from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

from frontend.Tasks.basetask import BaseTask

__author__ = 'sbassi@plos.org'

class ReviewerReportTask(BaseTask):
  """
  Page Object Model for Reviewer Report Task
  """
  def __init__(self, driver):
    super(ReviewerReportTask, self).__init__(driver)
    # Locators - Instance members
    # Shared Locators
    self._review_note = (By.CSS_SELECTOR, 'div.reviewer-report-wrapper p strong')
    self._questions = (By.CLASS_NAME, 'question-text')
    self._questions_help = (By.CLASS_NAME, 'question-help')
    self._submit_button = (By.CLASS_NAME, 'button-primary')
    # Question one is the same regardless front-matter or research type - all other questions differ
    self._q1_accept_label = (By.CSS_SELECTOR, 'div.flex-group > label')
    self._q1_accept_radio = (By.CSS_SELECTOR, 'input[value=\'accept\']')
    self._q1_reject_label = (By.CSS_SELECTOR, 'div.flex-group > label + label')
    self._q1_reject_radio = (By.CSS_SELECTOR, 'input[value=\'reject\']')
    self._q1_majrev_label = (By.CSS_SELECTOR, 'div.flex-group > label + label + label')
    self._q1_majrev_radio = (By.CSS_SELECTOR, 'input[value=\'major_revision\']')
    self._q1_minrev_label = (By.CSS_SELECTOR, 'div.flex-group > label + label + label + label')
    self._q1_minrev_radio = (By.CSS_SELECTOR, 'input[value=\'minor_revision\']')
    # Research Reviewer Report locators
    self._res_q2_yes_label = (By.CSS_SELECTOR, '')
    self._res_q2_yes_radio = (By.CSS_SELECTOR, '')
    self._res_q2_no_label = (By.CSS_SELECTOR, '')
    self._res_q2_no_radio = (By.CSS_SELECTOR, '')
    self._res_q2_form = (By.CLASS_NAME, 'reviewer_report--competing_interests--detail')
    self._res_q3_form = (By.CLASS_NAME, 'reviewer_report--identity')
    self._res_q4_form = (By.CLASS_NAME, 'reviewer_report--comments_for_author')
    self._res_q5_form = (By.CLASS_NAME, 'reviewer_report--additional_comments')
    self._res_q6_form = (By.CLASS_NAME, 'reviewer_report--suitable_for_another_journal--journal')
    # Front Matter Reviewer Report locators




  # POM Actions
  def validate_task_elements_styles(self):
    """
    This method validates the styles of the task elements including the common tasks elements
    :return void function
    """
    self.validate_common_elements_styles()
    accrb = self._get(self._q1_accept_radio)
    self.validate_radio_button(accrb)
    acclbl = self._get(self._q1_accept_label)
    assert acclbl.text == 'Accept', acclbl.text
    self.validate_radio_button_label(acclbl)
    rejrb = self._get(self._q1_reject_radio)
    self.validate_radio_button(rejrb)
    rejlbl = self._get(self._q1_reject_label)
    assert rejlbl.text == 'Reject', acclbl.text
    self.validate_radio_button_label(rejlbl)
    majrevrb = self._get(self._q1_majrev_radio)
    self.validate_radio_button(majrevrb)
    majrevlbl = self._get(self._q1_majrev_label)
    assert majrevlbl.text == 'Major Revision', majrevlbl.text
    self.validate_radio_button_label(majrevlbl)
    minrevrb = self._get(self._q1_minrev_radio)
    self.validate_radio_button(minrevrb)
    minrevlbl = self._get(self._q1_minrev_label)
    assert majrevlbl.text == 'Major Revision', majrevlbl.text
    self.validate_radio_button_label(majrevlbl)
    question_list = self._gets(self._questions)
    q1, q2, q3, q4, q5, q6 = question_list
    for q in question_list:
      self.validate_application_list_style(q)
    question_help_list = self._gets(self._questions_help)
    qh2, qh3, qh4, qh5, qh6 = question_help_list
    for qh in question_help_list:
      self.validate_application_ptext(qh)

  def validate_reviewer_report(self, research_type=True):
    """
    Validates content of Reviewer Report task.
    :param research_type: If set to False, validates content against Front-Matter type report; when
      True uses research type reviewer report content
    :return None
    """
    self._wait_for_element(self._get(self._review_note))
    review_note = self._get(self._review_note)
    if research_type:
      assert u'Please refer to our referee guidelines for detailed instructions.' in \
          review_note.text
      assert '<a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines#loc-criteria-'\
          'for-publication">referee</a>' in review_note.get_attribute('innerHTML')
      question_list = self._gets(self._questions)
      q1, q2, q3, q4, q5, q6 = question_list
      assert q1.text == u'Please provide your publication recommendation:', q1.text
      assert q2.text == u'Do you have any potential or perceived competing interests that may '\
          u'influence your review?', q2.text
      assert q3.text == u'(Optional) If you\'d like your identity to be revealed to the authors, '\
          u'please include your name here.', q3.text
      assert q4.text == u'Add your comments to authors below.', q4.text
      assert q5.text == u'(Optional) If you have any additional confidential comments to the editor,'\
          u' please add them below.', q5.text
      assert q6.text == u'If the manuscript does not meet the standards of PLOS Biology, do you '\
          u'think it is suitable for another PLOS journal?', q6.text
      qh2, qh3, qh4, qh5, qh6 = self._gets(self._questions_help)
      assert qh2.text == u'Please review our Competing Interests policy and declare any potential'\
          u' interests that you feel the Editor should be aware of when considering your review.', \
          qh2.text
      assert qh3.text == u'Your name and review will not be published with the manuscript.', \
          qh3.text
      assert qh4.text == u'These comments will be transmitted to the author.', qh4.text
      assert qh5.text == u'Additional comments may include concerns about dual publication, '\
          u'research or publication ethics.\n\nThese comments will not be transmitted to the '\
          u'authors.', qh5.text
      assert qh6.text == u'If so, please specify which journal and whether you will be willing' \
          u' to continue there as reviewer. PLOS Wombat is committed to facilitate the transfer' \
          u' between journals of suitable manuscripts to reduce redundant review cycles, and we ' \
          u'appreciate your support.', qh6.text
    else:
      assert u'Please refer to our referee guidelines and information on our article ' \
                         u'types.' in review_note.text, review_note.text
      assert '<a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines#loc-criteria-' \
             'for-publication" target="_blank">referee</a>' in \
             review_note.get_attribute('innerHTML'), review_note.get_attribute('innerHTML')
      question_list = self._gets(self._questions)
      q1, q2, q3, q4, q5, q6 = question_list
      assert q1.text == u'Please provide your publication recommendation:', q1.text
      assert q2.text == u'Do you have any potential or perceived competing interests that may ' \
                        u'influence your review?', q2.text
      assert q3.text == u'Is this manuscript suitable in principle for the magazine section of ' \
                        u'PLOS Biology?', q3.text
      assert q4.text == u'If previously unpublished data are included to support the conclusions,' \
                        u' please note in the box below whether:', q4.text
      assert q5.text == u'(Optional) Please offer any additional confidential comments to the ' \
                        u'editor', q5.text
      assert q6.text == u'(Optional) If you\'d like your identity to be revealed to the authors, ' \
                        u'please include your name here.', q6.text
      qh2, qh3, qh4, qh5, qh6 = self._gets(self._questions_help)
      assert qh2.text == u'Please review our Competing Interests policy and declare any potential' \
                         u' interests that you feel the Editor should be aware of when ' \
                         u'considering your review. If you have no competing interests, please ' \
                         u'write: "I have no competing interests."', qh2.text
      assert qh3.text == u'Please refer to our referee guidelines and information on our article ' \
                         u'types.\nSubmit your detailed comments in the box below. These will be ' \
                         u'communicated to the authors.', qh3.text
      assert qh4.text == u'The data have been generated rigorously with relevant controls, ' \
                         u'replication and sample sizes, if applicable.\nThe data provided ' \
                         u'support the conclusions that are drawn.', qh4.text
      assert qh5.text == u'Additional comments may include concerns about dual publication, ' \
                         u'research or publication ethics.', qh5.text
      assert qh6.text == u'Your name and review will not be published with the manuscript.', \
          qh6.text
    submit_button = self._get(self._submit_button)
    assert submit_button.text == u'SUBMIT THIS REPORT', submit_button.text
    self.validate_primary_big_green_button_style(submit_button)
    # TODO: Check options when APERTA-7321 is ready
