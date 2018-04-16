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
  factory :correspondence do
    body       Faker::Lorem.paragraph
    sender     Faker::Internet.safe_email
    recipients Faker::Internet.safe_email
    sent_at    DateTime.now.in_time_zone
    sequence(:subject) { |n| "Correspondence Subject #{n}" }

    association :paper, factory: :paper

    trait :with_journal do
      association :journal, factory: :journal
    end

    trait :with_task do
      association :task, factory: :ad_hoc_task
    end

    trait :as_external do
      bcc         Faker::Internet.safe_email
      cc          Faker::Internet.safe_email
      description Faker::Lorem.sentence
      external    true
    end
  end
end
