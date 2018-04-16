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

# This enables automatic calls to iThenticate on a paper's first submission.
# This is a stand-in until APERTA-9495 is completed, so that APERTA-9951
# can be QA'd.
#
# Run the task with:
#
#     rake settings:enable_ithenticate_automation[1,at_first_full_submission]
#
# ...where "1" is the id of the manuscript manager template that already
# contains a Similarity Check task, and "at_first_full_submission" is one of
# the following five values:
#
#    off
#    at_first_full_submission
#    after_any_first_revise_decision
#    after_minor_revise_decision
#    after_major_revise_decision
#
# To find the manuscript manager template id, go to edit a manuscript manager
# template in the admin screen, and check the url. For instance:
# https://plos-ciagent-pr-3094.herokuapp.com/admin/journals/1/manuscript_manager_templates/4/edit
# This is the manuscript manager template id ----------------------------------------------^
namespace :settings do
  desc "Enable Similarity Check automation by given manuscript manager template"
  task :enable_ithenticate_automation, [:id, :value] => :environment do |_, args|
    task_template = TaskTemplate.where(title: "Similarity Check")
      .joins(phase_template: :manuscript_manager_template)
      .where(manuscript_manager_templates: { id: args[:id] })
      .first

    task_template.setting('ithenticate_automation').update!(value: args[:value])
    puts "Updated manuscript manager template #{args[:id]} to use automation value #{args[:value]}"
  end
end
