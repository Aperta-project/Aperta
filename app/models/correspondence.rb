# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

  def user_can_view?(check_user)
    check_user.can? :manage_workflow, paper
  end

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
