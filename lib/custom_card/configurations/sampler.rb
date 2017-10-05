# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class Sampler < Base
      def self.name
        "Card Configuration Sampler"
      end

      def self.view_role_names
        :all
      end

      def self.edit_role_names
        :all
      end

      def self.view_discussion_footer_role_names
        :all
      end

      def self.edit_discussion_footer_role_names
        :all
      end

      def self.publish
        true
      end

      def self.do_not_create_in_production_environment
        true
      end

      def self.xml_content
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8"?>
          <card required-for-submission="false" workflow-display-only="false">
            <content content-type="display-children">
              <content content-type="description">
                <text>This is a block of instructional text. It is not a question, and requires no answer.</text>
              </content>
              <content content-type="short-input" value-type="text">
                <text>This is the text of a custom question.  Agree?</text>
              </content>
              <content content-type="short-input" value-type="text">
                <text>This is a second question</text>
              </content>
              <content content-type="date-picker" value-type="text">
                <text>A Title</text>
              </content>
              <content content-type="check-box" value-type="boolean">
                <text>This is a check box</text>
                <label>Check this box if you agree</label>
              </content>
              <content content-type="check-box" value-type="boolean">
                <label>Check this box if you disagree instead</label>
              </content>
              <content content-type="radio" value-type="text">
                <text>
                  <![CDATA[This is a radio button question.  <b>Please</b> pick a choice]]>
                </text>
                <possible-value label="Choice 1" value="1"/>
                <possible-value label="Choice 2" value="2"/>
                <content content-type="display-with-value" visible-with-parent-answer="1">
                  <content content-type="display-children" custom-class="card-content-field-set">
                    <content content-type="short-input" value-type="text">
                      <text>You have answered 1 to the radio question</text>
                    </content>
                    <content content-type="short-input" value-type="text">
                      <text>What'd you think of that first question, huh?</text>
                    </content>
                  </content>
                </content>
                <content content-type="display-with-value" visible-with-parent-answer="2">
                  <content content-type="display-children" custom-class="card-content-field-set">
                    <content content-type="description">
                      <text>This is a message that comes up when you pick Choice 2 up above</text>
                    </content>
                    <content content-type="short-input" value-type="text">
                      <text>Now that you've picked that second choice, what will you do next?</text>
                    </content>
                  </content>
                </content>
              </content>
              <content content-type="paragraph-input" value-type="text">
                <text>Type a paragraph</text>
              </content>
              <content content-type="dropdown" value-type="text">
                <text>
                  <![CDATA[This is a dropdown question.  <b>Please</b> pick a choice]]>
                </text>
                <possible-value label="Choice 1" value="1"/>
                <possible-value label="Choice 2" value="2"/>
              </content>
              <content content-type="file-uploader" value-type="attachment">
                <text>Eat a hot dog; take a picture; upload it here</text>
                <label>Ima Button</label>
                <possible-value label="tif" value=".tif"/>
                <possible-value label="png" value=".png"/>
              </content>
              <content content-type="error-message" key="validationErrors.sourcefile">
                <text>Please upload your source file</text>
              </content>
              <content content-type="if" condition="isEditable">
                <content content-type="paragraph-input" value-type="html">
                  <text>This is the THEN branch of an IF condition.</text>
                </content>
                <content content-type="short-input" value-type="text">
                  <text>This is the ELSE branch of an IF condition.</text>
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
