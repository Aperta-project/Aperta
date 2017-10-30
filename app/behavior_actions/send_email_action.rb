class SendEmailAction < BehaviorAction
  def call(action_params, behavior_params)
    letter_template = action_params[:paper].journal.letter_templates.find_by(behavior_params['letter_template_name'])
    scenario = letter_template.scenario.constantize
    letter_template.render(scenario.new(task_obj))

    GenericMailer.delay.send_email(
      subject: letter_template.subject,
      body: letter_template.body,
      to: letter_template.to,
      task: task
    )
  end
end
