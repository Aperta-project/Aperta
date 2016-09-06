namespace :clean do
  desc <<-DESC
    Cleans/purge/remove temporary files from disk.

    This should be used to cleanup temporary files that result from
    CarrierWave uploads and downloads.

    It will clean files older than 24 hours.
  DESC
  task temp_files: :environment do
    CarrierWave.clean_cached_files!
  end
end
