# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
