class SendEmailAction < BehaviorAction
  required_parameters letter_template: :string

  def call(user:, paper:, task: nil, **parameters)
    letter_template = paper.journal.letter_templates.find_by(parameters['letter_template_name'])
    scenario = letter_templates.scenario.constantize
    letter_template.render(scenario.new(task_obj))

    GenericMailer.delay.send_email(
      subject: letter_template.subject,
      body: letter_template.body,
      to: letter_template.to,
      task: task
    )
  end
end
