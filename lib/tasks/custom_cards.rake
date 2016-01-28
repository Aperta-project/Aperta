require 'rake'
require 'json'
require 'pathname'

namespace :tahi do
  desc 'Install a tahi engine for a git repo or local path'
  task :install_plugin, [:git_or_file_path] => :environment do |_, args|
    path = args[:git_or_file_path]
    fail "Please supply a git or file path!" if path.nil?
    needle = '# Task Engines'
    gem_type = if path.match(/^(http|git)/)
                 'git'
               else
                 'path'
               end
    engine_name = path.split(/\//)[-1].gsub(/.git$/, '')
    engine_path = engine_name.gsub(/-/, '/')
    engine_module = engine_path.classify
    insert_after('Gemfile', needle, "gem '#{engine_name}', #{gem_type}: '#{path}'")
    Bundler.with_clean_env do
      sh 'bundle install'
    end
    Bundler.with_clean_env do
      # need to do this in subshell because our ruby process doesn't
      # know about the engine yet
      migration_task = "#{engine_name.gsub(/-/,'_')}:install:migrations"
      if `bundle exec rake -T #{migration_task}`.size > 0
        sh "bundle exec rake #{migration_task}"
      else
        puts "No migration task found for this card. If you add migrations for #{engine_name} in in the future, you can install migrations with #{migration_task}."
      end

      # tahi magic installer
      sh 'bundle exec rake data:update_journal_task_types'
    end

    # modify route
    needle = "### DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE ###"
    insert_after("config/routes.rb", needle, "  mount #{engine_module}::Engine => '/api'")

    # modify application.scss
    needle = "// DO NOT DELETE OR EDIT. AUTOMATICALLY MOUNTED CUSTOM TASK CARDS GO HERE"
    insert_after("app/assets/stylesheets/application.scss", needle, "@import '#{engine_path}/application';")

    # offer help
    help_url = "https://github.com/Tahi-project/tahi/wiki/HOWTO:-Customizing-Custom-Cards#custom-card-styles"
    puts "For more information on how to Customize Tahi Cards, visit: #{help_url}"
  end

  def relative_path(to, from)
    Pathname.new(to).relative_path_from(Pathname.new(from))
  end

  # This should just use Rails::Generators or Thor's inject_into_file(:before) method
  def insert_before(filename, needle, string)
    hay = File.open(filename, "r").read
    needle_index = hay.index(needle)
    updated_string = hay.insert(needle_index, "#{string}\n")

    File.open(filename, "w") do |f|
      f << updated_string
      puts "updated #{filename}"
    end
  end

  # This should just use Rails::Generators or Thor's inject_into_file(:after) method
  def insert_after(filename, needle, string)
    hay = File.open(filename, "r").read
    needle_index = hay.index(needle)
    if hay.include? string
      puts "#{filename} already contains #{string}"
    else
      updated_string = hay.insert(needle_index + needle.length, "\n#{string}")
      File.open(filename, "w") do |f|
        f << updated_string
        puts "updated #{filename}"
      end
    end
  end
end
