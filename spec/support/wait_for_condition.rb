class Capybara::Session
  # Helpful if you're facing an issue where the Capybara thread is waiting on
  # the Rails thread. For example: Rails writes to the DB, but the
  # transaction result isn't immediately visible to the Capybara
  # thread/connection.

  def wait_for_condition(loop_sleep = 0.001, &blk)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        break if yield blk
        sleep(loop_sleep)
      end
    end
  end
end

module WaitForCondition
  def wait_for_condition(loop_sleep = 0.001,
                         session = Capybara.current_session,
                         &block)
    session.wait_for_condition(loop_sleep, &block)
  end
end

RSpec.configure do |config|
  config.include WaitForCondition, type: :feature
end
