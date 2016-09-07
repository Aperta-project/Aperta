# This migration tries to automatically move CarrierWave cache files
# on systems that have /var/www/tahi. This is a no-op on other systems
# such as dev boxes and heroku environments.
class MoveCarrierWaveCacheDirectory < ActiveRecord::Migration
  def up
    bash_exec <<-BASH.strip_heredoc
      #!/usr/bin/env bash

      # If we are on a system with this directory structure then we want
      # to try to move the CarrierWave cache directory.
      if [ -d /var/www/tahi/releases/ ] ; then
        echo "On a system with /var/www/tahi. Attempting to move CarrierWave cache_dir."

        # Find the previous deploy directory
        PREVIOUS_DEPLOY=/var/www/tahi/releases/`ls -t /var/www/tahi/releases | head -n 2 | tail -n 1`

        echo "Previous deployment was at: $PREVIOUS_DEPLOY"

        # Old uploads directory
        OLD_UPLOADS_DIRECTORY=$PREVIOUS_DEPLOY/public/uploads

        # Old carrierwave directory for storing cached files
        OLD_UPLOADS_TMP_DIRECTORY=$OLD_UPLOADS_DIRECTORY/tmp

        # New carrierwave directory for storing cached files
        NEW_DIRECTORY=/var/www/tahi/shared/public/uploads/tmp/carrierwave/

        # if the old uploads directory exists then move whatever files may exist
        if [ ! -d $OLD_UPLOADS_TMP_DIRECTORY ]; then
          echo "$OLD_UPLOADS_TMP_DIRECTORY does not exist. Nothing to do. Skipping."
          exit 0
        fi

        if [ -h $OLD_UPLOADS_DIRECTORY ]; then
          echo "$OLD_UPLOADS_DIRECTORY is a symlink which indicates this migration has been setup and there is nothing to do. Skipping."
          exit 0
        fi

        echo "Creating new Carrierwave cache directory: $NEW_DIRECTORY"
        mkdir -p $NEW_DIRECTORY

        # Move old temporary files (in case there are files that were processing when deploy happened)
        file_count=`ls -A $OLD_UPLOADS_TMP_DIRECTORY | wc -l`
        if [ $file_count -gt 0 ] ; then
          mv $OLD_UPLOADS_TMP_DIRECTORY/* /var/www/tahi/current/public/uploads/tmp/carrierwave/
        else
          echo "There are no files in $OLD_UPLOADS_TMP_DIRECTORY/tmp/. Nothing to do. Skipping."
        fi
      else
        echo "Not on a system with /var/www/tahi. This migration is a no-op. Skipping."
      fi
    BASH
  end

  private

  def bash_exec(script)
    require 'shellwords'
    require 'tempfile'

    file = Tempfile.new('carrierwave-cache-dir-migration')
    file.write script
    file.close

    File.chmod 0755, file.path
    success = system ". #{file.path}"

    unless success
      STDERR.puts <<-ERROR
        Bash script failed with a non-zero exitstatus.

        You may need to manually move the CarrierWave cache directory.

        See information on JIRA issue:
          https://developer.plos.org/jira/browse/APERTA-7399
      ERROR
    end
  end
end
