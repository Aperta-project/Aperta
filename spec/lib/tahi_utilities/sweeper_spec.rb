require 'rails_helper'
require 'tahi_utilities/sweeper'

describe TahiUtilities::Sweeper do

  let(:temporary_directory) { './tmp/sweeper' }

  let(:dump_files) {[
    'aperta-2016-01-01T01:01:01Z.dump',
    'aperta-2016-02-02T02:02:02Z.dump',
    'aperta-2016-03-03T03:03:03Z.dump',
    'aperta-2016-04-04T04:04:04Z.dump',
    'aperta-2016-05-05T05:05:05Z.dump',
    'aperta-2016-06-06T06:06:06Z.dump',
    'aperta-2016-07-07T07:07:07Z.dump',
    'aperta-2016-08-08T08:08:08Z.dump',
    'aperta-2016-09-09T09:09:09Z.dump',
    'aperta-2016-10-10T10:10:10Z.dump',
  ]}

  let(:remaining_files) { `ls -1 #{temporary_directory}`.split("\n") }

  def newest_file_in(directory)
    Dir.chdir(directory) { Dir.glob("*").max_by {|file| File.mtime(file)} }
  end

  def oldest_file_in(directory)
    Dir.chdir(directory) { Dir.glob("*").min_by {|file| File.mtime(file)} }
  end

  before(:each) do
    # ensure that (for these tests!) the temporary_directory is inside the project directory
    expect(File.expand_path(temporary_directory)).to start_with(Rails.root.to_s)

    # create tmp directory if it doesn't exist
    `mkdir -p #{temporary_directory}`

    # ensure no previously interrupted runs left behind junk:
    `rm -f #{temporary_directory}/*`

    # create fake files
    dump_files.first(number_of_files).each do |file|
      `touch #{temporary_directory}/#{file}`
      sleep 1 # we need this delay to guarantee proper sorting!!!
    end

    @newest_file  = newest_file_in(temporary_directory)
    @oldest_file  = oldest_file_in(temporary_directory)
    @return_value = TahiUtilities::Sweeper.remove_old_files(from_folder: temporary_directory, matching_glob: 'aperta-????-??-??T??:??:??Z.dump', keeping_newest: files_to_leave)
  end

  after(:each) do
    # clean up fake files
    `rm -f #{temporary_directory}/*`
  end

  describe ".remove_old_files" do

    context "with a need to save 2 files" do
      let(:files_to_leave) { 2 }

      context "when starting out with 10 dump files" do
        let(:number_of_files) { 10 }

        it "leaves 2 dump files behind when it is finished" do
          TahiUtilities::Sweeper.remove_old_files(from_folder: temporary_directory, matching_glob: 'aperta-????-??-??T??:??:??Z.dump', keeping_newest: files_to_leave)
          expect(remaining_files.count).to eq(2)
        end

        it "deletes older files and leaves newer files" do
          expect(remaining_files).to include @newest_file
          expect(remaining_files).not_to include @oldest_file
        end

        it "leaves files 9 and 10 (the newest files)" do
          expect(remaining_files).to eq(dump_files.last(2))
        end
      end

      context "when starting out with 2 dump files" do
        let(:number_of_files) { 2 }

        it "leaves 2 dump files behind when it is finished" do
          expect(remaining_files.count).to eq(2)
        end

        it "leaves both newest and oldest files (because they are all there is)" do
          expect(remaining_files).to include @newest_file
          expect(remaining_files).to include @oldest_file
        end

        it "leaves files 1 and 2 (the newest files)" do
          expect(remaining_files).to eq(dump_files.first(2))
        end
      end

      context "when starting out with 1 dump file" do
        let(:number_of_files) { 1 }

        it "leaves 1 dump file behind when it is finished" do
          expect(remaining_files.count).to eq(1)
        end

        it "leaves the newest file" do
          newest_file = newest_file_in(temporary_directory)
          expect(remaining_files).to include newest_file
        end

        it "leaves file 1 (the newest, and only file)" do
          expect(remaining_files).to eq(dump_files.first(1))
        end
      end

      context "when starting out with no dump file" do
        let(:number_of_files) { 0 }

        it "leaves 0 files when it is finished" do
          expect(remaining_files.count).to eq(0)
        end
      end
    end

    context "with a need to save 3 files" do
      let(:files_to_leave) { 3 }

      context "when starting out with 10 dump files" do
        let(:number_of_files) { 10 }

        it "leaves 3 dump files behind when it is finished" do
          expect(remaining_files.count).to eq(3)
        end

        it "deletes older files and leaves newer files" do
          expect(remaining_files).to include @newest_file
          expect(remaining_files).not_to include @oldest_file
        end

        it "leaves files 8, 9, and 10 (the newest 3 files)" do
          expect(remaining_files).to eq(dump_files.last(3))
        end
      end

      context "when starting out with 2 dump files" do
        let(:number_of_files) { 2 }

        it "leaves 2 dump files behind when it is finished" do
          expect(remaining_files.count).to eq(2)
        end

        it "leaves both files" do
          expect(remaining_files).to include @newest_file
          expect(remaining_files).to include @oldest_file
        end

        it "leaves files 1 and 2 (which are newest)" do
          expect(remaining_files).to eq(dump_files.first(2))
        end

        it "returns a hash containing remaining and deleted file arrays" do
          expect(@return_value).to be_an_instance_of(Hash)
          expect(@return_value[:remaining_files]).to be_an_instance_of(Array)
          expect(@return_value[:deleted_files]).to be_an_instance_of(Array)
        end
      end

      context "when starting out with 1 dump file" do
        let(:number_of_files) { 1 }

        it "leaves 1 dump file behind when it is finished" do
          expect(remaining_files.count).to eq(1)
        end

        it "leaves the newest file" do
          newest_file = newest_file_in(temporary_directory)
          expect(remaining_files).to include newest_file
        end

        it "leaves file 1 (which is newest)" do
          expect(remaining_files).to eq(dump_files.first(1))
        end
      end

      context "when starting out with no dump file" do
        let(:number_of_files) { 0 }

        it "leaves 0 files when it is finished" do
          expect(remaining_files.count).to eq(0)
        end

        it "returns a hash containing empty remaining and deleted file arrays" do
          expect(@return_value).to be_an_instance_of(Hash)
          expect(@return_value[:remaining_files]).to eq([])
          expect(@return_value[:deleted_files]).to eq([])
        end
      end
    end
  end
end
