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
# This model has been deprecated as part of APERTA-10460 and once this work has
# been merged into production, it can be deleted.  This is here to ease the
# testing forpec/lib/custom_card/financial_disclosure_migrator_spec.rb
#

module CardConfiguration
  module NonstandardConfigurations
    class Funder
      def self.name
        "TahiStandardTasks::Funder"
      end

      def self.title
        "Funder"
      end

      def self.content
        [
          {
            ident: "funder--had_influence",
            value_type: "boolean",
            text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
            children: [
              {
                ident: "funder--had_influence--role_description",
                value_type: "text",
                text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript."
              }
            ]
          }
        ]
      end
    end
  end
end
