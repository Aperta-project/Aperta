# Include this module to have a green rotating spinner for your cli rake tasks
module Spinner
  def spin_it(times)
    pinwheel = %w(| / - \\)
    times.times do
      print "\r"
      print "\b" + "\e[32m" + pinwheel.rotate!.first + "\e[0m"
      sleep(0.1)
      print "\r"
    end
  end
end
