class CreateTaskBehavior < Behavior
  def call(event)
    task_name = entity_attributes.find_by(name: 'task_name').string_value
    phase_id = entity_attributes.find_by(name: 'phase_id').integer_value
    card_version = event.paper.journal.cards.find_by(name: task_name).latest_card_version

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

# Event.register('create_task')

# behavior = CreateTaskBehavior.create(event_name: 'create_task', journal_id: 1)

# task_ent = behavior.entity_attributes.create(name: 'task_name', value_type:'string', string_value: 'Ethics Statement')

# phase_ent = behavior.entity_attributes.create(name: 'phase_id', value_type:'integer', integer_value: 51)

# event = Event.new(name: 'create_task', paper: Paper.first, task: Paper.first.tasks.first, user: nil)

# event.trigger
