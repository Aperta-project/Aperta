# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require "English"

namespace :circleci do
  desc "Run Ember tests split across CircleCI containers"
  task :qunit do
    node_index = ENV["CIRCLE_NODE_INDEX"]
    node_total = ENV["CIRCLE_NODE_TOTAL"]
    reports_dir = ENV["CIRCLE_TEST_REPORTS"]
    Dir.chdir "client" do
      output = `./node_modules/.bin/ember test --query "workerIndex=#{node_index}&numWorkers=#{node_total}" --silent -r xunit`
      status = $CHILD_STATUS.exitstatus
      File.open(File.join(reports_dir, 'qunit.xml'), 'w') do |f|
        # qunit mangles XML output. Fix it.
        in_garbage = false
        output.lines.each do |line|
          next if line =~ /^Warning/
          if line =~ /^{ \[?Error/
            in_garbage = true # Starting a garbage section.
            next
          end
          if in_garbage
            next unless line =~ /^</ # Got a <, probably out of the garbage and into XML again
            in_garbage = false
          end
          f << line
        end
      end
      # Return the proper exit status to circleci
      exit(status)
    end
  end
end
