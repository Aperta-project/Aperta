#!/usr/bin/env python2

__author__ = 'jgray@plos.org'

'''
Test cases for Content Repo Bucket requests.
'''
from ..api.RequestObject.buckets_json import BucketsJson


class GetBuckets(BucketsJson):

  def test_buckets(self):
    """
    Get Buckets API call
    """
    self.get_buckets()
    self.verify_buckets()

if __name__ == '__main__':
    BucketsJson._run_tests_randomly()
