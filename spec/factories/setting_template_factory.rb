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

FactoryGirl.define do
  factory :setting_template do
    key "test_key"
    value_type "string"
    setting_klass "Setting"
    setting_name "on"
    global true

    factory :review_duration_period_setting_template do
      key "TaskTemplate:TahiStandardTasks::PaperReviewerTask"
      value_type "integer"
      setting_name "review_duration_period"
      value 10
    end

    trait :with_possible_values do
      transient do
        possible_values []
      end

      after(:create) do |template, evaluator|
        evaluator.possible_values.each do |v|
          template.possible_setting_values << PossibleSettingValue.create(
            value_type: template.value_type,
            value: v
          )
        end
      end
    end
  end
end
