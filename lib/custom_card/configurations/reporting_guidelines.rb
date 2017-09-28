module CustomCard
  module Configurations
    #
    # This class defines the specific attributes of a particular
    # Card and it can be used to create a new valid Card into the
    # system via the CustomCard::Loader.
    #
    class ReportingGuidelines < Base
      def self.name
        "Reporting Guidelines"
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
        <<-XML.strip_heredoc.strip_heredoc
        <?xml version="1.0" encoding="UTF-8"?>
        <card required-for-submission="false" workflow-display-only="false">
          <content content-type="display-children">
            <content content-type="display-children" child-tag="li" custom-class="question-list" custom-child-class="question" wrapper-tag="ol">
              <content content-type="text">
                <text>
                  <![CDATA[Authors should check the <a target="_blank" href="http://www.equator-network.org">EQUATOR Network</a> site for any reporting guidelines that apply to their study design, and ensure that any required Supporting Information (checklists, protocols, flowcharts, etc.) be included in the article submission.]]>
                </text>
              </content>
            </content>
            <content content-type="display-children" custom-class="question-list">
              <content content-type="text">
                <text>Select all that apply</text>
              </content>
              <content content-type="display-children" custom-class="left-indent">
                <content ident="reporting_guidelines--clinical_trial" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Clinical Trial</text>
                </content>
                <content ident="reporting_guidelines--systematic_reviews" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Systematic Reviews</text>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="display-children" custom-class="card-content-field-set large-description-text-container">
                      <content ident="reporting_guidelines--systematic_reviews--checklist" content-type="file-uploader" value-type="attachment" allow-multiple-uploads="false" allow-file-captions="false" allow-annotations="false" required-field="false">
                        <text>
                          <![CDATA[Provide a completed PRISMA checklist as supporting information. You can <a target="_blank" href="http://www.prisma-statement.org">download it here.</a>]]>
                        </text>
                        <label>Upload Review Checklist</label>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="reporting_guidelines--meta_analyses" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Meta Analyses</text>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="display-children" custom-class="card-content-field-set large-description-text-container">
                      <content ident="reporting_guidelines--meta_analyses--checklist" content-type="file-uploader" value-type="attachment" allow-multiple-uploads="false" allow-file-captions="false" allow-annotations="false" required-field="false">
                        <text>
                          <![CDATA[Provide a completed PRISMA checklist as supporting information. You can <a target="_blank" href="http://www.prisma-statement.org">download it here.</a>]]>
                        </text>
                        <label>Upload PRISMA Checklist</label>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="reporting_guidelines--diagnostic_studies" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Diagnostic studies</text>
                </content>
                <content ident="reporting_guidelines--epidemiological_studies" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Epidemiological studies</text>
                </content>
                <content ident="reporting_guidelines--microarray_studies" content-type="check-box" value-type="boolean" allow-annotations="false" required-field="false">
                  <text>Microarray studies</text>
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
