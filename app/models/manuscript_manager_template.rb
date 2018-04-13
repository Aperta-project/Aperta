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

class ManuscriptManagerTemplate < ActiveRecord::Base
  include ViewableModel
  belongs_to :journal, inverse_of: :manuscript_manager_templates
  has_many :phase_templates, -> { order("position asc") },
                                inverse_of: :manuscript_manager_template,
                                dependent: :destroy

  has_many :task_templates, through: :phase_templates

  validates :paper_type, presence: true
  validates :paper_type, uniqueness: { scope: :journal_id,
                                       case_sensitive: false }

  def papers
    journal.papers.where(paper_type: paper_type)
  end

  def task_template_by_kind(kind)
    task_templates.joins(:journal_task_type).find_by(journal_task_types: { kind: kind })
  end

  def user_can_view?(check_user)
    check_user.can?(:administer, journal)
  end
end
