namespace :behavior do
  desc "List all existing behaviors."
  task list: :environment do |_t, _args|
    if Behavior.count.zero?
      STDOUT.write("No behaviors found\n")
    else
      Behavior.all.find_each do |behavior|
        STDOUT.write("#{behavior.inspect}\n")
      end
    end
  end

  desc "Destroy a behavior with a given id. Use rake behavior:list to determine the id."
  task :destroy, [:behavior_id] => :environment do |_t, args|
    behavior = Behavior.find(args[:behavior_id].to_i)
    behavior.destroy!
    STDOUT.write("Destroyed #{behavior.inspect}\n")
  end

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

    desc "Create a new autocomplete task behavior."
    task :task_completion, [:journal_id, :event, :card_id, :change_to] => [:environment] do |_t, args|
      Event.register(args['event'])
      behavior = TaskCompletionBehavior.create!(
        journal: Journal.find(args[:journal_id].to_i),
        event_name: args['event'],
        card_id: args['card_id'],
        change_to: args['change_to']
      )
      STDOUT.write("Created #{behavior.inspect}\n")
    end
  end
end
