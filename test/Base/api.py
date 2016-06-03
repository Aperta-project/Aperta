#!/usr/bin/env python2

"""
Module to store various Decorators that will come in handy while service testing
"""

__author__ = 'jkrzemien@plos.org'

from functools import wraps
from unittest import TestCase
from datetime import datetime
import time


class Needs(object):

  """
  Decorator to guarantee a given attribute is **present** in an instance.
  If the attribute is not present, test fails with a message containing instructions of which method was not called
  from test to create the required attribute.
  If the attribute is present this decorator does nothing.
  """

  def __init__(self, attribute, needsMethod):
    self.attributeNeeded = attribute
    self.methodToInvoke = needsMethod

  def __call__(self, method):
    @wraps(method)
    def wrapper(value, *args, **kw):
      if not hasattr(value, self.attributeNeeded):
        TestCase.fail(value, 'You MUST invoke %s first, BEFORE performing any validations!' % self.methodToInvoke)
      else:
        return method(value, *args, **kw)

    return wrapper


def timeit(method):
  """
  Function decorator.
  Allows to measure the execution times of dedicated methods
  (module-level methods or class methods) by just adding the
  @timeit decorator in in front of the method call.
  """

  @wraps(method)
  def wrapper(value, *args, **kw):
    setattr(value, '_testStartTime', datetime.now())
    ts = time.time()
    result = method(value, *args, **kw)
    te = time.time()
    setattr(value, '_apiTime', (datetime.now() - value._testStartTime).total_seconds())

    print ''
    print 'Method %r %r call took %2.2f sec...' % (method.__name__, args[:], te - ts)
    return result

  return wrapper
