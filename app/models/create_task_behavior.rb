class CreateTaskBehavior < Behavior
  # has_attributes string: integer: %w[card_id]
  # validates :task_name, presence: true

  # deal with real time card display
  # deal with attributes
  # tests
  def call(event)
    card_id = entity_attributes.find_by(name: 'card_id').value
    card = Card.find card_id

    task_attrs = get_task_attrs(card)
    return if disallowed_duplicate?(event, task_attrs[:name])
    phase_id = event.paper.phases.first.id

    task_opts = {
      "completed" => false,
      "title" => task_attrs[:name],
      "phase_id" => phase_id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card.latest_published_card_version
    }

    TaskFactory.create(task_attrs[:class], task_opts)
  end

  def get_task_attrs(card)
    # Legacy cards are locked at creation. This is like asking 'card.legacy_card?'
    if card.locked?
      task_class = card.name.constantize
      task_name = task_class::DEFAULT_TITLE
    else
      task = Task.find_by(title: card.name)
      task_class = task.class
      task_name = task.title
    end

    { class: task_class, name: task_name }
  end

  def disallowed_duplicate?(event, task_name)
    !entity_attributes.find_by(name: 'duplicates_allowed').value &&
    event.paper.tasks.where(title: task_name).any?
  end
end

# this should be done by rake task
# b1 = CreateTaskBehavior.create(event_name: "paper.state_changed.submitted", journal_id: Journal.first.id )

# b1.entity_attributes.create(name: 'card_id', value_type:'integer', integer_value: 68)

# b1.entity_attributes.create(name: 'duplicates_allowed', value_type:'boolean', boolean_value: true)

# b2 = CreateTaskBehavior.create(event_name: "paper.state_changed.submitted", journal_id: Journal.first.id )

# b2.entity_attributes.create(name: 'card_id', value_type:'integer', integer_value: 27)

# b2.entity_attributes.create(name: 'duplicates_allowed', value_type:'boolean', boolean_value: true)

