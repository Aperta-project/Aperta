require 'rake'
require 'json'
require 'pathname'

namespace :tahi do
  desc 'Install a tahi engine for a git repo or local path'
  task :install_plugin, [:path] => :environment do |_, args|
    path = args[:path]
    needle = '# Task Engines'
    gem_type = if path.match(/^(http|git)/)
                 'git'
               else
                 'path'
               end
    engine_name = path.split(/\//)[-1].gsub(/^tahi-/, '').gsub(/.git$/, '')
    insert_after('Gemfile', needle, "gem '#{engine_name}', #{gem_type}: '#{path}'")
    Bundler.with_clean_env do
      sh 'bundle install'
    end
    Bundler.with_clean_env do
      # need to do this in subshell because our ruby process doesn't
      # know about the engine yet
      sh "bundle exec rake tahi:install[#{engine_name}]"
      migration_task = "#{engine_name}:install:migrations"
      sh "bundle exec rake #{migration_task}" if `bundle exec rake -T #{migration_task}`.size > 0
    end
    if gem_type == 'path'
      update_package_json(path)
    else
      engine_path = `bundle show #{engine_name}`.chomp
      if File.directory? engine_path
        update_package_json(engine_path)
      end
    end
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

  def relative_path(to, from)
    Pathname.new(to).relative_path_from(Pathname.new(from))
  end

  # Update package.json to include an ember addon at path
  def update_package_json(path)
    package_path = File.join(Rails.root, 'client', 'package.json')
    client_path = File.expand_path(File.join(path, 'client'))
    relative_client_path = relative_path(client_path, File.join(Rails.root, 'client'))
    package = JSON.load(File.open(package_path))
    package['ember-addon'] ||= {}
    package['ember-addon']['paths'] ||= []
    package['ember-addon']['paths'].push(relative_client_path)
    File.open(package_path, 'w') << JSON.pretty_generate(package)
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
