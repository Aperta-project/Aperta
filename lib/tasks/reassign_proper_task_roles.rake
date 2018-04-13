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

namespace :tahi do
  desc "Restores default role for editor and reviewer tasks"
  task restore_original_task_roles: :environment do
    i = 0
    editor_tasks = ["TahiStandardTasks::PaperReviewerTask", "TahiStandardTasks::RegisterDecisionTask"]

    JournalTaskType.where('kind = ? OR kind = ?', *editor_tasks).each do |jtt|
      jtt.update! role: 'editor'
      i += 1
    end

    JournalTaskType.where(kind: "TahiStandardTasks::ReviewerReportTask").each do |jtt|
      jtt.update! role: 'reviewer'
      i += 1
    end

    Task.where('type = ? OR type = ?', *editor_tasks).each do |task|
      task.update_column 'role', 'editor'
      i += 1
    end

    Task.where(type: "TahiStandardTasks::ReviewerReportTask").each do |task|
      task.update_column 'role', 'reviewer'
      i += 1
    end

    puts "#{i} Tasks updated"
  end
end
