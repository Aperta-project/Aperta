TahiNotifier.subscribe("paper.revised") do |subscription_name, payload|
  activity = payload[:activity]
  Notifications::Handler.new(activity: activity).call
end
