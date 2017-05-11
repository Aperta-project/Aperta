# specific settings for Ithenticate
class Setting::Ithenticate < Setting
  POSSIBLE_VALUES = [
    "off",
    "at_first_full_submission",
    "after_first_major_revise_decision",
    "after_any_first_revise_decision"
  ].freeze

  def on?
    value != "off"
  end

  def set_default_value
    self.value ||= "off"
  end

  validates :value, presence: true, inclusion: { in: POSSIBLE_VALUES }
end
