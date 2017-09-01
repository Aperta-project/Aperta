# rubocop:disable Metrics/BlockLength
namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11101: Convert fields to use inline-editor

      11101 is for changing a handful of card fields to use the TinyMCE inline
      style, to strip surround paragraph tags, br tags, and newlines. Two of
      the identified fields appeared in custom cards, one in Data Availability,
      the other in Competing Interests. This data migration publishes a new
      card version for both of those cards, altering the ideintified fields
      to use editor-style="inline"
    DESC

    task aperta_11101_change_competing_interests_and_data_availability_fields_to_inline_editor_style: :environment do
      def convert(name, xml)
        cards = Card.where(name: name)
        raise Exception, "No #{name} cards were found." if cards.empty?
        before_count = cards.count
        cards.each do |card|
          card.xml = xml
          card.publish!('Changing field to use editor-style="inline"')
        end
        after_count = Card.where(name: name).select { |card| card.to_xml.match /editor-style="inline"/ }.length
        raise Exception, "Not all cards were updated, rolling back." if after_count != before_count
      end

      competing_interests_xml =
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <card required-for-submission="true" workflow-display-only="false">
            <content content-type="display-children">
              <content content-type="radio" value-type="boolean" ident="competing_interests--has_competing_interests">
                <text>
                  <![CDATA[<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.</p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http://journals.plos.org/plosbiology/s/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?</div></li>]]>
                </text>
                <content content-type="display-with-value" visible-with-parent-answer="true">
                  <content content-type="field-set">
                    <content content-type="paragraph-input" value-type="html" editor-style="inline" ident="competing_interests--statement">
                      <text>
                        <![CDATA[Please provide details about any and all competing interests in the box below. Your response should begin with this statement: "I have read the journal's policy and the authors of this manuscript have the following competing interests."<br><br>Please note that if your manuscript is accepted, this statement will be published.]]>
                      </text>
                    </content>
                  </content>
                </content>
                <content content-type="display-with-value" visible-with-parent-answer="false">
                  <content content-type="field-set">
                    <content content-type="text">
                      <text>Your competing interests statement will appear as: "The authors have declared that no competing interests exist."
          Please note that if your manuscript is accepted, this statement will be published.</text>
                    </content>
                  </content>
                </content>
              </content>
            </content>
          </card>
        XML

      data_availability_xml =
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
                  <content ident="data_availability--data_fully_available" content-type="radio" value-type="boolean">
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
                  <content ident="data_availability--data_location" content-type="paragraph-input" value-type="html" editor-style="inline">
                  </content>
                </content>
                <content content-type="text">
                  <text>
                    <![CDATA[<div class="question-text">Additional Data Availability information</div>]]>
                  </text>
                  <content ident="data_availability--additional_information_doi" content-type="check-box" value-type="boolean">
                    <label>Tick here if the URLs/accession numbers/DOIs will be available only after acceptance of the manuscript for publication so that we can ensure their inclusion before publication.</label>
                  </content>
                  <content ident="data_availability--additional_information_other" content-type="check-box" value-type="boolean">
                    <label>Tick here if your circumstances are not covered by the content above and you need the journal’s help to make your data available.</label>
                  </content>
                </content>
              </content>
            </content>
          </card>
        XML

      Card.transaction do
        convert("Competing Interests", competing_interests_xml)
        convert("Data Availability", data_availability_xml)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
