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

require 'securerandom'

FactoryGirl.define do
  factory :card do
    sequence(:name) { |n| "Test Card #{n} #{SecureRandom.uuid}" }
    journal
    latest_version 1
    card_task_type

    trait :versioned do
      after(:build) do |card|
        card.state = "published"
        card.card_versions << FactoryGirl.build(
          :card_version,
          card: card,
          version: card.latest_version,
          published_at: Time.current,
          history_entry: "test version"
        ) if card.card_versions.size.zero?
      end
    end

    # draft is intended to be used with versioned.
    # in our tests it's more common to use published cards,
    # hence draft is a separate trait that acts after :create
    trait :draft do
      after(:create) do |card|
        card.update(state: "draft")
        card.latest_card_version.update(published_at: nil, history_entry: nil)
      end
    end

    trait :locked do
      after(:build) do |card|
        card.state = "locked"
      end
    end

    trait :published_with_changes do
      after(:build) do |card|
        card.state = "published_with_changes"
        card.card_versions << build(:card_version, version: card.latest_version, published_at: Time.current, history_entry: "entry") if card.card_versions.count.zero?
        # TODO: we should probably remove :latest_version from Card all
        # together. currently the XMLCardLoader handles incrementing it, which
        # is just an opportunity to let it get out of sync with the actual
        # latest CardVersion.version.
        card.increment(:latest_version)
        card.card_versions << build(:card_version, version: card.latest_version, published_at: nil)
      end
    end

    trait :archived do
      after(:build) do |card|
        card.state = "archived"
        card.archived_at = Time.current
      end
    end

  end
end
