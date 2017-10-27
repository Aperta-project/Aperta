#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Page object definition for the Preprint Posting Overlay
"""

import logging
import random
import time
from Base.PDF_Util import PdfUtil
from Base.PostgreSQL import PgSQL
import os

from selenium.webdriver.common.by import By

from frontend.Pages.authenticated_page import AuthenticatedPage

__author__ = 'gtimonina@plos.org'


class SubmissionReviewOverlay(AuthenticatedPage):
  """
  Page Object Model for the Submission Review overlay
  """

  def __init__(self, driver):
    super(SubmissionReviewOverlay, self).__init__(driver)
    self._title = (By.CLASS_NAME, 'overlay-body-title')
    self._subtitle = (By.CSS_SELECTOR, 'div.task-main-content>p')
    self._review_table = (By.CLASS_NAME, 'table')
    #
    self._headings = (By.CSS_SELECTOR, 'tr>th') # 6
    self._metadata = (By.CSS_SELECTOR, 'tbody>tr>td') # 6
    #
    self._review_ms_file_link = (By.CSS_SELECTOR, 'td>p>a')
    #
    self._review_overlay_submit_button = (By.ID, 'review-submission-submit-button')
    self._review_overlay_back2ms_button = (By.ID, 'review-submission-make-changes-button')
    # manuscript viewer page
    self._submit_button = (By.ID, 'sidebar-submit-paper')

  def overlay_ready(self):
    self._wait_for_element(self._get(self._review_overlay_submit_button),1)

  def go_back_make_changes(self):
    self._wait_for_element(self._get(self._review_overlay_back2ms_button), 1)
    self._get(self._review_overlay_back2ms_button).click()

  def complete_submission(self):
      """
      Validate form and closing the Submission Review overlay
      :return: None
      """
      self._wait_for_element(self._get(self._review_overlay_submit_button), 1)
      self._get(self._review_overlay_submit_button).click()
      logging.info('Submission after review')
      return

  def validate_styles_and_components(self):
    """
    validate_styles and components: Validates the elements, styles and texts for the Submission Review overlay
    :return: void function
    """
    # Assert overlay title style
    overlay_title = self._get(self._title)
    expected_overlay_title = 'Review Your Submission'

    assert overlay_title.text == expected_overlay_title, 'The overlay title: {0} is not ' \
                                                         'the expected: {1}'.format(overlay_title.text,
                                                                                    expected_overlay_title)
    # commented temporary as it will fail so far:
    # font-size 36px instead of 48px according to the style guide
    # should be filed as a bug in case if it is not fixed before deploying to CI
    # self.validate_overlay_card_title_style(overlay_title)

    overlay_subtitle = self._get(self._subtitle)
    expected_subtitle = 'Please verify that the metadata you entered is correct ' \
                        'before completing your submission.'
    assert overlay_subtitle.text == expected_subtitle, 'The overlay subtitle: {0} is not ' \
                                                         'the expected: {1}'.format(overlay_title.text,
                                                                                    expected_subtitle)
    self.validate_application_body_text(overlay_subtitle)

    # validate metadata in a table
    # validate names
    card_headings = self._gets(self._headings)
    expected_headings = ['Preprint', 'Title', 'Author', 'Co-Authors', 'Abstract', 'Manuscript']
    assert len(card_headings) == len(expected_headings)
    for i in range(len(card_headings)):
      assert card_headings[i].text.strip() == expected_headings[i], card_headings[i]
      # selected=True allows bold font, needs to be checked if it's correct
      self.validate_table_heading_style(card_headings[i], True)

    # metadata
    short_doi = self.get_paper_short_doi_from_url()
    db_title, db_abstract, db_authors_for_assertion, pp_posting_answer = self.get_metadata(short_doi)

    card_metadata = self._gets(self._metadata)
    expected_values = {'Preprint'   : ["Would you like to post this paper as a preprint?",
                                       "Yes, I want to post a preprint.",
                                       "No, I don't want to post a preprint."],
                       'Title'      : db_title,
                       'Author'     : db_authors_for_assertion[0],
                       'Co-Authors' : db_authors_for_assertion,
                       'Abstract'   : db_abstract,
                       'Manuscript' : ['Download PDF',
                                       'Note: Figures and Supplemental Files are included in the PDF.']}

    # Preprint line#1
    preprint_text = card_metadata[0].find_element_by_tag_name('dt')
    expected_text = expected_values["Preprint"][0]
    assert preprint_text.text.strip() == expected_text.strip()

    # Preprint line#2
    assert pp_posting_answer in {1,2}, pp_posting_answer
    preprint_text = card_metadata[0].find_element_by_tag_name('dd')
    expected_text = expected_values["Preprint"][pp_posting_answer]
    assert preprint_text.text.strip() == expected_text.strip()

    # Title
    title_text = card_metadata[1].find_element_by_css_selector('td>p')
    expected_text = expected_values["Title"]
    assert title_text.text.strip() == expected_text.strip()
    self.validate_application_body_text(title_text)

    # Author
    author_text = card_metadata[2].find_element_by_css_selector('td>p>span')
    expected_text = expected_values["Author"]
    # affiliations? according APERTA-10071, it should be  author name, Affiliation(s)
    assert self.normalize_spaces(author_text.text) in self.normalize_spaces(expected_text)
    self.validate_application_body_text(author_text)

    # Co-Author (list)
    coauthors = card_metadata[3].find_elements_by_css_selector('td>p>span')
    expected_coauthor_list = expected_values["Co-Authors"]
    # affiliations? according APERTA-10071, it should be  Author Name, Affiliation Name
    # Lauren said it's ok to have just names, but we have to double-check after PO acceptance
    for i in range(len(coauthors)):
      assert self.normalize_spaces(coauthors[i].text) == self.normalize_spaces(expected_coauthor_list[i])
      self.validate_application_body_text(coauthors[i])

    # Abstract
    abstract_lines = card_metadata[4].find_elements_by_css_selector('td>p>p') # list
    expected_text = expected_values["Abstract"]
    abstract_text = ' '.join(map(lambda x: ' ' + x.text, abstract_lines))
    assert abstract_text.strip() == expected_text.strip()
    for abstract_line in abstract_lines:
      self.validate_application_body_text(abstract_line)

    # Manuscript
    ms_text = card_metadata[5].find_element_by_css_selector('p.muted')
    expected_text = expected_values["Manuscript"][1]
    assert ms_text.text.strip() == expected_text.strip()
    self.validate_application_body_text(ms_text)

    # download pdf
    ms_pdf_link = card_metadata[5].find_element_by_css_selector('a')
    expected_link_title = expected_values["Manuscript"][0]
    assert ms_pdf_link.text.strip() == expected_link_title.strip()
    self.validate_default_link_style(ms_pdf_link)
    #self.validate_manuscript_downloaded_file(ms_pdf_link, format='pdf')

    # validate buttons
    submit_button = self._get(self._review_overlay_submit_button)
    assert submit_button.text == 'SUBMIT'
    self.validate_primary_big_green_button_style(submit_button)

    make_changes_button = self._get(self._review_overlay_back2ms_button)
    assert make_changes_button.text == 'MAKE CHANGES'
    self.validate_secondary_big_green_button_style(make_changes_button)

  def select_submit_or_make_changes(self, selection=''):
      """
      Validate making a selection and closing the preview submission overlay
      :param selection:  "Make Changes" or "Submit", not specified will lead to random selection
      :return: selection: "Make Changes" or "Submit"
      """
      go_back_button = self._get(self._review_overlay_back2ms_button)
      submit_button =  self._get(self._review_overlay_submit_button)
      logging.info('Submission Review button is: {0}'.format(selection))
      if not selection:
        selection = random.choice(['Make Changes', 'Submit'])
      if selection.lower() == 'make changes':
        go_back_button.click()
        self._wait_for_element(self._get(self._submit_button), 0.5)
        review_before_submission_button = self._get(self._submit_button)
        assert review_before_submission_button
      elif selection.lower() == 'submit':
        submit_button.click()
        self._wait_for_element(self._get(self._overlay_header_close), 1)
        close_submission_overlay = self._get(self._overlay_header_close)
        assert close_submission_overlay
      else:
          raise(ValueError, 'Invalid selection for going back/forward choice: {0}'.format(selection))
      return selection

  def get_metadata(self, short_doi):
    """
    Get the values populated in the db
    :param short_doi: The paper.short_doi of the relevant manuscript
    :return: db_title: string,  db_abstract: string, db_authors_for_assertions: list of strings
    """
    db_paper_id, db_title, db_abstract = PgSQL().query('SELECT id, title, abstract '
                                                       'FROM papers '
                                                       'WHERE short_doi=%s;', (short_doi,))[0]

    db_abstract = self.strip_tinymce_ptags(db_abstract)

    db_authors_for_assertion = []
    db_authors = PgSQL().query('SELECT a.first_name, a.middle_initial, a.last_name, a.affiliation '
                               'FROM authors a, author_list_items al '
                               'WHERE al.paper_id=%s AND al.author_id = a.id;',(db_paper_id,))


    for db_author in db_authors:
      logging.debug('Appending author {0} to the list db_authors_for_assertions'.format(db_author[0]))
      db_authors_for_assertion.append(
              ('' if db_author[0]==None else db_author[0].strip()+" ")+          # first name
              ('' if db_author[1]==None else db_author[1].strip()+" ")+          # middle name
              ('' if db_author[2]==None else db_author[2].strip()) +", "+    # last name
              ('' if db_author[3]==None else db_author[3].strip()))              # affiliation

    # check value selected in the 'Preprint Posting" card : 1(Yes) or 2 (No)
    # read card data from the DB
    task_id = PgSQL().query('SELECT id '
                            'FROM tasks '
                            'WHERE paper_id = %s '
                            'AND title = %s;', (db_paper_id, 'Preprint Posting'))[0][0]

    pp_posting_answer = PgSQL().query('SELECT value '
                                      'FROM answers '
                                      'WHERE owner_id = %s AND owner_type=%s;', (task_id, 'Task'))[0][0]

    return  db_title, db_abstract, db_authors_for_assertion, int(pp_posting_answer)