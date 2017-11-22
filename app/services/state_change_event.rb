class StateChangeEvent < Event
  # Single method to call to start a method.
  def initialize(aasm:, instance:, paper:, task:, user:)
    @aasm = aasm
    @instance = instance
    super(
      name: make_event_name(aasm.to_state),
      paper: paper,
      task: task,
      user: user
    )
  end

  def activity_feed_message
    "#{@instance.class.name} state changed to #{@aasm.to_state}"
  end

  # TODO: This should be based on the event, not the state
  def make_event_name(state)
    "#{@instance.class.name.underscore}.state_changed.#{@aasm.to_state}"
  end
end
