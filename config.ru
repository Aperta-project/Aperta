# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application

if ENV['PRINT_OBJECT_COUNT']
  Thread.new do
    while true do
      print "OBJECT COUNTS:"
      ObjectSpace.count_objects.each do |k, v|
        print " #{k}:#{v}"
      end
      print "\n"
      sleep 60
    end
  end
end
