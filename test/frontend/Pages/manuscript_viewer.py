#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Page Object Model for the Paper Editor Page. Validates global and dynamic elements and their styles
NOTE: This POM will be outdated when the Paper Editor is removed.
"""
import logging
import os
import random
import time
from datetime import datetime

from selenium.webdriver.common.by import By

from .authenticated_page import AuthenticatedPage, APPLICATION_TYPEFACE, APERTA_GREY_DARK
from Base.CustomException import ElementDoesNotExistAssertionError
from Base.Resources import users, staff_admin_login, pub_svcs_login, internal_editor_login, \
    super_admin_login, production_urls
from Base.PDF_Util import PdfUtil
from Base.PostgreSQL import PgSQL
from frontend.Overlays.submission_review import SubmissionReviewOverlay
from frontend.Tasks.additional_information_task import AITask
from frontend.Tasks.authors_task import AuthorsTask
from frontend.Tasks.basetask import BaseTask
from frontend.Tasks.billing_task import BillingTask
from frontend.Tasks.new_taxon_task import NewTaxonTask
from frontend.Tasks.revise_manuscript_task import ReviseManuscriptTask
from frontend.Tasks.reviewer_report_task import ReviewerReportTask
from frontend.Tasks.supporting_information_task import SITask
from frontend.Tasks.title_and_abstract_task import TitleAbstractTask
from .styles import StyledPage

__author__ = 'sbassi@plos.org'


class ManuscriptViewerPage(AuthenticatedPage):
    """
    Model an aperta paper viewer page
    """
    def __init__(self, driver, url_suffix='/'):
        super(ManuscriptViewerPage, self).__init__(driver, url_suffix)

        # Locators - Instance members
        # Main Viewer Div
        self._paper_title = (By.CSS_SELECTOR, 'div#control-bar-paper-title > span')
        self._paper_tracker_title = (By.CLASS_NAME, 'paper-tracker-message')
        self._paper_tracker_table_submit_date_th = (By.XPATH, '//th[4]')
        self._card = (By.CLASS_NAME, 'card')
        self._submit_button = (By.ID, 'sidebar-submit-paper')
        self._withdraw_banner = (By.CLASS_NAME, 'withdrawal-banner')
        self._withdraw_banner_reactivate_button = (By.CSS_SELECTOR,
                                                   'div.withdrawal-banner > button.button-secondary')
        self._manuscript_pane = (By.CLASS_NAME, 'manuscript-pane')
        self._manuscript_pdf_viewer_container = (By.ID, 'viewerContainer')
        self._accordion_pane = (By.CSS_SELECTOR, 'div.split-pane-element + div.split-pane-element')

        # Paper Viewer (manuscript) pane
        self._failed_conversion_heading = (By.CSS_SELECTOR, 'div.paper-preview-error-message>h3')
        # Sidebar Items
        self._task_headings = (By.CLASS_NAME, 'task-disclosure-heading')
        self._task_heading_status_icon = (By.CLASS_NAME, 'task-disclosure-completed-icon')
        self._task_heading_completed_icon = (By.CLASS_NAME, 'task-disclosure-completed-icon active')
        # Main Toolbar items
        self._tb_versions_link = (By.ID, 'nav-versions')
        self._tb_versions_diff_div = (By.CSS_SELECTOR, 'div.html-diff')
        self._tb_versions_pdf_message = (By.CLASS_NAME, 'versioning-bar-pdf-message')
        self._tb_versions_closer = (By.CLASS_NAME, 'versioning-bar-close')
        self._tb_collaborators_link = (By.ID, 'nav-collaborators')
        self._tb_add_collaborators_label = (By.CLASS_NAME, 'contributors-add')
        self._tb_collaborator_list_item = (By.CLASS_NAME, 'contributor')
        self._tb_downloads_link = (By.ID, 'nav-downloads')
        self._tb_ra_link = (By.ID, 'nav-recent-activity')
        self._close_ra_overlay = (By.CSS_SELECTOR, '.overlay-close')
        self._tb_more_link = (By.CSS_SELECTOR, 'div.more-dropdown-menu')
        self._tb_more_appeal_link = (By.ID, 'nav-appeal')
        self._tb_more_withdraw_link = (By.ID, 'nav-withdraw-manuscript')
        self._tb_workflow_link = (By.ID, 'nav-workflow')
        self._tb_correspondence_link = (By.ID, 'nav-correspondence')
        # Manage Collaborators Overlay
        self._add_collaborators_modal = (By.CLASS_NAME, 'show-collaborators-overlay')
        self._add_collaborators_modal_header = (By.CLASS_NAME, 'overlay-title-text')
        self._add_collaborators_modal_support_text = (By.CLASS_NAME, 'overlay-supporting-text')
        self._add_collaborators_modal_support_select = (By.CLASS_NAME, 'collaborator-select')
        self._add_collaborators_modal_input = (By.CLASS_NAME, 'select2-input')
        self._add_collaborators_modal_select = (By.CSS_SELECTOR, 'div.select2-container')

        self._add_collaborators_modal_cancel = (By.XPATH, "//div[@class='overlay-action-buttons']/a")
        self._add_collaborators_modal_save = (By.XPATH, "//div[@class='overlay-action-buttons']/button")
        # Withdraw Manuscript Overlay
        self._wm_modal = (By.CLASS_NAME, 'overlay--fullscreen')
        self._wm_exclamation_circle = (By.CLASS_NAME, 'fa-exclamation-circle')
        self._wm_modal_title = (By.CSS_SELECTOR, 'h1')
        self._wm_modal_text = (By.CSS_SELECTOR, 'div.overlay-body div p')
        self._wm_modal_textarea = (By.CSS_SELECTOR, 'div.paper-withdraw-wrapper > textarea')
        self._wm_modal_yes = (By.XPATH, '//div[@class="pull-right"]/button[1]')
        self._wm_modal_no = (By.XPATH, '//div[@class="pull-right"]/button[2]')
        # Submit Confirmation and Submit Congratulations Overlays (full and initial submit versions)
        # The overlay close X is universal and defined in
        # authenticated page (self._overlay_header_close)
        self._so_paper_submit_icon = (By.CLASS_NAME, 'paper-submit-icon')
        self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
        self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR,
                                                     'div.overlay-title-text-submit + h5')
        self._so_paper_title = (By.ID, 'paper-submit-title')
        self._so_submit_confirm = (By.CLASS_NAME, 'button-submit-paper')
        self._so_submit_cancel = (By.CSS_SELECTOR, 'div.submit-action-buttons button.button-link')
        self._so_close_after_submit = (By.CLASS_NAME, 'success-close')
        # Paper Sidebar and associated items
        self._paper_sidebar = (By.CLASS_NAME, 'paper-sidebar')
        self._paper_sidebar_info = (By.CLASS_NAME, 'paper-sidebar-info')
        self._paper_sidebar_assigned_tasks = (By.ID, 'paper-assigned-tasks')
        self._paper_sidebar_metadata_tasks = (By.ID, 'paper-metadata-tasks')
        self._paper_sidebar_diff_icons = (By.CLASS_NAME, 'card-diff-icon')
        # Sidebar Info Items
        self._paper_sidebar_submit_success_msg = (By.CLASS_NAME, 'task-list')
        self._paper_sidebar_state_information = (By.ID, 'submission-state-information')
        # Assigned Tasks
        self._billing_task = (By.CLASS_NAME, 'billing-task')
        self._cover_letter_task = (By.CLASS_NAME, 'cover-letter-task')
        self._cfa_task = (By.CLASS_NAME, 'changes-for-author-task')
        self._review_cands_task = (By.CLASS_NAME, 'reviewer-candidates-task')
        self._revise_task_task = (By.CLASS_NAME, 'revise-task')
        # Metadata Tasks
        self._addl_info_task = (By.CLASS_NAME, 'publishing-related-questions-task')
        self._authors_task = (By.CLASS_NAME, 'authors-task')
        self._competing_ints_task = (By.CLASS_NAME, 'competing-interests-task')
        self._early_article_posting_task = (By.CLASS_NAME, 'early-posting-task')
        self._data_avail_task = (By.CLASS_NAME, 'data-availability-task')
        self._ethics_statement_task = (By.CLASS_NAME, 'ethics-statement-task')
        self._figures_task = (By.CLASS_NAME, 'figure-task')
        self._fin_disclose_task = (By.CLASS_NAME, 'financial-disclosure-task')
        self._new_taxon_task = (By.CLASS_NAME, 'new-taxon-task')
        self._report_guide_task = (By.CLASS_NAME, 'reporting-guidelines-task')
        self._review_cands_task = (By.CLASS_NAME, 'reviewer-recommendations-task')
        self._research_reviewer_report_task = (By.CLASS_NAME, 'reviewer-report-task')
        self._front_matter_reviewer_report_task = (By.CLASS_NAME, 'front-matter-reviewer-report-task')
        self._supporting_info_task = (By.CLASS_NAME, 'supporting-info-task')
        self._upload_manu_task = (By.CLASS_NAME, 'task-type-upload-manuscript-task')
        # infobox
        self._question_mark_icon = (By.ID, 'submission-process-toggle')
        # While IDs are normally king, for this element, we don't hide the element, we just change
        # its class to "hide" it
        self._infobox = (By.ID, 'inner')
        self._infobox_closer = (By.ID, 'sp-close')
        self._manuscript_viewer_status_area = (By.ID, 'submission-state-information')
        self._status_info_initial_submit_todo = (By.CSS_SELECTOR,
                                                 'div.gradual-engagement-presubmission-messaging')
        self._status_info_ready_to_submit = (By.CSS_SELECTOR, 'div.ready-to-submit')
        self._title = (By.ID, 'control-bar-paper-title')
        self._generic_task_item = (By.CSS_SELECTOR, 'div.paper-sidebar > div.ember-view')
        # Download drawer
        self._download_drawer = (By.CLASS_NAME, 'sheet')
        self._download_drawer_title = (By.CSS_SELECTOR, '.sheet .sheet-title')
        self._download_drawer_table_header = (By.CSS_SELECTOR, '.sheet '
                                                               '.paper-downloads '
                                                               '.paper-downloads-row:not(.animation-fade-in) th')
        self._download_drawer_items = (By.CSS_SELECTOR, '.sheet .paper-downloads '
                                                        '.paper-downloads-row.animation-fade-in')
        self._download_drawer_close_btn = (By.CSS_SELECTOR, '.sheet .sheet-close-x')
        # Upload ms
        self._upload_source = (By.ID, 'upload-source-file')
        # Manuscript/sidebar resizing handle
        self._resize_handle_line = (By.CLASS_NAME, 'manuscript-handle')
        self._resize_handle_box = (By.CLASS_NAME, 'box-handle')
        self._resize_handle_box_lines = (By.CSS_SELECTOR, '.box-handle .vertical-line')
        self._resize_handle_box_tooltip = (By.CSS_SELECTOR, '.box-handle .tooltip')
        # Review before Submission overlay
        self._review_overlay_submit_button = (By.ID, 'review-submission-submit-button')
        self._review_before_submission = None
        # relative locators
        self._radio_buttons = (By.CSS_SELECTOR, "input[value]")

    # POM Actions
    def page_ready(self):
        """
        A simple method to validate the complete load of the manuscript page prior to starting
          testing of that page.
        :return: void function
        """
        self._wait_for_element(self._get(self._generic_task_item))

    def page_ready_post_create(self):
        """
        A method to validate that the manuscript page is ready for testing following the creation of a
          new manuscript
        :return: void function
        """
        self.set_timeout(10)
        error_msg = ''
        try:
            self.check_for_flash_success(timeout=30)
        except ElementDoesNotExistAssertionError:
            logging.warning('No Conversion success message displayed post create...')
            try:
                error_msg = self.check_for_flash_error()
            except ElementDoesNotExistAssertionError:
                logging.warning('No message displayed for conversion success or failure')
            if error_msg:
                self.check_failed_conversion_text(status='unsubmitted')
        self._wait_for_element(self._get(self._generic_task_item))
        current_url = self.get_current_url_without_args()
        logging.info(current_url)
        self.close_flash_message()
        self.restore_timeout()

    def validate_page_elements_styles_functions(self, user='', admin=''):
        """
        Main method to validate styles and basic functions for all elements
        in the page
        :param user: String with the user whom the page is rendered to
        :param admin: Boolean to indicate if the page is rendered for an admin user
        """
        if admin:
            self._get(self._tb_workflow_link)
        # Check application buttons
        self._check_version_btn_style()
        self._check_collaborator()
        self._check_download_btns()
        self._check_recent_activity()
        self._check_discussion(user)
        self._check_more_btn(user)
        self._check_resize_handle()

    def validate_independent_scrolling(self):
        """Ensure both the manuscript and accordion panes scroll independently"""
        logging.info('Validating Scrollbar presence')
        try:
            manuscript_pane = self._get(self._manuscript_pane)
        except ElementDoesNotExistAssertionError:
            manuscript_pane = self._get(self._manuscript_pdf_viewer_container)
        accordion_pane = self._get(self._accordion_pane)
        assert manuscript_pane.value_of_css_property('overflow-y') == 'auto', \
            manuscript_pane.value_of_css_property('overflow-y')
        assert accordion_pane.value_of_css_property('overflow-y') == 'auto', \
            accordion_pane.value_of_css_property('overflow-y')

    def _check_version_btn_style(self):
        """
        Test version button. This test checks styles but not funtion
        """
        version_btn = self._get(self._tb_versions_link)
        version_btn.click()
        try:
            self._get(self._tb_versions_diff_div)
        except ElementDoesNotExistAssertionError:
            self._get(self._tb_versions_pdf_message)

        bar_items = self._gets(self._bar_items)
        assert 'Now viewing:' in bar_items[0].text, bar_items[0].text
        assert 'Compare with:' in bar_items[1].text, bar_items[1].text
        self._get(self._tb_versions_closer).click()

    def get_ui_manuscript_version(self):
        """
        Retrieves current manuscript version. This method assumes the user is in the manuscript
        viewer and will open the version tab, retrieve the version string and close the tab
        :return: String with manuscript version number
        """
        version_btn = self._get(self._tb_versions_link)
        version_btn.click()
        # allow time for components to attach to DOM
        time.sleep(1)
        bar_items = self._gets(self._bar_items)
        version_number = bar_items[0].find_element(*self._bar_item_selected_item).text.split(' - ')[0]
        logging.info(version_number)
        self._get(self._tb_versions_closer).click()
        return version_number

    def get_journal_id(self):
        """
        Retrieves journal id
        :return: Int with journal_id
        """
        short_doi = self.get_paper_short_doi_from_url()
        logging.info(short_doi)
        journal_id = PgSQL().query('SELECT papers.journal_id '
                                   'FROM papers '
                                   'WHERE short_doi = %s;', (short_doi,))[0][0]
        return journal_id

    def _check_collaborator(self):
        """
        Test collaborator modal.
        """
        collaborator_btn = self._get(self._tb_collaborators_link)
        collaborator_btn.click()
        # APERTA-6840 - we disabled add collaborators temporarily
        # add_collaborators = self._get(self._tb_add_collaborators_label)
        # assert 'Add Collaborators' in add_collaborators.text
        # add_collaborators.click()
        # self._get(self._add_collaborators_modal)
        # add_collaborator_header = self._get(self._overlay_header_title)
        # assert "Who can collaborate on this manuscript?" == add_collaborator_header.text
        # # self.validate_modal_title_style(add_collaborator_header)
        # assert ("Select people to collaborate with on this paper. Collaborators can edit the "
        #         "paper, will be notified about edits on the paper, and can participate in the "
        #         "discussion about this paper." ==
        #         self._get(self._add_collaborators_modal_support_text).text)
        # self._get(self._add_collaborators_modal_support_select)
        # cancel = self._get(self._overlay_action_button_cancel)
        # self.validate_default_link_style(cancel)
        # save = self._get(self._overlay_action_button_save)
        # self.validate_primary_big_green_button_style(save)
        # close_icon_overlay = self._get(self._overlay_header_close)
        # # TODO: Change following line after bug #102078080 is solved
        # assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px')
        # assert APPLICATION_TYPEFACE in close_icon_overlay.value_of_css_property('font-family')
        # assert close_icon_overlay.value_of_css_property('color') == 'rgba(57, 163, 41, 1)'
        # close_icon_overlay.click()
        # time.sleep(1)
        collaborator_btn.click()
        time.sleep(1)

    def _check_download_btns(self):
        """
        Check basic function and style of the downloads buttons.
        """
        downloads_link = self._get(self._tb_downloads_link)
        downloads_link.click()
        downloads_drawer = self._get(self._download_drawer)
        assert downloads_drawer.is_displayed(), 'The download drawer is not open when it should be.'
        close_download_drawer_btn = self._get(self._download_drawer_close_btn)
        close_download_drawer_btn.click()

    def open_recent_activity(self):
        """
        Opens the recent activity overlay
        :return: void function
        """
        self._get(self._tb_ra_link).click()

    def _check_recent_activity(self):
        """
        Check recent activity modal styles
        """
        recent_activity = self._get(self._recent_activity)
        recent_activity.click()
        time.sleep(.5)
        self._get(self._recent_activity_modal)
        self._get(self._overlay_header_title)
        # APERTA-9589
        # self.validate_application_title_style(modal_title)
        close_icon_overlay = self._get(self._overlay_header_close)
        # APERTA-9591
        # assert close_icon_overlay.value_of_css_property('font-size') in ('24px', '16px'), \
        #     close_icon_overlay.value_of_css_property('font-size')
        assert APPLICATION_TYPEFACE in close_icon_overlay.value_of_css_property('font-family'), \
            close_icon_overlay.value_of_css_property('font-family')

        assert close_icon_overlay.value_of_css_property('color') == 'rgb(57, 163, 41)', \
            close_icon_overlay.value_of_css_property('color')
        # close recent activity overlay
        self._get(self._close_ra_overlay).click()
        time.sleep(1)

    def _check_discussion(self, useremail=''):
        """
        Check discussion modal styles
        """
        logging.info('Checking Discussions toolbar for {0}'.format(useremail))
        discussion_link = self._get(self._discussion_link)
        discussion_link.click()
        self._get(self._discussion_container)
        discussion_container_title = self._get(self._discussion_container_title)
        # Note: The following method is parametrized since we don't have a guide for modals
        self.validate_modal_title_style(discussion_container_title, '36px', '500', '39.6px')
        assert 'Discussions' in discussion_container_title.text
        # Only Admins, Internal Editors and PubSvcs Staff can initiate a discussion APERTA-5627
        if useremail in [staff_admin_login['email'],
                         pub_svcs_login['email'],
                         internal_editor_login['email'],
                         super_admin_login['email'],
                         ]:
            discussion_create_new_btn = self._get(self._discussion_create_new_btn)
            # APERTA-6361 Styling incorrect
            # self.validate_secondary_big_green_button_style(discussion_create_new_btn)
            create_new_topic = self._get(self._create_new_topic)
            assert 'Create New Topic'.upper() in create_new_topic.text, create_new_topic.text
            discussion_create_new_btn.click()
            # TODO: Styles for cancel since is not in the style guide
            cancel = self._get(self._create_topic_cancel)
            StyledPage.validate_cancel_button_style(cancel)

            titles = self._gets(self._topic_title)
            assert 'Topic Title' == titles[0].text
            assert 'Message' == titles[1].text
            create_topic_btn = self._get(self._create_topic_btn)
            self.validate_primary_big_green_button_style(create_topic_btn)
            close_icon_overlay = self._get(self._sheet_close_x)
            # TODO: Change following line after bug #102078080 is solved
            assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px', '42px')
            assert APPLICATION_TYPEFACE in close_icon_overlay.value_of_css_property('font-family')
            assert close_icon_overlay.value_of_css_property('color') == 'rgb(57, 163, 41)'
            close_icon_overlay.click()

    def _check_more_btn(self, user=''):
        """
        Check all options inside More button (Appeal and Withdraw).
        Note that Appeal is not implemented yet, so it is not tested.
        """
        logging.info('Checking More Toolbar menu for {0}'.format(user))
        more_btn = self._get(self._tb_more_link)

        more_btn.click()
        # For the time being, the appeals link is being removed for everybody.
        # self._get(self._tb_more_appeal_link)
        # Per APERTA-5371 only creators, admins, pub svcs and internal editors can see the withdraw item
        withdraw_users = users + [staff_admin_login['email'],
                    pub_svcs_login['email'],
                    internal_editor_login['email'],
                    super_admin_login['email'],
                                  ]
        if user in withdraw_users:
            withdraw_link = self._get(self._tb_more_withdraw_link)
            withdraw_link.click()
            self._get(self._wm_modal)
            self._get(self._wm_exclamation_circle)
            modal_title = self._get(self._wm_modal_title)
            assert 'Are you sure?' == modal_title.text
            # TODO: Style parametrized due to lack of styleguide for modals
            self.validate_modal_title_style(modal_title, '48px', line_height='52.8px',
                                            font_weight='500', color=APERTA_GREY_DARK)
            withdraw_modal_text = self._get(self._wm_modal_text)
            # TODO: Leave comment out until solved. Pivotal bug#103864752
            # self.validate_application_body_text(withdraw_modal_text)
            assert ('Withdrawing your manuscript will withdraw it from consideration.\n'
                    'Please provide your reason for withdrawing this manuscript.' in
                    withdraw_modal_text.text)
            self._get(self._wm_modal_textarea)
            yes_btn = self._get(self._wm_modal_yes)
            assert 'YES, WITHDRAW' == yes_btn.text, yes_btn.text
            no_btn = self._get(self._wm_modal_no)
            assert "NO, I'M STILL WORKING" == no_btn.text, no_btn.text
            self.validate_link_big_grey_button_style(yes_btn)
            # TODO: Leave comment out until solved. Pivotal bug#103858114
            # self.validate_secondary_grey_small_button_modal_style(no_btn)
            close_icon_overlay = self._get(self._overlay_header_close)
            # TODO: Change following line after bug #102078080 is solved
            # APERTA-9608
            # assert close_icon_overlay.value_of_css_property('font-size') in ('80px', '90px'), \
            #   close_icon_overlay.value_of_css_property('font-size')
            assert APPLICATION_TYPEFACE in close_icon_overlay.value_of_css_property('font-family'), \
                  close_icon_overlay.value_of_css_property('font-family')
            assert close_icon_overlay.value_of_css_property('color') == APERTA_GREY_DARK, \
                  close_icon_overlay.value_of_css_property('color')
            close_icon_overlay.click()
            # Need to allow the slightest time for the overlay to close to prevent covered element
            #   syndrome
            time.sleep(.5)

    def withdraw_manuscript(self):
        """
        Executes a withdraw action for a given manuscript
        :return: void function
        """
        more_btn = self._get(self._tb_more_link)
        more_btn.click()
        self._wait_for_element(self._get(self._tb_more_withdraw_link))
        withdraw_link = self._get(self._tb_more_withdraw_link)
        withdraw_link.click()
        self._get(self._wm_modal_textarea).send_keys('This a deployment test document...please ignore')
        self._get(self._wm_modal_yes).click()
        # Give a little time for the db transaction
        time.sleep(3)

    def reactivate_manuscript(self):
        """
        Executes a reactivate action for a given manuscript
        This must be called from the login of a valid internal staff account or the button will not
          exist
        :return: void function
        """
        reactivate_btn = self._get(self._withdraw_banner_reactivate_button)
        reactivate_btn.click()
        # Give a little time for the db transaction
        time.sleep(3)

    def check_for_reactivate_btn(self):
        """
        A method to check for the presence of the reactivate button for a given manuscript.
        It should only display for Withdrawn manuscripts when viewed by an internal user.
        :return: boolean indicating presence
        """
        self.set_timeout(15)
        try:
          self._get(self._withdraw_banner_reactivate_button)
        except ElementDoesNotExistAssertionError:
          return False
        finally:
          self.restore_timeout()
        return True

    def validate_reactivate_btn(self):
        """
        Content and Style validations for the reactivate button of the withdraw banner
        :return: void function
        """
        reactivate_button = self._get(self._withdraw_banner_reactivate_button)
        assert reactivate_button.text == 'REACTIVATE', reactivate_button.text
        # Disabling while APERTA-7062 is not closed
        # self.validate_secondary_big_grey_button_style(reactivate_button)

    def validate_roles(self, user_buttons, user=''):
        """
        Given an amount of expected item, check if they are in the top menu.
        This can be expanded as needed.
        :param user_buttons: number of expected buttons
        :param user: string with the user whose role is being validated
        """
        # Time needed to update page and get correct amount of items
        time.sleep(1)
        buttons = self._gets(self._control_bar_right_items)
        assert self._get(self._tb_workflow_link) if user_buttons == 7 else (len(buttons) == 6), \
            'Found {0} buttons for {1}'.format(len(buttons), user)

    def is_task_present(self, task_name):
        """
        Check if a task is available in the task list
        :param task_name: The name of the task to validate
        :return: True if task is present and False otherwise
        """
        tasks = self._gets(self._task_headings)
        for task in tasks:
          if task.text == task_name:
            return True
        return False

    def is_task_marked_complete(self, task_name):
        """
        Check if a task is marked as completed
        :param task_name: The name of the task to validate
        :return: True if task is marked as completed and False otherwise
        """
        tasks = self._gets(self._task_headings)
        for task in tasks:
          if task.text == task_name:
            completed_icon = task.find_element_by_css_selector('div div')
            if 'active' in completed_icon.get_attribute('class'):
              logging.info('Completed is true')
              return True
        logging.info('Completed is False')
        return False

    def is_task_open(self, task_name):
        """
        Check if a task is open
        :param task_name: The name of the task to validate
        :return: True if task is open and False if closed
        """
        tasks = self._gets(self._task_headings)
        for task in tasks:
          if task.text == task_name:
            div_list = task.find_elements_by_xpath("../div")
            # if task is open it should be 2 div under task: task-disclosure-heading and task-disclosure-body
            # if task is closed, only 1: task-disclosure-heading
            return len(div_list)==2

        raise ElementDoesNotExistAssertionError('This task is not present')

    def click_task(self, task_name):
        """
        Click a task title
        NOTE: this covers only the author facing tasks, with the exception of initial_decision
        NOTE also that the locators for these are specifically defined within the scope of the manuscript_viewer or
            workflow page
        NOTE: Note this method is temporarily bifurcated into click_card() and click_task() to support both the manuscript
            and workflow contexts while we transition.
        :param task_name: A string with the name of the task to click, like 'Cover Letter'
            or 'Billing'
        :return: True or False, if taskname is unknown.
        """
        tasks = self._gets(self._task_headings)
        self._scroll_into_view(self._get(self._task_headings))
        for task in tasks:
          if task_name.lower() in task.text.lower():
            self._scroll_into_view(task)
            self._actions.move_to_element(task).perform()
            task.click()
            return True
        logging.info('Unknown Task')
        return False

    def complete_task(self,
                      task_name,
                      click_override=False,
                      data=None,
                      author='',
                      prod=False):
        """
        On a given task, check complete and then close
        :param task_name: The name of the task to complete (str)
        :param click_override: If True, do not prosecute task click to open (when already open)
        :param data: A dictionary with the required data for each task.
        :param author: Author to use in completing author task, if applicable - looks up values from
          Base/Resources.py
        :param prod: boolean, default False - used to signal method call being executed against prod
          where we don't have db access.
        :return outdata or None: returns a list of the values used to fill out the form or None if
          nothing is captured.
        """
        outdata = None
        logging.info('Complete task called for task: {0}'.format(task_name))
        tasks = self._gets(self._task_headings)
        # if task is marked as complete, leave is at is.
        if not click_override:
          for task in tasks:
            task_div = task.find_element_by_xpath('..')
            if task_name in task.text \
                and 'active' \
                not in task_div.find_element(*self._task_heading_status_icon).get_attribute('class'):
              self._scroll_into_view(self._get(self._paper_sidebar_manuscript_id))
              manuscript_id_text = self._get(self._paper_sidebar_manuscript_id)
              self._actions.move_to_element(manuscript_id_text).perform()
              self.click_covered_element(task)
              time.sleep(.5)
              break
            elif task_name in task.text and 'active' \
                in task_div.find_element(*self._task_heading_status_icon).get_attribute('class'):
              return None
          else:
            return None
        else:
          for task in tasks:
            if task_name in task.text:
              break
          else:
            return None
        base_task = BaseTask(self._driver)
        base_task.set_timeout(60)
        if task_name == 'Additional Information':
          ai_task = AITask(self._driver)
          ai_task.task_ready()
          # If the task is read only due to completion state, set read-write
          if ai_task.completed_state():
            ai_task.click_completion_button()
            self._wait_on_lambda(lambda: ai_task.is_task_editable() == True)
          if data:
            ai_task.complete_ai(data)
            self._wait_for_element(task.find_element_by_css_selector('div.active'))
          # complete_addl info task
          if not base_task.completed_state():
            base_task.click_completion_button()
          task.click()
          self._wait_on_lambda(lambda: self.is_task_open('Additional Information') == False)
        elif task_name == 'Billing':
          billing_task = BillingTask(self._driver)
          billing_task.task_ready()
          billing_task.complete(data)
          self._wait_for_element(task.find_element_by_css_selector('div.active'))
          self.click_covered_element(task)
          self._wait_on_lambda(lambda: self.is_task_open('Billing') == False)
        elif task_name == 'Review by':
          review_report = ReviewerReportTask(self._driver)
          review_report.task_ready()
          outdata = review_report.complete_reviewer_report()
          time.sleep(1)
        elif task_name == 'Response to Reviewers':
          revise_manuscript = ReviseManuscriptTask(self._driver)
          revise_manuscript.task_ready()
          revise_manuscript.validate_styles()
          if data and 'response_number' not in data:
            revise_manuscript.validate_empty_response()
          revise_manuscript.response_to_reviewers(data)
          # complete revise task
          if not base_task.completed_state():
            base_task.click_completion_button()
            task.click()
          time.sleep(3) #This sleep is probably also tinymce... Code after Response to Reviewers was failing because completing it took more time than allowed for.
        elif task_name == 'Supporting Info':
          supporting_info = SITask(self._driver)
          supporting_info.task_ready()
          supporting_info.validate_styles()
          if data and 'file_name' in data:
            supporting_info.add_file(data['file_name'])
            time.sleep(5)

            file_label = (By.CLASS_NAME, 'si-file-label-field')
            self._get(file_label).send_keys("1")
            time.sleep(.3)
            self._get((By.CSS_SELECTOR, 'span.ember-power-select-placeholder')).click()
            time.sleep(.3)
            self._gets((By.CLASS_NAME, 'ember-power-select-option'))[1].click()
            time.sleep(.3)
            self._get((By.CLASS_NAME, 'si-file-save-edit-button')).click()

            assert self._get(supporting_info.si_trash_icon)
            edit_btn = self._get(supporting_info.si_pencil_icon)
            edit_btn.click()
            supporting_info.complete_si_item_form(data)
          # complete task
          if not base_task.completed_state():
            base_task.click_completion_button()
            # close task
            task.click()
          time.sleep(1)
        elif task_name == 'Upload Manuscript':
          # before checking that the complete is selected, in the accordion we need to
          # check if it is open
          # if task is open it should be 2 div under task: task-disclosure-heading and task-disclosure-body
          # if task is closed, only 1: task-disclosure-heading
          div_list = task.find_elements_by_xpath("../div")
          if len(div_list) == 1:
            # accordion is close it, open it:
            logging.info('Accordion was closed, opening: {0}'.format(task.text))
            task.click()
          base_task.task_ready()
          # Check completed_check status
          if not base_task.completed_state():
            base_task.move2completion_button(task)
            base_task.click_completion_button()
          self.click_covered_element(task)
          time.sleep(2) #This sleep was added to fix a case where a following complete_task() call failed because this one wasn't done.
        elif task_name in ('Cover Letter', 'Figures', 'Financial Disclosure', 'Reviewer Candidates', 'Preprint Posting'):
          # before checking that the complete is selected, in the accordion we need to
          # check if it is open
          if click_override:
            # Open Upload Manuscript Task
            logging.info('Accordion was closed, opening: {0}'.format(task.text))
            task.click()
            base_task.click_completion_button()
            self.click_covered_element(task)
          else:
            # if task is open it should be 2 div under task: task-disclosure-heading and task-disclosure-body
            # if task is closed, only 1: task-disclosure-heading
            div_list = task.find_elements_by_xpath("../div")
            if len(div_list) == 1:
              # accordion is close it, open it:
              logging.info('Accordion was closed, opening: {0}'.format(task.text))
              task.click()
            base_task.task_ready()

            if task_name == 'Financial Disclosure':
                # click on 'No' in 'Financial Disclosure' card to complete the task
                # since it is required field in the release 1.56,
                # but this should be updated using POM for 'Financial Disclosure' card
                # once APERTA-8895 gets done
                radio_button_no = div_list[1].find_elements(*self._radio_buttons)[1]
                radio_button_no.click()

            # Check completed_check status
            if not base_task.completed_state():
              base_task.move2completion_button(task)
              base_task.click_completion_button()
              self.click_covered_element(task)
              time.sleep(1)
        elif task_name == 'Authors':
          # Complete authors data before mark close
          logging.info('Completing Author Task')
          author_task = AuthorsTask(self._driver)
          author_task.task_ready()
          author_task.edit_author(author)
          self.click_covered_element(task)
          self._wait_on_lambda(lambda: self.is_task_open('Authors') == False)
        elif task_name == 'New Taxon':
          # Complete New Taxon data before mark close
          logging.info('Completing New Taxon Task')
          new_taxon_task = NewTaxonTask(self._driver)
          new_taxon_task.task_ready()
          if data:
            new_taxon_task.validate_taxon_questions_action(data)
            outdata = data
          else:
            scenario = new_taxon_task.generate_test_scenario()
            new_taxon_task.validate_taxon_questions_action(scenario)
            outdata = scenario
          base_task.click_completion_button()
          self.click_covered_element(task)
        elif task_name == 'Title And Abstract':
          # Complete T&A data before mark close
          logging.info('Completing Title And Abstract Task')
          title_and_abstract_task = TitleAbstractTask(self._driver)
          title_and_abstract_task.task_ready()
          short_doi = title_and_abstract_task.get_short_doi()
          if prod:
            title_and_abstract_task.set_abstract(short_doi, prod=True)
          else:
            title_and_abstract_task.set_abstract(short_doi)
          # Need a delay to ensure the card state is updated before clicking the completion button.
          # Without this delay, the click of the completion button fails, unfortunately.
          time.sleep(5)
          base_task.click_completion_button()
          self.click_covered_element(task)
          self._wait_on_lambda(lambda: self.is_task_open('Title And Abstract') == False)
        elif task_name in ('Competing Interests', 'Data Availability', 'Early Version',
                           'Ethics Statement', 'Reporting Guidelines'):
          # Complete Competing Interest data before mark close
          logging.info('Completing {0} Task'.format(task.text))
          base_task.task_ready()
          base_task.click_completion_button()
          self.click_covered_element(task)
        else:
          raise ValueError('No information on this task: {0}'.format(task_name))
        base_task.restore_timeout()
        return outdata

    def get_paper_title_from_page(self):
        """
        Returns the encoded paper title as it appears on the manuscript_viewer page
        :return: paper_title
        """
        paper_title = self._get(self._paper_title).text
        return paper_title

    def click_submit_btn(self, review_overlay_validation=False):
        """Press the submit button
        :param review_overlay_validation: boolean, validates Preview Submission Overlay if True; default is False
        :return: void function
        """
        self._wait_for_element(self._get(self._submit_button), multiplier=2)
        self._get(self._submit_button).click()
        self._review_before_submission = self.is_review_before_submission()
        if self._review_before_submission:
          if review_overlay_validation:
            submission_review_overlay = SubmissionReviewOverlay(self._driver)
            submission_review_overlay.overlay_ready()
            submission_review_overlay.validate_styles_and_components()
            submission_review_overlay.select_submit_or_edit_submission("Submit")
          else:
            self._wait_for_element(self._get(self._review_overlay_submit_button), multiplier=2)
            self._get(self._review_overlay_submit_button).click()

    def is_preprint_on(self) -> bool:
        """
        A method that will determine for mmt if the pre-print feature flag is ON
        :return: True if preprint feature flag is ON, otherwise False
        :type return: bool
        """
        current_env = os.getenv('WEBDRIVER_TARGET_URL', '')
        logging.info(current_env)
        if current_env in production_urls:
            return False
        preprint_feature_flag = PgSQL().query('SELECT active FROM feature_flags WHERE name = \'PREPRINT\';')[0][0]
        return preprint_feature_flag

    def is_review_before_submission(self):
        """
        A method that will determine for the manuscript if the 'Review Your Submission' overlay should be shown
        on submission. Tests for Preprint feature flag enablement for system, preprint checkbox selection for mmt,
        and finally presence of Preprint Posting card in the manuscript. If all three are found,
        return True, else False
        """
        # check if the pre-print feature flag is ON
        if not self.is_preprint_on():
            return False

        # check if manuscript template is preprint eligible
        short_doi = self.get_paper_short_doi_from_url()
        paper_id, paper_type, pp_eligible_mmt = PgSQL().query('SELECT p.id, p.paper_type, mmt.is_preprint_eligible '
                                                              'FROM papers p, journals j, '
                                                              'manuscript_manager_templates mmt '
                                                              'WHERE p.journal_id = j.id '
                                                              'AND mmt.journal_id = j.id '
                                                              'AND mmt.paper_type = p.paper_type '
                                                              'AND p.short_doi =%s;', (short_doi,))[0]

        if not pp_eligible_mmt:
            return False
        # check if "Preprint Posting" card is present
        is_pp_task_present = self.is_task_present('Preprint Posting')
        if not is_pp_task_present:
            return False

        return True

    def confirm_submit_btn(self):
        """Confirm paper submission"""
        # There is a lot going on under the covers in submittal - we need this pregnant delay
        if self._review_before_submission == None:
             self._review_before_submission = self.is_review_before_submission()
        if not self._review_before_submission:
            confirm_btn = self._get(self._so_submit_confirm)
            confirm_btn.click()
            time.sleep(10)

    def confirm_submit_cancel(self):
        """Cancel on confirm paper submission"""
        self._get(self._so_submit_cancel).click()

    def close_submit_overlay(self):
        """Close the submit overlay after confirm paper submission"""
        closer = self._get(self._overlay_header_close)
        closer.click()

    def click_workflow_link(self):
        """Click workflow button"""
        self._wait_for_element(self._get(self._tb_workflow_link))
        self._get(self._tb_workflow_link).click()

    def click_correspondence_link(self):
        """Click correspondence history link"""
        self._wait_for_element(self._get(self._tb_correspondence_link))
        self._get(self._tb_correspondence_link).click()

    def click_question_mark(self):
        """Click on the question mark to open Infobox"""
        self._get(self._question_mark_icon).click()

    def click_aperta_dashboard_link(self):
        """Click on dashboard link"""
        self._get(self._nav_aperta_dashboard_link).click()

    def click_your_manuscript_link(self):
        """Click on Your Manuscripts link"""
        self._get(self._your_manuscripts_link).click()

    def go_to_dashboard(self, item=''):
        """
        Go to the dashboard
        :param item: string with the item where to click ('aperta' for Aperta Icon or
                     'your_manuscripts' for Your Manuscripts link)
        """
        dashboard = {'aperta': self._nav_aperta_dashboard_link,
                     'your_manuscripts': self._your_manuscripts_link}
        if item:
          self._get(dashboard[item]).click()
        else:
          dashboard_link = dashboard[random.choice(dashboard)]
          self._get(dashboard_link).click()

    def get_infobox(self):
        """Get the infobox element"""
        return self._get(self._infobox)

    def close_infobox(self):
        """Close the infobox element, if present"""
        self._wait_for_element(self._get(self._infobox_closer))
        infobox_closer = self._get(self._infobox_closer)
        infobox_closer.click()
        time.sleep(.5)

    def get_paper_doi_part(self):
        """
        Returns the local paper identifier part of the doi
        """
        doi_text = self._get(self._paper_sidebar_manuscript_id).text
        return doi_text.split(':')[1]

    def get_title(self):
        """
        Returns the title
        """
        return self._get(self._title).text

    def validate_so_overlay_elements_styles(self, type_, paper_title):
        """
        Validates styles and content on submit overlay
        :param type_: full_submit, initial_submit, initial_submit_full, congrats, congrats_is,
        congrats_is_full
        :param paper_title: Title of manuscript whose submit overlay you are validating
        :return:
        """
        self._get(self._overlay_header_close)
        self._so_paper_submit_title_text_submit = (By.CSS_SELECTOR, 'div.overlay-title-text-submit h1')
        self._so_paper_submit_subhead_text_submit = (By.CSS_SELECTOR,
                                                     'div.overlay-title-text-submit + h5')
        main_head = self._get(self._so_paper_submit_title_text_submit)
        subhead = self._get(self._so_paper_submit_subhead_text_submit)
        if type_ == 'full_submit':
          assert 'Are you sure?' in main_head.text, main_head.text
          assert 'You are about to submit the paper' in subhead.text, subhead.text
        elif type_ == 'congrats':
          # assert 'Congratulations' in main_head.text, main_head.text
          self._get(self._so_paper_submit_icon)
          assert 'You\'ve successfully submitted your paper!' in subhead.text, subhead.text
        elif type_ == 'congrats_is':
          assert 'You have successfully submitted your manuscript for initial review. If the initial ' \
                 'review is favorable, we will invite you to add some information to facilitate peer ' \
                 'review.' in subhead.text, subhead.text
        elif type_ == 'congrats_full':
          assert 'You have successfully submitted your manuscript. We will start the peer review ' \
                 'process.' in subhead.text, subhead.text
        if type_ in ('full_submit', 'initial_submit', 'initial_submit_full'):
          title = self._get(self._so_paper_title)
          assert paper_title in title.text, '{0} vs {1}'.format(paper_title, title.text)
          self._get(self._so_submit_confirm)

    def validate_submit_success(self):
        """
        Ensure the successful submit message appears in the upper right corner of the manuscript
        viewer page
        """
        success_msg = self._get(self._paper_sidebar_state_information)
        assert 'This paper has been submitted.' in success_msg.text, success_msg.text

    def validate_initial_submit_success(self):
        """Ensure the final submit message does not appear on initial submit"""
        success_msg = self._get(self._paper_sidebar_state_information)
        assert 'This paper has been submitted.' not in success_msg.text, success_msg.text

    def add_collaborators(self, user):
        """
        Add a collaborator
        :param user: user
        :return: None
        """
        logging.info('Adding {0} as collaborator'.format(user['name']))
        self._get(self._tb_collaborators_link).click()
        self._get(self._tb_add_collaborators_label).click()
        time.sleep(2)
        select_div = self._get(self._add_collaborators_modal_select)
        select_div.find_element_by_tag_name('a').click()
        select_input = self._get(self._add_collaborators_modal_input)
        select_input.send_keys(user['name'][0:4])
        # Need time for list to populate dynamically
        time.sleep(2)
        select_items = (By.CSS_SELECTOR, 'ul.select2-results')
        items = self._get(select_items)
        for item in items.find_elements_by_tag_name('li'):
          if item.text == user['name']:
            item.click()
            time.sleep(.5)
            break
        else:
          raise Exception("User {0} not found".format(user['name']))
        time.sleep(1)
        self._get(self._add_collaborators_modal_save).click()

    def get_submission_status_initial_submission_todo(self):
        """Extract the submission status text from the page"""
        return self._get(self._status_info_initial_submit_todo).text

    def get_submission_status_ready2submit_text(self):
        """
        Extract the submission status text from the page
        """
        return self._get(self._status_info_ready_to_submit).text

    def wait_for_viewer_page_population(self):
        """
        Purgatory, waiting for an update that sometimes takes forever, sigh
        :return:
        """
        logging.info(datetime.now())
        self.set_timeout(230)
        self._get(self._paper_sidebar_state_information)
        logging.info(datetime.now())
        self.restore_timeout()

    def reset_view_top_accordion(self):
        """ Resets the view to the submission information section of the right hand column"""
        sub_info = self._get(self._paper_sidebar_state_information)
        self._actions.move_to_element(sub_info).perform()
        time.sleep(.5)

    def select_manuscript_version_item(self, version_selector='compare',
                                       item_index=None):
        """
        Select a manuscript version item
        :param version_selector: The version selector to use (compare or viewing). String
        :param item_index: The item index in the selector. Integer
        :return: None
        """
        # Convert the string to a bar_item elements index
        bar_items_index = None
        if version_selector == 'viewing':
          bar_items_index = 0
        elif version_selector == 'compare':
          bar_items_index = 1

        # Open the versioning box
        version_btn = self._get(self._tb_versions_link)
        version_btn.click()
        # Waits for versioning box be visible
        self._wait_for_element(
          self._gets(self._bar_items)[1])

        # Get the bar items
        bar_items = self._gets(self._bar_items)
        # click on
        version_select = bar_items[bar_items_index].find_element_by_class_name(
          'ember-power-select-trigger')
        version_select.click()
        version_select_id = version_select.get_attribute('id')
        items_holder_selector = (By.ID, version_select_id.replace('trigger', 'content'))
        items_holder = self._get(items_holder_selector)
        items_holder.find_elements_by_class_name('ember-power-select-option')[
          item_index].click()

    def get_manuscript_versions(self):
        """
        get_manuscript_versions: Returns the list of versions for this manuscript
        :return: A list of version objects
        """
        short_doi = self.get_short_doi()
        versions = []
        results = PgSQL().query("select id,major_version,minor_version,created_at,paper_id,file_type from "
                                "versioned_texts where paper_id = (SELECT ID from papers "
                                "where short_doi = '{0}') order by id DESC;".format(short_doi))
        for version in results:
          if version[1] is None:
            version_number = 'draft'
          else:
            version_number = '{0}.{1}'.format(version[1], version[2])

          versions.append({
            'id': version[0],
            'version': version_number,
            'date': version[3],
            'paper_id': version[4],
            'format': version[5]
          })

        return versions

    def validate_download_drawer_styles(self):
        """
        validate_download_drawer_styles: Validates the download drawer styles
        and version items
        :return: void function
        """
        # Get manuscript versions list
        ms_versions = self.get_manuscript_versions()

        # Open download drawer
        self._get(self._tb_downloads_link).click()

        # Validate drawer title
        title = self._get(self._download_drawer_title)
        expected_title = 'Downloads'
        assert title.text == expected_title, 'The drawer title {0} is not the ' \
                                             'expected {1}'.format(title.text, expected_title)
        # self.validate_manuscript_title_style(title)

        # Validate table headers
        table_headers = self._gets(self._download_drawer_table_header)
        expected_table_headers = ['Manuscript Version', '* Format']
        for key, table_header in enumerate(table_headers):
          assert table_header.text == expected_table_headers[key], \
              'The download table header {0}: {1} is not the expected:' \
              ' {2}'.format(key, table_header.text, expected_table_headers[key])

          # self.validate_table_heading_style(table_header)

        # Validate table items
        table_items = self._gets(self._download_drawer_items)
        for key, table_item in enumerate(table_items):
          version_data = ms_versions[key]
          expected_version_name = version_data['version']
          # adding submission date: APERTA-9335
          expected_version_date = version_data['date'].strftime("%b %d, %Y")

          # Fix for adding the 'V' before the version number
          if expected_version_name != 'draft':
            expected_version_name = 'V{0} - {1}'.format(expected_version_name, expected_version_date)

          # Validate version name styles
          version_name = table_item.find_element_by_class_name('paper-downloads-version')
          assert version_name.text.lower() == expected_version_name.lower(), \
              'Download table item {0} version name {1} is not the expected {2}'\
              .format(key, version_name.text, expected_version_name)
          self.validate_application_body_text(version_name)

          download_links = table_item.find_elements_by_class_name(
            'paper-downloads-link')

          expected_link_title = {'download-source': 'Word', 'download-docx': 'Word', 'download-pdf': 'PDF'}

          # Validate table item links
          for download_link in download_links:
            link = download_link.find_element_by_tag_name('a')
            download_link_classes = download_link.get_attribute('class').split(' ')
            if 'paper-downloads-link--pdf' in download_link_classes:
              assert 'text-align-right' in download_link_classes, \
                  'The PDF link is not right aligned as expected'

            link_class = link.get_attribute('class')
            assert link.text == expected_link_title[link_class],\
                'The download link {0} of the item {1} title {2} is not the ' \
                'expected {3}'.format(link_class, key, link.text,
                                      expected_link_title[link_class])

            self.validate_default_link_style(link)

        self._get(self._download_drawer_close_btn).click()

    def validate_manuscript_downloaded_file(self, download_link_el,
                                              format='pdf'):
        """
        validate_manuscript_downloaded_file: Validates if the manuscript
        download was successful
        :param: download_link_el: The element to click to start the download
        :param: format: The format of the manuscript to be downloaded
        :return: void function
        """
        original_dir = os.getcwd()
        download_link_el.click()
        # Longer sleep for PDF generation
        if format == 'pdf':
          time.sleep(15)
        else:
          time.sleep(5)

        # Note that there is no validation of the doc or docx - we are not manipulating them at all
        #   Just returning the last stored version - so not doing anything beyond validating download
        #   completion.
        os.chdir('/tmp')
        files = filter(os.path.isfile, os.listdir('/tmp'))
        files = [os.path.join('/tmp', f) for f in files]  # add path to each file
        files.sort(key=lambda x: os.path.getmtime(x))
        newest_file = files[-1]
        logging.debug(newest_file)
        while newest_file.split('.')[-1] == 'part':
          time.sleep(.5)
          files = filter(os.path.isfile, os.listdir('/tmp'))
          files = [os.path.join('/tmp', f) for f in files]  # add path to each file
          files.sort(key=lambda x: os.path.getmtime(x))
          newest_file = files[-1]
          logging.debug(newest_file.split('.')[-1])
        logging.debug(newest_file)

        pdf_valid = False
        try:
          if format == 'pdf':
            logging.info('PDF to validate: {0}'.format(newest_file))
            pdf_valid = PdfUtil.validate_pdf(newest_file)
          else:
            pdf_valid = True
        finally:
          os.remove(newest_file)
          os.chdir(original_dir)

        # Raising error just after move to the original working dir
        if not pdf_valid:
          logging.error('PDF file: {0} is invalid'.format(newest_file))
          raise ('Invalid PDF generated for {0}'.format(newest_file))

    def validate_version_download_link(self, version_data, link, link_format):
        """
        validate_version_download_link: Validates the download link url for a manuscript version
        :param version_data: The version data object. Object
        :param link: The URL to validate. String
        :param link_format: The format of the link to validate (doc or pdf). String
        :return: void function
        """
        expected_paper_id = 'paper_downloads/{0}'.format(version_data['paper_id'])
        assert expected_paper_id in link, 'The paper id {0} is not on the link {1}'.format(expected_paper_id, link)

        expected_export_format = 'export_format={0}'.format(link_format)
        assert expected_export_format in link, 'The export format {0} is not on the link {1}'.format(
          expected_export_format, link)

        expected_version_id = 'versioned_text_id={0}'.format(version_data['id'])
        assert expected_version_id in link, 'The version id {0} is not on the link {1}'.format(
          expected_version_id, link)

    def validate_download_btn_actions(self):
        """
        validate_download_btn_actions: Validates the download buttons actions
        for all the manuscript versions
        :return: void function
        """
        # Get manuscript versions list
        ms_versions = self.get_manuscript_versions()

        # Open download drawer
        self._get(self._tb_downloads_link).click()

        # Validate table items links action
        table_items = self._gets(self._download_drawer_items)
        for key, table_item in enumerate(table_items):
          version_data = ms_versions[key]
          item_version_name = version_data['version']

          word_formats = ['doc', 'docx']
          pdf_link = table_item.find_element_by_class_name('download-pdf')

          if version_data['format'] in word_formats:
            word_link = table_item.find_element_by_class_name('download-docx')
            logging.info('Validating word format file for version {0}'.format(
              item_version_name))
            self.validate_version_download_link(version_data,
                                                word_link.get_attribute('href'),
                                                'doc')
            self.validate_manuscript_downloaded_file(word_link, format='word')

          logging.info('Validating pdf format file for version {0}'.format(
            item_version_name))

          self.validate_version_download_link(version_data,
                                              pdf_link.get_attribute('href'),
                                              'pdf')
          self.validate_manuscript_downloaded_file(pdf_link)

        self._get(self._download_drawer_close_btn).click()

    def _check_resize_handle(self):
        """
        _check_resize_handle: Validates the sidebar/manuscript resize handle
        styles and tooltip action
        :return: void function
        """
        handle_line = self._get(self._resize_handle_line)
        handle_box = self._get(self._resize_handle_box)
        handle_box_lines = self._gets(self._resize_handle_box_lines)

        # Validate handle line
        # Ps: Cannot validate the line width because it's on a CSS pseudo-element
        assert handle_line.is_displayed(), 'The handle line is not displayed'
        # Certify the handle line is over the other elements
        assert handle_line.value_of_css_property('z-index') == '2', \
            'The handle line z-index {0} is not the expected 2'.format(handle_line.value_of_css_property('z-index'))

        assert handle_line.value_of_css_property('cursor') == 'ew-resize', \
            'The handle line cursor {0} is not the expected ew-resize'.format(handle_line.value_of_css_property('cursor'))

        # Validate handle box
        handle_box_expected_width = '23px'
        handle_box_expected_height = '35px'

        handle_box_expected_bg = ['#ddd', 'rgb(221, 221, 221)']

        handle_box_expected_left = '-9px'

        assert handle_box.is_displayed(), 'The handle box is not displayed'

        assert handle_box.value_of_css_property('width') == \
               handle_box_expected_width, 'The handle box width {0} is not the ' \
                                          'expected {1}'.format(
          handle_box.value_of_css_property('width'), handle_box_expected_width)

        assert handle_box.value_of_css_property('height') == \
               handle_box_expected_height, 'The handle box height {0} is not the ' \
                                          'expected {1}'.format(
          handle_box.value_of_css_property('height'), handle_box_expected_height)

        assert handle_box.value_of_css_property('background-color') in \
               handle_box_expected_bg, 'The handle box bg color {0} is not the ' \
                                           'expected {1}'.format(
          handle_box.value_of_css_property('background-color'),
          handle_box_expected_bg)

        assert handle_box.value_of_css_property('left') == \
               handle_box_expected_left, 'The handle box left {0} is not the ' \
                                        'expected {1}'.format(
          handle_box.value_of_css_property('left'), handle_box_expected_left)

        # Validate handle box lines
        assert len(handle_box_lines) == 3, 'The handle box have {0} lines when 3 ' \
                                           'is expected'.format(len(handle_box_lines))
        line_expected_top = '4px'
        line_expected_padding_left = '2px'
        line_expected_height = '26px'

        for key, line in enumerate(handle_box_lines):
          assert line.value_of_css_property('top') == line_expected_top, \
              'The handle box line {0} top {1} is not the expected: {2}'.format(
              line.value_of_css_property('top'), line_expected_top)

          assert line.value_of_css_property('padding-left') == line_expected_padding_left, \
              'The handle box line {0} padding-left {1} is not the expected: {2}'.format(
              key, line.value_of_css_property('padding-left'),
              line_expected_padding_left)

          assert line.value_of_css_property('height') == line_expected_height, \
            'The handle box line {0} height {1} is not the expected: {2}'.format(
              key, line.value_of_css_property('height'), line_expected_height)

        # Validate tooltip
        self._actions.move_to_element(handle_box).perform()
        self._wait_for_element(self._get(self._resize_handle_box_tooltip))
        tooltip = self._get(self._resize_handle_box_tooltip)
        tooltip_expected_text = 'adjust the size of your workspace'
        assert tooltip.is_displayed(), 'The handle box tooltip is not visible.'
        assert tooltip.text == tooltip_expected_text, \
            'The handle box tooltip text {0} is not the expected {1}'.format(
              tooltip.text, tooltip_expected_text)

    def check_failed_conversion_text(self, status=''):
        """
        A method to check if the correct failed conversion method is presented in the preview pane
        :param status: string, valid values are 'unsubmitted' or 'submitted' (case insensitive)
        :return True if conversion message asserts, False if no, or incorrect, status passed to function
        """
        failed_conversion_heading = self._get(self._failed_conversion_heading)
        if not status or status.lower() not in ('unsubmitted', 'submitted'):
            logging.warning('You must pass a paper state of "unsubmitted" or "submitted" when calling '
                          'check_failed_conversion_text')
            return False
        elif status.lower() == 'unsubmitted':
            # validate unsubmitted failed conversion message - see APERTA-8858
            assert failed_conversion_heading.text == 'Your file was uploaded successfully, but we were ' \
                                                     'unable to render a preview at this time.', \
                                                     failed_conversion_heading.text
        else: #  status.lower() == 'submitted'
            # validate submitted failed conversion message - see APERTA-8858
            assert failed_conversion_heading.text == 'Preview for this manuscript is unavailable.', \
                failed_conversion_heading.text
        return True
