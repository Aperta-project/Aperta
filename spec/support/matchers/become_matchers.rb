RSpec::Matchers.define :become do |expected|
  supports_block_expectations

  match do |block|
    begin
      Timeout.timeout(Capybara.default_max_wait_time) do
        value = block.call
        while value != expected
          sleep(0.1)
          value = block.call
        end
        value
      end
    rescue Timeout::Error
      false
    end
  end
end
