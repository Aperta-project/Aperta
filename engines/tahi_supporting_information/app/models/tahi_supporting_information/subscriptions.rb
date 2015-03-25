TahiNotifier.subscribe("supporting_information/file:created", "supporting_information/file:updated") do |subscription_name, payload|
  action = payload[:action]
  record = payload[:record]

  EventStream.new(action, record, subscription_name).post
end
