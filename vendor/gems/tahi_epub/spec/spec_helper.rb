require 'bundler/setup'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'tahi_epub'
require 'fog'
require 'pry'

ENV["AWS_ACCESS_KEY_ID"] = "fake access id"
ENV["AWS_SECRET_ACCESS_KEY"] = "fake access key"
ENV["AWS_REGION"] = "fake region"
ENV["S3_BUCKET"] = "fake bucket"

RSpec.configure do |config|
  # Configuration goes here
end
