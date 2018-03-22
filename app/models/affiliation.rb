class Affiliation < ActiveRecord::Base
  include ViewableModel
  belongs_to :user, inverse_of: :affiliations

  validates :user, :name, :email, presence: true
  validates :email, format: Devise.email_regexp, allow_blank: true
  validates_with AffiliationDateValidator

  scope :by_date, -> { order(end_date: :desc, start_date: :asc) }
end
