# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class CoverLetter < Base
      def self.name
        "Cover Letter"
      end

      def self.view_role_names
        ["Academic Editor", "Billing Staff", "Collaborator", "Cover Editor", "Creator", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Staff Admin"]
      end

      def self.edit_role_names
        ["Collaborator", "Cover Editor", "Creator", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Staff Admin"]
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        false
      end

      def self.xml_content
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <card required-for-submission="false" workflow-display-only="false">
            <content content-type="display-children">
              <content content-type="text">
                <text>To be of most use to editors, we suggest your letter could address the following questions:</text>
              </content>
              <content content-type="text">
                <text>
                  <![CDATA[<ul>
                    <li>What is the scientific question you are addressing?</li>
                    <li>What is the key finding that answers this question?</li>
                    <li>What is the nature of the evidence you provide in support of your conclusion?</li>
                    <li>What are the three most recently published articles that are relevant to this question?</li>
                    <li>What significance do your results have for the field?</li>
                    <li>What significance do your results have for the broader community (of biologists and/or the public)?</li>
                    <li>What other novel findings do you present?</li>
                    <li>Is there additional information that we should take into account?</li>
                  </ul>]]>
                </text>
              </content>
              <content content-type="paragraph-input" value-type="html" ident="cover_letter--text">
                <text>In your cover letter, please list any scientists whom you request be excluded from the assessment process along with a justification. You may also suggest experts appropriate to be considered as Academic Editors for your manuscript. Please be aware that your cover letter may be seen by members of the Editorial Board. For Research articles, if our initial assessment is positive, we will request further information, including Reviewer Candidates and Competing Interests. For other submission types, if the Reviewer Candidate and Competing Interests cards are already visible to you, please complete them now with the relevant information.</text>
              </content>
              <content content-type="file-uploader" value-type="attachment" ident="cover_letter--attachment" allow-multiple-uploads="true" allow-file-captions="true">
                <label>Attach File</label>
                <possible-value label="doc" value=".doc"/>
                <possible-value label="docx" value=".docx"/>
                <possible-value label="pdf" value=".pdf"/>
              </content>
            </content>
          </card>
        XML
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
