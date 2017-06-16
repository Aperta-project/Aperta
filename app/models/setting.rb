# Settings are a fairly generic model intended to let us store configuration for
# pretty much anything in the database. If you have specific behavior for a
# setting you should create a subclass of Settings (see
# Setting::IthenticateAutomation for an example)
class Setting < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  after_initialize :set_default_value

  validates :value_type,
            presence: true,
            inclusion: { in: %w(string integer boolean) }

  def set_default_value
    # no-op
  end

  def value
    send value_method_name
  end

  def value=(new_value)
    send value_method_name, new_value
  end

  def value_method_name
    "#{value_type}_value".to_sym
  end
end
