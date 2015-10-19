class Snapshot < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :paper
end
