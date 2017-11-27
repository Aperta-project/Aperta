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
  end
end
