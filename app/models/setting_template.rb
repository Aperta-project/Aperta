# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# SettingTemplate is the mapping between
# an instance of a thing and the type of settings that
# it should have.
#
# For instance, the SimilarityCheck Card (in this case meaning a Card whose name
# is 'SimilarityCheck') has an IthenticateAutomation setting that needs to be
# edited from a TaskTemplate associated to the card. The IthenticateAutomation
# settings are an enumeration of values that need special validation.
# SettingTemplate will map from a key (in this case
# 'TaskTemplate:SimilarityCheck') to the names and classes of the settings for
# that key ('Setting' and 'ithenticate')
#
# SettingTemplate also handles defaults for a given setting, and holds the
# enumeration of possible values that could be assigned to a Setting via
# possible_setting_values. Note that some settings will be 'global', and some
# will be associated to a specific journal. Initially we're only using global
# settings.
class SettingTemplate < ActiveRecord::Base
  include ViewableModel
  # For a SettingTemplate the 'value' is really the default value the Setting
  # should take, but the extra specificity didn't seem worth having to discard
  # the mixin.
  include SettingValues

  belongs_to :journal

  validates :journal, presence: true, if: -> { !global }

  has_many :possible_setting_values, dependent: :destroy
  has_many :settings, dependent: :destroy
end
