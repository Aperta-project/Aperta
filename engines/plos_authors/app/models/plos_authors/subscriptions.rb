# TahiNotifier.subscribe("author:created") do |payload|
#   record = payload[:record]
#
#   # generic Authors may have been created in a different task, so
#   # convert them to PlosAuthors
#   record.paper.tasks_for_type("PlosAuthors::PlosAuthorsTask").each do |task|
#     task.convert_generic_authors!
#   end
# end
#
# TahiNotifier.subscribe("plos_authors/plos_author:*") do |payload|
#   action = payload[:action]
#   record = payload[:record]
#   excluded_socket_id = payload[:requester_socket_id]
#
#   # serialize the plos_author down the paper channel
#   EventStream::Broadcaster.new(record).post(action: action, channel_scope: record.plos_authors_task.paper, excluded_socket_id: excluded_socket_id)
# end
