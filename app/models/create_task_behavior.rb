class CreateTaskBehavior < Behavior
  has_attributes integer: %w[card_id], boolean: %w[duplicates_allowed]
  validates :card_id, presence: true
  validates :duplicates_allowed, inclusion: { in: [true, false] }
  validate :card_available_in_journal

  def call(event)
    card = Card.find card_id

    task_attrs = get_task_attrs(card)
    return if disallowed_duplicate?(event.paper, task_attrs[:name])

    task_opts = create_task_opts(event, card, task_attrs)
    TaskFactory.create(task_attrs[:class], task_opts)
  end

  private

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

  def disallowed_duplicate?(paper, task_name)
    return false if duplicates_allowed
    card_versions = Card.find(card_id).card_versions.pluck :id
    paper.tasks.where(card_version: card_versions)
  end

  def card_available_in_journal
    return if errors.present?
    card = Card.find card_id

    return if card.journal_id.in? [journal.id, nil]
    errors.add(:card_id, "The card added to this behavior is not available for the behavior's journnal")
  end
end
