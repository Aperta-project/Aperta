# rubocop:disable Metrics/MethodLength
module CustomCard
  module Configurations
    #
    # This class defines a rake task loadable custom card for Reporting Guidelines
    #
    class ReportingGuidelines < Base
      def self.name
        "Reporting Guidelines"
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
          <card required-for-submission="false" workflow-display-only="false">
            <content content-type="display-children">
              <content ident="reporting_guidelines--has_quideline" content-type="text">
                <text>
                  <![CDATA[<ol class="question-list"><li class="question"><div class="question-text"><div>Authors should check the <a target="_blank" href="http://www.equator-network.org">EQUATOR Network</a> site for any reporting guidelines that apply to their study design, and ensure that any required Supporting Information (checklists, protocols, flowcharts, etc.) be included in the article submission.</div></div></li>]]>
                </text>
              </content>
              <content content-type="plain-list">
                <content content-type="text">
                  <text>Select all that apply</text>
                </content>
                <content ident="reporting_guidelines--clinical_trial" content-type="check-box" value-type="boolean">
                  <label>Clinical Trial</label>
                </content>
                <content ident="reporting_guidelines--systematic_reviews" content-type="check-box" value-type="boolean">
                  <label>Systematic Reviews</label>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="field-set">
                      <content ident="reporting_guidelines--systematic_reviews--checklist" content-type="file-uploader" value-type="attachment">
                        <text>
                          <![CDATA[<div class="question-text">Provide a completed PRISMA checklist as supporting information. You can <a target="_blank" href="http://www.prisma-statement.org">download it here.</a></div>]]>
                        </text>
                        <label>Upload Review Checklist</label>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="reporting_guidelines--meta_analyses" content-type="check-box" value-type="boolean">
                  <label>Meta Analyses</label>
                  <content content-type="display-with-value" visible-with-parent-answer="true">
                    <content content-type="field-set">
                      <content ident="reporting_guidelines--meta_analyses--checklist" content-type="file-uploader" value-type="attachment">
                        <text>
                          <![CDATA[<div class="question-text">Provide a completed PRISMA checklist as supporting information. You can <a target="_blank" href="http://www.prisma-statement.org">download it here.</a></div>]]>
                        </text>
                        <label>Upload PRISMA Checklist</label>
                      </content>
                    </content>
                  </content>
                </content>
                <content ident="reporting_guidelines--diagnostic_studies" content-type="check-box" value-type="boolean">
                  <label>Diagnostic studies</label>
                </content>
                <content ident="reporting_guidelines--epidemiological_studies" content-type="check-box" value-type="boolean">
                  <label>Epidemiological studies</label>
                </content>
                <content ident="reporting_guidelines--microarray_studies" content-type="check-box" value-type="boolean">
                  <label>Microarray studies</label>
                </content>
              </content>
            </content>
          </card>
        XML
      end
    end
  end
end
