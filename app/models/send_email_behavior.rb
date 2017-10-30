class SendEmailBehavior < EventBehavior
  validates :letter_template, presence: true
  self.action_class = SendEmailAction
end
