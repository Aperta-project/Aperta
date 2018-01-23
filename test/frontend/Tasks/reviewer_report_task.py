#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import logging
from random import choice
import time

from loremipsum import generate_paragraph

from selenium.webdriver.common.by import By

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
        self._question_block = (By.CSS_SELECTOR, 'li.question')
        self._questions = (By.CLASS_NAME, 'question-text')
        self._questions_help = (By.CSS_SELECTOR, 'ul.question-help')
        self._submit_button = (By.CLASS_NAME, 'button-primary')
        self._submit_confirm_text = (By.CLASS_NAME, 'reviewer-report-confirmation')
        self._submit_confirm_yes_btn = (
            By.CSS_SELECTOR, 'div.reviewer-report-confirmation > button')
        self._submit_confirm_no_btn = (By.CSS_SELECTOR,
                                       'div.reviewer-report-confirmation > button + button')
        self._submitted_status = (By.CLASS_NAME, 'long-status')
        # Question one is the same regardless front-matter or research type - all other questions
        # differ
        self._q1_accept_label = (By.CSS_SELECTOR, 'div.flex-group > label')
        self._q1_accept_radio = (By.CSS_SELECTOR, 'input[value=\'accept\']')
        self._q1_reject_label = (By.CSS_SELECTOR, 'div.flex-group > label + label')
        self._q1_reject_radio = (By.CSS_SELECTOR, 'input[value=\'reject\']')
        self._q1_majrev_label = (By.CSS_SELECTOR, 'div.flex-group > label + label + label')
        self._q1_majrev_radio = (By.CSS_SELECTOR, 'input[value=\'major_revision\']')
        self._q1_minrev_label = (By.CSS_SELECTOR, 'div.flex-group > label + label + label + label')
        self._q1_minrev_radio = (By.CSS_SELECTOR, 'input[value=\'minor_revision\']')
        # Research Reviewer Report locators
        # Note these must be used with a find to be unique
        self._res_yes_label = (By.CSS_SELECTOR, 'div.ember-view > label')
        self._res_yes_radio = (By.CSS_SELECTOR, 'div.ember-view > label > input')
        self._res_no_label = (By.CSS_SELECTOR, 'div.ember-view > label + label')
        self._res_no_radio = (By.CSS_SELECTOR, 'div.ember-view > label + label > input')
        self._res_q2_form = (By.NAME, 'reviewer_report--competing_interests--detail')
        self._res_q3_form = (By.NAME, 'reviewer_report--identity')
        self._res_q4_form = (By.NAME, 'reviewer_report--comments_for_author')
        self._res_q5_form = (By.NAME, 'reviewer_report--additional_comments')
        self._res_q6_form = (By.NAME, 'reviewer_report--suitable_for_another_journal--journal')
        self._res_q7_question = (By.CSS_SELECTOR, 'div.reviewer_report--attachments-question-text')
        self._res_q7_explain = (
            By.CSS_SELECTOR, 'div.reviewer_report--attachments-question-text > p')
        self._res_q7_file_link = (By.CSS_SELECTOR, 'div.attachment-item > a')
        self._res_q7_file_replace = (
            By.CSS_SELECTOR, 'div.attachment-item > span.replace-attachment')
        self._res_q7_file_delete = (By.CSS_SELECTOR, 'div.attachment-item > span.delete-attachment')
        self._res_q7_upload_btn = (By.CSS_SELECTOR, 'div.attachment-manager > div.fileinput-button')
        # The following locators (except res_q6_ans) must be used with a find under each question
        # block
        self._res_q1_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q2_answer_bool = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q2_answer = (By.CSS_SELECTOR,
                               'div[data-editor = "reviewer_report--competing_interests--detail"]'
                               ' > div.answer-text')
        self._res_q3_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q4_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q5_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q6_answer_bool = (By.CSS_SELECTOR, 'div.answer-text')
        self._res_q6_answer = \
            (By.CSS_SELECTOR,
             'div[data-editor = "reviewer_report--suitable_for_another_journal--journal"] > '
             'div.answer-text')
        # Front Matter Reviewer Report locators
        # Note these must be used with a find to be unique
        self._fm_yes_label = (By.CSS_SELECTOR, 'div.yes-no-with-comments > div > label')
        self._fm_yes_radio = (By.CSS_SELECTOR, 'div.yes-no-with-comments > div > label > input')
        self._fm_no_label = (By.CSS_SELECTOR, 'div.yes-no-with-comments > div > label + label')
        self._fm_no_radio = (By.CSS_SELECTOR,
                             'div.yes-no-with-comments > div > label + label > input')
        self._fm_q2_form = (By.NAME, 'front_matter_reviewer_report--competing_interests')
        self._fm_q3_form = (By.NAME, 'front_matter_reviewer_report--suitable--comment')
        self._fm_q4_form = (By.NAME,
                            'front_matter_reviewer_report--includes_unpublished_data--explanation')
        self._fm_q5_form = (By.NAME, 'front_matter_reviewer_report--additional_comments')
        self._fm_q6_form = (By.NAME, 'front_matter_reviewer_report--identity')
        # The following locators must be used with a find under each question block
        self._fm_q1_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._fm_q2_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._fm_q3_answer_bool = (By.CSS_SELECTOR, 'div.answer-text')
        self._fm_q3_answer = (By.CSS_SELECTOR, 'div.additional-data div.answer-text')
        self._fm_q4_answer_bool = (By.CSS_SELECTOR, 'div.answer-text')
        self._fm_q4_answer = (By.CSS_SELECTOR, 'div.additional-data div.answer-text')
        self._fm_q5_answer = (By.CSS_SELECTOR, 'div.answer-text')
        self._fm_q6_answer = (By.CSS_SELECTOR, 'div.answer-text')

    # POM Actions
    def validate_task_elements_styles(self, research_type=True):
        """
        This method validates the styles of the task elements including the common tasks elements
        :param research_type: boolean, determines whether elements will be validated as a research
          type reviewer report (default) or a front-matter type report.
        :return void function
        """
        time.sleep(2)
        # First the global elements/sytles
        # self.validate_common_elements_styles() # not working - button.task-completed is no longer
        # there
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
        self._get(self._q1_minrev_label)
        assert majrevlbl.text == 'Major Revision', majrevlbl.text
        self.validate_radio_button_label(majrevlbl)
        question_block_list = self._gets(self._question_block)
        qb1, qb2, qb3, qb4, qb5, qb6, qb7 = question_block_list
        question_list = self._gets(self._questions)
        for q in question_list:
            self.validate_application_list_style(q)
            # APERTA-11450
            # question_help_list = self._gets(self._questions_help)
            # for qh in question_help_list:
            # self.validate_application_body_text(qh)
        # Then the specific styles
        if research_type:
            q2yeslbl = qb2.find_element(*self._res_yes_label)
            assert q2yeslbl.text == 'Yes', q2yeslbl.text
            self.validate_radio_button_label(q2yeslbl)
            q2yesradio = qb2.find_element(*self._res_yes_radio)
            self.validate_radio_button(q2yesradio)
            q2nolbl = qb2.find_element(*self._res_no_label)
            assert q2nolbl.text == 'No', q2nolbl.text
            self.validate_radio_button_label(q2nolbl)
            q2noradio = qb2.find_element(*self._res_no_radio)
            self.validate_radio_button(q2noradio)
            q6yeslbl = qb6.find_element(*self._res_yes_label)
            assert q6yeslbl.text == 'Yes', q6yeslbl.text
            self.validate_radio_button_label(q6yeslbl)
            q6yesradio = qb6.find_element(*self._res_yes_radio)
            self.validate_radio_button(q6yesradio)
            q6nolbl = qb6.find_element(*self._res_no_label)
            assert q6nolbl.text == 'No', q6nolbl.text
            self.validate_radio_button_label(q6nolbl)
            q6noradio = qb6.find_element(*self._res_no_radio)
            self.validate_radio_button(q6noradio)
            q7uplbtn = qb7.find_element(*self._res_q7_upload_btn)
            assert q7uplbtn.text == 'UPLOAD FILE'

            # Research reviewer report competing interests question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--competing_interests--detail')
            # RT stands for Research Type Reviewer Report, rte for rich text editor
            logging.info('RT Competing Interests rte instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
            # Research reviewer report identity for authors question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--identity')
            logging.info('RT Identity for Author rte instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
            # Research reviewer report comments for authors question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--comments_for_author')
            logging.info('RT Comments for Author rte instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
            # Research reviewer report comments to editor question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--additional_comments')
            logging.info('RT Comments to Editor rte instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
            # Research reviewer report suitable other journal question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                        'reviewer_report--suitable_for_another_journal--journal')
            logging.info('RT Suitability to other PLOS journal Editor instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
        else:
            q3yeslbl = qb3.find_element(*self._fm_yes_label)
            assert q3yeslbl.text == 'Yes', q3yeslbl.text
            self.validate_radio_button_label(q3yeslbl)
            q3yesradio = qb3.find_element(*self._fm_yes_radio)
            self.validate_radio_button(q3yesradio)
            q3nolbl = qb3.find_element(*self._fm_no_label)
            assert q3nolbl.text == 'No', q3nolbl.text
            self.validate_radio_button_label(q3nolbl)
            q3noradio = qb3.find_element(*self._fm_no_radio)
            self.validate_radio_button(q3noradio)
            q4yeslbl = qb4.find_element(*self._fm_yes_label)
            assert q4yeslbl.text == 'Yes', q4yeslbl.text
            self.validate_radio_button_label(q4yeslbl)
            q4yesradio = qb4.find_element(*self._fm_yes_radio)
            self.validate_radio_button(q4yesradio)
            q4nolbl = qb4.find_element(*self._fm_no_label)
            assert q4nolbl.text == 'No', q4nolbl.text
            self.validate_radio_button_label(q4nolbl)
            q4noradio = qb4.find_element(*self._fm_no_radio)
            self.validate_radio_button(q4noradio)
            # Front matter competing insterests question
            fm_ci_tinymce_editor_instance_id, fm_ci_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--competing_interests')
            logging.info('FM Competing Interests Editor instance '
                         'is: {0}'.format(fm_ci_tinymce_editor_instance_id))
            # Front matter suitability for PLOS Biology question
            fm_suitable_tinymce_editor_instance_id, fm_suitable_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--suitable--comment')
            logging.info('FM Competing Interests Editor instance '
                         'is: {0}'.format(fm_suitable_tinymce_editor_instance_id))
            # Front matter unpublished data question
            fm_ud_tinymce_editor_instance_id, fm_ud_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                        'front_matter_reviewer_report--includes_unpublished_data--explanation')
            logging.info('FM Competing Interests Editor instance '
                         'is: {0}'.format(fm_ud_tinymce_editor_instance_id))
            # Front matter editor comments question
            fm_ed_tinymce_editor_instance_id, fm_ed_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--additional_comments')
            logging.info('FM Competing Interests Editor instance '
                         'is: {0}'.format(fm_ed_tinymce_editor_instance_id))
            # Front matter identity for authors question
            fm_ifa_tinymce_editor_instance_id, fm_ifa_tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('front_matter_reviewer_report--identity')
            logging.info('FM Competing Interests Editor instance '
                         'is: {0}'.format(fm_ifa_tinymce_editor_instance_id))
        submit_btn = self._get(self._submit_button)
        assert submit_btn.text == 'SUBMIT THIS REPORT', submit_btn.text
        self.validate_primary_big_green_button_style(submit_btn)
        self._scroll_into_view(qb6)
        # Need to move to an appropriate place so this button is not under the toolbar.
        self._actions.move_to_element(qb6).perform()
        submit_btn.click()
        confirm_text = self._get(self._submit_confirm_text)
        assert 'Once you submit the report, you will no longer be able to edit it. Are you sure?' \
               in confirm_text.text, confirm_text.text
        # APERTA-8079
        # self.validate_application_h4_style(confirm_text)
        confirm_yes = self._get(self._submit_confirm_yes_btn)
        assert confirm_yes.text == 'YES, I’M SURE', confirm_yes.text
        self.validate_primary_big_green_button_style(confirm_yes)
        confirm_no = self._get(self._submit_confirm_no_btn)
        assert confirm_no.text == 'NO', confirm_no.text
        self.validate_secondary_big_green_button_style(confirm_no)
        confirm_no.click()

    def validate_reviewer_report_edit_mode(self, journal, research_type=True):
        """
        Validates content of Reviewer Report task.
        :param journal: Journal in which the paper for report is registered
        :param research_type: If set to False, validates content against Front-Matter type report;
          when True uses research type reviewer report content
        :return None
        """
        logging.info('Validating reviewer report')
        self._wait_for_element(self._get(self._review_note))
        review_note = self._get(self._review_note)
        if research_type:
            assert 'Please refer to our reviewer guidelines for detailed instructions.' in \
                   review_note.text
            assert '<a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines#loc-' \
                   'criteria-for-publication">reviewer</a>' \
                   in review_note.get_attribute('innerHTML')
            question_list = self._gets(self._questions)
            q1, q2, q3, q4, q5, q6, q7 = question_list
            assert q1.text == 'Please provide your publication recommendation:', q1.text
            assert q2.text == 'Do you have any potential or perceived competing interests that ' \
                              'may influence your review?', q2.text
            assert q3.text == '(Optional) If you\'d like your identity to be revealed to the ' \
                              'authors, please include your name here.', q3.text
            assert q4.text == 'Please add your review comments to authors below.', q4.text
            assert q5.text == '(Optional) If you have any additional confidential comments to ' \
                              'the editor, please add them below.', q5.text
            assert q6.text == 'If the manuscript does not meet the standards of PLOS Biology, ' \
                              'do you think it is suitable for another PLOS journal with only ' \
                              'minor revisions?', q6.text
            assert '(Optional) If you\'d like to include files to support your review, please ' \
                   'attach them here.' in q7.text, q7.text
            qh2, qh3, qh4, qh5, qh6 = self._gets(self._questions_help)
            assert qh2.text == 'Please review our Competing Interests policy and declare any ' \
                               'potential interests that you feel the Editor should be aware ' \
                               'of when considering your review.', qh2.text
            assert qh3.text == 'Your name and review will not be published with the manuscript.', \
                qh3.text
            assert 'In reviewing the manuscript, please comment on the novelty and ' \
                   'significance of the findings, its technical merit, and the experimental ' \
                   'and analytical design. Please also comment on the strength and ' \
                   'sufficiency of the statistical analysis, on the supplementary information, ' \
                   'and whether all data needed to replicate the study are available. ' \
                   'If you request revisions, please indicate which of your proposed revisions ' \
                   'are *essential* to support the current conclusions.' in qh4.text, qh4.text
            assert qh5.text == 'Additional comments may include concerns about dual publication, ' \
                               'research or publication ethics.\n\nThese comments will not be ' \
                               'transmitted to the authors.', qh5.text
            assert qh6.text == 'If so, please specify which PLOS journal and whether you will be ' \
                               'willing to continue there as reviewer on this manuscript. To ' \
                               'reduce redundant review cycles, PLOS Biology is committed to ' \
                               'facilitating the transfer of suitable manuscripts between ' \
                               'journals, and we appreciate your support.'.format(journal), qh6.text
        else:
            assert 'Please refer to our reviewer guidelines and information on our article ' \
                   'types.' in review_note.text, review_note.text
            assert '<a href="http://journals.plos.org/plosbiology/s/reviewer-guidelines#' \
                   'loc-reviewing-magazine-submissions" target="_blank">reviewer guidelines</a>' \
                   in review_note.get_attribute('innerHTML'), review_note.get_attribute('innerHTML')
            question_list = self._gets(self._questions)
            q1, q2, q3, q4, q5, q6, q7 = question_list
            assert q1.text == 'Please provide your publication recommendation:', q1.text
            assert q2.text == 'Do you have any potential or perceived competing interests that ' \
                              'may influence your review?', q2.text
            # APERTA-10621
            # assert q3.text == 'Is this manuscript suitable in principle for the magazine section
            # of {0}?'.format(journal), q3.text
            assert 'Please add your review comments in the box below.' in q3.text, \
                q3.text
            assert q4.text == '(Optional) If previously unpublished data are included to support ' \
                              'the conclusions, please note in the box below whether:', q4.text
            assert q5.text == '(Optional) Please offer any additional confidential comments to ' \
                              'the editor.', q5.text
            assert q6.text == '(Optional) If you’d like your identity to be revealed to the ' \
                              'authors, please include your name here.', q6.text
            qh2, qh3, qh4, qh5, qh6 = self._gets(self._questions_help)
            assert qh2.text == 'Please review our Competing Interests policy and declare any ' \
                               'potential interests that you feel the Editor should be aware of ' \
                               'when considering your review.', qh2.text
            assert qh3.text == 'Do you think this manuscript is suitable, in principle, for the ' \
                               'magazine section of PLOS Biology? What recommendations do you ' \
                               'have for revisions that might make the manuscript ' \
                               'suitable?\nPlease refer to our reviewer guidelines and ' \
                               'information on our article types.\nYour review comments ' \
                               'will be communicated to the authors.', qh3.text
            assert qh4.text == 'The data have been generated rigorously with relevant controls, ' \
                               'replication and sample sizes, if applicable.\nThe data provided ' \
                               'support the conclusions that are drawn.', qh4.text
            assert qh5.text == 'Additional comments may include concerns about dual publication, ' \
                               'research or publication ethics.', qh5.text
            assert qh6.text == 'Your name and review will not be published with the manuscript.', \
                qh6.text

    def validate_view_mode_report_in_task(self, data):
        """
        Validate the elements, display and styles of the reviewer report in view mode (submitted
          state) in the task accordion.
        :param data: A dictionary with the data used to complete the task, will be used to check
          that the task is completed as expected
        :return: None
        """
        research_type = False
        question_list = self._gets(self._questions)
        q1, q2, q3, q4, q5, q6, q7 = question_list
        question_block_list = self._gets(self._question_block)
        self._wait_for_element(question_block_list[0])
        qb1, qb2, qb3, qb4, qb5, qb6, qb7 = question_block_list
        if q3.text == '(Optional) If you\'d like your identity to be revealed to the authors, ' \
                      'please include your name here.':
            research_type = True
        if research_type:
            recc_data, q2_bool_data, q2_data, q3_data, q4_data, q5_data, q6_bool_entry, \
                q6_data = data
            self._wait_for_element(qb1.find_element(*self._res_q1_answer))
            recommendation = qb1.find_element(*self._res_q1_answer)
            assert recommendation.text.strip().lower() == recc_data.strip().lower(), \
                '{0} != {1}'.format(recommendation.text.strip(), recc_data.strip())
            self.validate_application_body_text(recommendation)
            q2_page_bool = qb2.find_element(*self._res_q2_answer_bool)
            self.validate_application_body_text(q2_page_bool)
            if q2_bool_data:
                assert q2_page_bool.text == 'Yes', q2_page_bool.text
            else:
                assert q2_page_bool.text == 'No', q2_page_bool.text
            q2_page_ans = qb2.find_element(*self._res_q2_answer)
            self.validate_application_body_text(q2_page_ans)
            assert q2_page_ans.text == q2_data, '{0} != {1}'.format(q2_page_ans.text, q2_data)
            q3_page_ans = qb3.find_element(*self._res_q3_answer)
            self.validate_application_body_text(q3_page_ans)
            assert q3_page_ans.text == q3_data, '{0} != {1}'.format(q3_page_ans.text, q3_data)
            q4_page_ans = qb4.find_element(*self._res_q4_answer)
            self.validate_application_body_text(q4_page_ans)
            assert q4_page_ans.text == q4_data, '{0} != {1}'.format(q4_page_ans.text, q4_data)
            q5_page_ans = qb5.find_element(*self._res_q5_answer)
            self.validate_application_body_text(q5_page_ans)
            assert q5_page_ans.text == q5_data, '{0} != {1}'.format(q5_page_ans.text, q5_data)
            q6_page_bool = qb6.find_element(*self._res_q6_answer_bool)
            self.validate_application_body_text(q6_page_bool)
            if q6_bool_entry:
                assert q6_page_bool.text == 'Yes', q6_page_bool.text
            else:
                assert q6_page_bool.text == 'No', q6_page_bool.text
            q6_page_ans = self._get(self._res_q6_answer)
            self.validate_application_body_text(q6_page_ans)
            assert q6_page_ans.text == q6_data, '{0} != {1}'.format(q6_page_ans.text, q6_data)
        else:
            question_block_list = self._gets(self._question_block)
            qb1, qb2, qb3, qb4, qb5, qb6, qb7 = question_block_list
            recc_data, q2_data, q3_bool_data, q3_data, q4_bool_data, q4_data, q5_data, \
                q6_data = data
            self._wait_for_element(qb1.find_element(*self._res_q1_answer), multiplier=2)
            recommendation = qb1.find_element(*self._res_q1_answer)
            self.validate_application_body_text(recommendation)
            assert recommendation.text.strip().lower() == recc_data.strip().lower(), \
                '{0} != {1}'.format(recommendation.text.strip(), recc_data.strip())
            q2_page_ans = qb2.find_element(*self._fm_q2_answer)
            self.validate_application_body_text(q2_page_ans)
            if q2_data is True:
                q2_data = "Yes"
            assert q2_page_ans.text == q2_data, '{0} != {1}'.format(q2_page_ans.text, q2_data)
            q3_page_bool = qb3.find_element(*self._fm_q3_answer_bool)
            self.validate_application_body_text(q3_page_bool)
            if q3_bool_data:
                assert q3_page_bool.text == 'Yes', q3_page_bool.text
            else:
                assert q3_page_bool.text == 'No', q3_page_bool.text
            q3_page_ans = qb3.find_element(*self._fm_q3_answer)
            assert q3_page_ans.text == q3_data, '{0} != {1}'.format(q3_page_ans.text,
                                                                    q3_data)
            self.validate_application_body_text(q3_page_ans)
            assert q3_page_ans.text == q3_data, '{0} != {1}'.format(q3_page_ans.text,
                                                                    q3_data)
            q4_page_bool = qb4.find_element(*self._fm_q4_answer_bool)
            self.validate_application_body_text(q4_page_bool)
            q4_page_ans = qb4.find_element(*self._fm_q4_answer)
            assert q4_page_ans.text == q4_data, '{0} != {1}'.format(q4_page_ans.text,
                                                                    q4_data)
            self.validate_application_body_text(q4_page_ans)
            q5_page_ans = qb5.find_element(*self._fm_q5_answer)
            self.validate_application_body_text(q5_page_ans)
            assert q5_page_ans.text == q5_data, '{0} != {1}'.format(q5_page_ans.text, q5_data)
            q6_page_ans = qb6.find_element(*self._fm_q6_answer)
            self.validate_application_body_text(q6_page_ans)
            assert q6_page_ans.text == q6_data, '{0} != {1}'.format(q6_page_ans.text, q6_data)

    def complete_reviewer_report(self, recommendation=''):
        """
        Completes and submits the reviewer report
        :param recommendation: optional parameter that can be one of 'Accept', 'Reject',
          'Major Revision', 'Minor Revision' if an explicit outcome is desired
        :return: outdata: a list of responses to the questions submitted in filling out the report.
        """
        logging.info('Complete Reviewer Report called')
        research_type = False
        review_note = self._get(self._review_note)
        self._scroll_into_view(review_note)
        self._actions.move_to_element(review_note).perform()
        if 'Please refer to our reviewer guidelines for detailed instructions.' in review_note.text:
            research_type = True
        logging.info('Is this a research type report? {0}'.format(research_type))
        question_block_list = self._gets(self._question_block)
        qb1, qb2, qb3, qb4, qb5, qb6, qb7 = question_block_list
        if not recommendation:
            choices = ['Accept', 'Reject', 'Major Revision', 'Minor Revision']
            recommendation = choice(choices)
        if recommendation == 'Accept':
            accrb = self._get(self._q1_accept_radio)
            accrb.click()
        elif recommendation == 'Reject':
            rejrb = self._get(self._q1_reject_radio)
            rejrb.click()
        elif recommendation == 'Major Revision':
            majrevrb = self._get(self._q1_majrev_radio)
            majrevrb.click()
        elif recommendation == 'Minor Revision':
            minrevrb = self._get(self._q1_minrev_radio)
            minrevrb.click()
        else:
            logging.error('Requested recommendation: {0} is invalid'.format(recommendation))
        if research_type:
            q2radval = self.get_random_bool()
            if q2radval:
                q2yesradio = qb2.find_element(*self._res_yes_radio)
                q2yesradio.click()
            else:
                q2noradio = qb2.find_element(*self._res_no_radio)
                q2noradio.click()
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--competing_interests--detail')
            q2response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q2response)
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--identity')
            q3response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q3response)
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--comments_for_author')
            q4response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q4response)
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('reviewer_report--additional_comments')
            q5response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q5response)
            q6radval = self.get_random_bool()
            self._scroll_into_view(qb5)

            if q6radval:
                q6yesradio = qb6.find_element(*self._res_yes_radio)
                q6yesradio.click()
            else:
                q6noradio = qb6.find_element(*self._res_no_radio)
                q6noradio.click()
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                        'reviewer_report--suitable_for_another_journal--journal')
            q6response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q6response)
        else:
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--competing_interests')
            q2response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q2response)
            q3radval = self.get_random_bool()
            if q3radval:
                q3yesradio = qb3.find_element(*self._fm_yes_radio)
                q3yesradio.click()
            else:
                q3noradio = qb3.find_element(*self._fm_no_radio)
                q3noradio.click()
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--suitable--comment')
            q3response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q3response)
            q4radval = self.get_random_bool()
            if q4radval:
                q4yesradio = qb4.find_element(*self._fm_yes_radio)
                q4yesradio.click()
            else:
                q4noradio = qb4.find_element(*self._fm_no_radio)
                q4noradio.click()
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                        'front_matter_reviewer_report--includes_unpublished_data--explanation')
            q4response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q4response)
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance(
                    'front_matter_reviewer_report--additional_comments')
            q5response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q5response)
            tinymce_editor_instance_id, tinymce_editor_instance_iframe = \
                self.get_rich_text_editor_instance('front_matter_reviewer_report--identity')
            q6response = generate_paragraph()[2]
            self.tmce_set_rich_text(tinymce_editor_instance_iframe, content=q6response)
        submit_report_btn = self._get(self._submit_button)
        submit_report_btn.click()
        self._wait_for_element(self._get(self._submit_confirm_yes_btn))
        confirm_yes = self._get(self._submit_confirm_yes_btn)
        confirm_yes.click()
        time.sleep(1)
        if research_type:
            outdata = [recommendation,
                       q2radval,
                       q2response,
                       q3response,
                       q4response,
                       q5response,
                       q6radval,
                       q6response]
        else:
            outdata = [recommendation,
                       q2response,
                       q3radval,
                       q3response,
                       q4radval,
                       q4response,
                       q5response,
                       q6response]
        return outdata

    def task_ready(self):
        """
        A basic method to test that a task is fully populated before we interact with it.
        This card lacks the common Completion button, so this method overrides the one in basetask
        :return: Void Function
        """
        self._wait_for_element(self._get(self._submit_button))
