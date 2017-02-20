#
# This is a way to tell Rails that when it auto-reloads code it should also
# make sure SnapshotService registrations get reloaded if necessary. Without
# this if the SnapshotService gets reloaded its registry gets cleared out
# and snapshotting fails after that point without a server restart.
#
# This only applies to 'development' or ANY environment where
# `config.cache_classes = false`. For environments where
# config.cache_classes is set to true this will only fire once.
#
# rubocop:disable Metrics/LineLength
ActionDispatch::Reloader.to_prepare do
  if SnapshotService.registry.empty?
    SnapshotService.configure do
      serialize AdhocAttachment, with: Snapshot::AttachmentSerializer
      serialize Author, with: Snapshot::AuthorSerializer
      serialize Figure, with: Snapshot::AttachmentSerializer
      serialize CardContent, with: Snapshot::CardContentSerializer
      serialize QuestionAttachment, with: Snapshot::AttachmentSerializer
      serialize SupportingInformationFile, with: Snapshot::AttachmentSerializer

      serialize TahiStandardTasks::AuthorsTask, with: Snapshot::AuthorTaskSerializer
      serialize TahiStandardTasks::CompetingInterestsTask, with: Snapshot::CompetingInterestsTaskSerializer
      serialize TahiStandardTasks::DataAvailabilityTask, with: Snapshot::DataAvailabilityTaskSerializer
      serialize TahiStandardTasks::EthicsTask, with: Snapshot::EthicsTaskSerializer
      serialize TahiStandardTasks::EarlyPostingTask, with: Snapshot::EarlyPostingTaskSerializer
      serialize TahiStandardTasks::FigureTask, with: Snapshot::FigureTaskSerializer
      serialize TahiStandardTasks::FinancialDisclosureTask, with: Snapshot::FinancialDisclosureTaskSerializer
      serialize TahiStandardTasks::Funder, with: Snapshot::FunderSerializer
      serialize TahiStandardTasks::PublishingRelatedQuestionsTask, with: Snapshot::PublishingRelatedQuestionsTaskSerializer
      serialize TahiStandardTasks::ReportingGuidelinesTask, with: Snapshot::ReportingGuidelinesTaskSerializer
      serialize TahiStandardTasks::ReviewerRecommendation, with: Snapshot::ReviewerRecommendationSerializer
      serialize TahiStandardTasks::ReviewerRecommendationsTask, with: Snapshot::ReviewerRecommendationsTaskSerializer
      serialize TahiStandardTasks::SupportingInformationTask, with: Snapshot::SupportingInformationTaskSerializer
      serialize TahiStandardTasks::TaxonTask, with: Snapshot::TaxonTaskSerializer
      serialize TahiStandardTasks::UploadManuscriptTask, with: Snapshot::UploadManuscriptTaskSerializer
      serialize TahiStandardTasks::CoverLetterTask, with: Snapshot::CoverLetterTaskSerializer
    end
  end
end
# rubocop:enable Metrics/LineLength
