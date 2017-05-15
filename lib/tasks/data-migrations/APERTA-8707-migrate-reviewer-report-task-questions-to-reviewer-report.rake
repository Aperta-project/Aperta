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
            decision = answer.decision
            if decision.nil?
              decision = Decision.find(answer.owner.body['decision_id'])
              STDOUT.puts("DECISION MISSING: Setting decision for answer: #{answer.id} for decision #{decision.id}")
            end
            task = answer.owner
            reviewer_report = ReviewerReport.where(
              task: task,
              user: task.reviewer,
              decision: decision
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

      task answerless_reviewer_report_task_to_reviewer_report: :environment do
        relevant_tasks = ['TahiStandardTasks::ReviewerReportTask', 'TahiStandardTasks::FrontMatterReviewerReportTask']
        task_id_set = Set.new Task.where(type: relevant_tasks).pluck(:id).uniq

        # Every accepted reviewer invitation should have a corresponding Reviewer Report. If it does not, this next block will create one.
        task_id_set.each do |task_id|
          task = Task.find(task_id)
          task.paper.decisions.each do |decision|
            if decision.invitations.where(invitee: task.reviewer, invitee_role: 'Reviewer', state: 'accepted').first
              reviewer_report = ReviewerReport.where(
                task: task,
                user: task.reviewer,
                decision: decision
              )

              if reviewer_report.empty?
                STDOUT.puts("Creating reviewer report for #{task.id}")
                reviewer_report.first_or_create!
              end
            end
          end
        end

        # All Reviewer Report Tasks should have at least one corresponding Reviewer Report. This checks to see if there are any tasks that are missing
        # a Reviewer Report. If any such tasks exists, it's likely because it had a Reviewer Invitation that was accepted and then rescinded
        rr_task_id_set = Set.new ReviewerReport.all.map(&:task).map(&:id).uniq
        missing_id_set = task_id_set - rr_task_id_set
        missing_id_set.each do |id|
          task = Task.find(id)
          STDOUT.puts("Processing Task: #{task.id} Paper: #{task.paper.id} #{task.paper.publishing_state}")

          task.paper.decisions.each do |decision|
            reviewer_invitation = decision.invitations.where(invitee: task.reviewer, invitee_role: 'Reviewer').first
            if reviewer_invitation
              STDOUT.puts("Creating reviewer report for Task: #{task.id} Reviewer: #{task.reviewer.full_name} Invitation state: #{reviewer_invitation.state}")
              reviewer_report = ReviewerReport.where(
                task: task,
                user: task.reviewer,
                decision: reviewer_invitation.decision
              ).create!
            end
          end
        end

        invitations_without_reviewer_reports = Invitation.where(invitee_role: 'Reviewer', state: 'accepted').select do |invitation|
          invitation.decision.reviewer_reports.where(user: invitation.invitee).first.nil?
        end

        # Some invitations are missing a corresponding Reviewer Task probably because a user deleted it
        # The following block checks to see if there are any invitations that do indeed have a
        # Reviewer Report Task but not corresponding Reviewer Report
        # If we do find any, something has gone wrong.
        invitations_without_reviewer_reports.select do |invitation|
          task = Task.where(type: relevant_tasks, paper: invitation.paper).select do |task|
            next if task.reviewer.nil?
            task.reviewer.id == invitation.invitee_id
          end.present?
        end. each do |invitation|
          STDERR.puts("Invitation #{invitation.id} has a corresponding Reviewer Report Task but not Reviewer Report")
        end
      end

      task reviewer_report_to_reviewer_report_task: :environment do
        # Not all Reviewer Report NestedQuestions are associated with a Reviewer Report
        NestedQuestion.where(owner_type: ReviewerReport.name).find_each do |question|
          question.nested_question_answers.find_each do |answer|
            answer.owner = answer.owner.task
            answer.save(validate: false)
          end
          if question.ident.start_with?("front")
            question.update!(owner_type: 'TahiStandardTasks::FrontMatterReviewerReportTask')
          else
            question.update!(owner_type: 'TahiStandardTasks::ReviewerReportTask')
          end
        end

        ReviewerReport.find_each do |report|
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
