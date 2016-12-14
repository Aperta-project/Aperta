module TahiUtilities
  class Sweeper

    # Cleans up old files, such as old database dump files.
    # Parameters:
    # - from_folder: the directory the files are being cleaned up from
    # - matching_glob: the globbing pattern used for matching files you want to clean up
    # - keeping_newest: the number of files you want to keep

    def self.remove_old_files(from_folder:, matching_glob:, keeping_newest:)
      # switch naming p.o.v. from parts of a sentence to developer-facing labels for data
      folder          = from_folder
      file_pattern    = matching_glob
      save_file_count = keeping_newest

      list_in_order   = 'ls -1tr' # list files in a single column, in chronological order, oldest first
      silently        = '2> /dev/null'
      shell_command   = "#{list_in_order} #{folder}/#{file_pattern} #{silently}"
      dump_files      = %x[#{shell_command}].split("\n")
      save_files      = dump_files.pop(save_file_count)

      %x[rm #{dump_files.join(' ')}] if dump_files.count > 0

      remaining_files = %x[#{shell_command}].split("\n")
      if remaining_files.count > save_file_count
        STDERR.puts "Clean up of database dump files appears to have failed.  Please investigate manually."
      else
        puts "The #{remaining_files.count} most recent log files have been left:\n"
        puts remaining_files.map{|path| ' * ' + path}
        puts "and #{dump_files.count} files have been removed."
      end
      return { remaining_files: remaining_files, deleted_files: dump_files }
    end
  end
end
