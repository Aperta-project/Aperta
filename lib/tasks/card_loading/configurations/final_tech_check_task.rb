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
  class FinalTechCheckTask
    def self.name
      "PlosBioTechCheck::FinalTechCheckTask"
    end

    def self.title
      "Plos Bio Final Tech Check Task"
    end

    def self.content
      [
        {
          ident: "plos_bio_final_tech_check--open_rejects",
          value_type: "boolean",
          text: "Check Section Headings of all new submissions (including Open Rejects). Should broadly follow: Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References, Acknowledgements, and Figure Legends."
        },

        {
          ident: "plos_bio_final_tech_check--human_subjects",
          value_type: "boolean",
          text: "Check the ethics statement - does it mention Human Participants? If so, flag this with the editor in the discussion below."
        },

        {
          ident: "plos_bio_final_tech_check--ethics_needed",
          value_type: "boolean",
          text: "Check if there are any obvious ethical flags (mentions of animal/human work in the title/abstract), check that there's an ethics statement. If not, ask the authors about this."
        },

        {
          ident: "plos_bio_final_tech_check--data_available",
          value_type: "boolean",
          text: "Is the data available? If not, or it's only available by contacting an author or the institution, make a note in the discussion below."
        },

        {
          ident: "plos_bio_final_tech_check--supporting_information",
          value_type: "boolean",
          text: "If author indicates the data is available in Supporting Information, check to make sure there are Supporting Information files in the submission (don't need to check for specifics at this stage)."
        },

        {
          ident: "plos_bio_final_tech_check--dryad_url",
          value_type: "boolean",
          text: "If the author has mentioned Dryad in their Data statement, check that they've included the Dryad reviewer URL. If not, make a note in the discussion below."
        },

        {
          ident: "plos_bio_final_tech_check--financial_disclosure",
          value_type: "boolean",
          text: "If Financial Disclosure Statement is not complete (they've written N/A or something similar), message author."
        },

        {
          ident: "plos_bio_final_tech_check--tobacco",
          value_type: "boolean",
          text: "If the Financial Disclosure Statement includes any companies from the Tobacco Industry, make a note in the discussion below."
        },

        {
          ident: "plos_bio_final_tech_check--figures_legible",
          value_type: "boolean",
          text: "If any figures are completely illegible, contact the author."
        },

        {
          ident: "plos_bio_final_tech_check--cited",
          value_type: "boolean",
          text: "If any files or figures are cited but not included in the submission, message the author."
        },

        {
          ident: "plos_bio_final_tech_check--cover_letter",
          value_type: "boolean",
          text: "Have the authors asked any questions in the cover letter? If yes, contact the editor/journal team."
        },

        {
          ident: "plos_bio_final_tech_check--billing_inquiries",
          value_type: "boolean",
          text: "Have the authors mentioned any billing information in the cover letter? If yes, contact the editor/journal team."
        },

        {
          ident: "plos_bio_final_tech_check--ethics_statement",
          value_type: "boolean",
          text: "If an Ethics Statement is present, make a note in the discussion below."
        }
      ]
    end
  end
end
