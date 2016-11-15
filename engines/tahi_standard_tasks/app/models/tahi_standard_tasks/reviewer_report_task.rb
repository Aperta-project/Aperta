module TahiStandardTasks
  # Note the ReviewerReportTask and its subclasses are used for
  # "ALL REVIEWS COMPLETE" in the paper tracker. If a task is expected to show
  # up in the "ALL REVIEWS COMPLETE" query, it should inherit from
  # ReviewerReportTask.
  class ReviewerReportTask < Task
    DEFAULT_TITLE = 'Reviewer Report'.freeze
    DEFAULT_ROLE_HINT = 'reviewer'.freeze
    SYSTEM_GENERATED = true

    # NOTE As of 8 Nov 2016, I do not think this is necessary. However, it
    # seems to be necessary in order to update the decisions when the task is
    # loaded - at least the Reviewer Report Task feature spec fails without it.
    # So I am leaving it here for now, but please consider removing it.
    has_many :decisions, -> { uniq }, through: :paper

    # Overrides Task#restore_defaults to not restore +title+. This
    # will never update +title+ as that is dynamically determined. If you
    # need to change the reviewer report title write a data migration.
    def self.restore_defaults
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
        decision: decision
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

    def incomplete!
      update!(
        completed: false,
        body: body.except("submitted")
      )
    end

    # NOTE As of 8 Nov 2016, I do not think this is necessary. Ideally, on the
    # client side the reviewer report task should just find the draftDecision.
    # However, it seems to be necessary in order to update the decisions when
    # the task is loaded - at least the Reviewer Report Task feature spec fails
    # without it. So I am leaving it here for now, but please consider removing
    # it.
    def decision
      paper.draft_decision
    end

    def submitted?
      !!body["submitted"]
    end

    private

    def update_body(hsh)
      self.body = body.merge(hsh)
    end
  end
end
