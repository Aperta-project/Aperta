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

# Supporting Information includes Figures, Data, and other Files that help in
# understanding the manuscript, but are not central to the scientific argument.
# They are often linked to, but not typically embedded in the document.
class SupportingInformationFile < Attachment
  self.public_resource = true

  default_scope { order(:id) }

  scope :publishable, -> { where(publishable: true) }

  validates :category, presence: true, if: :task_completed?

  validates :status, acceptance: { accept: STATUS_DONE }, if: :task_completed?

  before_create :set_publishable

  delegate_view_permission_to :paper

  def alt
    if file.present?
      regex = /#{::File.extname(filename)}$/
      filename.split('.').first.gsub(regex, '').humanize
    else
      "no attachment"
    end
  end

  private

  # Default to true if unset
  def set_publishable
    self.publishable = true if publishable.nil?
  end

  def task_completed?
    task && task.completed?
  end

  protected

  def build_title
    title
  end
end
