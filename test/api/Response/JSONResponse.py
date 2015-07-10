#!/usr/bin/env python2

"""
Base class for Rhino's JSON based service tests.
Python's JSONPath can be installed via the following command:
  sudo pip install --allow-external jsonpath --allow-unverified jsonpath jsonpath
"""

__author__ = 'jgray@plos.org'

import json
from jsonpath import jsonpath
from AbstractResponse import AbstractResponse


class JSONResponse(AbstractResponse):

  _json = None

  def __init__(self, response):
    try:
      self._json = json.loads(response)
    except Exception as e:
      print 'Error while trying to parse response as JSON!'
      print 'Actual response was: "%s"' % response
      raise e

  def get_json(self):
    return self._json

  def jpath(self, path):
    return jsonpath(self._json, path)

  def get_buckets(self):
    return self.jpath('$.')

  def get_bucketTimestamp(self):
    return self.jpath('$..timestamp')

  def get_bucketCreationDate(self):
    return self.jpath('$..creationDate')

  def get_bucketID(self):
    return self.jpath('$..bucketID')

  def get_bucketName(self):
    return self.jpath('$..bucketName')

  def get_bucketActiveObjects(self):
    return self.jpath('$..bucketActiveObjects')

  def get_bucketTotalObjects(self):
    return self.jpath('$..bucketTotalObjects')

  def get_objectKey(self):
    return self.jpath('$..objectKey')


