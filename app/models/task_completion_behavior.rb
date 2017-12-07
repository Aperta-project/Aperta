class TaskCompletionBehavior < Behavior
  has_attributes integer: %w[card_id], string: %w[change_to]

  validates :card_id, presence: true
  validates :change_to, presence: true, inclusion: { in: %w[completed incomplete toggle] }

  def call(event)
    # load card
    card = Card.find(card_id)

    # load the task
    tasks = event.paper.tasks.where(card_version_id: card.card_versions.pluck(:id))

    # test to see if the tasks is empty registered to be autocompleted
    return if tasks.empty?

    tasks.each do |task|
      case change_to
      when 'toggle'
        task.completed = !task.completed
      when 'completed'
        task.completed = true
      when "incomplete"
        task.completed = false
      end
      task.notify_requester = true
      task.save!
    end
  end
end
