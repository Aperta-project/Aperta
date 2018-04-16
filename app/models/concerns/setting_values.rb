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

# SettingValues holds common validations and accessors that are used in
# Setting, SettingTemplate, and PossibleSettingValue.
# Each model gets and sets a 'value' which may be one of several underlying
# types. Rather than storing the value in a string column and casting it we've
# chosen to store a value_type and to shove the value into the appropriately
# typed column.
module SettingValues
  extend ActiveSupport::Concern

  included do
    validates :value_type,
              presence: true,
              inclusion: { in: %w(string integer boolean) }

    def value
      value_method_name = "#{value_type}_value".to_sym
      send value_method_name
    end

    def value=(new_value)
      value_method_name = "#{value_type}_value=".to_sym
      send value_method_name, new_value
    end
  end
end
