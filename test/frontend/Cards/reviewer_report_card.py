#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from selenium.webdriver.common.by import By

from frontend.Cards.basecard import BaseCard

__author__ = 'sbassi@plos.org'


class ReviewerReportCard(BaseCard):
    """
    Page Object Model for Reviewer Report Card
    This is a placeholder class since we are currently using this card as a task
    """

    def __init__(self, driver):
        super(ReviewerReportCard, self).__init__(driver)
        # Locators - Instance members
        self._question_block = (By.CSS_SELECTOR, 'li.question')
        self._questions = (By.CLASS_NAME, 'question-text')
        self._submitted_status = (By.CLASS_NAME, 'long-status')
        # The following locators (except res_q6_ans) must be used with a find under each
        # question block
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
    def validate_card_elements_styles(self, paper_id):
        """
        This method validates the styles of the card elements including the common card elements
        :return void function
        """
        self.validate_common_elements_styles(paper_id)

    def validate_reviewer_report(self, data, research_type=True):
        """
        Validate the elements, display and styles of the reviewer report in view mode
          (submitted state) in the workflow/card view.
        :return void function
        """
        question_block_list = self._gets(self._question_block)
        self._wait_for_element(question_block_list[0])
        qb1, qb2, qb3, qb4, qb5, qb6, qb7 = question_block_list
        if research_type:
            recc_entry, q2bentry, q2entry, q3entry, q4entry, q5entry, q6bentry, q6entry = data
            recommendation = qb1.find_element(*self._res_q1_answer)
            assert recommendation.text.strip().lower() == recc_entry.strip().lower(), \
                '{0} != {1}'.format(recommendation.text.strip(), recc_entry.strip())
            self.validate_application_body_text(recommendation)
            q2bool = qb2.find_element(*self._res_q2_answer_bool)
            self.validate_application_body_text(q2bool)
            if q2bentry:
                assert q2bool.text == 'Yes', q2bool.text
            else:
                assert q2bool.text == 'No', q2bool.text
            q2ans = qb2.find_element(*self._res_q2_answer)
            self.validate_application_body_text(q2ans)
            assert q2ans.text == q2entry, '{0} != {1}'.format(q2ans.text, q2entry)
            q3ans = qb3.find_element(*self._res_q3_answer)
            self.validate_application_body_text(q3ans)
            assert q3ans.text == q3entry, '{0} != {1}'.format(q3ans.text, q3entry)
            q4ans = qb4.find_element(*self._res_q4_answer)
            self.validate_application_body_text(q4ans)
            assert q4ans.text == q4entry, '{0} != {1}'.format(q4ans.text, q4entry)
            q5ans = qb5.find_element(*self._res_q5_answer)
            self.validate_application_body_text(q5ans)
            assert q5ans.text == q5entry, '{0} != {1}'.format(q5ans.text, q5entry)
            q6bool = qb6.find_element(*self._res_q6_answer_bool)
            self.validate_application_body_text(q6bool)
            if q6bentry:
                assert q6bool.text == 'Yes', q6bool.text
            else:
                assert q6bool.text == 'No', q6bool.text
            q6ans = self._get(self._res_q6_answer)
            self.validate_application_body_text(q6ans)
            assert q6ans.text == q6entry, '{0} != {1}'.format(q6ans.text, q6entry)
        else:
            recc_entry, q2entry, q3bentry, q3entry, q4bentry, q4entry, q5entry, q6entry = data
            recommendation = qb1.find_element(*self._fm_q1_answer)
            self.validate_application_body_text(recommendation)
            assert recommendation.text.strip().lower() == recc_entry.strip().lower(), \
                '{0} != {1}'.format(recommendation.text.strip(), recc_entry.strip())
            q2ans = qb2.find_element(*self._fm_q2_answer)
            self.validate_application_body_text(q2ans)
            assert q2ans.text == q2entry, '{0} != {1}'.format(q2ans.text, q2entry)
            q3bool = qb3.find_element(*self._fm_q3_answer_bool)
            self.validate_application_body_text(q3bool)
            if q3bentry:
                assert q3bool.text == 'Yes', q3bool.text
            else:
                assert q3bool.text == 'No', q3bool.text
            q3ans = qb3.find_element(*self._fm_q3_answer)
            self.validate_application_body_text(q3ans)
            assert q3ans.text == q3entry, '{0} != {1}'.format(q3ans.text, q3entry)
            q4bool = qb4.find_element(*self._fm_q4_answer_bool)
            self.validate_application_body_text(q4bool)
            if q4bentry:
                assert q4bool.text == 'Yes', q4bool.text
            else:
                assert q4bool.text == 'No', q4bool.text
            q4ans = qb4.find_element(*self._fm_q4_answer)
            self.validate_application_body_text(q4ans)
            assert q4ans.text == q4entry, '{0} != {1}'.format(q4ans.text, q4entry)
            q5ans = qb5.find_element(*self._fm_q5_answer)
            self.validate_application_body_text(q5ans)
            assert q5ans.text == q5entry, '{0} != {1}'.format(q5ans.text, q5entry)
            q6ans = qb6.find_element(*self._fm_q6_answer)
            self.validate_application_body_text(q6ans)
            assert q6ans.text == q6entry, '{0} != {1}'.format(q6ans.text, q6entry)
        # This out of place re-definition is necessary to avoid a stale reference exception
        #  because the element has been redefined since initial load of the card.
        self._submitted_status = (By.CLASS_NAME, 'long-status')
        report_submit_status = self._get(self._submitted_status)
        assert 'Completed' in report_submit_status.text, report_submit_status.text
        self.validate_application_list_style(report_submit_status)

    def card_ready(self):
        """
        A basic method to test that a card is fully populated before we interact with it.
        This card lacks the common Completion button, so this method overrides the one in basecard
        :return: Void Function
        """
        self._wait_for_element(self._get(self._discussion_div))
