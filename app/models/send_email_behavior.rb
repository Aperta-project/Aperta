class SendEmailBehavior < Behavior
  has_attributes string: %w[letter_template]
  validates :letter_template, presence: true

  def call(event)
    lt = paper.journal.letter_templates.find_by(letter_template)
    scenario = lt.scenario.constantize
    lt.render(scenario.new(task_obj))

    GenericMailer.delay.send_email(
      subject: lt.subject,
      body: lt.body,
      to: lt.to,
      task: task
    )
  end
end
