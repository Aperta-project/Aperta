#!/usr/bin/env python2


__author__ = 'jkrzemien@plos.org'

import unittest
import random

from teamcity import is_running_under_teamcity
from teamcity.unittestpy import TeamcityTestRunner

from WebDriverFactory import WebDriverFactory
from Base.Resources import login_valid_email, login_valid_pw
from frontend.Pages.login_page import LoginPage
from frontend.Pages.dashboard import DashboardPage

class FrontEndTest(unittest.TestCase):
  """
  Base class to provide Front End tests with desired WebDriver instances, as defined in
  [[Config.py]].
  It inherits from `TestCase` in order to count as a test suite for Python's `unittest` framework.
  """

  # This defines any `FrontEndTest` derived class as able to be run by Nose in a parallel way.
  # Requires Nose's `MultiProcess` plugin to be *enabled*
  _multiprocess_can_split_ = True

  # Will contain a single driver instance for the current test
  _driver = None

  # Will contain a list of driver (not instantiated) for the current test variations (for all browsers)
  _injected_drivers = []

  # Factory object to instantiate drivers
  factory = WebDriverFactory()

  def setUp(self):
    pass

  def tearDown(self):
    """
    Method in charge of destroying the WebDriver/Proxy instances
    once the test finished running (even upon test failure).
    """
    if self._driver:
      self._driver.quit()
    else:
      self.factory.teardown_webdriver()

  def getDriver(self):
    """
    Simple method to retrieve the WebDriver/Proxy instances for this class to test method.
    """
    if not self._driver:
      if len(self._injected_drivers) > 0:
        self._driver = self.factory.setup_remote_webdriver(self._injected_drivers.pop())
      else:
        self._driver = self.factory.setup_webdriver()
    return self._driver

  @staticmethod
  def _run_tests_randomly():
    """
    *Static* method for every test suite inheriting this class to be able to run its tests
    in, at least, a non linear fashion.
    """
    unittest.TestLoader.sortTestMethodsUsing = lambda _, x, y: random.choice([-1, 1])
    if is_running_under_teamcity():
      runner = TeamcityTestRunner()
    else:
      runner = unittest.TextTestRunner()
    unittest.main(testRunner=runner)
