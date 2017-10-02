#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

'''
This class loads up an XML file in order to be used later on for validations against
Tests's responses.
'''

from TIFValidator import TIFValidator


class PNGValidator(TIFValidator):

  def __init__(self, name, data, xml):
    super(PNGValidator, self).__init__(name, data, xml)
    self.MIME = 'image/png'
    self.EXT = 'PNG'

