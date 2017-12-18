#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
POM for the dynamically generated Changes for Author Card
"""

from selenium.webdriver.common.by import By

from frontend.Tasks.basetask import BaseTask

__author__ = 'jgray@plos.org'


class ChangesForAuthorTask(BaseTask):
    """
    Page Object Model for Changes For Author task
    """

    def __init__(self, driver):
        super(ChangesForAuthorTask, self).__init__(driver)

        # Locators - Instance members
        self._card_heading = (By.CSS_SELECTOR, 'div.task-main-content > h3')
        self._changes_requested_detail = (By.CSS_SELECTOR, 'p.preserve-line-breaks')

    # POM Actions
    def validate_styles(self):
        """
        Validate styles in the Changes For Author Task
        """
        heading_text = self._get(self._card_heading)
        self.validate_application_h3_style(heading_text)
        assert heading_text.text == ('Please address the following changes so we can process your '
                                     'manuscript:'), heading_text.text
        changes_detail_p = self._get(self._changes_requested_detail)
        self.validate_application_body_text(changes_detail_p)
