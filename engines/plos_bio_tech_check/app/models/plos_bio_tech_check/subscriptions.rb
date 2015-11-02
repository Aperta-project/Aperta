# This file is useful to take actions when event streaming is enabled on your model (mytask).
#
# TahiNotifier.subscribe("mytask:created", "mytask:updated") do |subscription_name, payload|
#   action = payload[:action]
#   record = payload[:record]
#
#   EventStream.new(action, record, subscription_name).post
# end

# TahiNotifier.subscribe("mytask:destroyed") do |subscription_name, payload|
#   action = payload[:action]
#   record = payload[:klass]
#
#   EventStream.new(action, record, subscription_name).destroy
# end
