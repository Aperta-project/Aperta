# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class CompetingInterest < Base
      def self.name
        "Competing Interests"
      end

      def self.excluded_view_permissions
      end

      def self.excluded_edit_permissions
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
          <card required-for-submission="true" workflow-display-only="false">
            <content content-type="display-children">
              <content content-type="radio" value-type="text" ident="competing_interests--has_competing_interests">
                <text>
                  <![CDATA[<ol class="question-list"><li class="question"><div class="question-text"><p>You are responsible for recognizing and disclosing on behalf of all authors any competing interest that could be perceived to bias their work, acknowledging all financial support and any other relevant financial or non-financial competing interests.</p>Do any authors of this manuscript have competing interests (as described in the <a target="_blank" href="http://journals.plos.org/plosbiology/s/competing-interests">PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?</div></li>]]>
                </text>
                <possible-value label="Yes" value="t"/>
                <possible-value label="No" value="f"/>
                <content content-type="display-with-value" visible-with-parent-answer="t">
                  <content content-type="field-set">
                    <content content-type="paragraph-input" value-type="html" ident="competing_interests--statement">
                      <text>Please provide details about any and all competing interests in the box below. Your response should begin with this statement: "I have read the journal's policy and the authors of this manuscript have the following competing interests.</text>
                    </content>
                  </content>
                </content>
                <content content-type="display-with-value" visible-with-parent-answer="f">
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
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
