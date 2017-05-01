namespace :data do
  namespace :migrate do
    desc <<-DESC
      Reassign correct CardVersion relationship for FrontMatterReviewerReports.

      A ReviewerReport will always have a Card associated to it through the
      CardVersion association.  This association helps determine the set of
      questions that is displayed to the end user.  When the ReviewerReport is
      initially created (using the ReviewerReportCreator service class), it
      will assign one of two different types of Cards -- either a
      ReviewerReport or a TahiStandardTasks::FrontMatterReviewerReport.  The
      ability to determine which of these two is assigned requires intimate
      knowledge of the Task instance that the Report is associated with and
      cannot be done simply by class name.  Compounding this issue is the fact
      that although there is an actual ReviewerReport class, there is no such
      thing as a TahiStandardTasks::FrontMatterReviewerReport model.

      This particular one time rake task will ensure that all
      FrontMatterReviewerReportTasks will have its front matter reviewer
      reports associated to the correct Card, so that the correct questions
      will be shown to the user on the front end.
    DESC
    task reassign_front_matter_reviewer_report_card_versions: :environment do
      latest_card_version = Card.find_by_class_name!("TahiStandardTasks::FrontMatterReviewerReport")
                                .latest_card_version

      TahiStandardTasks::FrontMatterReviewerReportTask.find_each do |fmrrt|
        fmrrt.reviewer_reports.update_all(card_version_id: latest_card_version)
      end
    end
  end
end
