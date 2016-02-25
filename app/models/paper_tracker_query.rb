# Editors use some searches on a daily or even more-than-daily basis,
# This is a place for them to store and share those queries.
class PaperTrackerQuery < ActiveRecord::Base
  def self.default_scope
    where deleted: false
  end
end
