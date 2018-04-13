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

namespace :maintenance do
  desc "List all Ember components used by Tahi"
  task :list_ember_components => :environment do
    core_ember_helpers = ["link-to", "bind-attr"]
    core_hbs_helpers = Dir.glob("client/app/helpers/*.{coffee,js}").map do |fp|
      File.basename(fp, ".*")
    end
    core_components = Dir.glob("client/app/pods/components/*").
                          select {|f| File.directory?(f) }.map do |fp|
      File.basename(fp)
    end

    black_list = core_ember_helpers + core_hbs_helpers
    histogram = Hash.new do |h,k|
      h[k] = { usage_count: 0, usage_files: [] }
    end

    Dir.glob("client/app/**/*.hbs").each do |f|
      histogram = File.open(f, "r").readlines.each_with_object(histogram) do |line, histogram|
        if line =~ /{{#?([a-z0-9]+-{1}[a-z\-0-9]*)/ && !black_list.include?($1)
          component = histogram[$1.strip]
          component[:usage_count] += 1
          component[:usage_files] << f
        end
      end
    end

    puts "# Component Usage Report"
    puts "\n"
    puts "Total Defined in Core : #{core_components.length}"
    puts "Used in core : #{histogram.keys.length}"
    puts "\n### Externally defined"
    (histogram.keys - core_components).each do |external_component|
      puts "\t#{external_component}"
    end
    puts "\n### Unused (or used elsewhere)"
    core_components.reject { |c| histogram.keys.include?(c) }.each do |unused_component|
      puts "\t#{unused_component}"
    end
    puts "\n### Usage frequency"
    histogram.sort_by { |k,_v| -histogram[k][:usage_count] }.each do |k,v|
      if core_components.include?(k)
        puts "\t(#{v[:usage_count]}) #{k}"
        v[:usage_files].each do |f|
          puts "\t\t#{f}"
        end
      end
    end
  end
end
