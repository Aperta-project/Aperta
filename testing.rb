#
# This is the Styleguide `Hydration` File
# It is responsible for retrieving elements from /docs/ux
# And updating the styleguide.html
#
require 'nokogiri'
require 'pry'

def get_content(ele)
  # Grab arguments from the element
  name = ele['element-name']
  filename = ele['source-page-name']
  selector = ele['source-page-selector']
  text = ele.text

  # Open the .html filenamee
  html = File.open("docs/ux/#{filename}.html", "r").read
  nodes = Nokogiri::HTML(html)

  # Find a snippet of .html based on the text
  selection = nodes.css(selector).to_html

  # return that snippet of markup
  p "GOOD"
  return selection
rescue => e
  p "Error: Could not open `#{name}` with selector `#{selector}`"
end


# def initialize
# end

styleguide_html = File.open("docs/styleguide.html", "r").read
nodes = Nokogiri::HTML styleguide_html

element_nodes = nodes.css("*[source-page-name]")

element_nodes.each do |ele|
  # ele.content = "yes"
  ele.content = get_content(ele)

  p ele['element-name'],
    ele['source-page-name'],
    ele['source-page-selector'],
    ele.text,
    "----------------------------------------------------"

  # ele.text =
end

File.open("docs/styleguide.html", "w") do |f|
  f << nodes.to_html
end

# def get_attrs(ele)
#   {
#     name: ele['element-name'],
#     filename: ele['source-page-name'],
#     selector: ele['source-page-selector'],
#     text: ele.text
#   }
# end
