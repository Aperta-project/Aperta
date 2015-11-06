#
# Snapshot(s) are intended to represent a snapshot of something in the system
# at a given point in time. The point in time is determined by the major and
# minor verison of the paper at the time of the snapshot.
#
# For example, after a paper is submitted several tasks are snapshotted. This
# lays the foundation for allowing users to view the history of those tasks as
# well to provide them a way to view differences between different versions
# of a task.
#
class Snapshot < ActiveRecord::Base
  belongs_to :source, polymorphic: true
  belongs_to :paper

  validates :paper, presence: true
  validates :source, presence: true
  validates :major_version, presence: true
  validates :minor_version, presence: true
end
