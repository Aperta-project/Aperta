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
    histogram.sort_by { |k,v| -histogram[k][:usage_count] }.each do |k,v|
      if core_components.include?(k)
        puts "\t(#{v[:usage_count]}) #{k}"
        v[:usage_files].each do |f|
          puts "\t\t#{f}"
        end
      end
    end
  end
end
