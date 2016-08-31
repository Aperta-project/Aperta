namespace :data do
  namespace :migrate do
    desc <<-EOT.strip_heredoc
      Ensure an answer exists for the selected-template question for each
      RegisterDecisionTask whose paper has a decision with a verdict.

      This is to backfill answers for existing decisions based on the letter
      template work.
    EOT
    task set_register_decision_letter_answers: :environment do
      question = NestedQuestion.find_by!(ident: 'register_decision_questions--selected-template')

      TahiStandardTasks::RegisterDecisionTask.all.includes(:paper).find_each do |task|
        most_recent_decision_with_a_verdict = task.paper.decisions.
          unscoped.
          where.not(verdict: nil).
          order('id asc').last

        # skip if there are no decisions with verdicts which indicates
        # no decision has been registered or is in the process of being
        # regsitered.
        next unless most_recent_decision_with_a_verdict

        answer = task.find_or_build_answer_for(nested_question: question)
        if answer.new_record?
          verdict = most_recent_decision_with_a_verdict.verdict
          puts "Setting the register decision letter to #{verdict.inspect} for #{task.inspect} based on decisid id=#{most_recent_decision_with_a_verdict.id}"
          answer.update!(value: verdict)
        else
          # skip, do not overwrite existing answers
        end
      end
    end
  end
end
