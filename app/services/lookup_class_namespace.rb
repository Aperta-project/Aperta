# rubocop:disable Metrics/LineLength
# This class is a stopgap to find the fully qualified name of an Answerable
# based on its un-namespaced form. We don't want to do this in the future but
# for now it's a simple alternative to having to change the client code. This
# service class is used in the NestedQuestionAnswersController
#
class LookupClassNamespace
  POSSIBLE_TYPES = {
    # Tasks
    "BillingTask"                    =>     "PlosBilling::BillingTask",
    "EditorsDiscussionTask"          =>     "PlosBioInternalReview::EditorsDiscussionTask",
    "ChangesForAuthorTask"           =>     "PlosBioTechCheck::ChangesForAuthorTask",
    "FinalTechCheckTask"             =>     "PlosBioTechCheck::FinalTechCheckTask",
    "InitialTechCheckTask"           =>     "PlosBioTechCheck::InitialTechCheckTask",
    "RevisionTechCheckTask"          =>     "PlosBioTechCheck::RevisionTechCheckTask",
    "AssignTeamTask"                 =>     "Tahi::AssignTeam::AssignTeamTask",
    "AuthorsTask"                    =>     "TahiStandardTasks::AuthorsTask",
    "DataAvailabilityTask"           =>     "TahiStandardTasks::DataAvailabilityTask",
    "EarlyPostingTask"               =>     "TahiStandardTasks::EarlyPostingTask",
    "EthicsTask"                     =>     "TahiStandardTasks::EthicsTask",
    "FigureTask"                     =>     "TahiStandardTasks::FigureTask",
    "FinancialDisclosureTask"        =>     "TahiStandardTasks::FinancialDisclosureTask",
    "FrontMatterReviewerReportTask"  =>     "TahiStandardTasks::FrontMatterReviewerReportTask",
    "InitialDecisionTask"            =>     "TahiStandardTasks::InitialDecisionTask",
    "PaperEditorTask"                =>     "TahiStandardTasks::PaperEditorTask",
    "PaperReviewerTask"              =>     "TahiStandardTasks::PaperReviewerTask",
    "ProductionMetadataTask"         =>     "TahiStandardTasks::ProductionMetadataTask",
    "PublishingRelatedQuestionsTask" =>     "TahiStandardTasks::PublishingRelatedQuestionsTask",
    "RegisterDecisionTask"           =>     "TahiStandardTasks::RegisterDecisionTask",
    "RelatedArticlesTask"            =>     "TahiStandardTasks::RelatedArticlesTask",
    "ReportingGuidelinesTask"        =>     "TahiStandardTasks::ReportingGuidelinesTask",
    "ReviewerRecommendationsTask"    =>     "TahiStandardTasks::ReviewerRecommendationsTask",
    "ReviewerReportTask"             =>     "TahiStandardTasks::ReviewerReportTask",
    "ReviseTask"                     =>     "TahiStandardTasks::ReviseTask",
    "SendToApexTask"                 =>     "TahiStandardTasks::SendToApexTask",
    "SupportingInformationTask"      =>     "TahiStandardTasks::SupportingInformationTask",
    "TaxonTask"                      =>     "TahiStandardTasks::TaxonTask",
    "TitleAndAbstractTask"           =>     "TahiStandardTasks::TitleAndAbstractTask",
    "UploadManuscriptTask"           =>     "TahiStandardTasks::UploadManuscriptTask",
    # The Rest
    "Funder"                         =>     "TahiStandardTasks::Funder",
    "ReviewerRecommendation"         =>     "TahiStandardTasks::ReviewerRecommendation"
  }.freeze

  # If the type_name isn't found in the POSSIBLE_TYPES, let it go on through as-is.
  def self.lookup_namespace(type_name)
    POSSIBLE_TYPES.fetch(type_name, type_name)
  end
end
# rubocop:enable Metrics/LineLength
