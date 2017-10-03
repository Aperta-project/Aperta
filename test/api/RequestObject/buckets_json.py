#!/usr/bin/env python2

"""
Base class for CREPO Bucket JSON related services
"""

__author__ = 'jgray@plos.org'

from ...Base.base_service_test import BaseServiceTest
from ...Base.Config import API_BASE_URL
from ...Base.api import Needs

BUCKETS_API = API_BASE_URL + '/v1/buckets'
DEFAULT_HEADERS = {'Accept': 'application/json'}
HEADER = '-H'


class BucketsJson(BaseServiceTest):

  def get_buckets(self):
    """
    Calls CREPO API to get bucket list
    :param
    :return:JSON response
    """
    header = {'header': HEADER}
    self.doGet('%s' % BUCKETS_API, header, DEFAULT_HEADERS)
    self.parse_response_as_json()

  @Needs('parsed', 'parse_response_as_json()')
  def verify_buckets(self):
    """
    Verifies a valid response
    :param
    :return: Bucket List + OK
    """
    print ('Validating buckets...'),
    actual_buckets = self.parsed.get_bucketName()
    print(str(actual_buckets))
    assert actual_buckets
    print ('OK')
