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

require 'rails_helper'

describe Setting do
  describe 'validations and defaults via SettingTemplate' do
    context 'possible values' do
      context 'the setting has an empty array of possible values' do
        it "does not validate the value against anything" do
          template = FactoryGirl.create(:setting_template, value: "foo")
          setting = FactoryGirl.create(:setting, setting_template: template, value: "foo")
          expect(setting).to be_valid
        end
      end
      context "the setting's possible values are present" do
        it "validates the inclusion of the value in the possible values" do
          template = FactoryGirl.create(:setting_template, :with_possible_values, value: "foo", possible_values: ["foo", "bar"])
          setting = FactoryGirl.create(:setting, value: "foo", setting_template: template)
          expect(setting).to be_valid
          setting.value = "baz"
          expect(setting).to have(1).errors_on(:value)
        end
      end
    end
  end
end
