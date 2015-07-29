# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

tahi = <<END


       d8888                           888
      d88888                           888
     d88P888                           888
    d88P 888 88888b.   .d88b.  888d888 888888  8888b.
   d88P  888 888 "88b d8P  Y8b 888P"   888        "88b
  d88P   888 888  888 88888888 888     888    .d888888
 d8888888888 888 d88P Y8b.     888     Y88b.  888  888
d88P     888 88888P"   "Y8888  888      "Y888 "Y888888
             888
             888
             888


END

puts tahi
