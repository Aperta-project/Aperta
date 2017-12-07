class TaskCompletionBehavior < Behavior
  CHANGE_TO = %w[completed incomplete toggle].freeze

  has_attributes integer: %w[card_id], string: %w[change_to]
  # rubocop:disable Style/FormatStringToken
  validates :card_id, presence: true, inclusion: { in: ->(_) { Card.pluck(:id) }, message: '%{value} is not a valid card id' }
  validates :change_to, presence: true, inclusion: { in: CHANGE_TO, message: "%{value} should be one of the following: #{CHANGE_TO}" }

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
        task.toggle(:completed)
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
