#!/usr/bin/env python2

"""
Class for accessing PDF utility functions of the PyPDF2 package.

Py2PDF can be installed via the following command:

  sudo pip install PyPDF2

"""

__author__ = 'jgray@plos.org'

import logging
import sys

import PyPDF2
from PyPDF2.utils import PdfReadError


class PdfUtil(object):
  """
  A wrapper for PyPDF2 that extends basic functions
  """
  @staticmethod
  def validate_pdf(filename):
    """
    Validates the file parameter to be a valid PDF
    :param filename: filename to validate as valid PDF
    :return: True if valid, else Error
    """
    try:
      document = PyPDF2.PdfFileReader(open(filename, "rb"), strict=True, warndest=sys.stdout)
    except PdfReadError:
      raise
    docinfo = document.getDocumentInfo()
    docmeta = document.getXmpMetadata()
    logging.debug('Validating {}'.format(filename))
    if docinfo['/Title'] == '':
      logging.warning('No Title set internal to PDF: {0}'.format(docinfo['/Title']))
    if docinfo['/Creator'] == '':
      logging.warning('No Creator set internal to PDF: {0}'.format(docinfo['/Creator']))
    logging.debug('PDF Document Information: {0}'.format(docinfo))
    logging.debug('PDF Document XMPInfo: {0}'.format(docmeta))
    return True
