# AuthorizationModelsSpecHelper contains model definitions that can be used
# test the authorization subsystem in as much isolation as possible.
# This is to help reduce the amount of maintenance that is required is
# the real application models change over time.
#
module AuthorizationModelsSpecHelper
  # Creates tables in the test database specificially for the model definitions
  # intended to test the authorization sub-system
  def self.create_db_tables
    @db_tables_created ||= begin
      ActiveRecord::Schema.define do
        create_table :fake_papers, force: true do |t|
        end

        create_table :fake_tasks, force: true do |t|
          t.integer :fake_paper_id
        end

        create_table :fake_task_things, force: true do |t|
          t.integer :fake_task_id
        end
      end
      true
    end
  end
end

module Authorizations
  class FakePaper < ActiveRecord::Base
    has_many :fake_tasks
    has_many :fake_task_things, through: :fake_tasks
  end

  class FakeTask < ActiveRecord::Base
    belongs_to :fake_paper
    has_one :fake_task_thing
  end

  class FakeTaskThing < ActiveRecord::Base
    belongs_to :fake_task
  end
end
