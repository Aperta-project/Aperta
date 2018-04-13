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
        $stderr.puts "Clean up of database dump files appears to have failed.  Please investigate manually."
      else
        $stderr.puts "The #{remaining_files.count} most recent log files have been left:\n"
        $stderr.puts remaining_files.map { |path| ' * ' + path }
        $stderr.puts "and #{dump_files.count} files have been removed."
      end
      { remaining_files: remaining_files, deleted_files: dump_files }
    end
  end
end
