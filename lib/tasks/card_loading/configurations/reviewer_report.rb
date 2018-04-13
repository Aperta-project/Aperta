# coding: utf-8

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
  class ReviewerReport
    def self.name
      "ReviewerReport"
    end

    def self.title
      "Reviewer Report"
    end

    def self.content
      [
        {
          ident: 'reviewer_report--decision_term',
          value_type: 'text',
          text: 'Please provide your publication recommendation:'
        },

        {
          ident: "reviewer_report--competing_interests",
          value_type: "boolean",
          text: "Do you have any potential or perceived competing interests that may influence your review?",
          children: [
            {
              ident: "reviewer_report--competing_interests--detail",
              value_type: "html",
              text: "Comment"
            }
          ]
        },

        {
          ident: "reviewer_report--identity",
          value_type: "html",
          text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here."
        },

        {
          ident: "reviewer_report--comments_for_author",
          value_type: "html",
          text: "Please add your review comments to authors below."
        },

        {
          ident: "reviewer_report--additional_comments",
          value_type: "html",
          text: "(Optional) If you have any additional confidential comments to the editor, please add them below."
        },

        {
          ident: "reviewer_report--suitable_for_another_journal",
          value_type: "boolean",
          text: "If the manuscript does not meet the standards of <em>PLOS Biology</em>, do you think it is suitable for another <a href='https://www.plos.org/publications'><em>PLOS</em> journal</a> with only minor revisions?",
          children: [
            {
              ident: "reviewer_report--suitable_for_another_journal--journal",
              value_type: "html",
              text: "Other Journal"
            }
          ]
        },

        {
          ident: "reviewer_report--attachments",
          value_type: "html",
          text: "(Optional) If you'd like to include files to support your review, please attach them here.<p>Please do NOT attach your review comments here as a separate file.<br>Instead, paste your review into the text fields provided above. Attachments should only be for supporting documents."
        }
      ]
    end
  end
end
