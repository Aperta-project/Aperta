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

# ReviewerNumber joins a reviewer and a paper.
#
# There is a unique index on user/paper, meaning there can only
# be one ReviewerNumber entry for a given user and paper.
#
# The same applies for paper/number combinations
class ReviewerNumber < ActiveRecord::Base
  include ViewableModel
  belongs_to :paper
  belongs_to :user

  validates :paper, presence: true
  validates :user, presence: true
  MAX_RETRIES = 5

  def self.number_for(reviewer, paper)
    where(user: reviewer, paper: paper).pluck(:number).first
  end

  def self.max_number_for_paper(paper)
    where(paper: paper).maximum(:number) || 0
  end

  def self.assign_new(reviewer, paper)
    # blow up if there's already a number for this reviewer/paper
    #
    # then try to create a new record
    # catch the ActiveRecord::RecordNotUnique and increment the new_number
    begin
      tries ||= 1
      new_number = max_number_for_paper(paper) + tries
      record = create!(paper: paper, user: reviewer, number: new_number)
      new_number
    rescue ActiveRecord::RecordNotUnique  => e
      retry if (tries +=1) < MAX_RETRIES
    end
  end
end
