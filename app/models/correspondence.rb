class Correspondence < ActiveRecord::Base
  self.table_name = "email_logs"

  belongs_to :paper
  belongs_to :task
  belongs_to :journal

  has_many :attachments, as: :owner,
                         class_name: 'ExternalCorrespondenceAttachment',
                         dependent: :destroy
end
