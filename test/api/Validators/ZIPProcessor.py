#!/usr/bin/env python2

__author__ = 'jkrzemien@plos.org'

"""
This class loads up a ZIP file and attempts to gather as much information as possible from it
in order to be used later on for validations against Tests's responses.
"""

from os.path import basename, isfile
from zipfile import ZipFile
from XMLValidator import XMLValidator
from PDFValidator import PDFValidator
from TIFValidator import TIFValidator
from PNGValidator import PNGValidator


class ZIPProcessor(object):

  DOI_HEADER = 'info:doi/'
  DOI_PREFFIX = '10.1371/journal.'

  def __init__(self, archive):
    self._verify_file_exists(archive)
    self._zip = ZipFile(archive, "r")
    self._parse_xml()
    self._parse_pdf()
    self._parse_images()

  def _verify_file_exists(self, filePath):
    if not isfile(filePath):
      raise IOError('File "%s" does not exist!. Failing test...' % filePath)
    self._archiveName = basename(filePath)[:-4]

  def _parse_xml(self):
    data = self._zip.read(self._archiveName + '.xml')
    self._xml = XMLValidator(data)

  def _parse_pdf(self):
    data = self._zip.read(self._archiveName + '.pdf')
    self._pdf = PDFValidator(data)

  def _is_tif_image(self, filename):
    return True if '.tif' in filename.lower() else False

  def _is_png_image(self, filename):
    return True if '.png' in filename.lower() else False

  def _parse_images(self):
    self._graphics = {}
    self._figures = {}
    for name in self._zip.namelist():
      if self._is_tif_image(name):
        self._graphics[name.lower()] = TIFValidator(name.lower(), self._zip.read(name), self._xml)
      elif self._is_png_image(name):
        self._figures[name.lower()] = PNGValidator(name.lower(), self._zip.read(name), self._xml)

  def get_xml_validator(self):
    return self._xml

  def get_pdf_validator(self):
    return self._pdf

  def get_graphics_validator(self, imageName):
    return self._graphics[imageName]

  def get_figures_validator(self, imageName):
    try:
      x = self._figures[imageName]
    except KeyError:
      x = self._graphics[imageName]
    return x

  def get_full_doi(self):
    return self.DOI_HEADER + self.DOI_PREFFIX + self._archiveName

  def get_doi(self):
    return self.DOI_PREFFIX + self._archiveName

  def get_archive_name(self):
    return self._archiveName

