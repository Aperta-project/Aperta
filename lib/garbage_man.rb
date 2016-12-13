class GarbageMan

  def self.pickup_db_dumps(folder = "~")
    save_file_count = 2
    list_in_order   = 'ls -1tr'
    file_pattern    = 'aperta-????-??-??T??:??:??Z.dump' # change if pattern changes in db:dump task
    silently        = '2> /dev/null'
    shell_command   = "#{list_in_order} #{folder}/#{file_pattern} #{silently}"
    dump_files      = %x[#{shell_command}].split("\n")
    save_files      = dump_files.pop(save_file_count)

    %x[rm #{dump_files.join(' ')}] if dump_files.count > 0

    remainder = %x[#{shell_command}].split("\n")
    if remainder.count > save_file_count
      STDERR.puts "Clean up of database dump files appears to have failed.  Please investigate manually."
    else
      puts "The #{remainder.count} most recent log files have been left:\n"
      puts remainder.map{|path| ' * ' + path}
      puts "and #{dump_files.count} files have been removed."
    end
  end
end
