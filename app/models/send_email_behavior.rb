class SendEmailBehavior < EventBehavior
  validates :letter_template, presence: true

  action_class SendEmailAction
end
