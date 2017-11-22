class CreateTaskBehavior < Behavior
  has_attributes integer: %w[card_id], boolean: %w[duplicates_allowed]
  validates :card_id, :duplicates_allowed, presence: true

  # deal with real time card display
  # tests

  def call(event)
    # Handle journal not having card
    card = Card.find card_id

    task_attrs = get_task_attrs(card)
    return if disallowed_duplicate?(event, task_attrs[:name])

    task_opts = create_task_opts(event, card, task_attrs)
    TaskFactory.create(task_attrs[:class], task_opts)
  end

  def create_task_opts(event, card, task_attrs)
    { "completed" => false,
      "title" => task_attrs[:name],
      "phase_id" => event.paper.phases.first.id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card.latest_published_card_version }
  end

  def get_task_attrs(card)
    # Legacy cards are locked at creation. This is like asking 'card.legacy_card?'
    if card.locked?
      task_class = card.name.constantize
      task_name = task_class::DEFAULT_TITLE
    else
      task_class = CustomCardTask
      task_name = card.name
    end

    { class: task_class, name: task_name }
  end

  def disallowed_duplicate?(event, task_name)
    !duplicates_allowed &&
    event.paper.tasks.where(title: task_name).any?
  end
end
