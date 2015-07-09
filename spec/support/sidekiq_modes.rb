RSpec.configure do |config|
  config.before(:example, :sidekiq => :inline!) do
    @sidekiq_mode = Sidekiq::Testing.__test_mode
    Sidekiq::Testing.inline!
  end

  config.after(:example, :sidekiq => :inline!) do
    reset_mode = @sidekiq_mode.presence || "fake"
    Sidekiq::Testing.send("#{reset_mode}!")
  end
end
