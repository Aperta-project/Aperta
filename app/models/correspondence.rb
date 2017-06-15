# Single class to handle internal and external correspondence
class Correspondence < ActiveRecord::Base
  self.table_name = "email_logs"

  belongs_to :paper
  belongs_to :task
  belongs_to :journal

  has_many :attachments, as: :owner

  with_options if: :external? do |correspondence|
    correspondence.validates :description,
                             :sender,
                             :recipients,
                             :body,
                             presence: true,
                             allow_blank: false
  end

  def external?
    external
  end
end
