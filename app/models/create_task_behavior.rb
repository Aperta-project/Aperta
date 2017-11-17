class CreateTaskBehavior < Behavior
  # has_attributes string: %w[task_name], integer: %w[phase_id]
  # validates :task_name, presence: true

  def call(event)
    task_name = entity_attributes.find_by(name: 'task_name').string_value
    card_version = event.paper.journal.cards.find_by(name: task_name).latest_card_version
    phase_id = event.paper.phases.first.id

    task_opts = {
      "completed" => false,
      "title" => task_name,
      "phase_id" => phase_id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card_version
    }

    TaskFactory.create(CustomCardTask, task_opts)
  end
end

# this should be done by rake task
# behavior = CreateTaskBehavior.create(event_name: "paper.state_changed.submitted", journal_id: Journal.first.id )

# task_ent = behavior.entity_attributes.create(name: 'task_name', value_type:'string', string_value: 'Ethics Statement')

# phase_ent = behavior.entity_attributes.create(name: 'phase_id', value_type:'integer', integer_value: 51)

