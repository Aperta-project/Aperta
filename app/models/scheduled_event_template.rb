# Every chasing object which has a due date also has a template from which these
# events are created. This affords TAHI the ability to allow some roles modify
# these templates.
#
# This is meant to serve as a base class for a scheduled event template. Ideally
# no class uses a ScheduledEventTemplate. These templates would be specific to
# their usecases. An invitation would have an InvitationScheduledEventTemplate,
# a reviewer would have a ReviewerScheduledEventTemplate, and so on.
class ScheduledEventTemplate < ActiveRecord::Base
  belongs_to :due_datetime
end
