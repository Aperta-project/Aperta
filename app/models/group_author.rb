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

# Authors that are not individual people; they are in the
# same list as authors, but have different data.
class GroupAuthor < ActiveRecord::Base
  include ViewableModel
  include Answerable
  include EventStream::Notifiable
  include Tokenable
  include UniqueEmail
  include CoAuthorConfirmable

  CONTRIBUTIONS_QUESTION_IDENT = "group-author--contributions".freeze
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "group-author--government-employee".freeze

  has_one :author_list_item, as: :author, dependent: :destroy, autosave: true

  include PgSearch
  pg_search_scope \
    :fuzzy_search,
    against: [:contact_first_name, :contact_last_name, :contact_email, :name],
    ignoring: :accents,
    using: { tsearch: { prefix: true }, trigram: { threshold: 0.3 } }

  # This is to associate specifically with the user that last manually modified
  # a coauthors status.  We have to track this separately from the standard
  # non-coauthor updates
  belongs_to :co_author_state_modified_by, class_name: "User"

  has_one :paper,
          through: :author_list_item,
          inverse_of: :authors
  delegate :position, to: :author_list_item

  before_create :set_default_co_author_state

  validates :contact_first_name,
            :contact_last_name,
            :contact_email,
            :name,
            presence: true,
            if: :task_completed?

  validates :contact_email,
            format: { with: Devise.email_regexp, message: "needs to be a valid email address" },
            if: :task_completed?

  validates :contributions,
            presence: { message: "one must be selected" },
            if: :task_completed?

  alias_attribute :email, :contact_email
  alias_attribute :full_name, :name

  delegate_view_permission_to :paper

  def paper_id
    ensured_author_list_item.paper_id
  end

  def paper_id=(paper_id)
    ensured_author_list_item.paper_id = paper_id
  end

  def task_completed?
    task && task.completed
  end

  def task
    Task.find_by(paper_id: paper_id, type: TahiStandardTasks::AuthorsTask.name)
  end

  def position=(position)
    ensured_author_list_item.position = position
  end

  def ensured_author_list_item
    author_list_item || build_author_list_item
  end

  def self.contributions_content
    CardContent.find_by(ident: CONTRIBUTIONS_QUESTION_IDENT)
  end

  def contributions
    contributions_content = self.class.contributions_content
    return [] unless contributions_content
    content_ids = self.class.contributions_content.children.map(&:id)
    answers.where(card_content_id: content_ids)
  end

  private

  def set_default_co_author_state
    self.co_author_state ||= 'unconfirmed'
  end
end
