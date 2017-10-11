#!/usr/bin/env python2

"""
"""

__author__ = 'jkrzemien@plos.org'

from abc import ABCMeta, abstractmethod


class AbstractValidator(object):

  __metaclass__ = ABCMeta

  def __init__(self, data):
    self._size = len(data)

  def get_size(self):
    return self._size

  @abstractmethod
  def metadata(self):
    pass
