# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class DataAvailability < Base
      def self.name
        "Data Availability"
      end

      def self.view_role_names
        ["Academic Editor", "Billing Staff", "Collaborator", "Cover Editor", "Creator", "Handling Editor", "Internal Editor", "Production Staff", "Publishing Services", "Reviewer", "Staff Admin"]
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
              <text>PLOS journals require authors to make all data underlying the findings described in their manuscript fully available, without restriction and from the time of publication, with only rare exceptions to address legal and ethical concerns (see the PLOS Data Policy and FAQ for further details). When submitting a manuscript, authors must provide a Data Availability Statement that describes where the data underlying their manuscript can be found.</text>
            </content>
            <content content-type="text">
              <text>Your answers to the following constitute your statement about data availability and will be included with the article in the event of publication. Please note that simply stating ‘data available on request from the author’ is not acceptable. If, however, your data are only available upon request from the author(s), you must answer “No” to the first question below, and explain your exceptional situation in the text box provided.</text>
            </content>
            <content content-type="display-children" child-tag="li" custom-class="question-list" custom-child-class="question" wrapper-tag="ol">
              <content content-type="text">
                <text>
                  <![CDATA[<div class="question-text">Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?</div>]]>
                </text>
                <content content-type="display-children" child-tag="li" custom-class="question-help" custom-child-class="item" wrapper-tag="ul">
                  <content content-type="text">
                    <text>
                      <![CDATA[Please see the <a target="_blank" href="http://journals.plos.org/plosbiology/s/data-availability" title="PLOS Data Policy">PLOS Data Policy</a> for details.]]>
                    </text>
                  </content>
                </content>
                <content ident="data_availability--data_fully_available" content-type="radio" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Is the data available as specified?</text>
                </content>
              </content>
              <content content-type="text">
                <text>
                  <![CDATA[<div class="question-text">Your answers should be entered into the box below and will be published in the form you provide them, if your manuscript is accepted. If you are copying our sample text below, please ensure you replace any instances of XXX with the appropriate details.</div>]]>
                </text>
                <content content-type="display-children" child-tag="li" custom-class="question-help" custom-child-class="item" wrapper-tag="ul">
                  <content content-type="text">
                    <text>If your data are all contained within the paper and/or Supporting Information files, please state this in your answer below. For example, "All relevant data are within the paper and its Supporting Information files."</text>
                  </content>
                  <content content-type="text">
                    <text>If your data are held or will be held in a public repository, include URLs, accession numbers or DOIs. For example, "All XXX files are available from the XXX database (accession number(s) XXX, XXX)." If this information will only be available after acceptance, please indicate this by ticking the box below.</text>
                  </content>
                  <content content-type="text">
                    <text>If neither of these applies but you are able to provide details of access elsewhere, with or without limitations, please do so in the box below. For example:</text>
                  </content>
                  <content content-type="display-children" child-tag="li" custom-class="question-help" custom-child-class="left-indent" wrapper-tag="ul">
                    <content content-type="text">
                      <text>"Data are available from the XXX Institutional Data Access / Ethics Committee for researchers who meet the criteria for access to confidential data."</text>
                    </content>
                    <content content-type="text">
                      <text>"Data are from the XXX study whose authors may be contacted at XXX."</text>
                    </content>
                  </content>
                </content>
                <content ident="data_availability--data_location" content-type="paragraph-input" value-type="html" allow-annotations="false" required-field="false">
                  <text>Please describe where your data may be found, writing in full sentences.</text>
                </content>
              </content>
              <content content-type="text">
                <text>
                  <![CDATA[<div class="question-text">Additional Data Availability information</div>]]>
                </text>
                <content ident="data_availability--additional_information_doi" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Tick here if the URLs/accession numbers/DOIs will be available only after acceptance of the manuscript for publication so that we can ensure their inclusion before publication.</text>
                </content>
                <content ident="data_availability--additional_information_other" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Tick here if your circumstances are not covered by the content above and you need the journal’s help to make your data available.</text>
                </content>
              </content>
            </content>
          </content>
        </card>
        XML
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
