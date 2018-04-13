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

namespace :data do
  desc 'Update or Create JournalTaskType and Tasks records for all journals'
  task update_journal_task_types: :environment do
    Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    Rails.logger.info 'Updating JournalTaskType records for all journals...'
    Journal.all.each do |journal|
      JournalServices::CreateDefaultTaskTypes.call(journal)
    end

    Rails.logger.info 'Updating existing task titles...'
    JournalServices::UpdateDefaultTasks.call
  end

  desc "Destroy and recreate manuscript manager templates"
  task :reset_mmts => :environment do
    ManuscriptManagerTemplate.destroy_all
    Rake::Task["journal:create_default_templates"].invoke
  end

  task :copy_task_template_title => :environment do
    TaskTemplate.where(title: nil).find_each do |template|
      template.update_attribute(:title, template.journal_task_type.try(:title))
    end
  end

  task :initialize_initial_tech_check_round => :environment do
    PlosBioTechCheck::InitialTechCheckTask.update_all body: { round: 1 }
    puts 'All PlosBioTechCheck::InitialTechCheckTask body attributes have been initialized to {round: 1}'
  end
end
