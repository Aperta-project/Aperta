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
