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

# This class defines the specific attributes of a particular Card and it can be
# used to create a new valid Card into the system.  The `content` can be used
# to create CardContent for the Card.
#
module CardConfiguration
  class ProductionMetadataTask
    def self.name
      "TahiStandardTasks::ProductionMetadataTask"
    end

    def self.title
      "Production Metadata Task"
    end

    def self.content
      [
        {
          ident: "production_metadata--publication_date",
          value_type: "text",
          text: "Publication Date"
        },

        {
          ident: "production_metadata--volume_number",
          value_type: "text",
          text: "Volume Number"
        },

        {
          ident: "production_metadata--issue_number",
          value_type: "text",
          text: "Issue Number"
        },

        {
          ident: "production_metadata--provenance",
          value_type: "text",
          text: "Provenance"
        },

        {
          ident: "production_metadata--production_notes",
          value_type: "html",
          text: "Production Notes"
        },

        {
          ident: "production_metadata--special_handling_instructions",
          value_type: "html",
          text: "Special Handling Instructions"
        }
      ]
    end
  end
end
