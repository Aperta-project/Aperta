require 'rake'

namespace :custom_cards do
  desc "Install a Custom Tahi .gem Card"
  task :install, [:card_name] => :environment do |task, args|
    # Append to the File
    task_name = args["card_name"]
    task_class_name = task_name.camelize

    engine_name = task_name.underscore
    puts "Installing Custom Tahi Card: #{engine_name}"
    engine_class_name = engine_name.camelize

    # Then, run the rake task
    Rake::Task["data:create_task_types"].invoke
    puts "Successfully ran `rake data:create_task_types` for #{engine_name}"

    needle = "### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###"
    insert_after("config/routes.rb", needle, "  mount #{engine_class_name}::Engine => '/'")

    needle = "// DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE //"
    insert_after("app/assets/javascripts/application.js.erb", needle, "//= require #{engine_name}/application")

    needle = "### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###"
    insert_after("app/assets/stylesheets/application.css.scss", needle, " *= require #{engine_name}/application")

    puts "Tahi Custom Task installation Successful!"
    puts "Also, be sure to add your new Custom Task to a Journal's Manuscript Manager Template"
  end

  # This should just use Rails::Generators or Thor's inject_into_file(:before) method
  def insert_before filename, needle, string
    hay = File.open(filename, "r").read
    needleIndex = hay.index(needle)
    updated_string = hay.insert(needleIndex, "#{string}\n")

    File.open(filename, "w") do |f|
      f << updated_string
      puts "updated #{filename}"
    end
  end

  # This should just use Rails::Generators or Thor's inject_into_file(:after) method
  def insert_after filename, needle, string
    hay = File.open(filename, "r").read
    needleIndex = hay.index(needle)
    updated_string = hay.insert(needleIndex + needle.length, "\n#{string}")

    File.open(filename, "w") do |f|
      f << updated_string
      puts "updated #{filename}"
    end
  end

end
