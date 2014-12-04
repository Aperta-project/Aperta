#!/bin/sh

# you may have some gems you need to install, or tests to migrate.
bin/bigrate

#
# acts almost like a CI server, for when you want to run the tests locally,
# because you know they will run faster.
#

CMD1="bundle exec rake teaspoon; say done-teaspoon"
osascript <<END
tell application "iTerm"
 tell the first terminal
  launch session "Default Session"
  tell the last session
   write text "cd \"`pwd`\";$CMD1"
  end tell
 end tell
end tell
END

CMD2="bundle exec rspec spec engines --format=documentation; say done-r-spec"
osascript <<END
tell application "iTerm"
 tell the first terminal
  launch session "Default Session"
  tell the last session
   write text "cd \"`pwd`\";$CMD2"
  end tell
 end tell
end tell
END
