module DataTransformation
  class DuplicateCounterError < ::StandardError; end
  class UnknownCounterError < ::StandardError; end
  class AssertionFailed < ::StandardError; end
  # ==A base class for data transformations
  # Provides convenient tools for common data transformation tasks
  #
  # To use this, extend this with your own class and implement a `transform`
  # method. When you want to run, instantiate your class and call the `call`
  # method.
  #
  # ==Example
  #
  # ```
  # class DeleteAllPapersTransformation < DataTransformation::Base
  #   counter :papers
  #
  #   def transform
  #     Paper.find_each do |paper|
  #       increment_counter(:papers)
  #       paper.destroy!
  #     end
  #   end
  # end
  #
  # MyTransformation.new(dry_run: true).call
  #
  # ==Fun features
  #   - dry run
  #   - counters
  #   - repl on failed assert
  #   - automatically run in a transaction
  #
  # ==Plans for the future
  #   - include minitest assertions (or rspec?)
  #   - call these directly from rails migrations instead of going through
  #     a rake task.
  #   - automatically generate rake tasks from these transform classes
  class Base
    attr_accessor :counters, :dry_run, :repl_on_failed_assert
    cattr_accessor(:klass_counters) { [] }

    def initialize(dry_run: false, repl_on_failed_assert: false)
      self.dry_run = dry_run
      self.repl_on_failed_assert = repl_on_failed_assert
      self.counters = {}
      self.class.klass_counters.each { |counter| register_counter(counter) }
      @logger = ActiveSupport::TaggedLogging.new(Rails.logger)
    end

    def self.counter(*counter_names)
      self.klass_counters += counter_names
    end

    def call
      Paper.transaction do
        transform
        raise ActiveRecord::Rollback if dry_run
      end
    ensure
      log_counters
    end

    private

    def transform
      raise NotImplementedError
    end

    def assert(assertion, msg = nil)
      unless assertion
        if repl_on_failed_assert
          repl
        else
          raise AssertionFailed, msg
        end
      end
    end

    def log(message)
      @logger.tagged(self.class.name) { @logger.info(message) }
    end

    def log_counters
      log("**Counters**")
      counters.each do |counter_name, count|
        log("#{counter_name}: #{count}")
      end
    end

    def register_counter(counter_name)
      raise DuplicateCounterError if counters.key?(counter_name)
      counters[counter_name] = 0
    end

    def increment_counter(counter_name)
      raise UnknownCounterError unless counters.key?(counter_name)
      counters[counter_name] += 1
    end

    def repl
      # rubocop:disable Lint/Debugger
      # use "up" in pry session to go up frames
      binding.pry
      # rubocop:enable Lint/Debugger
    end
  end
end
