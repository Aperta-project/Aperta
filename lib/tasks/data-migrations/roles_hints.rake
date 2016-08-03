namespace :data do
  namespace :migrate do
    namespace :roles do
      desc 'Sets the Task position value based on actual ordering'
      task add_assigned_to_hints: :environment do
        def assign_hint(names, hint)
          Role.where(name: names)
            .update_all(assigned_to_type_hint: hint)
        end

        assign_hint Role::USER_ROLES,             'User'
        assign_hint Role::DISCUSSION_TOPIC_ROLES, 'DiscussionTopic'
        assign_hint Role::TASK_ROLES,             'Task'
        assign_hint Role::PAPER_ROLES,            'Paper'
        assign_hint Role::JOURNAL_ROLES,          'Journal'
      end
    end
  end
end
