desc "Print out all defined subscriptions with event names and event handlers"
task subscriptions: :environment do
  Subscriptions.pretty_print
end
