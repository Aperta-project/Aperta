module TahiStandardTasks
  # Note the ReviewerReportTask and its subclasses are used for
  # "ALL REVIEWS COMPLETE" in the paper tracker. If a task is expected to show
  # up in the "ALL REVIEWS COMPLETE" query, it should inherit from
  # ReviewerReportTask.
  class ReviewerReportTask < Task
    DEFAULT_TITLE = 'Reviewer Report'.freeze
    DEFAULT_ROLE_HINT = 'reviewer'.freeze
    SYSTEM_GENERATED = true

    # Overrides Task#restore_defaults to not restore +title+. This
    # will never update +title+ as that is dynamically determined. If you
    # need to change the reviewer report title write a data migration.
    def self.restore_defaults
    end

    def reviewer
      assignments.joins(:role)
        .where(roles: {name: Role::REVIEWER_REPORT_OWNER_ROLE}).first.user
    end

    def reviewer_number
      ReviewerNumber.number_for(reviewer, paper)
    end

    # find_or_build_answer_for(...) will return the associated answer for this
    # task given :nested_question. For ReviewerReportTask this enforces the
    # lookup to be scoped to this task's current decision. Answers associated
    # with previous decisions will not be returned.
    #
    # == Optional Parameters
    #  * decision - ignored if provided, always enforces the task's decision.id
    #
    def find_or_build_answer_for(nested_question:, **_kwargs)
      super(
        nested_question: nested_question,
        decision: paper.draft_decision
      )
    end

    def body
      # body is a json column by default which returns an Array. We don't want
      # an array, we want to store properties. So if we get a blank
      # object from the DB then return a Hash instead of the default json Array.
      # Additionally, cache the body so we can set individual properties via
      # calls like "body['foo'] = 'bar'" and have them persist when this
      # task is saved.
      @body ||= begin
        result = super
        result.blank? ? {} : result
      end
    end

    def body=(new_body)
      @body = nil
      super(new_body)
    end

    def can_change?(_)
      !submitted?
    end

    # overriden to remove the 'submitted' flag from body
    def incomplete!
      update!(
        completed: false,
        body: body.except("submitted")
      )
    end

    def submitted?
      !!body["submitted"]
    end

    # before save we want to update the reviewer number if neccessary
    def on_completion
      super
      return unless persisted? # don't assign reviewer numbers to newly created tasks
      assign_reviewer_number if completed?
    end

    def assign_reviewer_number
      return if reviewer_number.present? || !paper.number_reviewer_reports
      add_number_to_title(new_reviewer_number)
    end

    def new_reviewer_number
      ReviewerNumber.assign_new(reviewer, paper)
    end

    # this is meant to run in a `before_save` hook so don't
    # call `save` in the method body
    def add_number_to_title(new_number)
      new_title = title + " (##{new_number})"
      self.title = new_title
    end

    private

    def update_body(hsh)
      self.body = body.merge(hsh)
    end
  end
end
