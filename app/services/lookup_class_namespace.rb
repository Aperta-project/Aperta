# rubocop:disable Metrics/LineLength
# This class is a stopgap to find the fully qualified name of an Answerable
# based on its un-namespaced form. We don't want to do this in the future but
# for now it's a simple alternative to having to change the client code. This
# service class is used in the NestedQuestionAnswersController
#
class LookupClassNamespace
  POSSIBLE_TYPES = {
    # Tasks
    "BillingTask"                    =>     "BillingTask",
    "EditorsDiscussionTask"          =>     "EditorsDiscussionTask",
    "ChangesForAuthorTask"           =>     "ChangesForAuthorTask",
    "FinalTechCheckTask"             =>     "FinalTechCheckTask",
    "InitialTechCheckTask"           =>     "InitialTechCheckTask",
    "RevisionTechCheckTask"          =>     "RevisionTechCheckTask",
    "AssignTeamTask"                 =>     "Tahi::AssignTeam::AssignTeamTask",
    "AuthorsTask"                    =>     "AuthorsTask",
    "DataAvailabilityTask"           =>     "DataAvailabilityTask",
    "FigureTask"                     =>     "FigureTask",
    "FrontMatterReviewerReportTask"  =>     "FrontMatterReviewerReportTask",
    "InitialDecisionTask"            =>     "InitialDecisionTask",
    "PaperEditorTask"                =>     "PaperEditorTask",
    "PaperReviewerTask"              =>     "PaperReviewerTask",
    "ProductionMetadataTask"         =>     "ProductionMetadataTask",
    "RegisterDecisionTask"           =>     "RegisterDecisionTask",
    "RelatedArticlesTask"            =>     "RelatedArticlesTask",
    "ReviewerRecommendationsTask"    =>     "ReviewerRecommendationsTask",
    "ReviewerReportTask"             =>     "ReviewerReportTask",
    "ReviseTask"                     =>     "ReviseTask",
    "SendToApexTask"                 =>     "SendToApexTask",
    "SupportingInformationTask"      =>     "SupportingInformationTask",
    "TaxonTask"                      =>     "TaxonTask",
    "TitleAndAbstractTask"           =>     "TitleAndAbstractTask",
    "UploadManuscriptTask"           =>     "UploadManuscriptTask",
    # The Rest
    "ReviewerRecommendation"         =>     "ReviewerRecommendation"
  }.freeze

  # If the type_name isn't found in the POSSIBLE_TYPES, let it go on through as-is.
  def self.lookup_namespace(type_name)
    POSSIBLE_TYPES.fetch(type_name, type_name)
  end
end
# rubocop:enable Metrics/LineLength
