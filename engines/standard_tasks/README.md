StandardTasks
=============

This is a pack of standard tasks for the Tahi project.


MIGRATION GUIDE TO ENGINES-BASED PLUGGABLE CARDS(DELETE LATER)
==============================================================

Command for creating brand new engine:
---------------------------------------
`rails plugin new engines/standard_tasks --full —mountable —skip-test-unit`
- Set up spec directory
- engine.rb config setup
- Add gem dependency in engine level gemspec file
  - Example: `s.add_development_dependency 'rspec-rails'`

After
- Add engine as a gem in root Gemfile
  - `gem 'standard_tasks', path: 'engines/standard_tasks'`
- require js files on bottom of application.js sprocket
  - `//= require standard_tasks/application`
- Move model file over
  - In order for model file to autoload, it must be under a namespaced folder under
  - `engines/standard_tasks/models/standard_tasks/foo_task.rb`

Changes in root app
-------------------
- In `phase.rb`, change the task name for task creation command under #initialize_defaults
  - Example: changing `FooTask.new` to `StandardTasks::FooTask.new`
- Define a method "active_model_serializer" on the model to return the corresponding Serializer

Specs
------
- Make sure to run all specs (root spec folder and engine spec folder)
  - run `rspec .` or `rspec spec engines`
- Move: model, serializer specs, change class names.
- Change class names in `phase_spec.rb` in the 'tasks' describe block.
- Change `card_name` in serializer spec in the let block.

For module testing from within the engine (ignore for now)
----------------------------------------------------------
- http://viget.com/extend/rails-engine-testing-with-rspec-capybara-and-factorygirl
- Rakefile setup
- `bundle exec rake app:db:migrate`
- `bundle exec rake app:db:test:prepare`
