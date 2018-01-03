#!/usr/bin/env python
# -*- coding: utf-8 -*-

import logging

import pytest

from Base.Decorators import MultiBrowserFixture
from frontend.common_test import CommonTest

__author__ = 'achoe@plos.org'


@MultiBrowserFixture
class ApertaToggleSettings(CommonTest):
  """
  This class is for enabling or disabling features by mean of the settings table in the database.
  """

  @pytest.mark.setup
  def test_enable_coauthor_confirmation(self):
    """
    test_enable_coauthor_confirmation: enables the coauthor confirmation feature for a journal.
    :return: void function
    """
    owner_id = 2
    owner_type = 'Journal'
    feature_name = 'coauthor_confirmation_enabled'
    enable = True

    loggin.info('setting feature {0} to {1}'.format(feature_name, enable))
    self.toggle_feature_setting_in_db(owner_id, owner_type, feature_name, enable)

if __name__ == '__main__':
  CommonTest.run_tests_randomly()
