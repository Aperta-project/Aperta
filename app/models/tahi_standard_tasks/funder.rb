module TahiStandardTasks
  class Funder < ActiveRecord::Base
    # This has been moved from the tahi_standard_tasks engine into the main
    # app as part of APERTA-9867 but due to complications migrations accompanying the
    # release it easier to avoid renaming the table at the time.
    #
    # After the 'MigrateFinancialDisclosureToCustomCard' migration is in
    # production this line can be removed
    self.table_name = 'tahi_standard_tasks_funders'
    include Answerable
    include ViewableModel

    belongs_to :task, foreign_key: :task_id

    # NestedQuestionAnswersController will save the paper_id to newly created
    # answers if an answer's owner responds to :paper. This method is needed by
    # the NestedQuestionAnswersController#fetch_answer method, among others
    def paper
      task.paper
    end
  end
end
