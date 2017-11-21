class CreateTaskBehavior < Behavior
  has_attributes integer: %w[card_id], boolean: %w[duplicates_allowed]
  validates :card_id, :duplicates_allowed, presence: true

  # deal with real time card display
  # tests

  def call(event)
    card_id = entity_attributes.find_by(name: 'card_id').value
    card = Card.find card_id

    task_attrs = get_task_attrs(card)
    return if disallowed_duplicate?(event, task_attrs[:name])

    task_opts = create_task_opts(event, card, task_attrs)
    TaskFactory.create(task_attrs[:class], task_opts)
  end

  def create_task_opts(event, card, task_attrs)
    {
      "completed" => false,
      "title" => task_attrs[:name],
      "phase_id" => event.paper.phases.first.id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card.latest_published_card_version
    }
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

# b1.card_id = 68

# b1.duplicates_allowed = true

# b2 = CreateTaskBehavior.create(event_name: "paper.state_changed.submitted", journal_id: Journal.first.id )

# b2.card_id = 27

# b2.duplicates_allowed = true


