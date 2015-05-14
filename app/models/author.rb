class Author < ActiveRecord::Base
  include EventStream::Notifiable

  actable
  acts_as_list

  belongs_to :paper

  def self.generic
    where(actable_id: nil, actable_type: nil)
  end

  def event_stream_serializer(user: nil)
    AuthorsSerializer.new(paper.authors, root: :authors)
  end
end
