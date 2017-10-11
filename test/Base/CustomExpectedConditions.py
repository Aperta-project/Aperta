#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

from selenium.common.exceptions import StaleElementReferenceException


# === Element To Be Clickable expectation definition ===
class ElementToBeClickable(object):
    """

    An expectation for checking that an element is **present on the DOM** of a
    page and **visible**.

    Arguments:

    1. element - an instance of a Web Element (**not** a locator)

    Returns:

    1. the same WebElement once it has been located and is visible

    *Visibility* means that the element is not only displayed
    but also that its *height* and *width* are *greater* than 0.

    """

    def __init__(self, element):
        self.element = element

    def __call__(self, driver):
        try:
            return self.element.is_displayed() and self.element.is_enabled()
        except StaleElementReferenceException:
            return False
