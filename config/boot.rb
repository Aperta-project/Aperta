# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

tahi = <<END


88888888888       888      d8b 
    888           888      Y8P 
    888           888          
    888   8888b.  88888b.  888 
    888      '88b 888 '88b 888 
    888  .d888888 888  888 888 
    888  888  888 888  888 888 
    888  'Y888888 888  888 888 


END

puts tahi
