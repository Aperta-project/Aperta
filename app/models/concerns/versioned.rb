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

# Module to use for things that have a major and minor version.
module Versioned
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    scope :version_desc, -> { order('major_version DESC, minor_version DESC') }
    scope :version_asc, -> { order('major_version ASC, minor_version ASC') }
    scope :completed, -> { where.not(major_version: nil) }
    scope :drafts, -> { where(major_version: nil) }
    validates :paper_id, uniqueness: {
      scope: [:major_version, :minor_version],
      message: "Paper already has a %{model} with that version" }
  end

  def draft?
    major_version.nil?
  end

  def completed?
    !draft?
  end
end
