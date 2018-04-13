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
  class CreateDefaultManuscriptManagerTemplates < BaseService
    def self.call(journal)
      with_noisy_errors do
        mmt = journal.manuscript_manager_templates.create!(paper_type: 'Research')

        create_phase_template(name: "Submission Data", journal: journal, mmt: mmt,
                              phase_content: [
                                TahiStandardTasks::TitleAndAbstractTask,
                                TahiStandardTasks::FigureTask,
                                TahiStandardTasks::SupportingInformationTask,
                                TahiStandardTasks::AuthorsTask
                              ])

        create_phase_template(name: "Invite Editor", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::PaperEditorTask)

        create_phase_template(name: "Invite Reviewers", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::PaperReviewerTask)

        create_phase_template(name: "Get Reviews", journal: journal, mmt: mmt)

        create_phase_template(name: "Make Decision", journal: journal, mmt: mmt,
                              phase_content: TahiStandardTasks::RegisterDecisionTask)
      end
    end

    def self.create_phase_template(name:, journal:, mmt:, phase_content: [])
      mmt.phase_templates.create!(name: name).tap do |phase_template|
        Array(phase_content).each do |content|
          if content <= Task
            # create a new JournalTaskTemplate for a legacy Task
            journal_task_type = journal.journal_task_types.find_by!(kind: content)
            phase_template.task_templates.create!(title: journal_task_type.title, journal_task_type: journal_task_type)
          else
            # create a new Card via seed data and associate to JournalTaskTemplate
            card = CustomCard::Loader.load!(content, journal: journal).first
            phase_template.task_templates.create!(title: card.name, card: card)
          end
        end
      end
    end
  end
end
