# Single class to handle internal and external correspondence
class Correspondence < ActiveRecord::Base
  self.table_name = "email_logs"

  belongs_to :paper
  belongs_to :task
  belongs_to :journal
  belongs_to :versioned_text

  has_many :attachments, as: :owner,
                         class_name: 'CorrespondenceAttachment',
                         dependent: :destroy

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

  def activities
    Activity.where(feed_name: ['workflow'], subject_type: ['Correspondence'])
      .map do |f|
        {
          key: f.activity_key,
          full_name: f.user.full_name,
          created_at: f.created_at
        }
      end
  end
end
