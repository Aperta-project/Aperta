require 'rails_helper'

describe "rake clean:temp_files" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  let :run_rake_task do
    Rake::Task['clean:temp_files'].reenable
    Rake.application.invoke_task 'clean:temp_files'
  end

  describe 'clearing out CarrierWave files' do
    let(:temp_path) do
      Pathname.new(CarrierWave.root).join('uploads/tmp/carrierwave')
    end

    # Match carrierwave's temp directory pattern <time>-\d+-\d+
    # CarrierWave only looks at the first set of digits to determine the
    # timestamp. It ignores the actual mtime of the File on the file-system.
    let(:directory) { temp_path.join("#{mtime.to_i}-111-222").to_s }

    let(:mtime) do
      raise NotImplementedError, ':mtime must be implemented in context'
    end

    before do
      FileUtils.mkdir_p directory
    end

    after do
      FileUtils.rmdir directory if Dir.exists?(directory)
    end

    context 'and the CarrierWave directory is older than 24 hours' do
      let(:mtime) { 25.hours.ago.to_time }

      it 'removes CarrierWave directories older than 24 hours' do
        expect do
          run_rake_task
        end.to change { Dir.exists?(directory) }.from(true).to(false)
      end
    end

    context 'and the CarrierWave directory is newer than 24 hours' do
      let(:mtime) { 23.hours.ago.to_time }

      it 'does not remove CarrierWave directories newer than 24 hours' do
        expect do
          run_rake_task
        end.to_not change { Dir.exists?(directory) }.from(true)
      end
    end
  end
end
