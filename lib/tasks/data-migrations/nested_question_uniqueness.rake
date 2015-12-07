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
