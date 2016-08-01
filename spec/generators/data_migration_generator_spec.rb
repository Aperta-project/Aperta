require 'rails_helper'
require 'generator_spec'
require 'data_migration'
require 'generators/data_migration/data_migration_generator'

describe DataMigrationGenerator, type: :generator do
  destination Rails.root.join('spec/tmp')
  arguments %w(PaintTheSkyBlue)

  before(:all) do
    prepare_destination
    run_generator
  end

  let(:migrations) { Dir[Rails.root.join('spec/tmp/db/migrate/*').to_s] }
  let(:migration) { migrations.first }

  it 'creates a migration in db/migrate' do
    expect(migrations.length).to eq 1
  end

  it 'names the migration like any other migration' do
    expect(File.basename(migration)).to match \
      /^\d+_paint_the_sky_blue.rb$/
  end

  it 'provides a default migration skeleton' do
    expect(File.read(migration)).to eq <<-FILE.strip_heredoc
      class PaintTheSkyBlue < DataMigration
        RAKE_TASK_UP = place_rake_task_as_string_here
        # RAKE_TASK_DOWN = 'fill_me_in or delete me if unnecessary'
      end
    FILE
  end
end
