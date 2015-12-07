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
              to: "taxon.zoological",
              children: [
                { from: "complies", to: "taxon.zoological.complies" }
              ]
            },
            {
              type: TahiStandardTasks::TaxonTask.name,
              from: "taxon_botanical",
              to: "taxon.botanical",
              children: [
                { from: "complies", to: "taxon.botanical.complies" }
              ]
            },

            {
              type: Author.name,
              from: "published_as_corresponding_author",
              to: "author.published_as_corresponding_author",
              children: []
            },
            {
              type: Author.name,
              from: "deceased",
              to: "author.deceased",
              children: []
            },
            {
              type: Author.name,
              from: "contributions",
              to: "author.contributions",
              children: [
                { from: "conceived_and_designed_experiments", to: "author.contributions.conceived_and_designed_experiments" },
                { from: "performed_the_experiments", to: "author.contributions.performed_the_experiments" },
                { from: "analyzed_data", to: "author.contributions.analyzed_data" },
                { from: "contributed_tools", to: "author.contributions.contributed_tools" },
                { from: "contributed_writing", to: "author.contributions.contributed_writing" },
                { from: "other", to: "author.contributions.other" }
              ]
            },

            {
              type: TahiStandardTasks::CompetingInterestsTask.name,
              from: "competing_interests",
              to: "competing_interests.has_competing_interests",
              children: [
                { from: "statement", to: "competing_interests.statement" },
              ]
            },


            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "competing_interests",
              to: "reviewer_report.competing_interests",
              children: []
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "support_conclusions",
              to: "reviewer_report.support_conclusions",
              children: [
                { from: "explanation", to: "reviewer_report.support_conclusions.explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "statistical_analysis",
              to: "reviewer_report.statistical_analysis",
              children: [
                { from: "explanation", to: "reviewer_report.statistical_analysis.explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "standards",
              to: "reviewer_report.standards",
              children: [
                { from: "explanation", to: "reviewer_report.standards.explanation" },
              ]
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "additional_comments",
              to: "reviewer_report.additional_comments",
              children: []
            },
            {
              type: TahiStandardTasks::ReviewerReportTask.name,
              from: "identity",
              to: "reviewer_report.identity",
              children: []
            },

            {
              type: TahiStandardTasks::Funder.name,
              from: "funder_had_influence",
              to: "funder.had_influence",
              children: [
                { from: "funder_role_description", to: "funder.had_influence.role_description" },
              ]
            },

            {
              type: TahiStandardTasks::DataAvailabilityTask.name,
              from: "data_fully_available",
              to: "data_availability.data_fully_available",
              children: []
            },
            {
              type: TahiStandardTasks::DataAvailabilityTask.name,
              from: "data_location",
              to: "data_availability.data_location",
              children: []
            },

            {
              type: TahiStandardTasks::EthicsTask.name,
              from: "human_subjects",
              to: "ethics.human_subjects",
              children: [
                { from: "participants", to: "ethics.human_subjects.participants" },
              ]
            },
            {
              type: TahiStandardTasks::EthicsTask.name,
              from: "animal_subjects",
              to: "ethics.animal_subjects",
              children: [
                { from: "field_permit", to: "ethics.animal_subjects.field_permit" },
              ]
            },

            {
              type: TahiStandardTasks::FigureTask.name,
              from: "figure_complies",
              to: "figures.complies",
              children: []
            },

            {
              type: TahiStandardTasks::FinancialDisclosureTask.name,
              from: "author_received_funding",
              to: "financial_disclosures.author_received_funding",
              children: []
            },


            {
              type: PlosBilling::BillingTask.name,
              from: "first_name",
              to: "plos_billing.first_name",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "last_name",
              to: "plos_billing.last_name",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "title",
              to: "plos_billing.title",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "department",
              to: "plos_billing.department",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "phone_number",
              to: "plos_billing.phone_number",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "email",
              to: "plos_billing.email",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "address1",
              to: "plos_billing.address1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "address2",
              to: "plos_billing.address2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "city",
              to: "plos_billing.city",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "state",
              to: "plos_billing.state",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "postal_code",
              to: "plos_billing.postal_code",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "country",
              to: "plos_billing.country",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affiliation1",
              to: "plos_billing.affiliation1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affiliation2",
              to: "plos_billing.affiliation2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "payment_method",
              to: "plos_billing.payment_method",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1",
              to: "plos_billing.pfa_question_1",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1a",
              to: "plos_billing.pfa_question_1a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_1b",
              to: "plos_billing.pfa_question_1b",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2",
              to: "plos_billing.pfa_question_2",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2a",
              to: "plos_billing.pfa_question_2a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_2b",
              to: "plos_billing.pfa_question_2b",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_3",
              to: "plos_billing.pfa_question_3",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_3a",
              to: "plos_billing.pfa_question_3a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_4",
              to: "plos_billing.pfa_question_4",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_question_4a",
              to: "plos_billing.pfa_question_4a",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_amount_to_pay",
              to: "plos_billing.pfa_amount_to_pay",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_supporting_docs",
              to: "plos_billing.supporting_docs",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "pfa_additional_comments",
              to: "plos_billing.pfa_additional_comments",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "affirm_true_and_complete",
              to: "plos_billing.affirm_true_and_complete",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "agree_to_collections",
              to: "plos_billing.agree_to_collections",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "gpi_country",
              to: "plos_billing.gpi_country",
              children: []
            },
            {
              type: PlosBilling::BillingTask.name,
              from: "ringgold_institution",
              to: "plos_billing.ringgold_institution",
              children: []
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
