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

module JournalServices
  # CreateDefaultTaskTypes is called by the 'data:update_journal_task_types'
  # migration which is run on every deploy. It ensures that every Task in the
  # system has an associated JournalTaskType in the database
  class CreateDefaultTaskTypes < BaseService
    def self.call(journal)
      Rails.logger.info "Processing journal: #{journal.name}..."
      with_noisy_errors do
        Task.descendants.each do |klass|
          next unless klass.create_journal_task_type?
          jtt = journal.journal_task_types.find_or_initialize_by(kind: klass)
          jtt.title = klass::DEFAULT_TITLE
          jtt.role_hint = klass::DEFAULT_ROLE_HINT
          jtt.system_generated = klass::SYSTEM_GENERATED
          jtt.save!
        end
      end
    end
  end
end
