# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines a rake task loadable custom card that allows opting out of preprint
    #
    class PreprintOptOut < Base
      def self.name
        "Preprint Posting"
      end

      def self.view_role_names
        ["Academic Editor",
         "Billing Staff",
         "Collaborator",
         "Cover Editor",
         "Creator",
         "Handling Editor",
         "Internal Editor",
         "Production Staff",
         "Publishing Services",
         "Site Admin",
         "Staff Admin"]
      end

      def self.edit_role_names
        ["Collaborator",
         "Creator",
         "Publishing Services",
         "Site Admin",
         "Staff Admin"]
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
              <content content-type="if" condition="isOverlay">
                <content content-type="display-children" child-tag="li" wrapper-tag="ol">
                  <content content-type="description">
                    <text>Benefit: Establish priority</text>
                  </content>
                  <content content-type="description">
                    <text>Benefit: Gather feedback</text>
                  </content>
                  <content content-type="description">
                    <text>Benefit: Cite for funding</text>
                  </content>
                </content>
                <content content-type="description">
                  <text>
                    <![CDATA[Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, indicate your choice below.]]>
                  </text>
                </content>
              </content>
              <content content-type="radio" value-type="text" default-answer-value="1" allow-annotations="false" required-field="false">
                <possible-value label="Yes, I want to accelerate research by publishing a preprint ahead of peer review" value="1"/>
                <possible-value label="No, I do not want my article to appear online ahead of the reviewed article" value="2"/>
              </content>
            </content>
          </card>
        XML
      end
    end
  end
end
# rubocop:enable Metrics/MethodLength
