class SendEmailBehavior < Behavior
  has_attributes string: %w[letter_template]
  validates :letter_template, presence: true
  self.action_class = SendEmailAction
end
