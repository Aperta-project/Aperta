class SendEmailBehavior < Behavior
  has_attributes string: %w[letter_template]
  validates :letter_template, presence: true

  def call(event)
    lt = event.paper.journal.letter_templates.find_by!(ident: letter_template)
    scenario_class = lt.send(:scenario_class)
    raise unless scenario_class == PaperScenario
    lt.render(scenario_class.new(event.paper))
    GenericMailer.delay.send_email(
      subject: lt.subject,
      body: lt.body,
      to: lt.to,
      task: nil
    )
  end
end
