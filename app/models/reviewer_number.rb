# ReviewerNumber joins a reviewer and a paper.
#
# There is a unique index on user/paper, meaning there can only
# be one ReviewerNumber entry for a given user and paper.
#
# The same applies for paper/number combinations
class ReviewerNumber < ActiveRecord::Base
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

  def self.get_new(reviewer, paper)
    # blow up if there's already a number for this reviewer/paper
    #
    # then try to create a new record
    # catch the ActiveRecord::RecordNotUnique and increment the new_number
    new_number = max_number_for_paper(paper) + 1
    record = create(paper: paper, user: reviewer, number: new_number)
  end
end
