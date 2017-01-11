namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Sets the paper id on all nested question answers'
      task reviewer_report_task_to_reviewer_report: :environment do
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        task_count = Task.where(type: relevant_tasks).count
        STDOUT.puts("Task count: #{task_count}")

        reviewer_report_ids = []
        NestedQuestion.where(owner_type: relevant_tasks).find_each do |question|
          STDOUT.puts("Processing Question #{question.id}")
          question.nested_question_answers.find_each do |answer|
            STDOUT.puts("Processing QuestionAnswer #{answer.id}")
            task = answer.owner
            reviewer_report = ReviewerReport.where(
              task: task,
              user: task.reviewer,
              decision: answer.decision
            ).first_or_create!
            answer.owner = reviewer_report
            unless reviewer_report_ids.include? reviewer_report.id
              reviewer_report_ids << reviewer_report.id
            end
            STDOUT.puts("Setting Answer Owner for answer: #{answer.id} for reviewer_report: #{reviewer_report.id}")
            answer.save(validate: false)
          end
          question.update!(owner_type: ReviewerReport.name)
        end
        STDOUT.puts("Task count: #{task_count}")
        STDOUT.puts("Reviewer Report Count: #{reviewer_report_ids.length}")

        if NestedQuestion.where(owner_type: relevant_tasks).empty?
          STDOUT.puts("Nested Question migration for Reviewer Report completed")
        else
          STDOUT.puts("Migration Failed, not all nested questions were moved")
        end
      end

      task reviewer_report_to_reviewer_report_task: :environment do
        # Not all Reviewer Report NestedQuestions are associated with a Reviewer Report
        NestedQuestion.where(owner_type: ReviewerReport.name).find_each do |question|
          task = question.owner.task
          question.nested_question_answers.find_each do |answer|
            answer.owner = task
            answer.save(validate: false)
          end
          question.update!(owner_type: task.class.name)
        end

        ReviewerReport.each do |report|
          if report.nested_questions.empty?
            STDOUT.puts("Destroying ReviewerReport: #{report.id}")
            report.destroy!
          else
            STDERR.puts("Error with a ReviewerReport (id: #{report.id}) that is still associated with nested questions")
          end
        end
      end
    end
  end
end
