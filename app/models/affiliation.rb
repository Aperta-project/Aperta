class Affiliation < ActiveRecord::Base
  belongs_to :user, inverse_of: :affiliations
  belongs_to :affiliable, polymorphic: true

  validates :affiliable, :name, presence: true
  validates :email, format: Devise.email_regexp, allow_blank: true
  validates_with AffiliationDateValidator

  scope :by_date, -> { order(end_date: :desc, start_date: :asc) }
end
