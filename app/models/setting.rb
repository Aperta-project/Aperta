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

# Settings are a fairly generic model intended to let us store configuration for
# pretty much anything in the database. A setting can have a default value and
# an array of possible values it could take when it's linked to a
# SettingTemplate (as all settings in our system will be for the time being)
class Setting < ActiveRecord::Base
  include ViewableModel
  include SettingValues

  belongs_to :owner, polymorphic: true

  belongs_to :setting_template

  delegate :possible_setting_values, to: :setting_template, allow_nil: true

  validates :value,
            inclusion: {
              in: ->(s) { s.possible_setting_values.map(&:value) }
            },
            if: -> { possible_setting_values.present? }
end
