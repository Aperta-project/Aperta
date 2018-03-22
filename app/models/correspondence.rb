# Single class to handle internal and external correspondence
class Correspondence < ActiveRecord::Base
  include ViewableModel
  include EventStream::Notifiable
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

  validates :reason, presence: true, if: :deleted?
  validate :external_if_deleted

  def activities
    Activity.feed_for('workflow', self).map do |f|
      {
        key: f.activity_key,
        full_name: f.user.full_name,
        created_at: f.created_at
      }
    end
  end

  def deleted?
    status == 'deleted'
  end

  def reason
    additional_context['delete_reason'] if additional_context.try(:has_key?, 'delete_reason')
  end

  def external_if_deleted
    return unless deleted?
    errors.add(:deleted, "Deleted records must be external") unless external
  end
end
