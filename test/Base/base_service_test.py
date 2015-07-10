#!/usr/bin/env python2

"""
Base class for Rhino related service tests.
"""

__author__ = 'jgray@plos.org'

import json
import random
import unittest
from ..api.Response.JSONResponse import JSONResponse
from api import timeit
from Config import TIMEOUT, PRINT_DEBUG
from inspect import getfile
from os import walk
from os.path import dirname, abspath
from requests import get, post, patch, put, delete
from teamcity import is_running_under_teamcity
from teamcity.unittestpy import TeamcityTestRunner


class BaseServiceTest(unittest.TestCase):

  __response = None

  # Autowired by @timeit decorator
  _testStartTime = None

  # Autowired by @timeit decorator
  _apiTime = None

  def setUp(self):
    pass

  def tearDown(self):
    self.__response = None
    self._testStartTime = None
    self._apiTime = None

  def _debug(self):
    if PRINT_DEBUG:
      print 'API Response = %s' % self.__response.text

  @timeit
  def doGet(self, url, params=None, headers=None):
    self.__response = get(url, headers=headers, params=params, verify=False, timeout=TIMEOUT, allow_redirects=True)
    self._debug()

  @timeit
  def doPost(self, url, data=None, files=None, headers=None):
    self.__response = post(url, headers=headers, data=data, files=files, verify=False, timeout=TIMEOUT,
                           allow_redirects=True)
    self._debug()

  @timeit
  def doPatch(self, url, data=None, headers=None):
    self.__response = patch(url, headers=headers, data=json.dumps(data), verify=False, timeout=TIMEOUT,
                            allow_redirects=True)
    self._debug()

  @timeit
  def doDelete(self, url, data=None, headers=None):
    self.__response = delete(url, headers=headers, data=data, verify=False, timeout=TIMEOUT, allow_redirects=True)
    self._debug()

  @timeit
  def doPut(self, url, data=None, headers=None):
    self.__response = put(url, headers=headers, data=data, verify=False, timeout=TIMEOUT, allow_redirects=True)
    self._debug()

  @timeit
  def doUpdate(self, url, data=None, headers=None):
    self.doPut(url, data, headers)

  def get_http_response(self):
    return self.__response

  def parse_response_as_json(self):
    self.parsed = JSONResponse(self.get_http_response().text)

  def verify_http_code_is(self, httpCode):
    print 'Validating HTTP Response code to be %s...' % httpCode,
    self.assertEquals(self.__response.status_code, httpCode)
    print 'OK'

  def find_file(self, filename):
    path = dirname(abspath(getfile(BaseServiceTest))) + '/../../'
    for root, dirs, files in walk(path):
      for file in files:
        if file == filename:
          return root + '/' + file

  @staticmethod
  def _run_tests_randomly():
    unittest.TestLoader.sortTestMethodsUsing = lambda _, x, y: random.choice([-1, 1])
    if is_running_under_teamcity():
      runner = TeamcityTestRunner()
    else:
      runner = unittest.TextTestRunner()
    unittest.main(testRunner=runner)
