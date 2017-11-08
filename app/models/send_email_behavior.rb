class SendEmailBehavior < EventBehavior
  has_attributes string: %w[letter_template]
  validates :letter_template, presence: true
  self.action_class = SendEmailAction
end
