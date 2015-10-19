SnapshotService.configure do
  serialize Attachment, with: Snapshot::AttachmentSerializer
  serialize Author, with: Snapshot::AuthorSerializer
  serialize NestedQuestion, with: Snapshot::NestedQuestionSerializer
  serialize QuestionAttachment, with: Snapshot::QuestionAttachmentSerializer

  serialize TahiStandardTasks::AuthorsTask, with: Snapshot::AuthorTaskSerializer
  serialize TahiStandardTasks::CompetingInterestsTask, with: Snapshot::CompetingInterestsTaskSerializer
  serialize TahiStandardTasks::DataAvailabilityTask, with: Snapshot::DataAvailabilityTaskSerializer
  serialize TahiStandardTasks::EthicsTask, with: Snapshot::EthicsTaskSerializer
  serialize TahiStandardTasks::FigureTask, with: Snapshot::FigureTaskSerializer
  serialize TahiStandardTasks::FinancialDisclosureTask, with: Snapshot::FinancialDisclosureTaskSerializer
  serialize TahiStandardTasks::Funder, with: Snapshot::FunderSerializer
  serialize TahiStandardTasks::PublishingRelatedQuestionsTask, with: Snapshot::PublishingRelatedQuestionsTaskSerializer
  serialize TahiStandardTasks::ReportingGuidelinesTask, with: Snapshot::ReportingGuidelinesTaskSerializer
  serialize TahiStandardTasks::ReviewerRecommendation, with: Snapshot::ReviewerRecommendationSerializer
  serialize TahiStandardTasks::ReviewerRecommendationsTask, with: Snapshot::ReviewerRecommendationsTaskSerializer
  serialize TahiStandardTasks::SupportingInformationTask, with: Snapshot::SupportingInformationTaskSerializer
  serialize TahiStandardTasks::TaxonTask, with: Snapshot::TaxonTaskSerializer
  serialize TahiUploadManuscript::UploadManuscriptTask, with: Snapshot::UploadManuscriptTaskSerializer
end
