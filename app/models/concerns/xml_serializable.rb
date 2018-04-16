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

require 'builder'

# Helper methods for xml serialization
module XmlSerializable
  extend ActiveSupport::Concern

  # PrettyMarkup promotes the _indent method of the parent class
  # Builder::XmlMarkup from private to public so it can be used to
  # properly format the xml content for custom cards that
  # contain raw html elements. The _indent method is called
  # by raw_dump_text. This is the best solution I could think of
  # to resolve this formatting problem.
  class PrettyMarkup < ::Builder::XmlMarkup
    def _indent
      super
    end
  end

  included do
    def setup_builder(options)
      options[:indent] ||= 2
      options[:builder] ||= PrettyMarkup.new(indent: options[:indent])
      options[:builder].instruct! unless options[:skip_instruct]
      options[:builder]
    end

    # Dump text into an element. If the text contains & or < , wrap the content
    # in a CDATA section.
    def safe_dump_text(builder, tag, text)
      if text =~ /(<|&)/
        builder.tag!(tag) { builder.cdata! text }
      else
        builder.tag!(tag, text)
      end
    end

    def raw_dump_text(builder, tag, text)
      # calling _indent fixes the pretty formatting
      builder._indent
      builder << "<#{tag}>"
      builder << text
      builder << "</#{tag}>\n"
    end
  end
end
