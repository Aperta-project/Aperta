class TaskCompletionBehavior < Behavior
  has_attributes integer: %w[card_id], string: %w[change_to]

  validates :card_id, presence: true
  validates :change_to, presence: true, inclusion: { in: %w[completed incomplete toggle] }

  def call(event)
    # load the task
    task = event.task

    # test to see if the task is not nil and is an instance of the card
    # registered to be autocompleted
    return if task.nil? || task.card.id != card_id

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
