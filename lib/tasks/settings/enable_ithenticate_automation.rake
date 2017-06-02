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
#    after_first_minor_revise_decision
#    after_first_major_revise_decision
#

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
