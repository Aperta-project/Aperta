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

class Phase < ActiveRecord::Base
  include ViewableModel
  has_many :tasks, inverse_of: :phase, dependent: :destroy
  belongs_to :paper, inverse_of: :phases
  has_one :journal, through: :paper

  acts_as_list scope: :paper

  delegate_view_permission_to :paper

  DEFAULT_PHASE_NAMES = [
    "Submission Data",
    "Invite Editor",
    "Invite Reviewers",
    "Get Reviews",
    "Make Decision"
  ]

  def self.default_phases
    DEFAULT_PHASE_NAMES.map.with_index { |name, pos| Phase.new name: name, position: pos + 1 }
  end
end
