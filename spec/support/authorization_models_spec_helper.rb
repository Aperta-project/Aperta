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

# AuthorizationModelsSpecHelper contains model definitions that can be used
# test the authorization subsystem in as much isolation as possible.
# This is to help reduce the amount of maintenance that is required is
# the real application models change over time.
#
module AuthorizationModelsSpecHelper
  # Creates tables in the test database specificially for the model definitions
  # intended to test the authorization sub-system
  def self.create_db_tables
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define do
        create_table :fake_journals, force: true do |t|
          t.string :name
        end

        create_table :fake_papers, force: true do |t|
          t.integer :fake_journal_id
          t.string :name
          t.string :publishing_state
        end

        create_table :fake_tasks, force: true do |t|
          t.string :name
          t.integer :fake_paper_id
          t.string :type, default: 'Authorizations::FakeTask'
          t.integer :fake_card_version_id
        end

        create_table :fake_task_things, force: true do |t|
          t.integer :fake_task_id
        end

        create_table :fake_card_versions, force: true do |t|
          t.integer :fake_task_id
        end
      end
    end
  end
end

module Authorizations
  class FakeJournal < ActiveRecord::Base
    has_many :fake_papers
  end

  class FakePaper < ActiveRecord::Base
    belongs_to :fake_journal
    has_many :fake_tasks
    has_many :fake_task_things, through: :fake_tasks, inverse_of: :fake_paper
    has_many :fake_card_versions, through: :fake_tasks
  end

  class FakeTask < ActiveRecord::Base
    belongs_to :fake_paper, inverse_of: :fake_tasks
    has_one :fake_journal, through: :fake_paper
    has_one :fake_task_thing
    def self.delegate_state_to
      :fake_paper
    end
    belongs_to :fake_card_version
    delegate :publishing_state, to: :fake_paper
  end

  class SpecializedFakeTask < FakeTask
  end

  class EvenMoreSpecializedFakeTask < SpecializedFakeTask
  end

  class FakeTaskThing < ActiveRecord::Base
    belongs_to :fake_task
    has_one :fake_paper, through: :fake_task
  end

  class FakeCardVersion < ActiveRecord::Base
  end
end
