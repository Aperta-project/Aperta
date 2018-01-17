#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime

from selenium.webdriver.common.by import By
from selenium.common.exceptions import TimeoutException

from Base.CustomException import ElementDoesNotExistAssertionError
from Base.PostgreSQL import PgSQL
from frontend.Cards.basecard import BaseCard
from ..Pages.ithenticate_page import IthenticatePage

__author__ = 'gtimonina@plos.org'


class SimilarityCheckCard(BaseCard):
    """
    Page object for the Similarity Check card
    """

    def __init__(self, driver):
        super(SimilarityCheckCard, self).__init__(driver)

        # Locators - Instance members
        self._sim_check_task_overlay = (By.CSS_SELECTOR, '.task.similarity-check-task')
        self._instruction = (By.CSS_SELECTOR, 'div.ember-view.task > div > p')
        self._automation_disabled_info = (By.CSS_SELECTOR, 'div.auto-report-off p')
        self._automated_report_status = (By.CSS_SELECTOR, '.task.similarity-check-task p')
        self._automated_report_status_active = (By.CSS_SELECTOR, 'div.automated-report-status p')
        self._generate_report_button = (By.CSS_SELECTOR, 'button.generate-confirm')
        self._confirm_container = (By.CSS_SELECTOR, 'div.confirm-container')
        self._confirm_form = (By.CSS_SELECTOR, 'div > div')
        self._confirm_text = (By.CSS_SELECTOR, 'div.confirm-container > h4')
        self._manually_generate_cancel_link = (By.CSS_SELECTOR, 'button.button-link')
        self._manually_generate_button = (By.CSS_SELECTOR, 'button.generate-report')
        self._report_pending_spinner = (By.CSS_SELECTOR, 'div.progress-spinner')
        self._report_pending_spinner_message = (By.CSS_SELECTOR,
                                                'div.ember-view.progress-spinner-message')
        self._sim_check_report_title = (By.CSS_SELECTOR, '.latest-versioned-text > h3')
        self._sim_check_report_completed = (By.CSS_SELECTOR, '.latest-versioned-text p')
        self._sim_check_report_score_text = (By.CSS_SELECTOR, '.latest-versioned-text p + p')
        self._sim_check_report_link = (By.CSS_SELECTOR, '.similarity-check a')
        self._sim_check_report_score = (By.CLASS_NAME, 'score')
        self._sim_check_report_history = (By.CSS_SELECTOR, '.task.similarity-check-task > div > h3')
        self._sim_check_report_revision_number = (By.CSS_SELECTOR,
                                                  '.similarity-check-bar-revision-number')
        self._version_report = (By.CSS_SELECTOR, '.similarity-check-bar > .similarity-check')
        self._btn_done = (By.CSS_SELECTOR, 'span.task-completed-section button')
        self._author = (By.CLASS_NAME, 'paper-creator')

    # POM Actions
    def validate_styles_and_components(self, ithenticate_automation, triggered=False,
                                       auto_report_done=False):
        """
        Validate styles and components in the Similarity Check Card
        :param ithenticate_automation: string: one of the options: 'off',
        'at_first_full_submission', 'after_major_revise_decision', 'after_minor_revise_decision',
        'after_any_first_revise_decision'
        :param triggered: boolean, True if the generating Report is expected to be triggered,
        False by default, optional
        :param auto_report_done: boolean, True if automated Report was triggered on the previous
        steps, default is False, optional
        :return: void function
        """
        card_title = self._get(self._card_heading)
        assert card_title.text == 'Similarity Check', 'Card title {0} is not ' \
                                                      'the expected: {1}'.format(card_title.text,
                                                                                 'Similarity Check')
        self.validate_overlay_card_title_style(card_title)

        # AC 4.1
        card_instruction = self._get(self._instruction)
        expected_instruction = 'Click below to generate a similarity report via iThenticate. ' \
                               'If a report was generated for a previous version it can be found ' \
                               'in the version history.'
        assert card_instruction.text.strip() == expected_instruction, card_instruction.text.strip()
        self.validate_application_body_text(card_instruction)

        # Button to send for manual report The button is only enabled if:
        # the card is marked incomplete

        # auto options (defined in APERTA-9958)
        auto_report_options_text = {'at_first_full_submission': 'first full submission',
                                    'after_major_revise_decision': 'major revision',
                                    'after_minor_revise_decision': 'minor revision',
                                    'after_any_first_revise_decision': 'any first revision'}

        if ithenticate_automation == 'off':
            auto_info = self._get(self._automation_disabled_info)
            assert auto_info.text.strip() == 'Automated similarity check is disabled:', \
                auto_info.text.strip()
        else:
            auto_info = self._gets(self._automated_report_status_active)
            expected_text = 'Automated similarity check is active: ' \
                            'This manuscript will be sent to iThenticate on {0}.'\
                .format(auto_report_options_text[ithenticate_automation])
            assert auto_info[0].text.strip() == expected_text, auto_info[0].text.strip()
            assert auto_info[1].text.strip() == 'Manually generating a report below will disable ' \
                                                'the automated similarity check for this ' \
                                                'manuscript.', auto_info[0].text.strip()

        if triggered:
            self.validate_pending()
            # check it is pending and "generate button is not enabled
            send_for_manual_report_button = self._iget(self._generate_report_button)
            assert not send_for_manual_report_button.is_enabled()
        else:
            if ithenticate_automation == 'off':
                # check if the button is enable when the card is incomplete
                if not self.completed_state():
                    self.validate_generate_report_button()
                    self.click_completion_button()  # mark task as complete
                # check if the button is disable if the card is complete
                self.validate_generate_report_button()
                self.click_completion_button()  # mark task as incomplete
                # The button triggers a confirm/cancel step before generation a report
                self.validate_manual_report_confirmation()
            else:
                # auto option is on, so we are here if:
                # 1) report sending is not triggered yet, for example, auto option is
                # 'after_major_revise_decision', and it's first submission or minor revision
                # 2) it is one of the next submissions after the automated report was done
                if not auto_report_done:  # 1)
                    assert not self.completed_state(), 'The card is expected to be editable'
                    self.validate_manual_report_confirmation()
                else:  # 2)
                    if not self.completed_state():
                        # it's still in pending status - triggered by previous submission
                        self.validate_pending_triggered_by_previous_submission()

    def validate_pending(self):
        """
        Validates card components - message and report title - when the Report is pending
        :return: void function
        """
        try:
            self._wait_for_element(self._get(self._report_pending_spinner_message))
            report_pending_spinner_message = self._get(self._report_pending_spinner_message)
            assert "Pending" in report_pending_spinner_message.text
        except ElementDoesNotExistAssertionError:
            # we were waiting for Similarity Check completion,
            # and now the report is ready
            report_title = self._get(self._sim_check_report_title)
            assert 'Similarity Check Report' in report_title.text.strip()
        return True

    def validate_pending_triggered_by_previous_submission(self):
        """
        Validates card components - message and report title - when the Report is pending
        If Report was triggered by previous submission, we checking History Report
        :return: void function
        """
        history_report = self.get_report_history()
        try:
            assert 'Pending' in history_report[2], \
                '\'Pending\' is expected in {0}'.format(history_report)
        except ElementDoesNotExistAssertionError:
            assert 'Similarity check completed' in history_report[2], \
                '\'Similarity check complete\' is expected in {0}'.format(history_report)
        return True

    def click_send_manual_report(self):
        """ Click on Generate Report button to send report manually """
        send_for_manual_report_button = self._get(self._generate_report_button)
        self.validate_primary_big_green_button_style(send_for_manual_report_button)
        send_for_manual_report_button.click()

    def validate_manual_report_confirmation(self):
        """
        Validates confirmation step before manual Report generation
        :return: void function
        """
        # AC 4.2.2 .The button triggers a confirm/cancel step before generation a report
        send_for_manual_report_button = self._get(self._generate_report_button)
        self.validate_primary_big_green_button_style(send_for_manual_report_button)
        send_for_manual_report_button.click()
        # confirm/cancel container
        self._wait_for_element(self._get(self._confirm_container))
        # assert self._get(self._confirm_container)
        confirm_container = self._get(self._confirm_container)
        self.validate_cancel_confirmation_style(confirm_container)
        self.validate_container_confirmation_style(confirm_container)
        confirm_text = self._get(self._confirm_text)
        expected_confirm_text = ['Manually generating the report will disable the automated '
                                 'similarity check for this manuscript', 'Are you sure?']
        assert confirm_text.text.strip() in expected_confirm_text, \
            'Confirmation text is: \'{0}\', expected: \'{1}\'' \
            .format(confirm_text.text.strip(), expected_confirm_text)

        confirm_cancel = self._get(self._manually_generate_cancel_link)
        self.validate_cancel_confirmation_style(confirm_cancel)

        confirm_generate_button = self._get(self._manually_generate_button)
        assert confirm_generate_button.text == 'GENERATE REPORT'  # confirm button
        self.validate_secondary_big_green_button_style(confirm_generate_button)
        # click on 'cancel' - confirm container should not be displayed
        confirm_cancel.click()
        gen_report_info = self._get(self._sim_check_task_overlay)
        gen_report_divs = gen_report_info.find_elements(*self._confirm_form)
        classes = [div.get_attribute('class') for div in gen_report_divs]
        assert 'confirm-container' not in classes, 'No \'confirm-container\' class is expected ' \
                                                   'in {0}'.format(str(classes))
        # click "GENERATE REPORT' again
        self.validate_generate_report_button()

    def get_report_history(self):
        """
        Gets Report History for result validation
        :return: report_history_title: string, versions: list of strings,
          last_version_report: string
        """
        report_history = self._get(self._sim_check_report_history)
        report_history_title = report_history.text.strip()
        version_numbers = self._gets(self._sim_check_report_revision_number)
        versions = [version.text.strip() for version in version_numbers]
        self._get(self._sim_check_report_revision_number).click()
        self._wait_for_element(self._get(self._version_report))
        last_version_report = self._get(self._version_report).text.strip()
        self._get(self._sim_check_report_revision_number).click()

        return report_history_title, versions, last_version_report

    def generate_manual_report(self):
        """
        Generate report manually by clicking on 'Generate Report' button
        :return: task_url: url to get back and check results,
            start_time: time when the generate report call has started, to track and calculate
            remaining time to wait for the Report from iThenicate,
            pending_message, report_title - text to validate
        """
        send_for_manual_report_button = self._get(self._generate_report_button)
        send_for_manual_report_button.click()

        # AC Button to send for manual report: The button is only enabled if the report status
        # is not pending
        confirm_generate_button = self._get(self._manually_generate_button)
        confirm_generate_button.click()
        report_pending_spinner_message = self._get(self._report_pending_spinner_message)
        pending_message = report_pending_spinner_message.text
        # assert "Pending" in report_pending_spinner_message.text
        # self.validate_progress_spinner_style(report_pending_spinner_message)
        # TODO: add assert for AC 4.2.1.3 when APERTA-11392 gets resolved
        # assert not send_for_manual_report_button.is_displayed

        self._wait_for_element(self._get(self._sim_check_report_title), 1)

        report_title = self._get(self._sim_check_report_title)
        report_title_text = report_title.text.strip()
        # assert 'Similarity Check Report' in report_title.text.strip(), report_title.text.strip()
        self.validate_application_h3_style(report_title)
        # save task url and current time to go back to the task after report is generated
        task_url = self.get_current_url()
        start_time = datetime.now()

        return task_url, start_time, pending_message, report_title_text

    def get_report_result(self, start_time=None):
        """
        Waits for the Report from iThenticate, fetch the results from the link and gets the results
        from Similar Card page and iThenticate page to validate
        :param start_time: time when generation has started to decrease maximum time to wait as
        there is a 10 minutes limit to wait for the result from iThenticate
        :return: empty string if validation is ok, error message or 'No error message',
        if generating report fails with TimeoutException;
        elapsed time in seconds to track time, data dictionaries with title,
        value (score) and author from card page and iThenticate page
        """
        validation_start_time = datetime.now()
        html_header_title = self._get(self._header_title_link)
        paper_title = html_header_title.text
        try:
            if start_time is None:
                seconds_to_wait = 500
            else:
                diff_time = datetime.now() - start_time
                seconds_to_wait = max(10, 500 - diff_time.seconds)

            self._wait_on_lambda(lambda: bool(self.completed_state()),
                                 max_wait=seconds_to_wait)  # score and style
        except TimeoutException:
            # after 10 minutes the 'Report not available' error message is expected to be displayed
            validation_seconds = (datetime.now() - validation_start_time).seconds
            try:
                error_message = self._get(self._flash_error_msg)
                return error_message.text.strip(), validation_seconds, None, None
            except ElementDoesNotExistAssertionError:
                return 'No error message', validation_seconds, None, None

        score = self._get(self._sim_check_report_score)
        score = score.text
        paper_author = (self._get(self._author)).text
        self.launch_ithenticate_page()  # return score and paper_title
        ithenticate_page = IthenticatePage(self._driver)
        ithenticate_page.page_ready()
        title, value, author = ithenticate_page.get_title_score()
        report_data = {'title': title.strip(), 'value': value.strip(),
                       'author': author.lower().strip()}
        paper_data = {'title': paper_title.strip(), 'value': score.strip(),
                      'author': paper_author.lower().strip()}
        validation_seconds = (datetime.now() - validation_start_time).seconds
        self._driver.close()
        self._wait_for_number_of_windows_to_be(1)
        self.traverse_from_window()

        return "", validation_seconds, paper_data, report_data

    def launch_ithenticate_page(self):
        """Click on iThenticate report link to go the Report page"""
        report_link = self._get(self._sim_check_report_link)
        report_link.click()
        self._wait_for_number_of_windows_to_be(2)
        self.traverse_to_new_window()

    def validate_generate_report_button(self):
        """
        Validate 'Generate Report' button visibility depending on card completion:
        it should be not visible if the card completed
        and visible if the card is editable
        :return: void function
        """
        card_completed_state = self.completed_state()
        send_for_manual_report_button = self._iget(self._generate_report_button)
        if card_completed_state:
            assert not send_for_manual_report_button.is_displayed()
        else:
            assert send_for_manual_report_button.is_displayed()

    def get_sim_check_auto_settings(self, short_doi):
        """
        A method to return the settings for automated sending report; Similarity Check task
        via a query
        :param short_doi: papers.short_doi of the requested paper
        :return: auto_settings (settings.string_value) from db, a string
        """

        mmt_id = PgSQL().query('SELECT manuscript_manager_templates.id '
                               'FROM papers, journals, manuscript_manager_templates '
                               'WHERE papers.journal_id = journals.id '
                               'AND journals.id = manuscript_manager_templates.journal_id '
                               'AND manuscript_manager_templates.paper_type = papers.paper_type '
                               'AND short_doi=%s;', (short_doi,))[0][0]

        auto_setting = PgSQL().query('SELECT settings.string_value '
                                     'FROM task_templates, phase_templates, settings '
                                     'WHERE phase_templates.manuscript_manager_template_id = %s '
                                     'AND phase_templates.id=task_templates.phase_template_id '
                                     'AND settings.owner_id=task_templates.id '
                                     'AND task_templates.title=%s '
                                     'AND settings.NAME =%s;', (mmt_id, 'Similarity Check',
                                                                'ithenticate_automation'))[0][0]
        return auto_setting
