require 'rake'
require 'json'
require 'pathname'

namespace :custom_cards do
  def relative_path(to, from)
    Pathname.new(to).relative_path_from(Pathname.new(from))
  end

  desc 'Install a tahi engine for a git repo or local path'
  task :install_engine, [:path] => :environment do |_, args|
    path = args[:path]
    needle = '# Task Engines'
    gem_type = if path.match(/^(http|git)/)
                 'git'
               else
                 'path'
               end
    engine_name = path.split(/\//)[-1].gsub(/^tahi-/, '')
    insert_after('Gemfile', needle, "gem '#{engine_name}', #{gem_type}: '#{path}'")
    Bundler.with_clean_env do
      sh 'bundle install'
    end
    Bundler.with_clean_env do
      # need to do this in subshell because our ruby process doesn't
      # know about the engine yet
      sh "rake custom_cards:install[#{engine_name}]"
      migration_task = "#{engine_name}:install:migrations"
      sh "rake #{migration_task}" if `rake -T #{migration_task}`.size > 0
    end
    if gem_type == 'path'
      Rake::Task['custom_cards:update_package_json'].invoke(File.expand_path(File.join(path, 'client')))
    else
      # TODO: need to make this work
      puts 'I do not know how to install a git repos ember code.'
    end
  end

  desc 'Update package.json to include a path'
  task :update_package_json, [:path] => :environment do |_, args|
    package_path = File.join(Rails.root, 'client', 'package.json')
    package = JSON.load(File.open(package_path))
    package['ember-addon'] ||= {}
    package['ember-addon']['paths'] ||= []
    package['ember-addon']['paths'].push(relative_path(args[:path], File.join(Rails.root, 'client')))
    File.open(package_path, 'w') << JSON.pretty_generate(package)
  end

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

    needle = "// DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE"
    insert_after("app/assets/stylesheets/application.scss", needle, "@import '#{engine_name}/application';")

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
