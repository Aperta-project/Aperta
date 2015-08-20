#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

import platform
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import TimeoutException, NoSuchElementException
from selenium.webdriver.common.keys import Keys
from CustomException import ElementDoesNotExistAssertionError
from bs4 import BeautifulSoup, NavigableString
from LinkVerifier import LinkVerifier
import CustomExpectedConditions as CEC
import Config as Config


class PlosPage(object):
  """
  Model an abstract base Journal page.
  """
  PROD_URL = ''

  def __init__(self, driver, urlSuffix=''):
    # Internal WebDriver-related protected members
    self._driver = driver
    self._wait = WebDriverWait(self._driver, Config.wait_timeout)
    self._actions = ActionChains(self._driver)

    base_url = self.__buildEnvironmentURL(urlSuffix)

    # Prevents WebDriver from navigating to a page more than once (there should be only one starting point for a test)
    if not hasattr(self._driver, 'navigated'):
      try:
        self._driver.get(base_url)
        self._driver.navigated = True
      except TimeoutException as toe:
        print '\t[WebDriver Error] WebDriver timed out while trying to load the requested web page "%s".' % base_url
        raise toe

    # Internal private member
    self.__linkVerifier = LinkVerifier()

    # Locators - Instance variables unique to each instance
    self._article_type_menu = (By.ID, 'article-type-menu')

  # POM Actions

  def __buildEnvironmentURL(self, urlSuffix):
    """
    *Private* method to detect on which environment we are running the test.
    Then builds up a URL accordingly

    1. urlSuffix: String representing the suffix to append to the URL. It is generally provided by

    **Returns** A string representing the whole URL from where our test starts

    """
    env = Config.environment.lower()
    base_url = self.PROD_URL if env == 'prod' else Config.base_url + urlSuffix
    return base_url

  def _get(self, locator):
    try:
      return self._wait.until(EC.visibility_of_element_located(locator))
    except TimeoutException:
      print '\t[WebDriver Error] WebDriver timed out while trying to identify element by %s.' % str(locator)
      raise ElementDoesNotExistAssertionError(locator)

  def _iget(self, locator):
    """
    Unlike the regular _get() function, this one will be successful for elements with a width and or height of zero
    stupid name, but suggesting 'i' for invisible as a zero width/height element.
    :param locator: locator
    """
    try:
      return self._wait.until(EC.presence_of_element_located(locator))
    except TimeoutException:
      print '\t[WebDriver Error] WebDriver timed out while trying to identify element by %s.' % str(locator)
      raise ElementDoesNotExistAssertionError(locator)

  def _gets(self, locator):
    try:
      return self._wait.until(EC.presence_of_all_elements_located(locator))
    except TimeoutException:
      print '\t[WebDriver Error] WebDriver timed out while trying to identify elements by %s.' % str(locator)
      raise ElementDoesNotExistAssertionError(locator)

  def _wait_for_element(self, element):
    self._wait.until(CEC.element_to_be_clickable(element))

  def _is_link_valid(self, link):
    return self.__linkVerifier.is_link_valid(link.get_attribute('href'))

  def traverse_to_frame(self, frame):
    print '\t[WebDriver] About to switch to frame "%s"...' % frame,
    self._wait.until(EC.frame_to_be_available_and_switch_to_it(frame))
    print 'OK'

  def traverse_from_frame(self):
    print '\t[WebDriver] About to switch to default content...',
    self._driver.switch_to.default_content()
    print 'OK'

  def set_timeout(self, new_timeout):
    self._driver.implicitly_wait(new_timeout)
    self._wait = WebDriverWait(self._driver, new_timeout)

  def restore_timeout(self):
    self._driver.implicitly_wait(Config.wait_timeout)
    self._wait = WebDriverWait(self._driver, Config.wait_timeout)

  def get_text(self, s):
    soup = BeautifulSoup(s)
    clean_out = soup.get_text()
    print(clean_out)
    return clean_out

  def open_new_tab(self):
    """Open a new tab"""
    os = platform.system()
    if os in ('Linux', 'Windows'):
      self._get((By.CSS_SELECTOR, 'body')).send_keys(Keys.CONTROL + 't')
    elif os == 'Darwin':
      self._get((By.CSS_SELECTOR, 'body')).send_keys(Keys.COMMAND + 't')
    return self

  def go_to_tab(self, tab_number):
    """Go to the requested tab"""
    self._get((By.CSS_SELECTOR, 'body')).send_keys(Keys.ALT + str(tab_number))
    return self

  def refresh(self):
    """refreshes current page"""
    self._driver.refresh()
    return self