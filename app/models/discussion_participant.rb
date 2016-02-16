class DiscussionParticipant < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :discussion_topic, inverse_of: :discussion_participants
  belongs_to :user, inverse_of: :discussion_participants

  delegate :journal, to: :discussion_topic

  after_create :add_discussion_participant_assignment
  after_destroy :remove_discussion_participant_assignment

  private

  def add_discussion_participant_assignment
    discussion_topic.assignments.create(
      user: user,
      role: journal.discussion_participant_role
    )
  end

  def remove_discussion_participant_assignment
    discussion_topic.assignments.find_by(
      user: user,
      role: journal.discussion_participant_role
    ).destroy
  end
end
