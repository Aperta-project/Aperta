# Settings are a fairly generic model intended to let us store configuration for
# pretty much anything in the database. If you have specific behavior for a
# setting you should create a subclass of Settings (see
# Setting::IthenticateAutomation for an example)
class Setting < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  after_initialize :set_default_value

  def set_default_value
    # no-op
  end
end
