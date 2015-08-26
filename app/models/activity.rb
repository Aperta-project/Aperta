class Activity < ActiveRecord::Base
  belongs_to :subject, polymorphic: true
  belongs_to :user

  def self.feed_for(feed_names, subject)
    where(feed_name: feed_names, subject_id: subject.id).order('created_at DESC')
  end
end
