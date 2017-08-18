# Make faker deterministic
Faker::Config.random = Random.new(RSpec.configuration.seed) if Rails.env.test?
