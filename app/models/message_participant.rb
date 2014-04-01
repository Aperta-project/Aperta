class MessageParticipant < ActiveRecord::Base
  belongs_to :message_task, class_name: 'StandardTasks::MessageTask',
                            inverse_of: :message_participants,
                            foreign_key: 'task_id'
  belongs_to :participant, class_name: 'User', inverse_of: :message_participants
end
