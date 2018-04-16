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

require 'digest'

FactoryGirl.define do
  factory :attachment, class: 'Attachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10000).to_s(16) }
    association :owner, factory: :paper

    after :build do |attachment|
      attachment['file'] ||= 'factory-test-file.jpg'
    end

    before :create do |attachment|
      attachment.owner ||= FactoryGirl.create(:ad_hoc_task)
    end

    trait :processing do
      status "processing"
    end

    trait :errored do
      status "error"
      error_message "Failed for some reason"
    end

    trait :completed do
      status "done"
    end

    trait :unknown_state do
      status "unknown"
    end

    trait :with_resource_token do
      after :build do |attachment|
        attachment.build_resource_token(attachment.file)
      end
    end

    trait :with_task do
      association :owner, factory: :ad_hoc_task
    end

    trait :with_revise_task do
      association :owner, factory: :revise_task
    end
  end
end
