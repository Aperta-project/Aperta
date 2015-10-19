class Snapshot < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :paper

  validates :paper, presence: true
  validates :source, presence: true
  validates :major_version, presence: true
  validates :minor_version, presence: true
end
