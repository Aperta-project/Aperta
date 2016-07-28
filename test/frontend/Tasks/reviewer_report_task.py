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
    self._review_note = (By.CSS_SELECTOR, 'div.reviewer-report-wrapper p strong')
    self._questions = (By.CLASS_NAME, 'question-text')
    self._questions_help = (By.CLASS_NAME, 'question-help')
    self._q2_form = (By.CLASS_NAME, 'reviewer_report--competing_interests--detail')
    self._q3_form = (By.CLASS_NAME, 'reviewer_report--identity')
    self._q4_form = (By.CLASS_NAME, 'reviewer_report--comments_for_author')
    self._q5_form = (By.CLASS_NAME, 'reviewer_report--additional_comments')
    self._q6_form = (By.CLASS_NAME, 'reviewer_report--suitable_for_another_journal--journal')
    self._submit_button = (By.CLASS_NAME, 'button-primary')

  # POM Actions
  def validate_task_elements_styles(self):
    """
    This method validates the styles of the task elements including the common tasks elements
    :return void function
    """
    self.validate_common_elements_styles()

  def validate_reviewer_report(self):
    """
    Validates content of Reviewer Report task.
    :return None
    """
    time.sleep(.5)
    review_note = self._get(self._review_note)
    assert u'Please refer to our referee guidelines for detailed instructions.' in \
        review_note.text
    assert '<a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines#loc-criteria-'\
        'for-publication">referee</a>' in review_note.get_attribute('innerHTML')
    question_list = self._gets(self._questions)
    q1, q2, q3, q4, q5, q6 = question_list
    assert q1.text == u'Please provide your publication recommendation:', q1.text
    assert q2.text == u'Do you have any potential or perceived competing interests that may '\
        'influence your review?', q2.text
    assert q3.text == u"(Optional) If you'd like your identity to be revealed to the authors, please '\
        'include your name here.", q3.text
    assert q4.text == u'Add your comments to authors below.', q4.text
    assert q5.text == u'(Optional) If you have any additional confidential comments to the editor, '\
        'please add them below.', q5.text
    assert q6.text == u'If the manuscript does not meet the standards of PLOS Biology, do you '\
        'think it is suitable for another PLOS journal?', q6.text
    qh2, qh3, qh4, qh5, qh6 = self._gets(self._questions_help)
    assert qh2.text == u'Please review our Competing Interests policy and declare any potential'\
        ' interests that you feel the Editor should be aware of when considering your review.', \
        qh2.text
    assert qh3.text == u'Your name and review will not be published with the manuscript.', \
        qh3.text
    assert qh4.text == u'These comments will be transmitted to the author.', qh4.text
    assert qh5.text == u'Additional comments may include concerns about dual publication, '\
        'research or publication ethics.\n\nThese comments will not be transmitted to the '\
        'authors.', qh5.text
    assert qh6.text == u'If so, please specify which journal and whether you will be willing'\
        ' to continue there as reviewer. PLOS Biology is committed to facilitate the transfer'\
        ' between journals of suitable manuscripts to reduce redundant review cycles, and we '\
        'appreciate your support.', qh6.text
    submit_button = self._get(self._submit_button)
    assert submit_button.text == u'SUBMIT THIS REPORT', submit_button.text
    self.validate_primary_big_green_button_style(submit_button)
    # TODO: Check options when APERTA-7321 is ready
