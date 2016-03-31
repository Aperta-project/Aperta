#!/usr/bin/python2.7


class ElementDoesNotExistAssertionError(AssertionError):
  """
  Raises a failure on Element Does Not Exist when used as a test
  """


class ErrorAlertThrownException(StandardError):
  """
  Raises a failure on an Error being thrown when it shouldn't
  """