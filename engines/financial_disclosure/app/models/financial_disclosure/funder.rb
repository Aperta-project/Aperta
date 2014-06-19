module FinancialDisclosure
  class Funder < ActiveRecord::Base
    belongs_to :task
    has_many :funded_authors, inverse_of: :funder
    has_many :authors, through: :funded_authors
  end
end

