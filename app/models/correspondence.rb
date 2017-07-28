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

  after_create :save_manuscript_version_and_status

  def external?
    external
  end

  def save_manuscript_version_and_status
    return if external?
    paper = self.paper
    # we have cases where correspondence(s) are not
    # created with a paper. Cards like Assigned AE emails,
    # AE Invitation Emails, Author Chase Emails, creates a
    # correspondence with the paper_id nil
    return unless paper
    update_attributes manuscript_version: paper.versioned_texts.last.version,
                      manuscript_status: paper.publishing_state,
                      versioned_text_id: paper.versioned_texts.last.id
  end
end
