require 'English'
CLIENT_DIR = File.join("..", "..", "client", "app")

class SourceFile
  def initialize(file_type, path)
    @file_type = file_type
    @original_path = path
  end

  def ensure_dir
    "mkdir -p #{File.dirname(pod_dir)}"
  end

  def git_mv
    "git mv #{@original_path} #{pod_dir}"
  end

  def pod_dir
    raise NotImplementedError
  end
end

class JsFile < SourceFile
  # "../../client/app/services/foo/bar.js"
  # "../../client/app/pods/foo/bar/service.js"
  def pod_dir
    pod_name = @original_path.chomp(".js").split("/").drop(5) # remove ../../client/app/<%type %>
    if @file_type == "component"
      File.join(CLIENT_DIR, "pods", "components", pod_name, @file_type + ".js")
    else
      File.join(CLIENT_DIR, "pods", pod_name, @file_type + ".js")
    end
  end
end

class TemplateFile < SourceFile
  def normalize_partial(name_arr)
    name_arr.last.gsub!(/^[-_]/, "")
    name_arr
  end

  def pod_dir
    pod_name = @original_path.chomp(".hbs").split("/").drop(5) # remove ../../client/app/templates/
    pod_name = normalize_partial(pod_name)

    if pod_name[0] == "components"
      File.join(CLIENT_DIR, "pods", "components", pod_name.drop(1), @file_type + ".hbs")
    else
      File.join(CLIENT_DIR, "pods", pod_name, @file_type + ".hbs")
    end
  end
end

# From https://ember-cli.com/generators-and-blueprints#pods
# The built-in blueprints that support pods structure are:
# adapter
# component
# controller
# model
# route
# resource
# serializer
# service
# template
# transform
# view

# Pluralize those and use them as sources

def initialize_files
  {
    "adapter" => "*.js",
    "component" => "*.js",
    "controller" => "*.js",
    "model" => "*.js",
    "route" => "*.js",
    "serializer" => "*.js",
    "service" => "*.js",
    "template" => "*.hbs",
    "transform" => "*.js",
    "view" => "*.js"
  }.flat_map do |type, extension|
    glob = File.join(CLIENT_DIR, type + "s", "**", extension)
    files = Dir.glob(glob)
    if type == "template"
      files.map { |f| TemplateFile.new(type, f) }
    else
      files.map { |f| JsFile.new(type, f) }
    end
  end
end

FILE_NAME = "move-pods.sh".freeze
def write_move_script
  files = initialize_files
  puts "Moving #{files.count} files"
  File.open(FILE_NAME, "w") do |f|
    initialize_files.each do |i|
      f.write(i.ensure_dir + "\n")
      f.write(i.git_mv + "\n")
    end
  end
  puts "Done"
end

case ARGV[0]
when "check"
  write_move_script
  puts "open #{FILE_NAME} to see what will be done"
when "run"
  puts "Creating script..."
  write_move_script
  puts "Moving files..."
  system "sh ./#{FILE_NAME}"
  if $CHILD_STATUS.exitstatus.zero?
    puts "Success!"
    system "rm ./#{FILE_NAME}"
  else
    puts "Failure! Check #{FILE_NAME} for problems"
  end
else
  puts "Usage: ruby #{__FILE__} {check|run}"
end
