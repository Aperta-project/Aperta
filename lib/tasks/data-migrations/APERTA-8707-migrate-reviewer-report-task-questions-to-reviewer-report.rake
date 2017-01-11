namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Sets the paper id on all nested question answers'
      task reviewer_report_task_to_reviewer_report: :environment do
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        task_count = Task.where(type: relevant_tasks).count
        STDOUT.puts("Task count: #{task_count}")
        Task.where(type: relevant_tasks).find_each do |task|
          STDOUT.puts("Processing #{task.title} id: #{task.id}")
          reviewer_report_ids = []
          task.nested_questions.each do |question|
            STDOUT.puts("Processing Question #{question.id}")
            if question.nested_question_answers.present?
              question.nested_question_answers.find_each do |answer|
                STDOUT.puts("Processing QuestionAnswer #{answer.id}")
                reviewer_report = ReviewerReport.where(
                  task: task,
                  user: task.reviewer,
                  decision: answer.decision
                ).first_or_create!
                unless reviewer_report_ids.include? reviewer_report.id
                  reviewer_report_ids << reviewer_report.id
                end
                STDOUT.puts("Setting Answer Owner for answer: #{answer.id} for reviewer_report: #{reviewer_report.id}")
                question.owner_type = ReviewerReport.name
                answer.owner = reviewer_report
                answer.save(validate: false)
              end
            else
              if question.parent
                question.owner_type = question.parent.owner_type
              else
                STDERR.puts("Found an orphan question without answers")
                fail "Found an orphan question!"
              end
            end
            question.save
          end
          STDOUT.puts("Task count: #{task_count}")
          STDOUT.puts("Reviewer Report Count: #{reviewer_report_ids.length}")
        end
        if Task.where(type: relevant_tasks).map(&:nested_questions).flatten.empty?
          STDOUT.puts("Nested Question migration for Reviewer Report completed")
        else
          STDOUT.puts("Migration Failed, not all nested questions were moved")
        end
      end

      task reviewer_report_to_reviewer_report_task: :environment do
        ReviewerReport.find_each do |report|
          task = report.task

          report.nested_questions.each do |question|
            question.nested_question_answers.find_each do |answer|
              answer.owner = task
              answer.save(validate: false)
            end
            question.update!(owner_type: task.class.name)
          end
          report.destroy!
        end
      end
    end
  end
end
