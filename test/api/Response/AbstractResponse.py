#!/usr/bin/env python2

"""
"""

__author__ = 'jkrzemien@plos.org'

from abc import ABCMeta, abstractmethod


class AbstractResponse(object):

  __metaclass__ = ABCMeta

  @abstractmethod
  def get_buckets(self):
    pass

  @abstractmethod
  def get_bucketID(self):
    pass

  @abstractmethod
  def get_bucketName(self):
    pass

  @abstractmethod
  def get_bucketTimestamp(self):
    pass

  @abstractmethod
  def get_bucketCreationDate(self):
    pass

  @abstractmethod
  def get_bucketActiveObjects(self):
    pass

  @abstractmethod
  def get_bucketTotalObjects(self):
    pass

  @abstractmethod
  def get_objectKey(self):
    pass

#  @abstractmethod
#  def get_objectChecksum(self):
#    pass
#
#  @abstractmethod
#  def get_objectTimestamp(self):
#    pass
#
#  @abstractmethod
#  def get_objectDownloadName(self):
#    pass
#
#  @abstractmethod
#  def get_objectContentType(self):
#    pass
#
#  @abstractmethod
#  def get_objectSize(self):
#    pass
#
#  @abstractmethod
#  def get_objectTag(self):
#    pass
#
#  @abstractmethod
#  def get_objectVersionNumber(self):
#    pass
#
#  @abstractmethod
#  def get_objectStatus(self):
#    pass
#
#  @abstractmethod
#  def get_objectCreationDate(self):
#    pass
#
#  @abstractmethod
#  def get_objectVersionChecksum(self):
#    pass
#
#  @abstractmethod
#  def get_objectReproxyURL(self):
#    pass
#
#  @abstractmethod
#  def get_collectionKey(self):
#    pass
#
#  @abstractmethod
#  def get_collectionTimestamp(self):
#    pass
#
#  @abstractmethod
#  def get_collectionVersionNumber(self):
#    pass
#
#  @abstractmethod
#  def get_collectionTag(self):
#    pass
#
#  @abstractmethod
#  def get_collectionCreationDate(self):
#    pass
#
#  @abstractmethod
#  def get_collectionVersionChecksum(self):
#    pass
#
#  @abstractmethod
#  def get_collectionStatus(self):
#    pass
#
#  @abstractmethod
#  def get_collectionObjects(self):
#    pass
#
#  @abstractmethod
#  def get_infoStatusReadsSinceStart(self):
#    pass
#
#  @abstractmethod
#  def get_infoStatusWritesSinceStart(self):
#    pass
#
#  @abstractmethod
#  def get_infoStatusBucketCount(self):
#    pass
#
#  @abstractmethod
#  def get_infoStatusServiceStarted(self):
#    pass
#
#  @abstractmethod
#  def get_infoConfigVersion(self):
#    pass
#
#  @abstractmethod
#  def get_infoConfigObjectStoreBackend(self):
#    pass
#
#  @abstractmethod
#  def get_infoConfigSQLServiceBackend(self):
#    pass
#
#  @abstractmethod
#  def get_infoConfighasXReproxy(self):
#    pass
#
#  @abstractmethod
#  def get_infoHasXReproxy(self):
#    pass
#####
