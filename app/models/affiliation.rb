class Affiliation < ActiveRecord::Base
  belongs_to :user, inverse_of: :affiliations

  validates :user, :name, presence: true
end
