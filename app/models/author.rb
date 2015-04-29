class Author < ActiveRecord::Base
  include EventStream::Notifier

  actable
  acts_as_list

  belongs_to :paper

  def self.generic
    where(actable_id: nil, actable_type: nil)
  end

  def event_stream_serializer(user)
    AuthorsSerializer.new(paper.authors, user: user, root: :authors)
  end
end
