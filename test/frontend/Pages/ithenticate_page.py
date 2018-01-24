#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Page Object Model for the api.ithenticate.com page.
"""

from selenium.webdriver.common.by import By

from Base.PlosPage import PlosPage

__author__ = 'gtimonina@plos.org'


class IthenticatePage(PlosPage):
    """
    Model an abstract api.iThenticate.com page
    """

    def __init__(self, driver):
        super(IthenticatePage, self).__init__(driver)

        # Locators - Instance members
        # ithenticate page locators
        self._logo_img = (By.CSS_SELECTOR, 'div.branding-view>img')
        self._ithenticate_title = (By.CSS_SELECTOR, 'div.infobar-title')
        self._ithenticate_value = (By.CSS_SELECTOR, 'div.infobar-value')
        self._ithenticate_sidebar = (By.CSS_SELECTOR, 'div.originality-cumulative-sidebar')
        self._ithenticate_author = (By.CSS_SELECTOR, 'div.author')

    # POM Actions
    def page_ready(self):
        """
        Ensure the page is ready for interaction
        :return: void function
        """
        self._wait_for_element(self._get(self._ithenticate_sidebar))

    def get_title_score(self):
        """
        gets elements of the api.ithenticate page
        :return: title, value, author - strings to validate
        """
        title = self._get(self._ithenticate_title).text
        value = self._get(self._ithenticate_value).text
        author = self._get(self._ithenticate_author).text

        return title, value, author
