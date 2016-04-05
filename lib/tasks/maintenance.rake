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

  desc "Capture screenshots of all pages in Tahi"
  task :screenshot => :environment do |task, args|
    return unless Rails.env.development?
    require 'auto_screenshot'

    options = {}
    o = OptionParser.new
    o.on("--url URL") { |url|
      options[:url] = url
    }
    args = o.order!(ARGV) {}
    o.parse!(args)

    base_path = options[:url] || "http://localhost:5000"

    # TODO: update this list of urls when new urls are added to Tahi
    urls = [
      "/users/sign_up",
      "/users/password/new",
      "/users/sign_in",
      "/",

      "/profile",

      "/papers/1/edit",
      "/papers/1/edit/discussions",
      "/papers/1/edit/discussions/new",
      "/papers/1/workflow",

      # Tasks
      "/papers/1/tasks/1",
      "/papers/1/tasks/2",
      "/papers/1/tasks/3",
      "/papers/1/tasks/4",
      "/papers/1/tasks/5",

      "/paper_tracker",

      "/admin/journals",
      "/admin/journals/1",
      "/admin/journals/1/manuscript_manager_templates/1/edit"
    ]

    urls = urls.map { |url| "#{base_path}#{url}" }
    client = AutoScreenshot::Screenshot.new(urls: urls)
    client.action_map = {
      "#{base_path}/sign_in" => :wait
    }
    client.go
  end
end
