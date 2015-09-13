module DataMigrator
  class Base
    def self.cleanup
      new.cleanup
    end

    def self.migrate!
      new.migrate!
    end

    def self.reset
      new.reset
    end

    # +cleanup+ is intended to remove any old data that is no longer necessar
    # after the data migration is complete.
    def cleanup
      raise NotImplementedError, "Must override #cleanup in subclass"
    end

    # +migrate!+ runs the data migration.
    def migrate!
      raise NotImplementedError, "Must override #migrate! in subclass"
    end

    # +reset+ resets/undo the data migration so it can be run again from scratch.
    def reset
      raise NotImplementedError, "Must override #reset in subclass"
    end

    private

    def ask(question)
      $stdout.puts question
      $stdout.flush
      $stdin.gets
    end

    def migrating(count:, from:, to:, &blk)
      print "Importing #{yellow(count)} #{from} questions to #{to} nested questions... "
      yield
      puts green("done")
    end

    def green(text)
      "\e[32m#{text}\e[0m"
    end

    def yellow(text)
      "\e[33m#{text}\e[0m"
    end


  end
end
