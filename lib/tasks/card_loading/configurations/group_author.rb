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
  class GroupAuthor
    def self.name
      "GroupAuthor"
    end

    def self.title
      "Group Author"
    end

    def self.content
      [
        {
          ident: "group-author--contributions",
          value_type: "question-set",
          text: "Author Contributions",
          children: [
            {
              ident: "group-author--contributions--conceptualization",
              value_type: "boolean",
              text: "Conceptualization"
            },
            {
              ident: "group-author--contributions--investigation",
              value_type: "boolean",
              text: "Investigation"
            },
            {
              ident: "group-author--contributions--visualization",
              value_type: "boolean",
              text: "Visualization"
            },
            {
              ident: "group-author--contributions--methodology",
              value_type: "boolean",
              text: "Methodology"
            },
            {
              ident: "group-author--contributions--resources",
              value_type: "boolean",
              text: "Resources"
            },
            {
              ident: "group-author--contributions--supervision",
              value_type: "boolean",
              text: "Supervision"
            },
            {
              ident: "group-author--contributions--software",
              value_type: "boolean",
              text: "Software"
            },
            {
              ident: "group-author--contributions--data-curation",
              value_type: "boolean",
              text: "Data Curation"
            },
            {
              ident: "group-author--contributions--project-administration",
              value_type: "boolean",
              text: "Project Administration"
            },
            {
              ident: "group-author--contributions--validation",
              value_type: "boolean",
              text: "Validation"
            },
            {
              ident: "group-author--contributions--writing-original-draft",
              value_type: "boolean",
              text: "Writing - Original Draft"
            },
            {
              ident: "group-author--contributions--writing-review-and-editing",
              value_type: "boolean",
              text: "Writing - Review and Editing"
            },
            {
              ident: "group-author--contributions--funding-acquisition",
              value_type: "boolean",
              text: "Funding Acquisition"
            },
            {
              ident: "group-author--contributions--formal-analysis",
              value_type: "boolean",
              text: "Formal Analysis"
            }
          ]
        },

        {
          ident: "group-author--government-employee",
          value_type: "boolean",
          text: "Is this group a United States Government agency, department or organization?"
        }
      ]
    end
  end
end
