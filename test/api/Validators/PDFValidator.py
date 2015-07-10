#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

'''
This class loads up a PDF file in order to be used later on for validations against
Tests's responses.
'''

from datetime import datetime

from AbstractValidator import AbstractValidator


class PDFValidator(AbstractValidator):

  def _verify_created_date(self, section, testStartTime, apiTime):
    # Some dates (PDF section) seem to include millis too, double check for possible bug?
    sectionDate = datetime.strptime(section['created'], '%Y-%m-%dT%H:%M:%S.%fZ')
    deltaTime = sectionDate - testStartTime
    assert deltaTime.total_seconds() > 0, "Created field in metadata section should be greater than test start time!"
    # Next validation is not working properly because there seems to be a difference of
    # around 7 hours between my box and system under test environment (?) (one-leo.plosjournals.org)
    #assert apiTime > deltaTime.total_seconds(), "API invocation time should be greater than diff between Created field in metadata section & test start time!"


  def metadata(self, section, doi, testStartTime, apiTime):
    print 'Validating PDF metadata section in Response...',
    assert section is not None
    assert section['file'] == doi + '.PDF', "File field in metadata section did not match!"
    assert section['metadata']['doi'] == 'info:doi/' + doi, "DOI field in metadata section did not match!"
    assert section['metadata']['contentType'] == 'application/pdf', "ContentType field in metadata section did not match!"
    assert section['metadata']['extension'] == 'PDF', "Extension field in metadata section did not match!"
    assert section['metadata']['created'] == section['metadata']['lastModified'], "Created & LastModified fields in metadata section did not match!"
    assert section['metadata']['size'] == self.get_size(), "Size field in metadata section did not match!"
    self._verify_created_date(section['metadata'], testStartTime, apiTime)
    print 'OK'