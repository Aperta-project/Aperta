# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
