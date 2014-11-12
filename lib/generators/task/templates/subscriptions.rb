# This file is useful to take actions when event streaming is enabled on your model (mytask).
#
# TahiNotifier.subscribe("mytask:created", "mytask:updated") do |subscription_name, payload|
#   action     = payload[:action]
#   klass      = payload[:klass]
#   id         = payload[:id]
#
#   EventStream.new(action, klass, id, subscription_name).post
# end

# TahiNotifier.subscribe("mytask:destroyed") do |subscription_name, payload|
#   action     = payload[:action]
#   klass      = payload[:klass]
#   id         = payload[:id]
#
#   EventStream.new(action, klass, id, subscription_name).destroy
# end
