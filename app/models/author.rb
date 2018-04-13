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

# Manuscript author model
class Author < ActiveRecord::Base
  include ViewableModel
  include Answerable
  include EventStream::Notifiable
  include Tokenable
  include UniqueEmail
  include CoAuthorConfirmable

  CONTRIBUTIONS_QUESTION_IDENT = "author--contributions".freeze
  CORRESPONDING_QUESTION_IDENT = "author--published_as_corresponding_author".freeze
  GOVERNMENT_EMPLOYEE_QUESTION_IDENT = "author--government-employee".freeze

  attr_accessor :validate_all

  has_one :author_list_item, as: :author, dependent: :destroy, autosave: true

  has_one :paper,
          through: :author_list_item

  has_one :task,
          -> { where(type: 'TahiStandardTasks::AuthorsTask') },
          class_name: 'TahiStandardTasks::AuthorsTask',
          through: :paper,
          source: :tasks

  include PgSearch
  pg_search_scope \
    :fuzzy_search,
    against: [:first_name, :last_name, :email],
    ignoring: :accents,
    using: { tsearch: { prefix: true }, trigram: { threshold: 0.3 } }

  # Not validated as not all authors have corresponding users.
  belongs_to :user

  # This is to associate specifically with the user that last manually modified
  # a coauthors status.  We have to track this separately from the standard
  # non-coauthor updates
  belongs_to :co_author_state_modified_by, class_name: "User"

  delegate :position, to: :author_list_item

  validates :first_name, :last_name, :author_initial,
    :affiliation, :email, presence: true, if: :fully_validate?

  validates :email,
    format: { with: Devise.email_regexp, message: "needs to be a valid email address" },
    if: :fully_validate?

  validates :contributions,
    presence: { message: "one must be selected" }, if: :fully_validate?

  before_create :set_default_co_author_state

  before_validation :strip_whitespace

  delegate_view_permission_to :paper

  STRIPPED_ATTRS = [
    :first_name,
    :last_name,
    :middle_initial,
    :email
  ].freeze

  def strip_whitespace
    STRIPPED_ATTRS.each do |to_strip|
      old_value = self[to_strip]
      self[to_strip] = old_value.strip if old_value.present?
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def paper_id
    ensured_author_list_item.paper_id
  end

  def paper_id=(paper_id)
    ensured_author_list_item.paper_id = paper_id
  end

  def position=(position)
    ensured_author_list_item.position = position
  end

  def ensured_author_list_item
    author_list_item || build_author_list_item
  end

  def creator?
    user == paper.creator
  end

  def self.for_paper(paper)
    where(paper_id: paper)
  end

  def fully_validate?
    validate_all || task.try(:completed)
  end

  def corresponding?
    answer = answer_for(CORRESPONDING_QUESTION_IDENT)
    answer ? answer.value : false
  end

  def self.contributions_content
    CardContent.find_by(
      ident: CONTRIBUTIONS_QUESTION_IDENT
    )
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
