#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Page object definition for the Submission Review Overlay
"""

import logging
import random

from selenium.webdriver.common.by import By

from Base.PostgreSQL import PgSQL
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
        self._headings = (By.CSS_SELECTOR, 'tr>th')
        self._metadata = (By.CSS_SELECTOR, 'tbody>tr>td')
        self._abstract = (By.CSS_SELECTOR, 'td>p')
        self._manuscript = (By.CSS_SELECTOR, 'p.muted')
        self._review_ms_file_link = (By.CSS_SELECTOR, 'td>p>a')
        self._review_overlay_submit_button = (By.ID, 'review-submission-submit-button')
        self._edit_submission_button = (By.ID, 'review-submission-make-changes-button')
        # relative locators to validate metadata in the table
        self._preprint_text = (By.TAG_NAME, 'dt')
        self._posting_answer = (By.TAG_NAME, 'dd')
        self._title_text = (By.CSS_SELECTOR, 'td>p')
        self._author_text = (By.CSS_SELECTOR, 'td>p>span')
        self._ms_link = (By.TAG_NAME, 'a')

        # manuscript viewer page
        self._submit_button = (By.ID, 'sidebar-submit-paper')

    def overlay_ready(self):
        """"Ensure the overlay is ready to test"""
        # for some reason the last element that is showing up is the Abstract text, we are waiting
        # for all 6 elements to be presented on the overlay, and it is ready to be tested
        self._wait_on_lambda(lambda: len(self._gets(self._metadata)) == 6)

    def go_back_edit_submission(self):
        """"
        Go back to Manuscript View by clicking on the 'Make changes' button
        """
        self._wait_for_element(self._get(self._edit_submission_button), 1)
        self._get(self._edit_submission_button).click()

    def complete_submission(self):
        """
        Validate form and close the Submission Review overlay
        :return: Void function
        """
        self._wait_for_element(self._get(self._review_overlay_submit_button), 1)
        self._get(self._review_overlay_submit_button).click()
        logging.info('Submission after review')

    def validate_styles_and_components(self):
        """
        validate_styles and components: Validates the elements, styles and texts for the
        Submission Review overlay
        :return: void function
        """
        # Assert overlay title style
        overlay_title = self._get(self._title)
        expected_overlay_title = 'Review Your Submission'

        assert overlay_title.text == expected_overlay_title, \
            'The overlay title: {0} is not the expected: {1}'\
            .format(overlay_title.text, expected_overlay_title)

        # commented until APERTA-11857 gets resolved:
        # font-size is 36px instead of 48px according to the style guide
        # self.validate_overlay_card_title_style(overlay_title)
        journal_name = 'PLOS Wombat'
        short_doi = self.get_paper_short_doi_from_url()
        # get metadata from db
        db_title, db_abstract, db_authors_for_assertion, pp_posting_answer = self.get_metadata(
                short_doi)
        overlay_subtitle = self._gets(self._subtitle)
        expected_subtitle_line1 = 'You are about to submit your manuscript to {0}. ' \
                                  'Please verify that the information below is correct.'\
            .format(journal_name)

        assert overlay_subtitle[0].text == expected_subtitle_line1, \
            'The overlay subtitle, line 1: {0} is not ' \
            'the expected: {1}'.format(overlay_subtitle[0].text, expected_subtitle_line1)
        self.validate_application_body_text(overlay_subtitle[0])
        if pp_posting_answer:
            assert len(
                overlay_subtitle) == 2, '{0} text lines displayed while 2 lines are expected ' \
                                        'in the subtitle if the submitter opted in to preprint ' \
                                        'posting'.format(str(len(overlay_subtitle)))
            expected_subtitle_line2 = 'This information will also appear with the preprint you ' \
                                      'have elected to post on apertarxiv.org.'

            assert overlay_subtitle[1].text.strip() == expected_subtitle_line2, \
                'The overlay subtitle, line 2: {0} is not the expected: {1}' \
                .format(overlay_subtitle[1].text, expected_subtitle_line2)
            self.validate_application_body_text(overlay_subtitle[1])

        # validate metadata in a table
        # validate names
        card_headings = self._gets(self._headings)
        expected_headings = ['Preprint', 'Title', 'Author', 'Coauthors', 'Abstract', 'Manuscript']
        assert len(card_headings) == len(expected_headings)
        for i, card_heading in enumerate(card_headings):
            assert card_heading.text.strip() == expected_headings[i], card_heading
            self.validate_table_heading_style(card_heading, True)

        card_metadata = self._gets(self._metadata)
        expected_values = {
            'Preprint': ['Would you like to post this paper as a preprint?',
                         'Yes, I want to post a preprint.',
                         "No, I don't want to post a preprint."],
            'Title': db_title,
            'Author': db_authors_for_assertion[0],
            'Coauthors': db_authors_for_assertion[1:],
            'Abstract': db_abstract,
            'Manuscript': ['Manuscript (review version with figures and supporting information '
                           'files included)',
                           'This is the review version of your manuscript, which includes figures '
                           'and supplemental information.',
                           'In your posted preprint, figures will be inserted in the manuscript '
                           'text and supporting information files will be available via links on '
                           'the preprint page.']}

        # Preprint line#1
        preprint_text = card_metadata[0].find_element(*self._preprint_text)
        expected_text = expected_values['Preprint'][0]
        assert preprint_text.text.strip() == expected_text.strip(), preprint_text.text.strip()

        # Preprint line#2 - depends on the preprint posting answer
        assert pp_posting_answer in {True, False}, pp_posting_answer
        preprint_text = card_metadata[0].find_element(*self._posting_answer)
        answer_index = 1 if pp_posting_answer else 2
        expected_text = expected_values['Preprint'][answer_index]
        assert preprint_text.text.strip() == expected_text.strip(), preprint_text.text.strip()

        # Title
        title_text = card_metadata[1].find_element(*self._title_text)
        expected_text = expected_values['Title']
        assert title_text.text.strip() == expected_text.strip(), title_text.text.strip()
        self.validate_application_body_text(title_text)

        # Author
        author_text = card_metadata[2].find_element(*self._author_text)
        expected_text = self.normalize_spaces(expected_values['Author'])
        assert self.normalize_spaces(author_text.text) == expected_text, \
            'Invalid Author representation on the page: {0}, expected: {1}' \
            .format(self.normalize_spaces(author_text.text), expected_text)
        self.validate_application_body_text(author_text)

        # Co-Author (list) might be empty, if there are no co-authors
        coauthors = card_metadata[3].find_elements(*self._author_text)
        expected_coauthor_list = expected_values['Coauthors']
        for i, coauthor in enumerate(coauthors):
            assert self.normalize_spaces(coauthor.text) == \
                   self.normalize_spaces(expected_coauthor_list[i]), \
                   'Invalid Co-Authors representation on the page: {0}, expected: {1}' \
                   .format(self.normalize_spaces(coauthor.text), self.normalize_spaces(
                           expected_coauthor_list[i]))
            self.validate_application_body_text(coauthor)

        # Abstract
        abstract_text = card_metadata[4].find_element(*self._abstract)
        expected_text = self.normalize_spaces(expected_values['Abstract'])
        assert self.normalize_spaces(abstract_text.text) == expected_text, \
            'Invalid Abstract text on the page: {0}, expected: {1}' \
            .format(self.normalize_spaces(abstract_text.text), expected_text)

        # Manuscript
        ms_text = card_metadata[5].find_elements(*self._manuscript)
        expected_text = expected_values['Manuscript'][1]
        assert ms_text[0].text.strip() == expected_text.strip(), ms_text[0].text.strip()
        self.validate_application_body_text(ms_text[0])

        if pp_posting_answer:
            assert len(
                ms_text) == 2, '{0} text lines displayed for the manuscript while 2 lines are ' \
                               'expected if the submitter opted in to preprint posting' \
                .format(str(len(ms_text)))
            expected_text = expected_values['Manuscript'][2]
            assert ms_text[1].text.strip() == expected_text.strip(), ms_text[1].text.strip()
            self.validate_application_body_text(ms_text[1])

        # download pdf
        ms_pdf_link = card_metadata[5].find_element(*self._ms_link)
        expected_link_title = expected_values['Manuscript'][0]
        assert ms_pdf_link.text.strip() == expected_link_title.strip(), ms_pdf_link.text.strip()
        self.validate_default_link_style(ms_pdf_link)

        # validate buttons
        submit_button = self._get(self._review_overlay_submit_button)
        assert submit_button.text == 'SUBMIT'
        self.validate_primary_big_green_button_style(submit_button), submit_button.text

        edit_submission = self._get(self._edit_submission_button)
        assert edit_submission.text == 'EDIT SUBMISSION', edit_submission.text
        self.validate_secondary_big_green_button_style(edit_submission)

    def select_submit_or_edit_submission(self, selection=''):
        """
        Validate making a selection and closing the preview submission overlay
        :param selection:  "edit submission" or "submit", not specified will lead to random
        selection
        :return: selection: "edit submission" or "submit"
        """
        if selection:
            assert selection.lower() in ['edit submission', 'submit'], \
                'Invalid selection for going back/forward choice: {0}'.format(selection)
        if not selection:
            selection = random.choice(['edit submission', 'submit'])
        logging.info('Submission Review button is: {0}'.format(selection))
        if selection.lower() == 'edit submission':
            # go_back_button.click()
            self.go_back_edit_submission()
            self._wait_for_element(self._get(self._submit_button), 0.5)
        elif selection.lower() == 'submit':
            # submit_button.click()
            self.complete_submission()
            self._wait_for_element(self._get(self._overlay_header_close), 1)
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
        db_authors = PgSQL().query(
                'SELECT a.first_name, a.middle_initial, a.last_name, '
                'a.affiliation, a.secondary_affiliation, ga.name, al.author_type '
                'FROM  author_list_items al LEFT JOIN authors a '
                'ON al.author_id = a.id '
                'LEFT JOIN group_authors ga ON al.author_id = ga.id '
                'WHERE al.paper_id=%s '
                'ORDER BY al.position;', [db_paper_id])

        for db_author in db_authors:
            logging.debug(
                'Appending author {0} to the list db_authors_for_assertions'.format(db_author[0]))
            if db_author[6] == 'GroupAuthor':
                db_authors_for_assertion.append(db_author[5].strip())
            else:
                author_name = \
                    ('' if db_author[0] is None else db_author[0].strip() + " ") + \
                    ('' if db_author[1] is None else db_author[1].strip() + " ") + \
                    ('' if db_author[2] is None else db_author[2].strip())  # last name
                author_affiliations = \
                    ('' if db_author[3] is None else db_author[3].strip()) + \
                    ('' if db_author[4] is None else ', {0}'.format(db_author[4].strip()))
                author_info = '{0}, {1}'.format(author_name, author_affiliations)
                db_authors_for_assertion.append(author_info)

        # check value selected in the 'Preprint Posting" card : 1(Yes) or 2 (No)
        # read card data from the DB
        task_id = PgSQL().query('SELECT id '
                                'FROM tasks '
                                'WHERE paper_id = %s '
                                'AND title = %s;', (db_paper_id, 'Preprint Posting'))[0][0]

        pp_posting_answer = PgSQL().query('SELECT value '
                                          'FROM answers '
                                          'WHERE owner_id = %s AND owner_type=%s;',
                                          (task_id, 'Task'))[0][0]

        pp_posting_answer = True if pp_posting_answer == 't' else False

        return db_title, db_abstract, db_authors_for_assertion, pp_posting_answer
