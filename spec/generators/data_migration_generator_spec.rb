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
