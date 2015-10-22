##
# To see *all* subscriptions, try `rake subscriptions`!
#
# For event stream sbuscriptions, check out event_stream_subscribers.rb
#

Subscriptions.configure do
  add '.*', EventLogger
  add 'paper:submitted', Paper::Submitted::EmailCreator, Paper::Submitted::EmailAdmins, Paper::Submitted::SnapshotMetadata
  add 'paper:resubmitted', Paper::Resubmitted::EmailEditor
end
