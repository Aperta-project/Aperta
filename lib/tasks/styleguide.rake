namespace :styleguide do
  desc "Generate Live Styleguide"
  task generate: :environment  do
    system "rspec spec/features/harvest_styleguide.rb"
    system "ruby populate_styleguide.rb"
  end

  task watch: :environment do
    system('nodemon --exec "ruby populate_styleguide.rb" -w app/views/styleguide_template.hbs populate_styleguide.rb -V')
  end

  task hydrate: :environment do
    # This is the Styleguide `HYDRATION` File
    # It is responsible for retrieving elements from /doc/ux .html files
    # and updating the styleguide_template.html.erb
    #
    # See spec/features/harvest_styleguide.rb for more detail

    require 'cgi'
    require 'nokogiri'
    require 'pry'

    @styleguide_path = "app/views/styleguide_template.hbs"
    @populated_styleguide_path = "client/app/pods/styleguide/template.hbs"

    # Open the File
    styleguide_html = File.open(@styleguide_path, "r").read

    # loop all the source-page-names and set (or reset) the content
    # nodes = Nokogiri::HTML styleguide_html
    nodes = Nokogiri::HTML(styleguide_html) { |config| config.strict }
    element_nodes = nodes.css("*[source-page-name]")
    element_nodes.each do |ele|
      # ele.content = $RESET ? "" : get_content(ele)
      ele.content = get_content(ele)
    end

    # TODO maybe
    # nodes.css('.timestamp').first.content = Time.now.strftime("%A, %B %d, %Y, at %l:%M%P")

    # Write the unescaped html to file
    File.open(@populated_styleguide_path, "w") do |f|
      f << CGI::unescape_html(nodes.to_html)
    end
  end
end

def get_content(ele)
  # Grab arguments from the element
  name = ele['element-name']
  filename = ele['source-page-name']
  selector = ele['source-page-selector']
  necessary_context = ele['source-page-selector-context']

  # Open the .html filenamee
  html = File.open("doc/ux/#{filename}.html", "r").read
  nodes = Nokogiri::HTML(html)

  # Find a snippet of .html based on the text
  selection = nodes.css(selector).first.to_html

  # Wrap the selection in a div with the class or ID
  if necessary_context
    fragment = Nokogiri::HTML.fragment("<div></div>")
    wrapper_div = fragment.css("div").first

    wrapper_div.content = selection

    # add the ID or class if it was specified
    if necessary_context[0] == "#" # i'm a CSS id
      wrapper_div[:id] = necessary_context[1..-1]
    end

    if necessary_context[0] == "." # i'm a CSS class
      wrapper_div[:class] = necessary_context[1..-1] # ignore the first character (. | #)
    end

    selection = CGI::unescape_html wrapper_div.to_html
  end

  # return that snippet of markup
  return selection
rescue => e
  p e.inspect
  p "Error: Could not open `#{name}` in `#{filename}` with selector `#{selector}`"
end

# Wrap the html in a toggle-able code block
def in_code_block(html)
  seed = "collapse-#{rand(10000)}"

  s = "<div class=row>"
  s << "<div class=col-md-12>"
  s << "<button class='btn btn-primary' data-toggle=collapse href=##{seed} aria-expanded=false aria-controls=#{seed}>Show Source</button>"
  s << "<div class=collapse id=#{seed}>"
  s << "<pre>#{CGI::escape_html(html)}</pre>"
  s << "</div>"
  s << "</div>"
  s << "</div>"
  s
end
