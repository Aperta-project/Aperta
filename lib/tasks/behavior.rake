namespace :behavior do
  namespace :create do
    desc "Create a new send email behavior."
    task :send_email, [:journal_id, :event, :letter_template] => [:environment] do |_t, args|
      behavior = SendEmailBehavior.create!(
        journal: Journal.find(args[:journal_id].to_i),
        event_name: args['event'],
        letter_template: args['letter_template']
      )
      STDOUT.write("Created #{behavior.inspect}\n")
    end

    desc "Create a new create task behavior."
    task :create_task, [:journal_id, :event, :card_id, :duplicates_allowed] => [:environment] do |_t, args|
      behavior = CreateTaskBehavior.create!(
        journal: Journal.find(args[:journal_id].to_i),
        event_name: args['event'],
        card_id: args['card_id'],
        duplicates_allowed: ActiveRecord::Type::Boolean.new.type_cast_from_user(args['duplicates_allowed'])
      )
      STDOUT.write("Created #{behavior.inspect}\n")
    end
  end
end
