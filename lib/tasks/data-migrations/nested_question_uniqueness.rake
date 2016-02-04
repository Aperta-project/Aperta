namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Changes each nested question ident to make them unique'
      task unique: :environment do

        conversions =
          [
            {
              type: TahiStandardTasks::TaxonTask.name,
              from: "taxon_zoological",
              to: "taxon--zoological",
              children: [
                { from: "complies", to: "taxon--zoological--complies" }
              ]
            },
            {
              type: TahiStandardTasks::TaxonTask.name,
              from: "taxon_botanical",
              to: "taxon--botanical",
              children: [
                { from: "complies", to: "taxon--botanical--complies" }
              ]
            },

            {
              type: Author.name,
              from: "published_as_corresponding_author",
              to: "author--published_as_corresponding_author",
              children: []
            },
            {
              type: Author.name,
              from: "deceased",
              to: "author--deceased",
              children: []
            },
            {
              type: Author.name,
              from: "contributions",
              to: "author--contributions",
              children: [
                { from: "conceived_and_designed_experiments", to: "author--contributions--conceived_and_designed_experiments" },
                { from: "performed_the_experiments", to: "author--contributions--performed_the_experiments" },
                { from: "analyzed_data", to: "author--contributions--analyzed_data" },
                { from: "contributed_tools", to: "author--contributions--contributed_tools" },
                { from: "contributed_writing", to: "author--contributions--contributed_writing" },
                { from: "other", to: "author--contributions--other" }
              ]
            },

            {
              type: TahiStandardTasks::CompetingInterestsTask.name,
              from: "competing_interests",
              to: "competing_interests--has_competing_interests",
              children: [
                { from: "statement", to: "competing_interests--statement" },
              ]
            },


            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "competing_interests",
              to: "reviewer_report--competing_interests",
              children: []
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "support_conclusions",
              to: "reviewer_report--support_conclusions",
              children: [
                { from: "explanation", to: "reviewer_report--support_conclusions--explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "statistical_analysis",
              to: "reviewer_report--statistical_analysis",
              children: [
                { from: "explanation", to: "reviewer_report--statistical_analysis--explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "standards",
              to: "reviewer_report--standards",
              children: [
                { from: "explanation", to: "reviewer_report--standards--explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "additional_comments",
              to: "reviewer_report--additional_comments",
              children: []
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "identity",
              to: "reviewer_report--identity",
              children: []
            },

            {
              type: TahiStandardTasks::Funder.name,
              from: "funder_had_influence",
              to: "funder--had_influence",
              children: [
                { from: "funder_role_description", to: "funder--had_influence--role_description" },
              ]
            },

            {
              type: TahiStandardTasks::DataAvailabilityTask.name,
              from: "data_fully_available",
              to: "data_availability--data_fully_available",
              children: []
            },
            {
              type: TahiStandardTasks::DataAvailabilityTask.name,
              from: "data_location",
              to: "data_availability--data_location",
              children: []
            },

            {
              type: TahiStandardTasks::EthicsTask.name,
              from: "human_subjects",
              to: "ethics--human_subjects",
              children: [
                { from: "participants", to: "ethics--human_subjects--participants" },
              ]
            },
            {
              type: TahiStandardTasks::EthicsTask.name,
              from: "animal_subjects",
              to: "ethics--animal_subjects",
              children: [
                { from: "field_permit", to: "ethics--animal_subjects--field_permit" },
              ]
            },

            {
              type: TahiStandardTasks::FigureTask.name,
              from: "figure_complies",
              to: "figures--complies",
              children: []
            },

            {
              type: TahiStandardTasks::FinancialDisclosureTask.name,
              from: "author_received_funding",
              to: "financial_disclosures--author_received_funding",
              children: []
            },


            {
              type: PlosBilling::BillingTask.name,
              from: "first_name",
              to: "plos_billing--first_name",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "last_name",
              to: "plos_billing--last_name",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "title",
              to: "plos_billing--title",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "department",
              to: "plos_billing--department",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "phone_number",
              to: "plos_billing--phone_number",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "email",
              to: "plos_billing--email",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "address1",
              to: "plos_billing--address1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "address2",
              to: "plos_billing--address2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "city",
              to: "plos_billing--city",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "state",
              to: "plos_billing--state",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "postal_code",
              to: "plos_billing--postal_code",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "country",
              to: "plos_billing--country",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affiliation1",
              to: "plos_billing--affiliation1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affiliation2",
              to: "plos_billing--affiliation2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "payment_method",
              to: "plos_billing--payment_method",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1",
              to: "plos_billing--pfa_question_1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1a",
              to: "plos_billing--pfa_question_1a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1b",
              to: "plos_billing--pfa_question_1b",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2",
              to: "plos_billing--pfa_question_2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2a",
              to: "plos_billing--pfa_question_2a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2b",
              to: "plos_billing--pfa_question_2b",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_3",
              to: "plos_billing--pfa_question_3",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_3a",
              to: "plos_billing--pfa_question_3a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_4",
              to: "plos_billing--pfa_question_4",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_4a",
              to: "plos_billing--pfa_question_4a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_amount_to_pay",
              to: "plos_billing--pfa_amount_to_pay",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_supporting_docs",
              to: "plos_billing--pfa_supporting_docs",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_additional_comments",
              to: "plos_billing--pfa_additional_comments",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affirm_true_and_complete",
              to: "plos_billing--affirm_true_and_complete",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "agree_to_collections",
              to: "plos_billing--agree_to_collections",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "gpi_country",
              to: "plos_billing--gpi_country",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "ringgold_institution",
              to: "plos_billing--ringgold_institution",
              children: []
            },

            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "open_rejects",
              to: "plos_bio_final_tech_check--open_rejects",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "human_subjects",
              to: "plos_bio_final_tech_check--human_subjects",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "ethics_needed",
              to: "plos_bio_final_tech_check--ethics_needed",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "data_available",
              to: "plos_bio_final_tech_check--data_available",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "supporting_information",
              to: "plos_bio_final_tech_check--supporting_information",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "dryad_url",
              to: "plos_bio_final_tech_check--dryad_url",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "financial_disclosure",
              to: "plos_bio_final_tech_check--financial_disclosure",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "tobacco",
              to: "plos_bio_final_tech_check--tobacco",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "figures_legible",
              to: "plos_bio_final_tech_check--figures_legible",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "cited",
              to: "plos_bio_final_tech_check--cited",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "cover_letter",
              to: "plos_bio_final_tech_check--cover_letter",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "billing_inquiries",
              to: "plos_bio_final_tech_check--billing_inquiries",
              children: []
            },
            {
              type: PlosBioTechCheck::FinalTechCheckTask.name,
              from: "ethics_statement",
              to: "plos_bio_final_tech_check--ethics_statement",
              children: []
            },

            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "open_rejects",
              to: "plos_bio_initial_tech_check--open_rejects",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "human_subjects",
              to: "plos_bio_initial_tech_check--human_subjects",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "ethics_needed",
              to: "plos_bio_initial_tech_check--ethics_needed",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "data_available",
              to: "plos_bio_initial_tech_check--data_available",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "supporting_information",
              to: "plos_bio_initial_tech_check--supporting_information",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "dryad_url",
              to: "plos_bio_initial_tech_check--dryad_url",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "financial_disclosure",
              to: "plos_bio_initial_tech_check--financial_disclosure",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "tobacco",
              to: "plos_bio_initial_tech_check--tobacco",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "figures_legible",
              to: "plos_bio_initial_tech_check--figures_legible",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "cited",
              to: "plos_bio_initial_tech_check--cited",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "cover_letter",
              to: "plos_bio_initial_tech_check--cover_letter",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "billing_inquiries",
              to: "plos_bio_initial_tech_check--billing_inquiries",
              children: []
            },
            {
              type: PlosBioTechCheck::InitialTechCheckTask.name,
              from: "ethics_statement",
              to: "plos_bio_initial_tech_check--ethics_statement",
              children: []
            },

            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "open_rejects",
              to: "plos_bio_revision_tech_check--open_rejects",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "human_subjects",
              to: "plos_bio_revision_tech_check--human_subjects",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "ethics_needed",
              to: "plos_bio_revision_tech_check--ethics_needed",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "data_available",
              to: "plos_bio_revision_tech_check--data_available",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "supporting_information",
              to: "plos_bio_revision_tech_check--supporting_information",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "dryad_url",
              to: "plos_bio_revision_tech_check--dryad_url",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "financial_disclosure",
              to: "plos_bio_revision_tech_check--financial_disclosure",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "tobacco",
              to: "plos_bio_revision_tech_check--tobacco",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "figures_legible",
              to: "plos_bio_revision_tech_check--figures_legible",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "cited",
              to: "plos_bio_revision_tech_check--cited",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "cover_letter",
              to: "plos_bio_revision_tech_check--cover_letter",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "billing_inquiries",
              to: "plos_bio_revision_tech_check--billing_inquiries",
              children: []
            },
            {
              type: PlosBioTechCheck::RevisionTechCheckTask.name,
              from: "ethics_statement",
              to: "plos_bio_revision_tech_check--ethics_statement",
              children: []
            },

            {
              type: TahiStandardTasks::ProductionMetadataTask.name,
              from: "publication_date",
              to: "production_metadata--publication_date",
              children: []
            },
            {
              type: TahiStandardTasks::ProductionMetadataTask.name,
              from: "volume_number",
              to: "production_metadata--volume_number",
              children: []
            },
            {
              type: TahiStandardTasks::ProductionMetadataTask.name,
              from: "issue_number",
              to: "production_metadata--issue_number",
              children: []
            },
            {
              type: TahiStandardTasks::ProductionMetadataTask.name,
              from: "production_notes",
              to: "production_metadata--production_notes",
              children: []
            },

            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "published_elsewhere",
              to: "publishing_related_questions--published_elsewhere",
              children: [
                { from: "taken_from_manuscripts", to: "publishing_related_questions--published_elsewhere--taken_from_manuscripts" },
                { from: "upload_related_work", to: "publishing_related_questions--published_elsewhere--upload_related_work" }
              ]
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "submitted_in_conjunction",
              to: "publishing_related_questions--submitted_in_conjunction",
              children: [
                { from: "corresponding_title", to: "publishing_related_questions--submitted_in_conjunction--corresponding_title" },
                { from: "corresponding_author", to: "publishing_related_questions--submitted_in_conjunction--corresponding_author" }
              ]
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "previous_interactions_with_this_manuscript",
              to: "publishing_related_questions--previous_interactions_with_this_manuscript",
              children: [
                { from: "submission_details", to: "publishing_related_questions--previous_interactions_with_this_manuscript--submission_details" }
              ]
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "presubmission_inquiry",
              to: "publishing_related_questions--presubmission_inquiry",
              children: [
                { from: "submission_details", to: "publishing_related_questions--presubmission_inquiry--submission_details" }
              ]
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "other_journal_submission",
              to: "publishing_related_questions--other_journal_submission",
              children: [
                { from: "submission_details", to: "publishing_related_questions--other_journal_submission--submission_details" }
              ]
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "author_was_previous_journal_editor",
              to: "publishing_related_questions--author_was_previous_journal_editor",
              children: []
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "intended_collection",
              to: "publishing_related_questions--intended_collection",
              children: []
            },
            {
              type: TahiStandardTasks::PublishingRelatedQuestionsTask.name,
              from: "us_government_employees",
              to: "publishing_related_questions--us_government_employees",
              children: []
            },

            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "clinical_trial",
              to: "reporting_guidelines--clinical_trial",
              children: []
            },
            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "systematic_reviews",
              to: "reporting_guidelines--systematic_reviews",
              children: [
                { from: "checklist", to: "reporting_guidelines--systematic_reviews--checklist" }
              ]
            },
            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "meta_analyses",
              to: "reporting_guidelines--meta_analyses",
              children: [
                { from: "checklist", to: "reporting_guidelines--meta_analyses--checklist" }
              ]
            },
            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "diagnostic_studies",
              to: "reporting_guidelines--diagnostic_studies",
              children: [ ]
            },
            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "epidemiological_studies",
              to: "reporting_guidelines--epidemiological_studies",
              children: [ ]
            },
            {
              type: TahiStandardTasks::ReportingGuidelinesTask.name,
              from: "microarray_studies",
              to: "reporting_guidelines--microarray_studies",
              children: [ ]
            },

            {
              type: TahiStandardTasks::ReviewerRecommendation.name,
              from: "recommend_or_oppose",
              to: "reviewer_recommendations--recommend_or_oppose",
              children: [ ]
            },
            {
              type: TahiStandardTasks::ReviewerRecommendation.name,
              from: "reason",
              to: "reviewer_recommendations--reason",
              children: [ ]
            },
        ]

        NestedQuestionConverter.new(conversions, dry_run: false).convert
      end
    end



    class NestedQuestionConverter
      attr_reader :conversions, :dry_run

      def initialize(conversions, dry_run: false)
        @conversions = conversions
        @dry_run = dry_run
      end

      def convert
        NestedQuestion.transaction do
          conversions.each do |conversion|
            parent = update_parent(type: conversion[:type], from: conversion[:from], to: conversion[:to])
            if parent.present?
              conversion[:children].each do |child|
                update_child(parent: parent, from: child[:from], to: child[:to])
              end
            end
          end
          if dry_run
            puts "---> rolling back due to dry run"
            raise ActiveRecord::Rollback
          end
        end
      end

      private

      def update_parent(type:, from:, to:)
        parent = NestedQuestion.find_by(owner_type: type, parent_id: nil, ident: from)
        if parent.present?
          parent.update(ident: to)
          puts "Updated '#{type}' parent from '#{from}' to '#{to}'"
        else
          puts "!!! Could not find parent '#{type}' with ident '#{from}'"
        end
        parent
      end

      def update_child(parent:, from:, to:)
        child = NestedQuestion.children_of(parent).find_by(ident: from)
        if child.present?
          child.update(ident: to)
          puts "   Updated child from '#{from}' to '#{to}'"
        else
          puts "   !!! Could not find child nested question with ident '#{from}'"
        end
        child
      end
    end
  end
end
