# Service class that automates similarity checks
class AutomatedSimilarityCheck
  attr_reader :task, :paper, :previous_paper_state

  def initialize(task, paper)
    @task = task
    @paper = paper
    @previous_paper_state = paper.aasm.from_state.to_s
  end

  # I could use a hash of procs for this, but folks will probably
  # think it's way more weird than a case statement
  def should_run?
    case setting_value
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

  def setting_value
    # this gets called by `should_run?` and in the Rails.logger call, so
    # memoizing it won't hurt
    @setting_value ||=
      begin
        return 'off' unless task.task_template
        # task_template.setting() will either find or create the ithenticate
        # automation setting in the db.
        task.task_template.setting('ithenticate_automation').value
      end
  end

  def run
    Rails.logger.info "AutomatedSimilarityCheck: Possibly checking paper #{paper.id}"
    Rails.logger.info "AutomatedSimilarityCheck: set to #{setting_value.inspect}"
    Rails.logger.info "AutomatedSimilarityCheck: Paper previous state was #{previous_paper_state.inspect}"
    Rails.logger.info "AutomatedSimilarityCheck: is this the first revision? #{first_revision?}"
    Rails.logger.info "AutomatedSimilarityCheck: should_run? #{should_run?}"
    if should_run?
      similarity_check = SimilarityCheck.create!(
        versioned_text: paper.latest_submitted_version
      )
      Rails.logger.info <<-HERE
        Performing automated similarity check
        #{similarity_check.id} for paper #{paper.id}. Checks are set to run #{setting_value}
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
