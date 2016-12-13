require 'rails_helper'
require 'garbage_man'

describe GarbageMan do

  let(:temporary_directory) { '/tmp/aperta/garbage_man' }

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

  let(:remainder) { -> { `ls -1 #{temporary_directory}`.split("\n") } }

  before(:each) do
    # create tmp directory if it doesn't exist
    `mkdir -p #{temporary_directory}`

    # ensure no previously interrupted runs left behind junk:
    `rm -f #{temporary_directory}/*`

    # create fake files
    dump_files.first(number_of_files).each do |file|
      `touch #{temporary_directory}/#{file}`
      sleep 1 # we need this delay to guarantee proper sorting!!!
    end
  end

  after(:each) do
    # clean up fake files
    `rm -f #{temporary_directory}/*`
  end

  describe "pickup_db_dumps" do

    context "when starting out with 10 dump files" do
      let(:number_of_files) { 10 }

      it "leaves 2 dump files behind when it is finished" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call.count).to eq(2)
      end

      it "deletes older files and leaves newer files" do
        newest_file = Dir.chdir(temporary_directory) { Dir.glob("*").max_by {|f| File.mtime(f)} }
        oldest_file = Dir.chdir(temporary_directory) { Dir.glob("*").min_by {|f| File.mtime(f)} }
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to include newest_file
        expect(remainder.call).not_to include oldest_file
      end

      it "leaves files 9 and 10" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to eq(dump_files.last(2))
      end
    end

    context "when starting out with 2 dump files" do
      let(:number_of_files) { 2 }

      it "leaves 2 dump files behind when it is finished" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call.count).to eq(2)
      end

      it "leaves both files" do
        newest_file = Dir.chdir(temporary_directory) { Dir.glob("*").max_by {|f| File.mtime(f)} }
        oldest_file = Dir.chdir(temporary_directory) { Dir.glob("*").min_by {|f| File.mtime(f)} }
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to include newest_file
        expect(remainder.call).to include oldest_file
      end

      it "leaves files 1 and 2" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to eq(dump_files.first(2))
      end
    end

    context "when starting out with 1 dump file" do
      let(:number_of_files) { 1 }

      it "leaves 1 dump file behind when it is finished" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call.count).to eq(1)
      end

      it "leaves the newest file" do
        newest_file = Dir.chdir(temporary_directory) { Dir.glob("*").max_by {|f| File.mtime(f)} }
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to include newest_file
      end

      it "leaves file 1" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call).to eq(dump_files.first(1))
      end
    end

    context "when starting out with no dump file" do
      let(:number_of_files) { 0 }

      it "leaves 0 files when it is finished" do
        GarbageMan.pickup_db_dumps(temporary_directory)
        expect(remainder.call.count).to eq(0)
      end
    end
  end
end
