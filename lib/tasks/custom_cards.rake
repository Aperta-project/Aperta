require 'rake'

namespace :custom_cards do
  desc "Install a Custom Tahi .gem Card"
  task :install, [:card_name] => :environment do |task, args|
    # Append to the File
    task_name = args["card_name"]
    task_class_name = task_name.camelize

    engine_name = task_name.underscore
    engine_class_name = engine_name.camelize

    # This should just use Rails::Generators or Thor's inject_into_file method
    string = File.open("app/services/task_services/create_task_types.rb", "r").read

    additional_text = "{kind: '#{engine_class_name}::#{task_class_name}Task', default_role: 'author', default_title: '#{task_class_name}'},\n"
    index = string.index("]")

    updated_string = string.insert(index, additional_text)

    File.open("app/services/task_services/create_task_types.rb", "w") do |f|
      f << updated_string
    end

    # Then, run the rake task
    Rake::Task["data:create_task_types"].invoke
  end
end
