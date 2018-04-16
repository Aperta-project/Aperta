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
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"
    after(:build) do |c|
      c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
    end

    trait :root do
      parent_id nil
    end

    trait :unanswerable do
      value_type nil
    end

    trait :template do
      value_type nil
      content_type "email-template"
      letter_template "ident"
    end

    trait :with_answer do
      transient do
        answer_value nil
      end

      after(:create) do |card_content, evaluator|
        task = Task.find_by(card_version: card_content.card_version)
        FactoryGirl.create(:answer, card_content: card_content, paper: task.try(:paper), owner: task, value: evaluator.answer_value)
      end
    end

    trait :with_child do
      after(:create) do |root_content|
        FactoryGirl.create(:card_content).move_to_child_of(root_content)
        root_content.reload
      end
    end

    trait :with_children do
      after(:create) do |root_content|
        child_count = 0
        5.times do
          child = FactoryGirl.create(:card_content).move_to_child_of(root_content)
          child_count.times do
            FactoryGirl.create(:card_content).move_to_child_of(child)
          end
          child_count += 1
        end
        root_content.reload
      end
    end

    trait :with_string_match_validation do
      after(:build) do |c|
        c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
        c.card_content_validations << build(:card_content_validation, :with_string_match_validation)
      end
    end
  end
end
