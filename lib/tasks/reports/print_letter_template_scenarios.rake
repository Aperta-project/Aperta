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

require 'set'

def print_merge_fields(fields, level = 0)
  fields.each do |field|
    print '__' * level, field[:name]
    print '[]' if field[:is_array]
    print "\n"
    print_merge_fields(field[:children], level + 1) if field[:children]
  end
end

def get_all_nodes(klass, nodes)
  return nodes if nodes[klass]
  simple_fields = klass.merge_fields.map { |f| f[:name] }
  context_fields = []
  links = MergeField.subcontexts_for(klass).map do |cname, ctx|
    type = TemplateContext.class_for(ctx[:type] || cname)
    context_fields.push "#{cname} <font color='grey60'>#{type}</font>"
    simple_fields.delete cname
    type
  end
  nodes[klass] = {
    fields: simple_fields,
    contexts: context_fields,
    links: links
  }
  links
    .map { |link| get_all_nodes(link, nodes) }
    .reduce(nodes, :merge)
end

namespace :reports do
  task print_letter_template_scenarios: :environment do
    TemplateContext.scenarios.each do |name, klass|
      puts "\n#{name}"
      print_merge_fields(klass.merge_fields)
    end
  end
end

namespace :reports do
  task make_letter_template_scenario_diagrams: :environment do
    header = <<HEADER.strip_heredoc
  digraph ScenariosAndContexts {
  node[shape = "Mrecord", fontsize = "10", fontname = "ArialMT", margin = "0.07,0.05", penwidth = "1.0"];
  edge[ fontname  =  "ArialMT" , fontsize  =  "7" , dir  =  "both" , arrowsize  =  "0.9" , penwidth  =  "1.0" , labelangle  =  "32" , labeldistance  =  "1.8"];
HEADER
    puts header
    nodes = TemplateContext.scenarios
      .map { |_, klass| get_all_nodes(klass, {}) }
      .reduce({}, :merge)
    links = ""
    nodes.each do |name, params|
      table = '<table border="0" align="center" cellspacing="0.5" cellpadding="0">'
      table += "<tr><td align=\"center\" valign=\"bottom\">#{name}</td></tr>"
      table += '</table>'
      table += '|'
      unless params[:contexts].empty?
        table += '<table border="0" align="left" cellspacing="2" cellpadding="0">'
        params[:contexts].each do |ctx|
          table += "<tr><td align=\"left\">#{ctx}</td></tr>"
        end
        table += '</table>'
      end
      table += '|'
      unless params[:fields].empty?
        table += '<table border="0" align="left" cellspacing="2" cellpadding="0">'
        params[:fields].each do |field|
          table += "<tr><td align=\"left\">#{field}</td></tr>"
        end
        table += '</table>'
      end
      puts "#{name} [label = <{#{table}}>];\n"
      unless params[:links].empty?
        links += "#{name} -> {#{params[:links].join(' ')}} [arrowhead = \"normal\", arrowtail=\"none\", weight=\"1\"];\n"
      end
    end
    puts links
    puts '}'
  end
end
