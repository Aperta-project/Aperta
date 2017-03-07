# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  acts_as_paranoid

  belongs_to :journal, inverse_of: :cards
  has_many :card_content, inverse_of: :card, dependent: :destroy
  has_one :content_root, -> { where(parent_id: nil) }, class_name: 'CardContent'

  validates :name, presence: { message: "Please give your card a name." }
  validates :name, uniqueness: {
    scope: :journal,
    message: "That card name is taken. Please give your card a new name."
  }

  def content_root
    card_content.roots.first
  end

  def self.lookup_card(owner_type)
    return if owner_type.to_s =~ /AdHocTask$/
    name = case owner_type.to_s
           when /Task$/
             owner_type.to_s
           when "Author"
             'Author'
           when "GroupAuthor"
             'GroupAuthor'
           when "Funder"
             'TahiStandardTasks::Funder'
           when "ReviewerRecommendation"
             'TahiStandardTasks::ReviewerRecommendation'
           when "ReviewerReport"
             'ReviewerReport'
           else
             raise "Don't know how to lookup owner_type: #{owner_type}"
           end
    Card.find_by!(name: name)
  end
end
