module StandardTasks
  class FundedAuthor < ActiveRecord::Base
    belongs_to :funder, inverse_of: :funded_authors
    belongs_to :author
  end
end
