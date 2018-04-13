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

# TaskTemplate gets consumed by the PaperFactory to create a task
# when a paper is first created
class TaskTemplate < ActiveRecord::Base
  include ViewableModel
  include Configurable

  belongs_to :phase_template, inverse_of: :task_templates
  belongs_to :journal_task_type
  belongs_to :card

  has_one :manuscript_manager_template, through: :phase_template
  has_one :journal, through: :manuscript_manager_template

  validates :title, presence: true
  validate :only_one_mold

  delegate :required_for_submission, to: :latest, allow_nil: true

  acts_as_list scope: :phase_template

  def user_can_view?(check_user)
    check_user.can?(:administer, journal)
  end

  # setting_template_key is defined in Configurable
  def setting_template_key
    if journal_task_type
      "TaskTemplate:#{journal_task_type.kind}"
    else
      "TaskTemplate:#{card.name}"
    end
  end

  def latest
    card.latest_published_card_version if card
  end

  private

  # This validation enforces the decision point between the "old world" of
  # TaskTemplates being associated to a JournalTaskType and the new "card
  # config world" of being associated to a Card.  You cannot have feet in
  # both worlds.
  def only_one_mold
    unless [journal_task_type_id, card_id].one?
      errors.add(:base,
                 'must be associated with only one Journal Task Type or Card')
    end
  end
end
