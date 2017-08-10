module CustomCard
  module Configurations
    #
    # This class defines a rake task loadable custom card that allows opting out of preprint
    #
    class PreprintOptOut < Base
      def self.name
        "Preprint Posting"
      end

      def self.excluded_view_permissions
        [
          Role::DISCUSSION_PARTICIPANT,
          Role::FREELANCE_EDITOR_ROLE,
          Role::JOURNAL_SETUP_ROLE,
          Role::TASK_PARTICIPANT_ROLE,
          Role::REVIEWER_ROLE,
          Role::REVIEWER_REPORT_OWNER_ROLE
        ]
      end

      def self.excluded_edit_permissions
        [
          Role::ACADEMIC_EDITOR_ROLE,
          Role::BILLING_ROLE,
          Role::COVER_EDITOR_ROLE,
          Role::DISCUSSION_PARTICIPANT,
          Role::FREELANCE_EDITOR_ROLE,
          Role::HANDLING_EDITOR_ROLE,
          Role::INTERNAL_EDITOR_ROLE,
          Role::JOURNAL_SETUP_ROLE,
          Role::TASK_PARTICIPANT_ROLE,
          Role::PRODUCTION_STAFF_ROLE,
          Role::REVIEWER_ROLE,
          Role::REVIEWER_REPORT_OWNER_ROLE
        ]
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
              <content content-type="radio" value-type="text" default-answer-value="1">
                <text>
                  <![CDATA[Establish priority: take credit for your research and discoveries, by posting a copy of your uncorrected proof online. If you do <b>NOT</b> consent to having an early version of your paper posted online, uncheck the box below.]]>
                </text>
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
