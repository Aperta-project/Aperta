# DueDatetime allows us to easily add "due dates" (really datetimes)
# to any arbitrary class.  See ReviewerReport for an example,
# especially noting the following code:
#
#     has_one :due_datetime, as: :due
#
# # # This gives you convenient and conceptually simpler access to the data:
#
#     delegate :due_at, :originally_due_at, to: :due_datetime, allow_nil: true
#
# # # This gives you an interface to use from AASM:
#
#     def set_due_datetime(length_of_time: 10.days)
#       DueDatetime.set_for(self, length_of_time: length_of_time)
#     end
#
# The reason for using datetimes is that dates are necessarily bound
# to specific time zones.  A date is really a 24-hour span of time
# and that span of time changes every time you change time zone,
# so a given date refers to a different span of hours in every zone.
# Therefore it is invalid data in a globally accessible application.
# Thus, our only bug-free option is to use datetimes, though we may
# (judiciously!) summarize that as a date in cases where the space
# does not allow for inclusion of time, as long as the user has
# easy access to the full datetime.
#
# The originally_due_at property should be set once and never changed.
#
# The due date (& time), stored in due_at can be extended, in which case
# originally_due_at would differ from due_at, and then it would be
# relevant to display the original date in the UI.
#
class DueDatetime < ActiveRecord::Base
  belongs_to :due, polymorphic: true

  def self.set_for(object, length_of_time:)
    (object.due_datetime ||= DueDatetime.new)
      .set(length_of_time: length_of_time)
  end

  def set(length_of_time:)
    self.due_at = length_of_time.from_now.utc.beginning_of_hour + 1.hour
    self.originally_due_at = due_at unless originally_due_at
    save
  end
end
