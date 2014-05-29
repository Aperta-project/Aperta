module JournalServices
  class ServiceError < StandardError; end

  class BaseService

    # Because this service is being called inside an activerecord callback
    # any RecordInvalid exception that might be raised is being caught and squashed
    # by the save method. We need to reraise something that will be noisy.
    # This will still cause rollback to happen.
    def self.with_noisy_errors
      yield
    rescue ActiveRecord::RecordInvalid => e
      raise ServiceError.new(e)
    end
  end
end

