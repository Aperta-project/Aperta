# This is the Styleguide `HYDRATION` File
# It is responsible for retrieving elements from /doc/ux .html files
# and updating the styleguide2.html.erb
#
# See spec/features/populate_styleguide.rb for more detail

require 'cgi'
require 'nokogiri'
require 'pry'

# $RESET = true
# $RESET = false
@styleguide_path = "app/views/kss/home/styleguide2.html.erb"

def get_content(ele)
  # Grab arguments from the element
  name = ele['element-name']
  filename = ele['source-page-name']
  selector = ele['source-page-selector']
  necessary_context = ele['source-page-selector-context']
  text = ele.text

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

    if necessary_context[0] == "." # i'm a CSS css
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

def init
  # Open the File
  @styleguide_path = "app/views/kss/home/styleguide2.html.erb"
  @populated_styleguide_path = "app/views/kss/home/styleguide3.html.erb"

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

init
