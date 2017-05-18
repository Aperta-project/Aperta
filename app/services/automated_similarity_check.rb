# Service class that automates similarity checks
class AutomatedSimilarityCheck
  attr_reader :paper, :previous_paper_state

  def self.run(paper, previous_paper_state)
    new(paper, previous_paper_state).run
  end

  def initialize(paper, previous_paper_state)
    @paper = paper
    @previous_paper_state = previous_paper_state
  end

  # I could use a hash of procs for this, but folks will probably
  # think it's way more weird than a case statement
  # rubocop:disable Style/CyclomaticComplexity
  def should_run?
    return false unless setting
    case setting.value
    when 'off'
      false
    when 'at_first_full_submission'
      submitted_after_first_full_submission?
    when 'after_any_first_revise_decision'
      submitted_after_any_first_revise_decision?
    when 'after_first_minor_revise_decision'
      submitted_after_first_minor_revise_decision?
    when 'after_first_major_revise_decision'
      submitted_after_first_major_revise_decision?
    end
  end
  # rubocop:enable Style/CyclomaticComplexity

  def setting
    @setting ||=
      begin
        # does the paper have a similarity check task?
        check_task = paper.tasks.find_by(
          type: "TahiStandardTasks::SimilarityCheckTask"
        )

        return nil unless check_task
        check_task.task_template.setting('ithenticate')
      end
  end

  def run
    if should_run?
      similarity_check = SimilarityCheck.create!(
        versioned_text: paper.versioned_text
      )
      Rails.logger.info <<-HERE
        Performing automated similarity check
        #{similarity_check.id} for paper #{paper.id}. Checks are set to run #{setting.value}
      HERE
      similarity_check.start_report_async
      similarity_check
    end
  end

  def submitted_after_first_full_submission?
    ['unsubmitted', 'invited_for_full_submission'].include? previous_paper_state
  end

  def previous_verdict
    paper.last_completed_decision.verdict
  end

  def first_revision?
    paper.decisions.completed.revisions.count == 1 &&
      previous_paper_state == 'in_revision'
  end

  def submitted_after_first_major_revise_decision?
    first_revision? &&
      previous_verdict == 'major_revision'
  end

  def submitted_after_first_minor_revise_decision?
    first_revision? &&
      previous_verdict == 'minor_revision'
  end

  def submitted_after_any_first_revise_decision?
    first_revision? &&
      ['minor_revision', 'major_revision'].include?(previous_verdict)
  end
end
